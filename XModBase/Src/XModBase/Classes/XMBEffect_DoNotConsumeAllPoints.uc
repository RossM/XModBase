//---------------------------------------------------------------------------------------
//  FILE:    XMBEffect_DoNotConsumeAllPoints.uc
//  AUTHOR:  xylthixlm
//
//  A persistent effect which causes a specific ability or abilities to not end the
//  turn when used as a first action.
//
//  EXAMPLES
//
//  The following examples in Examples.uc use this class:
//
//  BulletSwarm
//
//  INSTALLATION
//
//  Install the XModBase core as described in readme.txt. Copy this file, and any files 
//  listed as dependencies, into your mod's Classes/ folder. You may edit this file.
//
//  DEPENDENCIES
//
//  Core
//---------------------------------------------------------------------------------------
class XMBEffect_DoNotConsumeAllPoints extends X2Effect_Persistent implements(XMBEffectInterface);

//////////////////////
// Bonus properties //
//////////////////////

var array<name> AbilityNames;		// The abilities which will not end the turn as first action


////////////////////
// Implementation //
////////////////////

// From XMBEffectInterface
function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue) { return false; }
function bool GetExtModifiers(name Type, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, optional ShotBreakdown ShotBreakdown, optional out array<ShotModifierInfo> ShotModifiers) { return false; }

// From XMBEffectInterface
function bool GetExtValue(LWTuple Tuple)
{
	local name Ability;
	local LWTValue Value;

	if (Tuple.id != 'DoNotConsumeAllPoints')
		return false;

	foreach AbilityNames(Ability)
	{
		Value.n = Ability;
		Value.kind = LWTVName;
		Tuple.Data.AddItem(Value);
	}

	return true;
}
