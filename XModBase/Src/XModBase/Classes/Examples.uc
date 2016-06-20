class Examples extends XMBAbility;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Weaponmaster());
	Templates.AddItem(AbsolutelyCritical());
	Templates.AddItem(Pyromaniac());
	Templates.AddItem(HitAndRun());
	Templates.AddItem(HitAndRunTrigger());
	Templates.AddItem(Assassin());
	Templates.AddItem(AssassinTrigger());
	Templates.AddItem(SlamFire());
	Templates.AddItem(DamnGoodGround());
	Templates.AddItem(MovingTarget());
	Templates.AddItem(PowerShot());
	Templates.AddItem(PowerShotBonuses());
	Templates.AddItem(CloseCombatSpecialist());
	Templates.AddItem(CloseCombatSpecialistShot());
	Templates.AddItem(CloseAndPersonal());
	Templates.AddItem(InspireAgility());
	Templates.AddItem(InspireAgilityTrigger());

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
	local X2AbilityTemplate Template;

	// Add a single movement-only action point to the unit
	Effect = new class'X2Effect_GrantActionPoints';
	Effect.NumActionPoints = 1;
	Effect.PointType = class'X2CharacterTemplateManager'.default.MoveActionPoint;

	// Create the template using a helper function. It will be triggered by the Hit and Run passive defined in HitAndRun();
	Template = SelfTargetTrigger('XMBExample_HitAndRunTrigger', "img:///UILibrary_PerkIcons.UIPerk_command", false, Effect, 'HitAndRun');

	Template.bShowActivation = true;

	return Template;
}

// Perk name:		Assassin
// Perk effect:		When you kill a flanked or uncovered enemy with your primary weapon, you gain concealment.
// Localized text:	"When you kill a flanked or uncovered enemy with your <Ability:WeaponName/>, you gain concealment."
// Config:			(AbilityName="XMBExample_Assassin", ApplyToWeaponSlot=eInvSlot_PrimaryWeapon)
static function X2AbilityTemplate Assassin()
{
	local X2AbilityTemplate						Template;
	local XMBEffect_AbilityTriggered			Effect;

	// Create an effect that listens for ability activations and triggers an event
	Effect = new class'XMBEffect_AbilityTriggered';
	Effect.EffectName = 'Assassin';
	Effect.TriggeredEvent = 'Assassin';

	// Require that the activated ability use the weapon associated with this ability
	Effect.bRequireAbilityWeapon = true;

	// Require that the target of the ability is now dead
	Effect.AbilityTargetConditions.AddItem(default.DeadCondition);

	// Require that the target of the ability was flanked or uncovered
	Effect.AbilityTargetConditions.AddItem(default.NoCoverCondition);

	// Create the template using a helper function
	Template = Passive('XMBExample_Assassin', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect);

	// We need an additional ability to actually listen for the trigger
	Template.AdditionalAbilities.AddItem('XMBExample_AssassinTrigger');

	return Template;
}

// This is part of the Assassin effect, above
static function X2AbilityTemplate AssassinTrigger()
{
	local X2AbilityTemplate Template;
	local X2Effect_RangerStealth StealthEffect;

	// Create a standard stealth effect
	StealthEffect = new class'X2Effect_RangerStealth';
	StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	StealthEffect.bRemoveWhenTargetConcealmentBroken = true;

	// Create the template using a helper function
	Template = SelfTargetTrigger('XMBExample_AssassinTrigger', "img:///UILibrary_PerkIcons.UIPerk_command", false, StealthEffect, 'Assassin');

	// Require that the unit be able to enter stealth
	Template.AbilityShooterConditions.AddItem(new class'X2Condition_Stealth');

	// Add an additional effect that causes the AI to forget where the unit was
	Template.AddTargetEffect(class'X2Effect_Spotted'.static.CreateUnspottedEffect());

	// Have the unit say it's entering concealment
	Template.ActivationSpeech = 'ActivateConcealment';

	return Template;
}

