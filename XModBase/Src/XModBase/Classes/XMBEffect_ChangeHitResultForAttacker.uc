//---------------------------------------------------------------------------------------
//  FILE:    XMBEffect_ChangeHitResultForAttacker.uc
//  AUTHOR:  xylthixlm
//
//  Changes the result of an attack after all other hit calculations.
//
//  EXAMPLES
//
//  The following examples in Examples.uc use this class:
//
//  Focus
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
class XMBEffect_ChangeHitResultForAttacker extends X2Effect_Persistent;

var array<X2Condition> AbilityTargetConditions;
var array<X2Condition> AbilityShooterConditions;

var array<EAbilityHitResult> IncludeHitResults;
var array<EAbilityHitResult> ExcludeHitResults;
var bool bRequireHit, bRequireMiss;

var EAbilityHitResult NewResult;

function bool ChangeHitResultForAttacker(XComGameState_Unit Attacker, XComGameState_Unit TargetUnit, XComGameState_Ability AbilityState, const EAbilityHitResult CurrentResult, out EAbilityHitResult NewHitResult)
{
	local XComGameState_Effect EffectState;

	EffectState = Attacker.GetUnitAffectedByEffectState(EffectName);

	if (ValidateAttack(EffectState, Attacker, TargetUnit, AbilityState) != 'AA_Success')
		return false;

	`Log(self @ "[" $ EffectName $ "]:" @ CurrentResult);

	if (IncludeHitResults.Length > 0 && IncludeHitResults.Find(CurrentResult) == INDEX_NONE)
		return false;
	if (ExcludeHitResults.Length > 0 && ExcludeHitResults.Find(CurrentResult) != INDEX_NONE)
		return false;

	if (bRequireHit && !class'XComGameStateContext_Ability'.static.IsHitResultHit(CurrentResult))
		return false;
	if (bRequireMiss && !class'XComGameStateContext_Ability'.static.IsHitResultMiss(CurrentResult))
		return false;

	NewHitResult = NewResult;
	return true;
}

function private name ValidateAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState)
{
	local name AvailableCode;

	AvailableCode = class'XMBEffectUtilities'.static.CheckTargetConditions(AbilityTargetConditions, EffectState, Attacker, Target, AbilityState);
	if (AvailableCode != 'AA_Success')
		return AvailableCode;
		
	AvailableCode = class'XMBEffectUtilities'.static.CheckShooterConditions(AbilityShooterConditions, EffectState, Attacker, Target, AbilityState);
	if (AvailableCode != 'AA_Success')
		return AvailableCode;
		
	return 'AA_Success';
}

DefaultProperties
{
	NewResult = eHit_Success
}