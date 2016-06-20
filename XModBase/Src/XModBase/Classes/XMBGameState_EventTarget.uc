class XMBGameState_EventTarget extends XComGameState_BaseObject;

var array<StateObjectReference> TriggeredAbilities;

function EventListenerReturn OnEvent(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Ability AbilityState, SourceAbilityState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit SourceUnit, TargetUnit;
	local StateObjectReference AbilityRef;
	local XComGameStateHistory History;
	local X2AbilityTrigger Trigger;
	local XMBAbilityTrigger_EventListener EventListener;
	local name AvailableCode;

	History = `XCOMHISTORY;

	SourceUnit = XComGameState_Unit(EventSource);
	if (SourceUnit == none)
		return ELR_NoInterrupt;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none)
		return ELR_NoInterrupt;

	AbilityState = XComGameState_Ability(EventData);
	if (AbilityState == none)
	{
		AbilityState = XComGameState_Ability(GameState.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
		if (AbilityState == none)
			AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
	}
	if (AbilityState == none)
		return ELR_NoInterrupt;

	TargetUnit = XComGameState_Unit(EventData);
	if (TargetUnit == none)
	{
		TargetUnit = XComGameState_Unit(GameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	}

	foreach TriggeredAbilities(AbilityRef)
	{
		SourceAbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));

		foreach SourceAbilityState.GetMyTemplate().AbilityTriggers(Trigger)
		{
			EventListener = XMBAbilityTrigger_EventListener(Trigger);
			if (EventListener != none && EventListener.ListenerData.EventID == EventID)
			{
				if (TargetUnit != none || EventListener.bSelfTarget)
				{
					AvailableCode = EventListener.ValidateAttack(SourceAbilityState, SourceUnit, TargetUnit, AbilityState);

					`Log("OnEvent:" @ EventID @ SourceAbilityState.GetMyTemplateName @ AvailableCode);

					if (AvailableCode == 'AA_Success')
					{
						if (EventListener.bSelfTarget)
							SourceAbilityState.AbilityTriggerAgainstSingleTarget(SourceUnit.GetReference(), false);
						else
							SourceAbilityState.AbilityTriggerAgainstSingleTarget(TargetUnit.GetReference(), false);
					}
				}

				break;
			}			
		}
	}

	return ELR_NoInterrupt;
}

function OnEndTacticalPlay()
{
	TriggeredAbilities.Length = 0;
}