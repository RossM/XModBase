class XMBAbilityTrigger_EventListener extends X2AbilityTrigger_EventListener;

////////////////////////
// Trigger properties //
////////////////////////

var bool bSelfTarget;

//////////////////////////
// Condition properties //
//////////////////////////

var bool bRequireAbilityWeapon;						// Require that the weapon or ammo used in the ability match the item associated with this effect.

var array<X2Condition> AbilityTargetConditions;		// Conditions on the target of the ability being checked.
var array<X2Condition> AbilityShooterConditions;	// Conditions on the shooter of the ability being checked.

simulated function RegisterListener(XComGameState_Ability AbilityState, Object FilterObject)
{
	local object TargetObj;
	local XMBGameState_EventTarget Target;
	local XComGameState_Unit UnitState;
	local XComGameState NewGameState;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityState.OwnerStateObject.ObjectID));

	// Because our listener function will trigger every XMBAbilityTrigger_EventListener on the
	// unit with a given event, we need to make sure that the event manager only calls it once
	// per unit for an event even if there are several abilities with the same trigger. We
	// could put it on the unit directly, but units have a lot of listeners we might clobber.
	// Instead, create a dummy state object and attach the event listener to it. We make the
	// dummy object a component of the unit to ensure that we can find it easily when 
	// registering more events.
	Target = XMBGameState_EventTarget(UnitState.FindComponentObject(class'XMBGameState_EventTarget', false));
	if (Target == none)
	{
		NewGameState = AbilityState.GetParentGameState();
		Target = XMBGameState_EventTarget(NewGameState.CreateStateObject(class'XMBGameState_EventTarget'));
		UnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.class, UnitState.ObjectID));

		UnitState.AddComponentObject(Target);

		NewGameState.AddStateObject(UnitState);
		NewGameState.AddStateObject(Target);
	}

	TargetObj = Target;

	`XEVENTMGR.RegisterForEvent(TargetObj, ListenerData.EventID, Listener, ListenerData.Deferral, ListenerData.Priority, FilterObject);
}

function static EventListenerReturn Listener(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Ability AbilityState, SourceAbilityState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Unit SourceUnit, TargetUnit;
	local StateObjectReference AbilityRef;
	local XComGameStateHistory History;
	local X2AbilityTrigger Trigger;
	local XMBAbilityTrigger_EventListener EventListener;

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
	if (TargetUnit == none)
		return ELR_NoInterrupt;

	foreach SourceUnit.Abilities(AbilityRef)
	{
		SourceAbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityRef.ObjectID));

		foreach SourceAbilityState.GetMyTemplate().AbilityTriggers(Trigger)
		{
			EventListener = XMBAbilityTrigger_EventListener(Trigger);
			if (EventListener != none && EventListener.ListenerData.EventID == EventID)
			{
				if (EventListener.ValidateAttack(SourceAbilityState, SourceUnit, TargetUnit, AbilityState) == 'AA_Success')
				{
					if (EventListener.bSelfTarget)
						SourceAbilityState.AbilityTriggerAgainstSingleTarget(SourceUnit.GetReference(), false);
					else
						SourceAbilityState.AbilityTriggerAgainstSingleTarget(TargetUnit.GetReference(), false);
				}
				break;
			}			
		}
	}

	return ELR_NoInterrupt;
}

function private name ValidateAttack(XComGameState_Ability SourceAbilityState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState)
{
	local X2Condition kCondition;
	local XComGameState_Item SourceWeapon;
	local StateObjectReference ItemRef;
	local name AvailableCode;
		
	if (bRequireAbilityWeapon)
	{
		SourceWeapon = AbilityState.GetSourceWeapon();
		if (SourceWeapon == none)
			return 'AA_UnknownError';

		ItemRef = SourceAbilityState.SourceWeapon;
		if (SourceWeapon.ObjectID != ItemRef.ObjectID && SourceWeapon.LoadedAmmo.ObjectID != ItemRef.ObjectID)
			return 'AA_UnknownError';
	}

	foreach AbilityTargetConditions(kCondition)
	{
		AvailableCode = kCondition.AbilityMeetsCondition(AbilityState, Target);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;

		AvailableCode = kCondition.MeetsCondition(Target);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
		
		AvailableCode = kCondition.MeetsConditionWithSource(Target, Attacker);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
	}

	foreach AbilityShooterConditions(kCondition)
	{
		AvailableCode = kCondition.MeetsCondition(Attacker);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
	}

	return 'AA_Success';
}
