class Examples extends XMBAbility;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Weaponmaster());
	Templates.AddItem(AbsolutelyCritical());
	Templates.AddItem(Pyromaniac());
	Templates.AddItem(HitAndRun());
	Templates.AddItem(HitAndRunTrigger());

	return Templates;
}

// Perk name:		Weaponmaster
// Perk effect:		Your primary weapon attacks deal +2 damage.
// Localized text:	"Your <Ability:WeaponName/> attacks deal +<Ability:Damage/> damage."
// Config:			(AbilityName="XMBExample_Weaponmaster", ApplyToWeaponSlot=eInvSlot_PrimaryWeapon)
static function X2AbilityTemplate Weaponmaster()
{
	local XMBEffect_ConditionalBonus              Effect;

	// Create a conditional bonus
	Effect = new class'XMBEffect_ConditionalBonus';

	// The bonus adds 2 damage to attacks
	Effect.AddDamageModifier(2);

	// The bonus only applies to attacks with the weapon associated with this ability
	Effect.bRequireAbilityWeapon = true;

	// Create the template using a helper function
	return Passive('XMBExample_Weaponmaster', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect);
}

// Perk name:		Absolutely Critical
// Perk effect:		You get an additional +50 Crit chance against flanked targets.
// Localized text:	"You get an additional +<Ability:Crit> Crit chance against flanked targets."
// Config:			(AbilityName="XMBExample_AbsolutelyCritical")
static function X2AbilityTemplate AbsolutelyCritical()
{
	local XMBEffect_ConditionalBonus             Effect;

	// Create a conditional bonus
	Effect = new class'XMBEffect_ConditionalBonus';

	// The bonus adds +50 Crit chance
	Effect.AddToHitModifier(50, eHit_Crit);

	// The bonus only applies while flanking
	Effect.OtherConditions.AddItem(default.FlankedCondition);

	// Create the template using a helper function
	return Passive('XMBExample_AbsolutelyCritical', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect);
}

// Perk name:		Pyromaniac
// Perk effect:		Your fire attacks deal +1 damage, and your burn effects deal +1 damage per turn. You get a free incendiary grenade on each mission.
// Localized text:	"Your fire attacks deal +1 damage, and your burn effects deal +1 damage per turn. You get a free incendiary grenade on each mission."
// Config:			(AbilityName="XMBExample_Pyromaniac")
static function X2AbilityTemplate Pyromaniac()
{
	local XMBEffect_BonusDamageByDamageType Effect;
	local X2AbilityTemplate Template;
	local XMBEffect_AddUtilityItem ItemEffect;

	// Create an effect that adds +1 damage to fire attacks and +1 damage to burn damage
	Effect = new class'XMBEffect_BonusDamageByDamageType';
	Effect.EffectName = 'Pyromaniac';
	Effect.RequiredDamageTypes.AddItem('fire');
	Effect.DamageBonus = 1;

	// Create the template using a helper function
	Template = Passive('XMBExample_Pyromaniac', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect);

	// Add another effect that grants a free incendiary grenade during each mission
	ItemEffect = new class 'XMBEffect_AddUtilityItem';
	ItemEffect.DataName = 'Firebomb';
	Template.AddTargetEffect(ItemEffect);

	return Template;
}

// Perk name:		Hit and Run
// Perk effect:		Move after taking a single action that would normally end your turn.
// Localized text:	"Move after taking a single action that would normally end your turn."
// Config:			(AbilityName="XMBExample_HitAndRun")
static function X2AbilityTemplate HitAndRun()
{
	local X2AbilityTemplate Template;
	local XMBEffect_AbilityTriggered Effect;
	local XMBCondition_AbilityCost CostCondition;
	local XMBCondition_AbilityName NameCondition;

	// Create an effect that listens for ability activations and triggers an event
	Effect = new class'XMBEffect_AbilityTriggered';
	Effect.EffectName = 'HitAndRun';
	Effect.TriggeredEvent = 'HitAndRun';

	// Require that the activated ability costs 1 action point, but actually spent at least 2
	CostCondition = new class'XMBCondition_AbilityCost';
	CostCondition.bRequireMaximumCost = true;
	CostCondition.MaximumCost = 1;
	CostCondition.bRequireMinimumPointsSpent = true;
	CostCondition.MinimumPointsSpent = 2;
	Effect.AbilityTargetConditions.AddItem(CostCondition);

	// Exclude overwatch abilities
	NameCondition = new class'XMBCondition_AbilityName';
	NameCondition.ExcludeAbilityNames.AddItem('HunkerDown');
	NameCondition.ExcludeAbilityNames.AddItem('Overwatch');
	NameCondition.ExcludeAbilityNames.AddItem('PistolOverwatch');
	NameCondition.ExcludeAbilityNames.AddItem('SniperRifleOverwatch');
	NameCondition.ExcludeAbilityNames.AddItem('Suppression');
	Effect.AbilityTargetConditions.AddItem(NameCondition);

	// Create the template using a helper function
	Template = Passive('XMBExample_HitAndRun', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect);

	// We need an additional ability to actually listen for the trigger
	Template.AdditionalAbilities.AddItem('XMBExample_HitAndRunTrigger');

	return Template;
}

// This is part of the Hit and Run effect, above
static function X2AbilityTemplate HitAndRunTrigger()
{
	local X2Effect_GrantActionPoints Effect;

	// Add a single movement-only action point to the unit
	Effect = new class'X2Effect_GrantActionPoints';
	Effect.NumActionPoints = 1;
	Effect.PointType = class'X2CharacterTemplateManager'.default.MoveActionPoint;

	// Create the template using a helper function. It will be triggered by the Hit and Run passive defined in HitAndRun();
	return SelfTargetTrigger('XMBExample_HitAndRunTrigger', "img:///UILibrary_PerkIcons.UIPerk_command", Effect, 'HitAndRun', true);
}
