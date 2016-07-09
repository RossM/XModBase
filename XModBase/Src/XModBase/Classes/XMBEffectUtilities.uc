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