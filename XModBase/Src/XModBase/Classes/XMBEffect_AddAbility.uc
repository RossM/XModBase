class XMBEffect_AddAbility extends X2Effect_Persistent;

var name AbilityName;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local X2AbilityTemplateManager AbilityTemplateMgr;
	local X2AbilityTemplate AbilityTemplate;
	local StateObjectReference AbilityRef;
	local XComGameState_Ability NewAbility;

	AbilityTemplateMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	AbilityTemplate = AbilityTemplateMgr.FindAbilityTemplate(AbilityName);

	AbilityRef = `TACTICALRULES.InitAbilityForUnit(AbilityTemplate, XComGameState_Unit(kNewTargetState), NewGameState, ApplyEffectParameters.ItemStateObjectRef);
	NewAbility = XComGameState_Ability(NewGameState.GetGameStateForObjectID(AbilityRef.ObjectID));
	NewAbility.CheckForPostBeginPlayActivation();

	NewEffectState.CreatedObjectReference = AbilityRef;
}

simulated function OnEffectRemoved(const out EffectAppliedData ApplyEffectParameters, XComGameState NewGameState, bool bCleansed, XComGameState_Effect RemovedEffectState)
{
	local XComGameStateHistory History;
	local XComGameState_Unit OwnerUnitState;
	local XComGameState_Effect AbilityEffectState;
	local StateObjectReference EffectRef;
	local int i;

	if (RemovedEffectState.CreatedObjectReference.ObjectID == 0)
		return;

	History = `XCOMHISTORY;

	OwnerUnitState = XComGameState_Unit(NewGameState.CreateStateObject(class'XComGameState_Unit', RemovedEffectState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	NewGameState.AddStateObject(OwnerUnitState);

	foreach OwnerUnitState.AffectedByEffects(EffectRef)
	{
		AbilityEffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
		if (AbilityEffectState != none && AbilityEffectState.ApplyEffectParameters.AbilityStateObjectRef == RemovedEffectState.CreatedObjectReference)
		{
			// Not really sure what the best value for bCleansed is here
			AbilityEffectState.RemoveEffect(NewGameState, NewGameState, bCleansed);
		}
	}
	foreach OwnerUnitState.AppliedEffects(EffectRef)
	{
		AbilityEffectState = XComGameState_Effect(History.GetGameStateForObjectID(EffectRef.ObjectID));
		if (AbilityEffectState != none && AbilityEffectState.ApplyEffectParameters.AbilityStateObjectRef == RemovedEffectState.CreatedObjectReference)
		{
			// Not really sure what the best value for bCleansed is here
			AbilityEffectState.RemoveEffect(NewGameState, NewGameState, bCleansed);
		}
	}

	// Remove the ability so it doesn't show up with HasSoldierAbility
	for (i = OwnerUnitState.Abilities.Length; i >= 0; i--)
	{
		if (OwnerUnitState.Abilities[i].ObjectID == RemovedEffectState.CreatedObjectReference.ObjectID)
		{
			OwnerUnitState.Abilities.Remove(i, 1);
			break;
		}
	}

	NewGameState.RemoveStateObject(RemovedEffectState.CreatedObjectReference.ObjectID);
}