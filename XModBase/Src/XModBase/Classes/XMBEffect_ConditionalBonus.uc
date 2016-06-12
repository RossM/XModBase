//---------------------------------------------------------------------------------------
//  FILE:    XMBEffect_ConditionalBonus.uc
//  AUTHOR:  xylthixlm
//
//  This class provides an easy way of creating passive effects that give bonuses based
//  on some condition. Build up the modifiers you want to add using AddToHitModifier
//  and related functions, and set the conditions for them by adding an X2Condition to
//  SelfConditions or OtherConditions. This class takes care of validating the
//  conditions and applying the modifiers. You can also define different modifiers
//  based on the tech tier of the weapon or other item used. Ability tags are
//  automatically defined for each modifier.
//
//  EXAMPLES
//
//  +4 damage against flanked targets:
//    ConditionalBonusEffect = new class'XMBEffect_ConditionalBonus';
//    ConditionalBonusEffect.OtherConditions.AddItem(default.FlankedCondition);
//    ConditionalBonusEffect.AddDamageModifier(4);
//
//  +100 dodge against reaction fire:
//    ConditionalBonusEffect = new class'XMBEffect_ConditionalBonus';
//    ConditionalBonusEffect.SelfConditions.AddItem(default.ReactionFireCondition);
//    ConditionalBonusEffect.AddToHitAsTargetModifier(100, eHit_Graze);
//
//  +10/15/20 crit chance with associated weapon, based on weapon tech:
//    ConditionalBonusEffect = new class'XMBEffect_ConditionalBonus';
//    ConditionalBonusEffect.bRequireAbilityWeapon = true;
//    ConditionalBonusEffect.AddToHitModifier(10, eHit_Crit, 'conventional');
//    ConditionalBonusEffect.AddToHitModifier(15, eHit_Crit, 'magnetic');
//    ConditionalBonusEffect.AddToHitModifier(20, eHit_Crit, 'beam');
//
//  INSTALLATION
//
//  Install the XModBase core as described in readme.txt. Copy this file, and any files 
//  listed as dependencies, into your mod's Classes/ folder. You may edit this file.
//
//  DEPENDENCIES
//
//  Core
//  XMBEffect_Extended.uc
//---------------------------------------------------------------------------------------

class XMBEffect_ConditionalBonus extends XMBEffect_Extended;


/////////////////////
// Data structures //
/////////////////////

struct ExtShotModifierInfo
{
	var ShotModifierInfo ModInfo;
	var name WeaponTech;
	var name Type;
};


//////////////////////
// Bonus properties //
//////////////////////

var array<ExtShotModifierInfo> Modifiers;			// Modifiers to attacks made by (or at) the unit with the effect

var bool bIgnoreSquadsightPenalty;					// Negates squadsight penalties. Requires XMBEffect_Extended.


//////////////////////////
// Condition properties //
//////////////////////////

var bool bRequireAbilityWeapon;						// Require that the weapon or ammo used in the ability match the item associated with this effect.

var array<X2Condition> SelfConditions;				// Conditions applied to the unit with the effect (usually the shooter)
var array<X2Condition> OtherConditions;				// Conditions applied to the other unit involved (usually the target)


/////////////
// Setters //
/////////////

// Adds a modifier to the hit chance of attacks made by the unit with the effect.
function AddToHitModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.WeaponTech = WeaponTech;
	ExtModInfo.Type = 'ToHit';
	Modifiers.AddItem(ExtModInfo);
}	

// Adds a modifier to the hit chance of attacks made against (not by) the unit with the effect.
function AddToHitAsTargetModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.WeaponTech = WeaponTech;
	ExtModInfo.Type = 'ToHitAsTarget';
	Modifiers.AddItem(ExtModInfo);
}	

// Adds a modifier to the damage of attacks made by the unit with the effect.
function AddDamageModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.WeaponTech = WeaponTech;
	ExtModInfo.Type = 'Damage';
	Modifiers.AddItem(ExtModInfo);
}	

// Adds a modifier to the armor shredding amount of attacks made by the unit with the effect.
function AddShredModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.WeaponTech = WeaponTech;
	ExtModInfo.Type = 'Shred';
	Modifiers.AddItem(ExtModInfo);
}	

