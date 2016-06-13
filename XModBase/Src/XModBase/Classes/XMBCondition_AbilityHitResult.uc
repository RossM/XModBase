//---------------------------------------------------------------------------------------
//  FILE:    XMBCondition_AbilityHitResult.uc
//  AUTHOR:  xylthixlm
//
//  USAGE
//
//  XMBAbility provides default instances of this class for common cases:
//
//  default.HitCondition		The ability hits (including crits and grazes)
//  default.MissCondition		The ability misses
//  default.CritCondition		The ability crits
//  default.GrazeCondition		The ability grazes
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
class XMBCondition_AbilityHitResult extends X2Condition;

var array<EAbilityHitResult> IncludeHitResults;
var array<EAbilityHitResult> ExcludeHitResults;
var bool bRequireHit;
var bool bRequireMiss;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState GameState;
	local XComGameStateContext_Ability AbilityContext;
	local EAbilityHitResult HitResult;

	GameState = kAbility.GetParentGameState();

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
	if (AbilityContext == none)
		return 'AA_ValueCheckFailed';

	HitResult = AbilityContext.ResultContext.HitResult;

	if (IncludeHitResults.Length > 0 && IncludeHitResults.Find(HitResult) == INDEX_NONE)
		return 'AA_ValueCheckFailed';
	if (ExcludeHitResults.Length > 0 && ExcludeHitResults.Find(HitResult) != INDEX_NONE)
		return 'AA_ValueCheckFailed';

	if (bRequireHit && !class'XComGameStateContext_Ability'.static.IsHitResultHit(HitResult))
		return 'AA_ValueCheckFailed';
	if (bRequireMiss && !class'XComGameStateContext_Ability'.static.IsHitResultMiss(HitResult))
		return 'AA_ValueCheckFailed';

	return 'AA_Success';
}