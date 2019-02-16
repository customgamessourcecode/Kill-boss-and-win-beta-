MagicLifesteal = class({})

local disabled_lifesteal_skills = {
	["necrolyte_heartstopper_aura"] = 1,
	["item_blade_mail"]				= 1,
}

function MagicLifesteal:GlobalListen( keys )
	local caster 		= keys.caster
	local target 		= keys.target
	local damage 		= keys.damage
	local skill_name 	= keys.skill_name
  	
  	if not caster then return end 

  	if disabled_lifesteal_skills[skill_name] then return end

  	if target:IsIllusion() then return end

	local lifesteal_pct = 0;
	if target == caster then return end
	if caster:HasModifier("modifier_skeleton_king_reincarnation_scepter_active") then return end
	
	if target:IsHero() then 
		lifesteal_pct = MagicLifesteal:_GetUnitMagicLifesteal_toHero(caster) / 100
	else 
		lifesteal_pct = MagicLifesteal:_GetUnitMagicLifesteal_toCreep(caster) / 100 
	end

	if lifesteal_pct == 0 then return end

	local particle_lifesteal = "particles/items3_fx/octarine_core_lifesteal.vpcf"
	local lifesteal_fx = ParticleManager:CreateParticle(particle_lifesteal, PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControl(lifesteal_fx, 0, caster:GetAbsOrigin())

	if damage*lifesteal_pct  < 1 or damage*lifesteal_pct  > caster:GetHealth() or damage*lifesteal_pct > 1000000 then return end

	caster:Heal(damage*lifesteal_pct , caster)
end

function MagicLifesteal:_GetUnitMagicLifesteal_toCreep(unit)
	local total_lifesteal = 0;
	if not unit or not unit:HasInventory() then return 0 end
	
	for item_name, lifesteal_data in pairs(self.items) do
		if unit:HasItemInInventory(item_name) then
			local item = MagicLifesteal:_FindItemInInventory(unit, item_name)

			if not item or not IsValidEntity(item) then 
				return 0 
			end
			
			if (lifesteal_data.creep) then
				local amount = item:GetSpecialValueFor(lifesteal_data.creep)
				if amount > total_lifesteal then total_lifesteal = amount end
			end

			if(lifesteal_data.all) then
				local amount = item:GetSpecialValueFor(lifesteal_data.all)
				if amount > total_lifesteal then total_lifesteal = amount end
			end
		end
	end

	for ability_name, lifesteal_data in pairs(self.abilities) do
		if unit:HasAbility(item_name) then

			local ability = unit:FindAbilityByName(ability_name)

			if (lifesteal_data.creep) then
				local amount = ability:GetSpecialValueFor(lifesteal_data.creep)
				if amount > total_lifesteal then total_lifesteal = amount end
			end

			if(lifesteal_data.all) then
				local amount = ability:GetSpecialValueFor(lifesteal_data.all)
				if amount > total_lifesteal then total_lifesteal = amount end
			end

		end
	end
	return total_lifesteal;
end

function MagicLifesteal:_GetUnitMagicLifesteal_toHero(unit)
	local total_lifesteal = 0;
	if not unit or not unit:HasInventory() then 
		return 0 
	end
	for item_name, lifesteal_data in pairs(self.items) do
		if unit:HasItemInInventory(item_name) then
			local item = MagicLifesteal:_FindItemInInventory(unit, item_name)

			if not item or not IsValidEntity(item) then 
				return 0 
			end

			if (lifesteal_data.hero) then
				local amount = item:GetSpecialValueFor(lifesteal_data.hero)
				if amount > total_lifesteal then total_lifesteal = amount end
			end

			if(lifesteal_data.all) then
				local amount = item:GetSpecialValueFor(lifesteal_data.all)
				if amount > total_lifesteal then total_lifesteal = amount end
			end
		end
	end

	for ability_name, lifesteal_data in pairs(self.abilities) do
		if unit:HasAbility(item_name) then

			local ability = unit:FindAbilityByName(ability_name)

			if (lifesteal_data.hero) then
				local amount = ability:GetSpecialValueFor(lifesteal_data.hero)
				if amount > total_lifesteal then total_lifesteal = amount end
			end

			if(lifesteal_data.all) then
				local amount = ability:GetSpecialValueFor(lifesteal_data.all)
				if amount > total_lifesteal then total_lifesteal = amount end
			end

		end
	end

	return total_lifesteal;
end

function MagicLifesteal:_FindItemInInventory(unit, item_name)
	for i = 0, 5 do
		local item = unit:GetItemInSlot(i) 
		if item and item:GetName() == item_name then
			return item;
		end
	end
end

function MagicLifesteal:RegisterLifestealAbility( ability_name, all_lifesteal)
	self.abilities[ability_name] = self.abilities[ability_name] or {}
	self.abilities[ability_name].all = all_lifesteal;
end

function MagicLifesteal:RegisterLifestealAbility( ability_name, hero_lifesteal, creep_lifesteal)
	self.abilities[ability_name] = self.abilities[ability_name] or {};
	self.abilities[ability_name].hero = hero_lifesteal;
	self.abilities[ability_name].creep = creep_lifesteal;
end

function MagicLifesteal:RegisterLifestealItem(item_name, all_lifesteal)
	self.items[item_name] = self.items[item_name] or {};
	self.items[item_name].all = all_lifesteal;
end

function MagicLifesteal:RegisterLifestealItem(item_name, hero_lifesteal, creep_lifesteal)
	self.items[item_name] = self.items[item_name] or {};
	self.items[item_name].hero = hero_lifesteal;
	self.items[item_name].creep = creep_lifesteal;
end

function MagicLifesteal:_init()
	_G._MagicLifesteal = {}
	_G._MagicLifesteal.main = function( keys ) MagicLifesteal:GlobalListen( keys ); end

	self.items = {}
	self.abilities = {}
	--MagicLifesteal:RegisterLifestealItem("item_octarine_core", "hero_lifesteal", "creep_lifesteal")
	MagicLifesteal:RegisterLifestealItem("item_octarine_core_2", "hero_lifesteal", "creep_lifesteal")

end

MagicLifesteal:_init()