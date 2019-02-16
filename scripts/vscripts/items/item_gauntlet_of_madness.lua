if item_gauntlet_of_madness == nil then item_gauntlet_of_madness = class({}) end
require('libraries/timers')

LinkLuaModifier("modifier_gauntlet_of_madness_passive","items/item_gauntlet_of_madness.lua",LUA_MODIFIER_MOTION_NONE)

function item_gauntlet_of_madness:GetIntrinsicModifierName(  )
	return "modifier_gauntlet_of_madness_passive"
end

function item_gauntlet_of_madness:OnSpellStart(  )
	local caster = self:GetCaster()
	if not caster:HasItemInInventory(self:GetName()) then return end
	 
	for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
        local current_item = caster:GetItemInSlot(i)
        if current_item == nil then
            caster:AddItem(CreateItem("item_dummy", caster, caster))
        end
    end
    
    caster:RemoveItem(self)
    caster:AddItem(CreateItem("item_gauntlet_of_madness_active", caster, caster))  --This should be put into the same slot that the removed item was in.
    
    for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
        local current_item = caster:GetItemInSlot(i)
        if current_item ~= nil then
            if current_item:GetName() == "item_dummy" then
                caster:RemoveItem(current_item)
            end
        end
    end
	caster:EmitSound("DOTA_Item.Armlet.Activate")
end

if modifier_gauntlet_of_madness_passive == nil then modifier_gauntlet_of_madness_passive = class({}) end

function modifier_gauntlet_of_madness_passive:IsHidden(  )
	return true
end

function modifier_gauntlet_of_madness_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_gauntlet_of_madness_passive:IsPurgable(  )
	return false
end

function modifier_gauntlet_of_madness_passive:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_gauntlet_of_madness_passive:GetModifierAttackSpeedBonus_Constant(  )
	return self:GetAbility():GetSpecialValueFor("atk")
end

function modifier_gauntlet_of_madness_passive:GetModifierOrbPriority(  )
	if self.activated == false then
		return DOTA_ORB_PRIORITY_ITEM
	end
	return DOTA_ORB_PRIORITY_FALSE
end

function modifier_gauntlet_of_madness_passive:OnCreated(  )
	if IsServer() then
		self.activated = false
		if self:GetAbility():GetName() == "item_gauntlet_of_madness_active" then self.activated = true self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_gauntlet_of_madness_active",{}) else self.activated = false end
	end
end

function modifier_gauntlet_of_madness_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if self:GetAbility():GetName() == "item_gauntlet_of_madness_active" then return end
	if params.attacker == caster and params.target ~= caster then 
		if not self:IsActiveOrb() then return end
		local prc = ability:GetSpecialValueFor("lifesteal")
		if modifier_gauntlet_of_madness_active.current_tick then 
			local tick = modifier_gauntlet_of_madness_active.current_tick
			local cap = ability:GetSpecialValueFor("cap")
			if tick then prc = prc + ((prc_act / cap) * tick) else prc = prc end
		end

		caster:HealCustom(params.damage * prc * 0.01,caster,true,false)
	end
end

function modifier_gauntlet_of_madness_passive:GetModifierPreAttack_BonusDamage(  )
	return self:GetAbility():GetSpecialValueFor("dmg")
end

function modifier_gauntlet_of_madness_passive:GetModifierConstantHealthRegen(  )
	return self:GetAbility():GetSpecialValueFor("hp_regen")
end

function modifier_gauntlet_of_madness_passive:GetModifierPhysicalArmorBonus(  )
	return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_gauntlet_of_madness_passive:GetModifierAttackSpeedBonus_Constant(  )
	return self:GetAbility():GetSpecialValueFor("atk")
end

if item_gauntlet_of_madness_active == nil then item_gauntlet_of_madness_active = class({}) end

LinkLuaModifier("modifier_gauntlet_of_madness_passive","items/item_gauntlet_of_madness.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_gauntlet_of_madness_active","items/item_gauntlet_of_madness.lua",LUA_MODIFIER_MOTION_NONE)

function item_gauntlet_of_madness_active:GetIntrinsicModifierName(  )
	return "modifier_gauntlet_of_madness_passive"
end