// Perk name:		Slam Fire
// Perk effect:		For the rest of the turn, whenever you get a critical hit with your primary weapon, your actions are refunded.
// Localized text:	"For the rest of the turn, whenever you get a critical hit with your <Ability:WeaponName/>, your actions are refunded."
// Config:			(AbilityName="XMBExample_SlamFire", ApplyToWeaponSlot=eInvSlot_PrimaryWeapon)
static function X2AbilityTemplate SlamFire()
{
	local X2AbilityTemplate					Template;
	local XMBEffect_AbilityCostRefund       SlamFireEffect;

	// Create an effect that refunds the action point cost of abilities
	SlamFireEffect = new class'XMBEffect_AbilityCostRefund';
	SlamFireEffect.EffectName = 'SlamFire';
	SlamFireEffect.TriggeredEvent = 'SlamFire';

	// Require that the activated ability use the weapon associated with this ability
	SlamFireEffect.bRequireAbilityWeapon = true;

	// Require that the activated ability get a critical hit
	SlamFireEffect.AbilityTargetConditions.AddItem(default.CritCondition);

	// The effect lasts until the end of the turn
	SlamFireEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);

	// Create the template for an activated ability using a helper function.
	Template = SelfTargetActivated('XMBExample_SlamFire', "img:///UILibrary_PerkIcons.UIPerk_command", true, SlamFireEffect, class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY, eCost_Free);
	AddCooldown(Template, 4);

	// Don't allow multiple ability-refunding abilities to be used in the same turn (e.g. Slam Fire and Serial)
	class'X2Ability_RangerAbilitySet'.static.SuperKillRestrictions(Template, 'Serial_SuperKillCheck');

	// Don't allow the ability to be used while the unit is disoriented, burning, unconscious, etc.
	Template.AddShooterEffectExclusions();

	return Template;
}

// Perk name:		Damn Good Ground
// Perk effect:		You get an additional +10 Aim and +10 Defense against targets at lower elevation.
// Localized text:	"You get an additional +<Ability:ToHit/> Aim and +<Ability:Defense/> Defense against targets at lower elevation."
// Config:			(AbilityName="XMBExample_DamnGoodGround")
static function X2AbilityTemplate DamnGoodGround()
{
	local XMBEffect_ConditionalBonus Effect;

	// Create a conditional bonus
	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'DamnGoodGround';

	// The bonus adds +10 Aim and +10 Defense
	Effect.AddToHitModifier(10);
	Effect.AddToHitAsTargetModifier(-10);

	// When being attacked, require that the unit have height advantage
	Effect.SelfConditions.AddItem(default.HeightAdvantageCondition);

	// When attacking, require that the target have height disadvantage
	Effect.OtherConditions.AddItem(default.HeightDisadvantageCondition);

	// Create the template using a helper function
	return Passive('XMBExample_DamnGoodGround', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect);
}

// Perk name:		Moving Target
// Perk effect:		You get an additional +30 Defense and +50 Dodge against reaction fire.
// Localized text:	"You get an additional +<Ability:Defense/> Defense and +<Ability:Dodge/> Dodge against reaction fire."
// Config:			(AbilityName="XMBExample_MovingTarget")
static function X2AbilityTemplate MovingTarget()
{
	local XMBEffect_ConditionalBonus Effect;

	// Create a conditional bonus
	Effect = new class'XMBEffect_ConditionalBonus';

	// The bonus adds +30 Defense and +50 Dodge
	Effect.AddToHitAsTargetModifier(-30);
	Effect.AddToHitAsTargetModifier(50, eHit_Graze);

	// Require that the incoming attack is reaction fire
	Effect.SelfConditions.AddItem(default.ReactionFireCondition);

	// Create the template using a helper function
	return Passive('XMBExample_MovingTarget', "img:///UILibrary_PerkIcons.UIPerk_command", false, Effect);
}

// Perk name:		Danger Zone
// Perk effect:		The radius of all your grenades is increased by 2.
// Localized text:	"The radius of all your grenades is increased by 2."
// Config:			(AbilityName="XMBExample_DangerZone")
static function X2AbilityTemplate DangerZone()
{
	local XMBEffect_BonusRadius Effect;

	// Create a bonus radius effect
	Effect = new class'XMBEffect_BonusRadius';
	Effect.EffectName = 'DangerZone';

	// Add 2m (1.33 tiles) to the radius of all grenades
	Effect.fBonusRadius = 2;

	return Passive('XMBExample_DangerZone', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect);
}

