//---------------------------------------------------------------------------------------
//  FILE:    XMBEffect_AbilityCostRefund.uc
//  AUTHOR:  xylthixlm
//
//  A persistent effect which causes the action point cost of any ability meeting
//  certain conditions to be automatically refunded. This can be used to create effects
//  that work like Serial.
//
//  EXAMPLES
//
//  The following examples in Examples.uc use this class:
//
//  SlamFire
//
//  INSTALLATION
//
//  Install the XModBase core as described in readme.txt. Copy this file, and any files 
//  listed as dependencies, into your mod's Classes/ folder. You may edit this file.
//
//  DEPENDENCIES
//
//  None.
//---------------------------------------------------------------------------------------
class XMBEffect_AbilityCostRefund extends X2Effect_Persistent config(GameData_SoldierSkills);


///////////////////////
// Effect properties //
///////////////////////

var name TriggeredEvent;							// An event that will be triggered when this effect refunds an ability cost.
var bool bShowFlyOver;								// Show a flyover when this effect refunds an ability cost. Requires TriggeredEvent to be set.


//////////////////////////
// Condition properties //
//////////////////////////

var bool bRequireAbilityWeapon;						// Require that the weapon or ammo used in the ability match the item associated with this effect.

var array<X2Condition> AbilityTargetConditions;		// Conditions on the target of the ability being refunded.
var array<X2Condition> AbilityShooterConditions;	// Conditions on the shooter of the ability being refunded.


////////////////////
// Implementation //
////////////////////

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;
	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.SourceStateObjectRef.ObjectID));

	if (bShowFlyOver && TriggeredEvent != '')
		EventMgr.RegisterForEvent(EffectObj, TriggeredEvent, EffectGameState.TriggerAbilityFlyover, ELD_OnStateSubmitted, , UnitState);
}

function bool PostAbilityCostPaid(XComGameState_Effect EffectState, XComGameStateContext_Ability AbilityContext, XComGameState_Ability kAbility, XComGameState_Unit SourceUnit, XComGameState_Item AffectWeapon, XComGameState NewGameState, const array<name> PreCostActionPoints, const array<name> PreCostReservePoints)
{
	local X2EventManager EventMgr;
	local XComGameState_Ability AbilityState;
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));
	if (TargetUnit == none)
		TargetUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID));

	if (ValidateAttack(EffectState, SourceUnit, TargetUnit, kAbility) != 'AA_Success')
		return false;

	//  restore the pre cost action points to fully refund this action
	if (SourceUnit.ActionPoints.Length != PreCostActionPoints.Length)
	{
		AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(EffectState.ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
		if (AbilityState != none)
		{
			SourceUnit.ActionPoints = PreCostActionPoints;

			if (TriggeredEvent != '')
			{
				EventMgr = `XEVENTMGR;
				EventMgr.TriggerEvent(TriggeredEvent, AbilityState, SourceUnit, NewGameState);
			}

			return true;
		}
	}

	return false;
}

function private name ValidateAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState)
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

		ItemRef = EffectState.ApplyEffectParameters.ItemStateObjectRef;
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

DefaultProperties
{
	DuplicateResponse = eDupe_Ignore
	bShowFlyOver = true
}