function item_gauntlet_of_madness_active:OnSpellStart(  )
	local caster = self:GetCaster()
	if not caster:HasItemInInventory(self:GetName()) then return end
	 
	for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
        local current_item = caster:GetItemInSlot(i)
        if current_item == nil then
            caster:AddItem(CreateItem("item_dummy", caster, caster))
        end
    end
    
    caster:RemoveItem(self)
    caster:AddItem(CreateItem("item_gauntlet_of_madness", caster, caster))  --This should be put into the same slot that the removed item was in.
    
    for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
        local current_item = caster:GetItemInSlot(i)
        if current_item ~= nil then
            if current_item:GetName() == "item_dummy" then
                caster:RemoveItem(current_item)
            end
        end
    end
	caster:EmitSound("DOTA_Item.Armlet.DeActivate")
end

if modifier_gauntlet_of_madness_active == nil then modifier_gauntlet_of_madness_active = class({}) end

function modifier_gauntlet_of_madness_active:GetModifierOrbPriority(  )
	return DOTA_ORB_PRIORITY_ITEM
end

function modifier_gauntlet_of_madness_active:OnCreated(  )
	local ability = self:GetAbility()
	local endTime = ability:GetSpecialValueFor("delay")
	local cap = ability:GetSpecialValueFor("cap")
	local caster = self:GetCaster()
		self.id0 = ParticleManager:CreateParticle("particles/armlet_custom.vpcf",PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
			ParticleManager:SetParticleControlEnt(self.id0, 1, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), false)
	local lif = ability:GetSpecialValueFor("lifesteal_act")
	local lifes = self:GetAbility():GetSpecialValueFor("lifesteal")
	local damage = ability:GetSpecialValueFor("take_dmg_act")
	local stre = ability:GetSpecialValueFor("str_act")
	local dmga = ability:GetSpecialValueFor("dmg_act")
	local atka = ability:GetSpecialValueFor("atk_act")
	local hp_sec = ability:GetSpecialValueFor("hp_per_sec")
	local hp_prc = ability:GetSpecialValueFor("hp_prc")
	local tick = 0
	self.current_tick = 0
	self.str = 0
	self.damage = 0
	self.lifesteal = 0
	self.dmg = 0
	self.atk = 0

	self.timer = Timers:CreateTimer(endTime,function()
		tick = tick + 1
		if tick == 9 then self.current_tick = self.current_tick + 2 tick = 0 end
		if self.current_tick < cap then

			self.current_tick = self.current_tick + 1
				self.str = (stre / cap) * self.current_tick
				self.damage = (damage / cap) * self.current_tick
				self.lifesteal = (lif / cap) * self.current_tick + lifes
				self.dmg = (dmga / cap) * self.current_tick
				self.atk = (atka / cap) * self.current_tick
			return endTime 
		else
			return nil
		end 
	end)

	self.damager = Timers:CreateTimer(endTime, function()
		if IsServer() then

			if not caster:HasItemInInventory("item_gauntlet_of_madness_active") then caster:RemoveModifierByName(self:GetName()) end

			local new_hp = 1

			new_hp = self:GetCaster():GetHealth() - (hp_sec * endTime) - (self:GetCaster():GetMaxHealth() * (hp_prc * 0.01) * endTime)
	    
		    if new_hp < 1 then  --Armlet cannot kill the caster from its HP drain.
		        new_hp = 1
		    end
		    
		    self:GetCaster():SetHealth(new_hp)

		 	return endTime 
	 	end
	end)
end

function modifier_gauntlet_of_madness_active:OnDestroy(  )
	self.current_tick = 0
	Timers:RemoveTimer(self.timer)
	Timers:RemoveTimer(self.damager)	
	ParticleManager:DestroyParticle(self.id0,false)
end

function modifier_gauntlet_of_madness_active:IsPurgable(  )
	return false
end

function modifier_gauntlet_of_madness_active:GetTexture(  )
	return "item_gauntlet_of_madness_active"
end

function modifier_gauntlet_of_madness_active:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_TOOLTIP,MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_gauntlet_of_madness_active:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_gauntlet_of_madness_active:GetModifierIncomingDamage_Percentage(  )
	return self.damage
end

function modifier_gauntlet_of_madness_active:GetModifierAttackSpeedBonus_Constant(  )
	return self.atk
end

function modifier_gauntlet_of_madness_active:GetModifierBonusStats_Strength(  )
	return self.str
end

function modifier_gauntlet_of_madness_active:GetModifierOrbPriority(  )
	return DOTA_ORB_PRIORITY_ITEM
end

function modifier_gauntlet_of_madness_active:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if params.attacker == caster and params.target ~= caster then 
		if self:IsActiveOrb() then 
			caster:HealCustom(params.damage * self.lifesteal * 0.01,caster,true,false)
		end
	end
end

function modifier_gauntlet_of_madness_active:OnTooltip(  )
	return self.lifesteal
end