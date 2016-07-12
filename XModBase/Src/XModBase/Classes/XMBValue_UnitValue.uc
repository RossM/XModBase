class XMBValue_UnitValue extends XMBValue;

var name UnitValueName;

function float GetValue(XComGameState_Effect EffectState, XComGameState_Unit UnitState, XComGameState_Ability AbilityState)
{
	local UnitValue Value;

	if (UnitState.GetUnitValue(UnitValueName, Value))
		return Value.fValue;
	else
		return 0;
}