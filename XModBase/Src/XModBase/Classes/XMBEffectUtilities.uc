class XMBEffectUtilities extends object;

static function bool IsPostBeginPlayTrigger(const out EffectAppliedData ApplyEffectParameters)
{
	local XComGameState_Ability AbilityState;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityTrigger AbilityTrigger;

	History = `XCOMHISTORY;

	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	AbilityTemplate = AbilityState.GetMyTemplate();

	foreach AbilityTemplate.AbilityTriggers(AbilityTrigger)
	{
		if (AbilityTrigger.IsA('X2AbilityTrigger_UnitPostBeginPlay'))
			return true;
	}
	
	return false;
}

function static name CheckTargetConditions(out array<X2Condition> AbilityTargetConditions, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState)
{
	local X2Condition kCondition;
	local XComGameState_Item SourceWeapon;
	local StateObjectReference ItemRef;
	local name AvailableCode;
		
	foreach AbilityTargetConditions(kCondition)
	{
		if (kCondition.IsA('XMBCondition_MatchingWeapon'))
		{
			SourceWeapon = AbilityState.GetSourceWeapon();
			if (SourceWeapon == none || EffectState == none)
				return 'AA_UnknownError';

			ItemRef = EffectState.ApplyEffectParameters.ItemStateObjectRef;
			if (SourceWeapon.ObjectID != ItemRef.ObjectID && SourceWeapon.LoadedAmmo.ObjectID != ItemRef.ObjectID)
				return 'AA_UnknownError';
		}

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

	return 'AA_Success';
}

function static name CheckShooterConditions(out array<X2Condition> AbilityShooterConditions, XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState)
{
	local X2Condition kCondition;
	local name AvailableCode;
		
	foreach AbilityShooterConditions(kCondition)
	{
		AvailableCode = kCondition.MeetsCondition(Attacker);
		if (AvailableCode != 'AA_Success')
			return AvailableCode;
	}

	return 'AA_Success';
}
