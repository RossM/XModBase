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

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());

	AbilityState = XComGameState_Ability(EventData);
	if (AbilityState == none && AbilityContext != none)
	{
		AbilityState = XComGameState_Ability(GameState.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
		if (AbilityState == none)
			AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID));
	}

	TargetUnit = XComGameState_Unit(EventData);
	if (TargetUnit == none && AbilityContext != none)
	{
		TargetUnit = XComGameState_Unit(GameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	}

	foreach TriggeredAbilities(AbilityRef)
	{
		SourceAbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));
		SourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(SourceAbilityState.OwnerStateObject.ObjectID));

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