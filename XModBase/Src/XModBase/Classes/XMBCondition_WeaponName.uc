class XMBCondition_WeaponName extends X2Condition;

var array<name> IncludeWeaponNames;
var array<name> ExcludeWeaponNames;
var bool bCheckAmmo;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState_Item SourceWeapon;
	local X2ItemTemplate AmmoTemplate;
	local name WeaponName, AmmoName;

	SourceWeapon = kAbility.GetSourceWeapon();
	WeaponName = SourceWeapon.GetMyTemplateName();
	if (bCheckAmmo)
	{
		AmmoTemplate = SourceWeapon.GetLoadedAmmoTemplate(kAbility);
		if (AmmoTemplate != none)
			AmmoName = AmmoTemplate.DataName;
	}

	if (IncludeWeaponNames.Length > 0)
	{
		if (IncludeWeaponNames.Find(WeaponName) == INDEX_NONE && (AmmoName == '' || IncludeWeaponNames.Find(AmmoName) == INDEX_NONE))
			return 'AA_WeaponIncompatible';
	}
	if (ExcludeWeaponNames.Length > 0)
	{
		if (ExcludeWeaponNames.Find(WeaponName) != INDEX_NONE || (AmmoName != '' && ExcludeWeaponNames.Find(AmmoName) != INDEX_NONE))
			return 'AA_WeaponIncompatible';
	}

	return 'AA_Success';
}

defaultproperties
{
	bCheckAmmo = true
}