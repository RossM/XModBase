class Examples extends XMBAbility;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(Weaponmaster());
	Templates.AddItem(AbsolutelyCritical());
	Templates.AddItem(Pyromaniac());
	Templates.AddItem(HitAndRun());
	Templates.AddItem(Assassin());
	Templates.AddItem(SlamFire());
	Templates.AddItem(DamnGoodGround());
	Templates.AddItem(MovingTarget());
	Templates.AddItem(PowerShot());
	Templates.AddItem(PowerShotBonuses());
	Templates.AddItem(CloseCombatSpecialist());
	Templates.AddItem(CloseAndPersonal());
	Templates.AddItem(InspireAgility());
	Templates.AddItem(InspireAgilityTrigger());
	Templates.AddItem(ReverseEngineering());
	Templates.AddItem(BullRush());
	Templates.AddItem(BullRushTrigger());

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
	Effect.OtherConditions.AddItem(default.MatchingWeaponCondition);

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
	local X2Effect_GrantActionPoints Effect;
	local X2AbilityTemplate Template;
	local XMBCondition_AbilityCost CostCondition;
	local XMBCondition_AbilityName NameCondition;

	// Add a single movement-only action point to the unit
	Effect = new class'X2Effect_GrantActionPoints';
	Effect.NumActionPoints = 1;
	Effect.PointType = class'X2CharacterTemplateManager'.default.MoveActionPoint;

	// Create the template using a helper function. It will be triggered by the Hit and Run passive defined in HitAndRun();
	Template = SelfTargetTrigger('XMBExample_HitAndRun', "img:///UILibrary_PerkIcons.UIPerk_command", false, Effect, 'AbilityActivated');

	// Trigger abilities don't appear as passives. Add a passive ability icon.
	AddIconPassive(Template);

	// Require that the activated ability costs 1 action point, but actually spent at least 2
	CostCondition = new class'XMBCondition_AbilityCost';
	CostCondition.bRequireMaximumCost = true;
	CostCondition.MaximumCost = 1;
	CostCondition.bRequireMinimumPointsSpent = true;
	CostCondition.MinimumPointsSpent = 2;
	AddTriggerTargetCondition(Template, CostCondition);

	// Exclude overwatch abilities
	NameCondition = new class'XMBCondition_AbilityName';
	NameCondition.ExcludeAbilityNames.AddItem('HunkerDown');
	NameCondition.ExcludeAbilityNames.AddItem('Overwatch');
	NameCondition.ExcludeAbilityNames.AddItem('PistolOverwatch');
	NameCondition.ExcludeAbilityNames.AddItem('SniperRifleOverwatch');
	NameCondition.ExcludeAbilityNames.AddItem('Suppression');
	AddTriggerTargetCondition(Template, NameCondition);

	Template.bShowActivation = true;

	return Template;
}

// Perk name:		Assassin
// Perk effect:		When you kill a flanked or uncovered enemy with your primary weapon, you gain concealment.
// Localized text:	"When you kill a flanked or uncovered enemy with your <Ability:WeaponName/>, you gain concealment."
// Config:			(AbilityName="XMBExample_Assassin", ApplyToWeaponSlot=eInvSlot_PrimaryWeapon)
static function X2AbilityTemplate Assassin()
{
	local X2AbilityTemplate Template;
	local X2Effect_RangerStealth StealthEffect;

	// Create a standard stealth effect
	StealthEffect = new class'X2Effect_RangerStealth';
	StealthEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnEnd);
	StealthEffect.bRemoveWhenTargetConcealmentBroken = true;

	// Create the template using a helper function
	Template = SelfTargetTrigger('XMBExample_Assassin', "img:///UILibrary_PerkIcons.UIPerk_command", false, StealthEffect, 'AbilityActivated');

	// Trigger abilities don't appear as passives. Add a passive ability icon.
	AddIconPassive(Template);

	// Require that the activated ability use the weapon associated with this ability
	AddTriggerTargetCondition(Template, default.MatchingWeaponCondition);

	// Require that the target of the ability is now dead
	AddTriggerTargetCondition(Template, default.DeadCondition);

	// Require that the target of the ability was flanked or uncovered
	AddTriggerTargetCondition(Template, default.NoCoverCondition);

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
	SlamFireEffect.AbilityTargetConditions.AddItem(default.MatchingWeaponCondition);

	// Require that the activated ability get a critical hit
	SlamFireEffect.AbilityTargetConditions.AddItem(default.CritCondition);

	// The effect lasts until the end of the turn
	SlamFireEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);

	// Create the template for an activated ability using a helper function.
	Template = SelfTargetActivated('XMBExample_SlamFire', "img:///UILibrary_PerkIcons.UIPerk_command", true, SlamFireEffect, class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY, eCost_Free);
	AddCooldown(Template, 4);

	// Don't allow multiple ability-refunding abilities to be used in the same turn (e.g. Slam Fire and Serial)
	class'X2Ability_RangerAbilitySet'.static.SuperKillRestrictions(Template, 'Serial_SuperKillCheck');

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
	local X2AbilityToHitCalc_StandardAim ToHit;

	// Create the template using a helper function
	Template = Attack('XMBExample_CloseCombatSpecialist', "img:///UILibrary_PerkIcons.UIPerk_command", false, none, class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY, eCost_None);
	
	// Reaction fire shouldn't show up as an activatable ability, it should be a passive instead
	HidePerkIcon(Template);
	AddIconPassive(Template);

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
	// times per turn (until we run out of ammo). AddPerTargetCooldown uses an X2Effect_Persistent
	// that does nothing to mark our target unit, and a condition to prevent taking a second 
	// attack on a marked target in the same turn.
	AddPerTargetCooldown(Template, 1);

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

