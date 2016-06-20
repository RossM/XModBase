XModBase (XMB) is a library for mod authors, designed to make it easier to create interesting and unique perks. It provides a collection of effects and conditions which can be combined to create a huge variety of different perks. It takes care of annoying details like filling out all the boring-but-necessary fields of X2AbilityTemplate, and provides support for localization tags so you can change your abilities' values in one place and have their descriptions update automatically.

FOR PLAYERS

If you're a player, you don't need to worry about XModBase. It's safe to install multiple mods that use XModBase, even if they use different versions.

INSTALLATION

There are two ways of using XMB: one that's easy, and one that's better.

EASY INSTALLATION

Easy installation will make it possible to build and run your mod using XModBase. However, if you publish your mod, your users will need to install XModBase separately.

1. Copy the XModBase mod files to "C:\Program Files (x86)\Steam\SteamApps\common\XCOM 2\XComGame\Mods\XModBase".

2. Copy all the XMB*.uc files from XModBase\Src\XModBase\Classes to your own mod's Classes directory.

3. Add the following lines to your mod's XComEngine.ini:

[UnrealEd.EditorEngine]
+ModEditPackages=LW_Tuple
+ModEditPackages=XModBase_Interfaces
+ModEditPackages=XModBase_Core_1_1_0

COMPLETE INSTALLATION

Complete installation will include the XModBase libraries in your mod, so you can publish it without your users needing to install XModBase. Your mod will still be compatible with other mods using XModBase, even mods which have a different version. Users will automatically get the latest version of XModBase from any installed mod.

1. Copy all the XMB*.uc files from XModBase\Src\XModBase\Classes to your own mod's Classes directory.

2. Create new folders under your mod's Src folder so it looks like this:

Src
  LW_Tuple
    Classes
  XModBase_Core_1_1_0
    Classes
  XModBase_Interfaces
    Classes

3. Now, for each of those "Classes" folders, right-click and choose "Add > Existing Item...", then add all of the *.uc files from the corresponding directory in XModBase. You should end up with a Src directory like this:

Src
  LW_Tuple
    Classes
	  LWTuple.uc
  XModBase_Core_1_1_0
    Classes
	  XMBAbilityMultiTarget_SoldierBonusRadius
	  XMBAbilityTag
	  XMBAbilityToHitCalc_StandardAim
	  XMBConfig
	  XMBDownloadableContentInfo_XModBase
      XMBTargetingMethod_Grenade
  XModBase_Interfaces
    Classes
	  XMBEffectInterface
	  XMBOverrideInterface

4. Add the following lines to your mod's XComEngine.ini:

[Engine.ScriptPackages]
+NonNativePackages=LW_Tuple
+NonNativePackages=XModBase_Interfaces
+NonNativePackages=XModBase_Core_1_1_0

[UnrealEd.EditorEngine]
+ModEditPackages=LW_Tuple
+ModEditPackages=XModBase_Interfaces
+ModEditPackages=XModBase_Core_1_1_0

USING XMODBASE

First, look in XModBase\Src\XModBase\Classes for Examples.uc. It contains several example abilities built using XModBase classes.

Your ability sets should extend XMBAbility, rather than X2Ability. XMBAbility adds several utility functions and properties to reduce the amount of boilerplate needed when to make a new ability.

The most versatile class in XModBase is XMBEffect_ConditionalBonus. It can provide passive bonuses to attack hit chances, damage, and/or defense. The bonuses can be conditional on hit type, weapon tech level, or any X2Condition - and XModBase includes a number of conditions for common checks. So if you want you can apply a damage bonus on critical hits with the primary weapon, or an increased hit chance against targets at higher elevation, you can.

XModBase provides additional effects that are either commonly useful or hard to do. Here's a list of the available effects:

XMBEffect_AbilityCostRefund			Passively refunds ability costs based on conditions
XMBEffect_AbilityTriggered			Lets you trigger an event when an ability is activated that meets conditions
XMBEffect_AddItemChargesBySlot		Adds extra charges to items in certain slots, like Heavy Ordnance but more general
XMBEffect_AddUtilityItem			Adds a bonus utility item that lasts for the duration of the mission then disappears
XMBEffect_BonusDamageByDamageType	Grants bonus damage on attacks and damage-over-time of a specific elemental damage type
XMBEffect_BonusRadius				Increases the radius of grenades of a specific type, or of all grenades
XMBEffect_ConditionalBonus			Grants attack and/or defense bonuses based on conditions
XMBEffect_Extended					Base class for defining your own X2Effects with additional functions to override
XMBEffect_RevealUnit				Makes a unit visible on the map
XMBEffect_ToHitModifierByRange		Modifies to-hit based on range to target and conditions