class XMBValue_Visibility extends XMBValue;

var bool bCountEnemies, bCountAllies, bCountNeutrals;
var array<X2Condition> RequiredConditions;

simulated function int CountVisibleUnitsForUnit(XComGameState_Unit SourceState, int HistoryIndex = -1)
{
	local int Index;
	local XComGameStateHistory History;
	local X2GameRulesetVisibilityManager VisibilityMgr;	
	local array<StateObjectReference> VisibleUnits;
	local StateObjectReference UnitRef;
	local int Count;

	History = `XCOMHISTORY;
	VisibilityMgr = `TACTICALRULES.VisibilityMgr;

	//Set default conditions (visible units need to be alive and game play visible) if no conditions were specified
	if( RequiredConditions.Length == 0 )
	{
		RequiredConditions = class'X2TacticalVisibilityHelpers'.default.LivingGameplayVisibleFilter;
	}

	VisibilityMgr.GetAllVisibleToSource(SourceState.ObjectID, VisibleUnits, class'XComGameState_Unit', HistoryIndex, RequiredConditions);

	foreach VisibleUnits(UnitRef)
	{
		if (SourceState.TargetIsEnemy(UnitRef.ObjectID, HistoryIndex))
		{
			if (bCountEnemies) Count++;
		}
		else if (SourceState.TargetIsAlly(UnitRef.ObjectID, HistoryIndex))
		{
			if (bCountAllies) Count++;
		}
		else
		{
			if (bCountNeutrals) Count++;
		}
	}

	return Count;
}

function float GetValue(XComGameState_Effect EffectState, XComGameState_Unit UnitState, XComGameState_Ability AbilityState)
{
	return CountVisibleUnitsForUnit(UnitState);
}