// Perk name:		Power Shot
// Perk effect:		Make an attack that has +20 crit chance and deals +3/4/5 damage on crit.
// Localized text:	"Make an attack that has +<Ability:Crit:PowerShotBonuses/> crit chance and deals +<Ability:CritDamage:PowerShotBonuses/> damage on crit."
// Config:			(AbilityName="XMBExample_PowerShot", ApplyToWeaponSlot=eInvSlot_PrimaryWeapon)
static function X2AbilityTemplate PowerShot()
{
	local X2AbilityTemplate Template;

	// Create the template using a helper function
	Template = Attack('XMBExample_PowerShot', "img:///UILibrary_PerkIcons.UIPerk_command", true, none, class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY, eCost_WeaponConsumeAll, 1);
	AddCooldown(Template, 3);

	// Add a secondary ability to provide bonuses on the shot
	Template.AdditionalAbilities.AddItem('XMBExample_PowerShotBonuses');

	return Template;
}

// This is part of the Power Shot effect, above
static function X2AbilityTemplate PowerShotBonuses()
{
	local X2AbilityTemplate Template;
	local XMBEffect_ConditionalBonus Effect;
	local XMBCondition_AbilityName Condition;

	// Create a conditional bonus effect
	Effect = new class'XMBEffect_ConditionalBonus';
	Effect.EffectName = 'PowerShotBonuses';

	// The bonus adds +20 Crit chance
	Effect.AddToHitModifier(20, eHit_Crit);

	// The bonus adds +3/4/5 damage on crit dependent on tech level
	Effect.AddDamageModifier(3, eHit_Crit, 'conventional');
	Effect.AddDamageModifier(4, eHit_Crit, 'magnetic');
	Effect.AddDamageModifier(5, eHit_Crit, 'beam');

	// The bonus only applies to the Power Shot ability
	Condition = new class'XMBCondition_AbilityName';
	Condition.IncludeAbilityNames.AddItem('XMBExample_PowerShot');
	Effect.OtherConditions.AddItem(Condition);

	// Create the template using a helper function
	Template = Passive('XMBExample_PowerShotBonuses', "img:///UILibrary_PerkIcons.UIPerk_command", false, Effect);

	// The Power Shot ability will show up as an active ability, so hide the icon for passive damage effect
	HidePerkIcon(Template);

	return Template;
}

// Perk name:		Close Combat Specialist
// Perk effect:		Confers a reaction shot against any enemy who closes to within 4 tiles. Does not require Overwatch.
// Localized text:	"Confers a reaction shot against any enemy who closes to within 4 tiles. Does not require Overwatch."
// Config:			(AbilityName="XMBExample_CloseCombatSpecialist", ApplyToWeaponSlot=eInvSlot_PrimaryWeapon)
static function X2AbilityTemplate CloseCombatSpecialist()
{
	local X2AbilityTemplate Template;

	// Create a pure passive which displays the passive perk icon
	Template = PurePassive('XMBExample_CloseCombatSpecialist', "img:///UILibrary_PerkIcons.UIPerk_command", true);

	// Add the actual shot ability
	Template.AdditionalAbilities.AddItem('XMBExample_CloseCombatSpecialistShot');

	return Template;
}

// This is part of the Close Combat Specialist, above
static function X2AbilityTemplate CloseCombatSpecialistShot()
{
	local X2AbilityTemplate Template;
	local X2AbilityToHitCalc_StandardAim ToHit;
	local X2Effect_Persistent PersistentEffect;
	local X2Condition_UnitEffectsWithAbilitySource EffectsCondition;

	// Create the template using a helper function
	Template = Attack('XMBExample_CloseCombatSpecialistShot', "img:///UILibrary_PerkIcons.UIPerk_command", false, none, class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY, eCost_None);
	
	// Reaction fire shouldn't show up as an activatable ability
	HidePerkIcon(Template);

	// Set the shot to be considered reaction fire
	ToHit = new class'X2AbilityToHitCalc_StandardAim';
	ToHit.bReactionFire = true;
	Template.AbilityToHitCalc = ToHit;

	// Remove the default trigger of being activated by the player
	Template.AbilityTriggers.Length = 0;

	// Add a trigger that activates the ability on movement
	AddMovementTrigger(Template);

	// Restrict the shot to units within 4 tiles
	Template.AbilityTargetConditions.AddItem(TargetWithinTiles(4));

	// Since the attack has no cost, if we don't do anything else, it will be able to attack many
	// times per turn (until we run out of ammo). We use an X2Effect_Persistent that does nothing
	// to mark our target unit, and a condition to prevent taking a second attack on a marked
	// target in the same turn.

	// Create a persistent effect
	PersistentEffect = new class'X2Effect_Persistent';
	// The effect name here doesn't matter, but it does have to match the name that
	// EffectsCondition uses below.
	PersistentEffect.EffectName = 'CCSTarget';
	// The effect lasts until the end of the turn
	PersistentEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
	// Apply the effect whether the attack hits or misses
	PersistentEffect.bApplyOnHit = true;
	PersistentEffect.bApplyOnMiss = true;
	Template.AddTargetEffect(PersistentEffect);

	// Create a condition that checks for the presence of a certain effect. There are three
	// similar classes that do this: X2Condition_UnitEffects,
	// X2Condition_UnitEffectsWithAbilitySource, and X2Condition_UnitEffectsWithAbilityTarget.
	// The first one looks for any effect with the right name, the second only for effects
	// with that were applied by the unit using this ability, and the third only for effects
	// that apply to the unit using this ability. Since we want to match the persistent effect
	// we applied as a mark - but not the same effect applied by any other unit - we use
	// X2Condition_UnitEffectsWithAbilitySource.
	EffectsCondition = new class'X2Condition_UnitEffectsWithAbilitySource';
	// AA_ codes indicate why an ability can't be used. They're listed in XComGameData.ini
	// under [XComGame.X2AbilityTemplateManager]. AA_UnitIsImmune is a good choice when no more
	// specific code applies.
	EffectsCondition.AddExcludeEffect('CCSTarget', 'AA_UnitIsImmune');
	Template.AbilityTargetConditions.AddItem(EffectsCondition);

	return Template;
}

