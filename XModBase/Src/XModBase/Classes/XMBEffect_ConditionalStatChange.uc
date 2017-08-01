class XMBEffect_ConditionalStatChange extends X2Effect_PersistentStatChange;

var array<X2Condition> Conditions;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local XComGameState_Unit UnitState;
	local X2EventManager EventMgr;
	local XMBGameState_EventProxy Proxy;
	local XComGameState NewGameState;
	local Object ListenerObj;

	EventMgr = `XEVENTMGR;

	NewGameState = EffectGameState.GetParentGameState();
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	Proxy = class'XMBGameState_EventProxy'.static.CreateProxy(EffectGameState, NewGameState);

	ListenerObj = Proxy;

	// Register to tick after EVERY action.
	Proxy.OnEvent = EventHandler;
	EventMgr.RegisterForEvent(ListenerObj, 'OnUnitBeginPlay', class'XMBGameState_EventProxy'.static.EventHandler, ELD_OnStateSubmitted, 25, UnitState);	
	EventMgr.RegisterForEvent(ListenerObj, 'AbilityActivated', class'XMBGameState_EventProxy'.static.EventHandler, ELD_OnStateSubmitted, 25);	
}

static function EventListenerReturn EventHandler(XComGameState_BaseObject SourceState, Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local XComGameState_Unit UnitState, SourceUnitState, NewUnitState;
	local XComGameState_Effect NewEffectState;
	local XComGameState_Ability AbilityState;
	local XComGameState NewGameState;
	local XMBEffect_ConditionalStatChange EffectTemplate;
	local XComGameState_Effect EffectState;
	local bool bOldApplicable, bNewApplicable;

	EffectState = XComGameState_Effect(SourceState);
	if (EffectState == none)
		return ELR_NoInterrupt;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	SourceUnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));

	EffectTemplate = XMBEffect_ConditionalStatChange(EffectState.GetX2Effect());

	bOldApplicable = EffectState.StatChanges.Length > 0;
	bNewApplicable = class'XMBEffectUtilities'.static.CheckTargetConditions(EffectTemplate.Conditions, EffectState, SourceUnitState, UnitState, AbilityState) == 'AA_Success';

	if (bOldApplicable != bNewApplicable)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Conditional Stat Change");

		NewUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', UnitState.ObjectID));
		NewEffectState = XComGameState_Effect(NewGameState.CreateStateObject(class'XComGameState_Effect', EffectState.ObjectID));

		NewGameState.AddStateObject(NewUnitState);
		NewGameState.AddStateObject(NewEffectState);

		if (bNewApplicable)
		{
			NewEffectState.StatChanges = EffectTemplate.m_aStatChanges;

			// Note: ApplyEffectToStats crashes the game if the state objects aren't added to the game state yet
			NewUnitState.ApplyEffectToStats(NewEffectState, NewGameState);
		}
		else
		{
			NewUnitState.UnApplyEffectFromStats(NewEffectState, NewGameState);
			NewEffectState.StatChanges.Length = 0;
		}

		`GAMERULES.SubmitGameState(NewGameState);
	}

	return ELR_NoInterrupt;
}


// From X2Effect_Persistent.
function bool IsEffectCurrentlyRelevant(XComGameState_Effect EffectGameState, XComGameState_Unit TargetUnit)
{
	return EffectGameState.StatChanges.Length > 0;
}


simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	super(X2Effect_Persistent).OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}