// Adds a modifier to the armor piercing amount of attacks made by the unit with the effect.
function AddArmorPiercingModifier(int Value, optional EAbilityHitResult ModType = eHit_Success, optional name WeaponTech = '')
{
	local ExtShotModifierInfo ExtModInfo;

	ExtModInfo.ModInfo.ModType = ModType;
	ExtModInfo.ModInfo.Reason = FriendlyName;
	ExtModInfo.ModInfo.Value = Value;
	ExtModInfo.WeaponTech = WeaponTech;
	ExtModInfo.Type = 'ArmorPiercing';
	Modifiers.AddItem(ExtModInfo);
}	


////////////////////
// Implementation //
////////////////////

// Checks that an attack meets all the conditions of this effect.
function private name ValidateAttack(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, bool bAsTarget = false)
{
	local X2Condition kCondition;
	local XComGameState_Item SourceWeapon;
	local StateObjectReference ItemRef;
	local name AvailableCode;
		
	// Check that the attack is using the correct weapon if required
	if (!bAsTarget && bRequireAbilityWeapon)
	{
		SourceWeapon = AbilityState.GetSourceWeapon();
		if (SourceWeapon == none)
			return 'AA_UnknownError';

		ItemRef = EffectState.ApplyEffectParameters.ItemStateObjectRef;
		if (SourceWeapon.ObjectID != ItemRef.ObjectID && SourceWeapon.LoadedAmmo.ObjectID != ItemRef.ObjectID)
			return 'AA_UnknownError';
	}

	if (!bAsTarget)
	{
		// Attack by the unit with the effect - check target conditions
		foreach OtherConditions(kCondition)
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

		// Attack by the unit with the effect - check shooter conditions
		foreach SelfConditions(kCondition)
		{
			AvailableCode = kCondition.MeetsCondition(Attacker);
			if (AvailableCode != 'AA_Success')
				return AvailableCode;
		}
	}
	else
	{
		// Attack against the unit with the effect - check target conditions
		foreach SelfConditions(kCondition)
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

		// Attack against the unit with the effect - check shooter conditions
		foreach TargetConditions(kCondition)
		{
			AvailableCode = kCondition.MeetsCondition(Attacker);
			if (AvailableCode != 'AA_Success')
				return AvailableCode;
		}
	}

	return 'AA_Success';
}

// Checks that the weapon used by the attack is the right tech tier for a modifier
static function name ValidateWeapon(ExtShotModifierInfo ExtModInfo, XComGameState_Item SourceWeapon)
{
	local X2WeaponTemplate WeaponTemplate;

	if (ExtModInfo.WeaponTech != '')
	{
		if (SourceWeapon == none)
			return 'AA_WeaponIncompatible';

		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());
		if (WeaponTemplate == none || WeaponTemplate.WeaponTech != ExtModInfo.WeaponTech)
			return 'AA_WeaponIncompatible';
	}

	return 'AA_Success';
}

// From X2Effect_Persistent. Returns a damage modifier for an attack by the unit with the effect.
function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local ExtShotModifierInfo ExtModInfo;
	local int BonusDamage;

	if (ValidateAttack(EffectState, Attacker, XComGameState_Unit(TargetDamageable), AbilityState) != 'AA_Success')
		return 0;

	foreach Modifiers(ExtModInfo)
	{
		if (ExtModInfo.Type != 'Damage')
			continue;

		if (ValidateWeapon(ExtModInfo, AbilityState.GetSourceWeapon()) != 'AA_Success')
			continue;

		if ((ExtModInfo.ModInfo.ModType == eHit_Success && class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult)) ||
			ExtModInfo.ModInfo.ModType == AppliedData.AbilityResultContext.HitResult)
		{
			BonusDamage += ExtModInfo.ModInfo.Value;
		}
	}

	return BonusDamage;
}

// From X2Effect_Persistent. Returns an armor shred modifier for an attack by the unit with the effect.
function int GetExtraShredValue(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData)
{
	local ExtShotModifierInfo ExtModInfo;
	local int BonusShred;

	if (ValidateAttack(EffectState, Attacker, XComGameState_Unit(TargetDamageable), AbilityState) != 'AA_Success')
		return 0;

	foreach Modifiers(ExtModInfo)
	{
		if (ExtModInfo.Type != 'Shred')
			continue;

		if (ValidateWeapon(ExtModInfo, AbilityState.GetSourceWeapon()) != 'AA_Success')
			continue;

		if ((ExtModInfo.ModInfo.ModType == eHit_Success && class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult)) ||
			ExtModInfo.ModInfo.ModType == AppliedData.AbilityResultContext.HitResult)
		{
			BonusShred += ExtModInfo.ModInfo.Value;
		}
	}

	return BonusShred;
}

