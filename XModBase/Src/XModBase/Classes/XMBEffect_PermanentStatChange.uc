class XMBEffect_PermanentStatChange extends X2Effect;

var array<StatChange> StatChanges;

simulated function AddStatChange(ECharStatType StatType, float StatAmount, optional ECharStatModApplicationRule ApplicationRule = ECSMAR_Additive )
{
	local StatChange NewChange;
	
	NewChange.StatType = StatType;
	NewChange.StatAmount = StatAmount;
	NewChange.ApplicationRule = ApplicationRule;

	StatChanges.AddItem(NewChange);
}

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit NewUnit;
	local StatChange Change;
	
	NewUnit = XComGameState_Unit(kNewTargetState);
	if (NewUnit == none)
		return;

	foreach StatChanges(Change)
	{
		NewUnit.SetBaseMaxStat(Change.StatType, NewUnit.GetBaseStat(Change.StatType) + Change.StatAmount, Change.ApplicationRule);
	}
}