// Perk name:		Inspire Agility
// Perk effect:		Give a friendly unit +50 Dodge until the start of your next turn. Whenever you kill an enemy, you gain an extra charge.
// Localized text:	"Give a friendly unit +<Ability:Dodge/> Dodge until the start of your next turn. Whenever you kill an enemy, you gain an extra charge."
// Config:			(AbilityName="XMBExample_InspireAgility")
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

// This is part of the Inspire Agility effect, above
static function X2AbilityTemplate InspireAgilityTrigger()
{
	local XMBEffect_AddAbilityCharges Effect;

	Effect = new class'XMBEffect_AddAbilityCharges';
	Effect.AbilityNames.AddItem('XMBExample_InspireAgility');
	Effect.BonusCharges = 1;

	return SelfTargetTrigger('XMBExample_InspireAgilityTrigger', "img:///UILibrary_PerkIcons.UIPerk_command", false, Effect, 'KillMail');
}

// Perk name:		Reverse Engineering
// Perk effect:		When you kill an enemy robotic unit you gain a permanent Hacking increase of 5.
// Localized text:	"When you kill an enemy robotic unit you gain a permanent Hacking increase of <Ability:Hacking/>."
// Config:			(AbilityName="XMBExample_ReverseEngineering")
static function X2AbilityTemplate ReverseEngineering()
{
	local XMBEffect_PermanentStatChange Effect;
	local X2AbilityTemplate Template;
	local X2Condition_UnitProperty Condition;

	Effect = new class'XMBEffect_PermanentStatChange';
	Effect.AddStatChange(eStat_Hacking, 5);

	Template = SelfTargetTrigger('XMBExample_ReverseEngineering', "img:///UILibrary_PerkIcons.UIPerk_command", false, Effect, 'KillMail');

	// Trigger abilities don't appear as passives. Add a passive ability icon.
	AddIconPassive(Template);

	Condition = new class'X2Condition_UnitProperty';
	Condition.ExcludeOrganic = true;
	Condition.ExcludeDead = false;
	Condition.ExcludeFriendlyToSource = true;
	Condition.ExcludeHostileToSource = false;
	AddTriggerTargetCondition(Template, Condition);

	return Template;
}

// Perk name:		Bull Rush
// Perk effect:		Make an unarmed melee attack that stuns the target. Whenever you take damage, this ability's cooldown resets.
// Localized text:	"Make an unarmed melee attack that stuns the target. Whenever you take damage, this ability's cooldown resets."
// Config:			(AbilityName="XMBExample_BullRush")
static function X2AbilityTemplate BullRush()
{
	local X2AbilityTemplate Template;
	local X2Effect_ApplyWeaponDamage DamageEffect;
	local X2Effect StunnedEffect;
	local X2AbilityToHitCalc_StandardMelee ToHitCalc;

	DamageEffect = new class'X2Effect_ApplyWeaponDamage';

	// Deals 1-2 damage, 50% chance of 1 and 50% chance of 2
	DamageEffect.EffectDamageValue.Damage = 1;
	DamageEffect.EffectDamageValue.PlusOne = 50;
	DamageEffect.bIgnoreBaseDamage = true;

	Template = MeleeAttack('XMBExample_BullRush', "img:///UILibrary_PerkIcons.UIPerk_command", true, DamageEffect, class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY, eCost_SingleConsumeAll);
	AddCooldown(Template, 5);

	ToHitCalc = new class'X2AbilityToHitCalc_StandardMelee';
	ToHitCalc.BuiltInHitMod = 20;
	Template.AbilityToHitCalc = ToHitCalc;

	// Create a stun effect that removes 2 actions and has a 100% chance of success if the attack hits.
	StunnedEffect = class'X2StatusEffects'.static.CreateStunnedStatusEffect(2, 100, false);
	Template.AddTargetEffect(StunnedEffect);

	// The default fire animation depends on the ability's associated weapon - shooting for a gun or 
	// slashing for a sword. If the ability has no associated weapon, no animation plays. Use an
	// alternate animation, FF_Melee, which is a generic melee attack that works with any weapon.
	Template.CustomFireAnim = 'FF_Melee';

	Template.AdditionalAbilities.AddItem('XMBExample_BullRushTrigger');

	return Template;
}

// This is part of the Bull Rush effect, above
static function X2AbilityTemplate BullRushTrigger()
{
	local X2Effect_ReduceCooldowns Effect;

	Effect = new class'X2Effect_ReduceCooldowns';
	Effect.AbilitiesToTick.AddItem('XMBExample_BullRush');
	Effect.ReduceAll = true;

	return SelfTargetTrigger('XMBExample_BullRushTrigger', "img:///UILibrary_PerkIcons.UIPerk_command", false, Effect, 'UnitTakeEffectDamage');
}