// From X2Effect_Persistent. Returns an armor piercing modifier for an attack by the unit with the effect.
function int GetExtraArmorPiercing(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData)
{
	local ExtShotModifierInfo ExtModInfo;
	local int BonusArmorPiercing;

	if (ValidateAttack(EffectState, Attacker, XComGameState_Unit(TargetDamageable), AbilityState) != 'AA_Success')
		return 0;

	foreach Modifiers(ExtModInfo)
	{
		if (ExtModInfo.Type != 'ArmorPiercing')
			continue;

		if (ValidateWeapon(ExtModInfo, AbilityState.GetSourceWeapon()) != 'AA_Success')
			continue;

		if ((ExtModInfo.ModInfo.ModType == eHit_Success && class'XComGameStateContext_Ability'.static.IsHitResultHit(AppliedData.AbilityResultContext.HitResult)) ||
			ExtModInfo.ModInfo.ModType == AppliedData.AbilityResultContext.HitResult)
		{
			BonusArmorPiercing += ExtModInfo.ModInfo.Value;
		}
	}

	return BonusArmorPiercing;
}

// From X2Effect_Persistent. Returns to hit modifiers for an attack by the unit with the effect.
function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ExtShotModifierInfo ExtModInfo;

	if (ValidateAttack(EffectState, Attacker, Target, AbilityState) == 'AA_Success')
	{	
		foreach Modifiers(ExtModInfo)
		{
			if (ExtModInfo.Type != 'ToHit')
				continue;

			if (ValidateWeapon(ExtModInfo, AbilityState.GetSourceWeapon()) != 'AA_Success')
				continue;

			ExtModInfo.ModInfo.Reason = FriendlyName;
			ShotModifiers.AddItem(ExtModInfo.ModInfo);
		}
	}
	
	super.GetToHitModifiers(EffectState, Attacker, Target, AbilityState, ToHitType, bMelee, bFlanking, bIndirectFire, ShotModifiers);	
}

// From X2Effect_Persistent. Returns to hit modifiers for an attack against (not by) the unit with the effect.
function GetToHitAsTargetModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ExtShotModifierInfo ExtModInfo;

	if (ValidateAttack(EffectState, Attacker, Target, AbilityState, true) == 'AA_Success')
	{
		foreach Modifiers(ExtModInfo)
		{
			if (ExtModInfo.Type != 'ToHitAsTarget')
				continue;

			if (ValidateWeapon(ExtModInfo, AbilityState.GetSourceWeapon()) != 'AA_Success')
				continue;

			ExtModInfo.ModInfo.Reason = FriendlyName;
			ShotModifiers.AddItem(ExtModInfo.ModInfo);
		}	
	}
	
	super.GetToHitAsTargetModifiers(EffectState, Attacker, Target, AbilityState, ToHitType, bMelee, bFlanking, bIndirectFire, ShotModifiers);	
}

// From XMBEffect_Extended. Returns true if squadsight penalties should be ignored for this attack.
function bool IgnoreSquadsightPenalty(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState) 
{
	if (!bIgnoreSquadsightPenalty)
		return false;

	if (ValidateAttack(EffectState, Attacker, Target, AbilityState) != 'AA_Success')
		return false;

	return true;
}

