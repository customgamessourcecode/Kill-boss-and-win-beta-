if item_ascention_scroll == nil then item_ascention_scroll = class({}) end

LinkLuaModifier("modifier_ascention_scroll_passive","items/item_ascention_scroll.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ascention_scroll_ascention","items/item_ascention_scroll.lua",LUA_MODIFIER_MOTION_NONE)

function item_ascention_scroll:OnSpellStart(  )
	local caster = self:GetCaster()
	if caster:GetLevel() == self:GetSpecialValueFor("lvl") and not caster.IsDueling == true then
		local int = math.floor(caster:GetBaseIntellect())
		local str = math.floor(caster:GetBaseStrength())
		local agi = math.floor(caster:GetBaseAgility())
		local hero = PlayerResource:ReplaceHeroWith(caster:GetPlayerID(),caster:GetName(),caster:GetGold(),0)
		hero:SetAbilityPoints(1)
		hero:SetBaseIntellect(int)
		hero:SetBaseAgility(agi)
		hero:SetBaseStrength(str)
		if RollPercentage(self:GetSpecialValueFor("chance")) then 
			local item = hero:AddItem(CreateItem("item_soul_shard",hero,hero))
			item:SetPurchaseTime(0)
		end
		local mod_list = caster:FindAllModifiers()
		for _,mod in pairs(mod_list) do 
			if mod:GetName() == "modifier_ascention_scroll_ascention" then 
				local stacks = 0
				hero:AddNewModifier(mod:GetCaster(),self,mod:GetName(),{duration = mod:GetDuration()})
				if caster:GetModifierStackCount(mod:GetName(),mod:GetCaster()) then 
					stacks = caster:GetModifierStackCount(mod:GetName(),mod:GetCaster())
					hero:SetModifierStackCount(mod:GetName(),mod:GetCaster(),stacks)
				end
			end
		end
		hero:AddNewModifier(hero,self,"modifier_ascention_scroll_ascention",{})
		local stack = hero:GetModifierStackCount("modifier_ascention_scroll_ascention",hero)
		hero:SetModifierStackCount("modifier_ascention_scroll_ascention",hero,stack + 1)
		for i=0,8 do 
			local item = hero:GetItemInSlot(i)
			if item:GetName() == self:GetName() then hero:RemoveItem(item) break end
		end
		caster:RemoveSelf()
		local point = Vector(0,0,0)
		if hero:GetTeamNumber() == 2 then point = CORD_RAD else point = CORD_DIRE end

		hero:SetAbsOrigin(point)
		FindClearSpaceForUnit(hero, point, false)
		PlayerResource:SetCameraTarget(hero:GetPlayerOwnerID(),hero)
		Timers:CreateTimer({endTime = 0.1, callback = function() PlayerResource:SetCameraTarget(hero:GetPlayerOwnerID(), nil) end})
	end
end

function item_ascention_scroll:CastFilterResult(  )
	local caster = self:GetCaster()
	if caster:GetLevel() < self:GetSpecialValueFor("lvl") then return UF_FAIL_CUSTOM end
	if caster.IsDueling then return UF_FAIL_CUSTOM end
	return UF_SUCCESS
end

function item_ascention_scroll:GetCustomCastError(  )
	local caster = self:GetCaster()
	if caster:GetLevel() < self:GetSpecialValueFor("lvl") then return "#dota_hud_error_custom_low_lvl" end
	if caster.IsDueling then return "#dota_hud_error_custom_is_dueling" end
	return ""
end

function item_ascention_scroll:GetIntrinsicModifierName(  )
	return "modifier_ascention_scroll_passive"
end

if modifier_ascention_scroll_passive == nil then modifier_ascention_scroll_passive = class({}) end

function modifier_ascention_scroll_passive:IsPurgable(  )
	return false
end

function modifier_ascention_scroll_passive:IsHidden(  )
	return true
end

function modifier_ascention_scroll_passive:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_ascention_scroll_passive:OnTakeDamage( params )
	local caster = self:GetCaster()
	if params.unit == caster then 
		self:GetAbility():StartCooldown(5)
	end
end

if modifier_ascention_scroll_ascention == nil then modifier_ascention_scroll_ascention = class({}) end

function modifier_ascention_scroll_ascention:GetTexture(  )
	return "ascention_buff_texture"
end

function modifier_ascention_scroll_ascention:RemoveOnDeath(  )
	return false
end

function modifier_ascention_scroll_ascention:IsPurgable(  )
	return false
end

function modifier_ascention_scroll_ascention:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS,MODIFIER_PROPERTY_TOOLTIP}
end

function modifier_ascention_scroll_ascention:OnCreated(  )
	self.int = self:GetAbility():GetSpecialValueFor("int")
end

function modifier_ascention_scroll_ascention:GetModifierBonusStats_Intellect(  )
	return self.int * self:GetStackCount()
end

function modifier_ascention_scroll_ascention:GetModifierBonusStats_Strength(  )
	return self.int * self:GetStackCount()
end

function modifier_ascention_scroll_ascention:GetModifierBonusStats_Agility(  )
	return self.int * self:GetStackCount()
end

function modifier_ascention_scroll_ascention:OnTooltip(  )
	return self:GetStackCount()
end