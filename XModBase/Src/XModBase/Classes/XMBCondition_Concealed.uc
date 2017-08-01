class XMBCondition_Concealed extends X2Condition;

event name CallMeetsCondition(XComGameState_BaseObject kTarget) 
{ 
	local XComGameState_Unit TargetUnit;

	TargetUnit = XComGameState_Unit(kTarget);
	if (TargetUnit == none)
		return 'AA_NotAUnit';

	if (!TargetUnit.IsConcealed())
		return 'AA_UnitAlreadySpotted';

	return 'AA_Success';
}