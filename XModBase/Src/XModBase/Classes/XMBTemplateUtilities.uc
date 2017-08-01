class XMBTemplateUtilities extends object;

static function X2SoldierAbilityUnlockTemplate AddClassUnlock(name DataName, name ClassName, name AbilityName, string Image = "img:///UILibrary_StrategyImages.GTS.GTS_FNG")
{
	local X2SoldierAbilityUnlockTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SoldierAbilityUnlockTemplate', Template, DataName);

	Template.AllowedClasses.AddItem(ClassName);
	Template.AbilityName = AbilityName;
	Template.strImage = Image;

	// Requirements
	Template.Requirements.RequiredHighestSoldierRank = 5;
	Template.Requirements.RequiredSoldierClass = ClassName;
	Template.Requirements.RequiredSoldierRankClassCombo = true;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 75;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	return Template;
}

static function X2SoldierAbilityUnlockTemplate AddBrigadierUnlock(name DataName, name ClassName, name AbilityName, string Image = "img:///UILibrary_StrategyImages.GTS.GTS_FNG")
{
	local X2SoldierAbilityUnlockTemplate Template;
	local ArtifactCost Resources;

	`CREATE_X2TEMPLATE(class'X2SoldierAbilityUnlockTemplate', Template, DataName);

	Template.bAllClasses = true;
	Template.AbilityName = AbilityName;
	Template.strImage = Image;

	// Requirements
	Template.Requirements.RequiredHighestSoldierRank = 8;
	Template.Requirements.RequiredSoldierClass = ClassName;
	Template.Requirements.RequiredSoldierRankClassCombo = true;
	Template.Requirements.bVisibleIfSoldierRankGatesNotMet = true;

	// Cost
	Resources.ItemTemplateName = 'Supplies';
	Resources.Quantity = 150;
	Template.Cost.ResourceCosts.AddItem(Resources);
	
	return Template;
}