// From XMBEffectInterface. Checks whether this effect handles a particular ability tag, such as
// "<Ability:ToHit/>", and gets the value of the tag if it's handled. This function knows which
// modifiers are actually applied by this effect, and will only handle those. A complete list of 
// the modifiers which might be handled is in the cases of the switch statement.
//
// For tech-dependent tags, in tactical play the tag displays the actual value based on the unit's
// equipment. In the Armory it displays all the possible values separated by slashes, such as
// "2/3/4".
function bool GetTagValue(name Tag, XComGameState_Ability AbilityState, out string TagValue)
{
	local float Result;
	local array<float> TechResults;
	local XComGameState_Item ItemState;
	local ExtShotModifierInfo ExtModInfo;
	local int ValidModifiers, ValidTechModifiers;
	local EAbilityHitResult HitResult;
	local float ResultMultiplier;
	local int idx;

	ResultMultiplier = 1;
	TechResults.Length = class'X2ItemTemplateManager'.default.WeaponTechCategories.Length;

	// These are all the combinations of modifier type and hit result that make sense.
	switch (Tag)
	{
	case 'ToHit':				Tag = 'ToHit';			HitResult = eHit_Success;							break;
	case 'ToHitAsTarget':		Tag = 'ToHitAsTarget';	HitResult = eHit_Success;							break;
	case 'Defense':				Tag = 'ToHitAsTarget';	HitResult = eHit_Success;	ResultMultiplier = -1;	break;
	case 'Damage':				Tag = 'Damage';			HitResult = eHit_Success;							break;
	case 'Shred':				Tag = 'Shred';			HitResult = eHit_Success;							break;
	case 'ArmorPiercing':		Tag = 'ArmorPiercing';	HitResult = eHit_Success;							break;
	case 'Crit':				Tag = 'ToHit';			HitResult = eHit_Crit;								break;
	case 'CritDefense':			Tag = 'ToHitAsTarget';	HitResult = eHit_Crit;		ResultMultiplier = -1;	break;
	case 'CritDamage':			Tag = 'Damage';			HitResult = eHit_Crit;								break;
	case 'CritShred':			Tag = 'Shred';			HitResult = eHit_Crit;								break;
	case 'CritArmorPiercing':	Tag = 'ArmorPiercing';	HitResult = eHit_Crit;								break;
	case 'Graze':				Tag = 'ToHit';			HitResult = eHit_Graze;								break;
	case 'Dodge':				Tag = 'ToHitAsTarget';	HitResult = eHit_Graze;								break;
	case 'GrazeDamage':			Tag = 'Damage';			HitResult = eHit_Graze;								break;
	case 'GrazeShred':			Tag = 'Shred';			HitResult = eHit_Graze;								break;
	case 'GrezeArmorPiercing':	Tag = 'ArmorPiercing';	HitResult = eHit_Graze;								break;
	case 'MissDamage':			Tag = 'Damage';			HitResult = eHit_Miss;								break;
	case 'MissShred':			Tag = 'Shred';			HitResult = eHit_Miss;								break;
	case 'MissArmorPiercing':	Tag = 'ArmorPiercing';	HitResult = eHit_Miss;								break;

	default:
		return false;
	}

	// If there are no modifiers of the right type, don't handle this ability tag.
	if (Modifiers.Find('Type', Tag) == INDEX_NONE)
		return false;

	if (AbilityState != none)
	{
		ItemState = AbilityState.GetSourceWeapon();
	}

	// Collect all the modifiers which apply.
	foreach Modifiers(ExtModInfo)
	{
		if (ExtModInfo.Type != Tag)
			continue;

		if (ExtModInfo.ModInfo.ModType != HitResult)
			continue;

		idx = class'X2ItemTemplateManager'.default.WeaponTechCategories.Find(ExtModInfo.WeaponTech);
		if (idx != INDEX_NONE)
		{
			// Track the results for each tech category
			TechResults[idx] += ExtModInfo.ModInfo.Value;
			ValidTechModifiers++;
		}

		// Validate the weapon being used against the required tech level of the modifier
		if (ValidateWeapon(ExtModInfo, ItemState) != 'AA_Success')
			continue;

		// This modifier applies. Add it to the result, and track the number of valid modifiers.
		Result += ExtModInfo.ModInfo.Value;
		ValidModifiers++;
	}

	// If there are no valid modifiers, but there would have been if there had been a weapon of
	// the right tech, output the modifier for each tech level.
	if (ValidModifiers == 0 && ValidTechModifiers > 0)
	{
		TagValue = "";
		for (idx = 0; idx < TechResults.Length && idx < 3; idx++)  // HACK
		{
			if (idx > 0) TagValue $= "/";
			TagValue $= string(int(TechResults[idx] * ResultMultiplier));
		}
		return true;
	}

	// Still no valid modifiers? Then this isn't a tag we handle.
	if (ValidModifiers == 0)
		return false;

	// Save the result. The ResultMultipler is to handle Defense, which is internally respresented
	// as a negative modifier to eHit_Success.
	TagValue = string(int(Result * ResultMultiplier));
	return true;
}