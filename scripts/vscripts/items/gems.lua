function EncrustArmorGreen(event)
local hero = event.caster
local ability = hero:FindAbilityByName("SDMS")
	if HeroHasSlottedArmor(hero) then
	ModifyRating(hero,25)
	CombineEpicArmor(hero)
	ability:ApplyDataDrivenModifier( hero, hero, "green_gem", {} )
	else
	hero:AddItemByName("item_gem_green")
	end
end

function EncrustWeaponBrown(event)
local hero = event.caster
local ability = hero:FindAbilityByName("SDMS")
	if HeroHasSlottedWeapon(hero) then
	ModifyRating(hero,25)
	CombineEpicWeapon(hero)
	ability:ApplyDataDrivenModifier( hero, hero, "brown_gem", {} )
	else
	hero:AddItemByName("item_gem_brown")
	end
end

function EncrustWeaponWheelStr(event)
local hero = event.caster
local ability = hero:FindAbilityByName("SDMS")
	if HeroHasSlottedWeapon(hero) then
	ModifyRating(hero,25)
	CombineEpicWeapon(hero)
	ability:ApplyDataDrivenModifier( hero, hero, "wheel_str_gem", {} )
	else
	hero:AddItemByName("item_gem_wheel_str")
	end
end

function EncrustWeaponWheelAgi(event)
local hero = event.caster
local ability = hero:FindAbilityByName("SDMS")
	if HeroHasSlottedWeapon(hero) then
	ModifyRating(hero,25)
	CombineEpicWeapon(hero)
	ability:ApplyDataDrivenModifier( hero, hero, "wheel_agi_gem", {} )
	else
	hero:AddItemByName("item_gem_wheel_agi")
	end
end

function EncrustWeaponWheelInt(event)
local hero = event.caster
local ability = hero:FindAbilityByName("SDMS")
	if HeroHasSlottedWeapon(hero) then
	ModifyRating(hero,25)
	CombineEpicWeapon(hero)
	ability:ApplyDataDrivenModifier( hero, hero, "wheel_int_gem", {} )
	else
	hero:AddItemByName("item_gem_wheel_int")
	end
end

function EncrustWeaponDark(event)
local hero = event.caster
local ability = hero:FindAbilityByName("SDMS")
	if HeroHasSlottedWeapon(hero) then
	ModifyRating(hero,25)
	CombineEpicWeapon(hero)
	ability:ApplyDataDrivenModifier( hero, hero, "dark_pierce", {} )
	else
	hero:AddItemByName("item_gem_dark")
	end
end