// Perk name:		Close and Personal
// Perk effect:		The first standard shot made within 4 tiles of the target does not cost an action.
// Localized text:	"The first standard shot made within 4 tiles of the target does not cost an action."
// Config:			(AbilityName="XMBExample_CloseAndPersonal")
static function X2AbilityTemplate CloseAndPersonal()
{
	local XMBEffect_AbilityCostRefund Effect;
	local XMBCondition_AbilityName AbilityNameCondition;
	
	// Create an effect that will refund the cost of attacks
	Effect = new class'XMBEffect_AbilityCostRefund';
	Effect.EffectName = 'CloseAndPersonal';
	Effect.TriggeredEvent = 'CloseAndPersonal';

	// Only refund once per turn
	Effect.CountValueName = 'CloseAndPersonalShots';
	Effect.MaxRefundsPerTurn = 1;

	// The bonus only applies to standard shots
	AbilityNameCondition = new class'XMBCondition_AbilityName';
	AbilityNameCondition.IncludeAbilityNames.AddItem('StandardShot');
	AbilityNameCondition.IncludeAbilityNames.AddItem('SniperStandardFire');
	AbilityNameCondition.IncludeAbilityNames.AddItem('PistolStandardShot');
	Effect.AbilityTargetConditions.AddItem(AbilityNameCondition);

	// Restrict the shot to units within 4 tiles
	Effect.AbilityTargetConditions.AddItem(TargetWithinTiles(4));

	// Create the template using a helper function
	return Passive('XMBExample_CloseAndPersonal', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect);
}

static function X2AbilityTemplate InspireAgility()
{
	local X2Effect_PersistentStatChange Effect;
	local X2AbilityTemplate Template;

	// Create a persistent stat change effect that grants +50 Dodge
	Effect = new class'X2Effect_PersistentStatChange';
	Effect.EffectName = 'InspireAgility';
	Effect.AddPersistentStatChange(eStat_Dodge, 50);

	// The effect lasts until the beginning of the player's next turn
	Effect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);

	Effect.VisualizationFn = EffectFlyOver_Visualization;

	// Create the template using a helper function
	Template = TargetedBuff('XMBExample_InspireAgility', "img:///UILibrary_PerkIcons.UIPerk_command", true, Effect, class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY, eCost_Free);

	AddCharges(Template, 1);

	PreventStackingEffects(Template);

	Template.AdditionalAbilities.AddItem('XMBExample_InspireAgilityTrigger');

	return Template;
}

static function X2AbilityTemplate InspireAgilityTrigger()
{
	local XMBEffect_AddAbilityCharges Effect;

	Effect = new class'XMBEffect_AddAbilityCharges';
	Effect.AbilityNames.AddItem('XMBExample_InspireAgility');
	Effect.BonusCharges = 1;

	return SelfTargetTrigger('XMBExample_InspireAgilityTrigger', "img:///UILibrary_PerkIcons.UIPerk_command", false, Effect, 'KillMail');
}