require('libraries/timers')
function swap_shield( keys )

	for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
        local current_item = keys.caster:GetItemInSlot(i)
        if current_item == nil then
            keys.caster:AddItem(CreateItem(item, keys.caster, keys.caster))
        end
    end
    
    keys.caster:RemoveItem(keys.ability)
    local item_s = keys.caster:AddItem(CreateItem("item_magic_shield_active", keys.caster, keys.caster))  --This should be put into the same slot that the removed item was in.
    item_s:SetPurchaseTime(0)
    for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
        local current_item = keys.caster:GetItemInSlot(i)
        if current_item ~= nil then
            if current_item:GetName() == "item_dummy" then
                keys.caster:RemoveItem(current_item)
            end
        end
    end
end

--------------------------------------

if item_magic_shield_active == nil then
	item_magic_shield_active = class({})
end

LinkLuaModifier("modifier_magic_shield_active_passive","items/item_magic_shield.lua",LUA_MODIFIER_MOTION_NONE)

function item_magic_shield_active:GetIntrinsicModifierName(  )
	return "modifier_magic_shield_active_passive"
end

function item_magic_shield_active:OnSpellStart(  )
	local caster = self:GetCaster()
	for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
        local current_item = caster:GetItemInSlot(i)
        if current_item == nil then
            caster:AddItem(CreateItem(item, caster, caster))
        end
    end
    
    caster:RemoveItem(self)
    local item_s = caster:AddItem(CreateItem("item_magic_shield", caster, caster))  --This should be put into the same slot that the removed item was in.
    item_s:SetPurchaseTime(0)
    for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
        local current_item = caster:GetItemInSlot(i)
        if current_item ~= nil then
            if current_item:GetName() == "item_dummy" then
                caster:RemoveItem(current_item)
            end
        end
    end
end

---------------------------------

if modifier_magic_shield_active_passive == nil then
	modifier_magic_shield_active_passive = class({})
end

function modifier_magic_shield_active_passive:DeclareFunctions(  )
	local hFuncs = { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_EVENT_ON_ATTACK_LANDED }
	return hFuncs
end

function modifier_magic_shield_active_passive:GetTexture(  )
	return "item_magic_shield_active"
end

function modifier_magic_shield_active_passive:OnCreated(  )
	local ability = self:GetAbility()
	local level = ability:GetLevel()
	local caster = self:GetCaster()

	self.dmg_prc = ability:GetSpecialValueFor("dmg_prc")
	self.mpd = ability:GetSpecialValueFor("mpd")
	self.damage = ability:GetSpecialValueFor("damage")
	self.hp_regen = ability:GetSpecialValueFor("hp_regen")
end

function modifier_magic_shield_active_passive:OnRefresh(  )
	local ability = self:GetAbility()
	local level = ability:GetLevel()
	local caster = self:GetCaster()

	self.dmg_prc = ability:GetSpecialValueFor("dmg_prc")
	self.mpd = ability:GetSpecialValueFor("mpd")
	self.damage = ability:GetSpecialValueFor("damage")
	self.hp_regen = ability:GetSpecialValueFor("hp_regen")
end

function modifier_magic_shield_active_passive:GetModifierConstantHealthRegen(  )
	return self.hp_regen
end

function modifier_magic_shield_active_passive:GetModifierPreAttack_BonusDamage(  )
	return self.damage
end

function modifier_magic_shield_active_passive:OnAttackLanded( params )
	if IsServer() and params.target == self:GetParent() then
		local caster = self:GetParent()
		local ability = self:GetAbility()
		local dnm = ability:GetSpecialValueFor("dnm") + (caster:GetMaxMana() / 100) * 2.3
		local int = params.damage * self.dmg_prc / 100
		local armor = caster:GetPhysicalArmorValue() * 0.6
		if armor <= 0 then armor = 1 end
		local mana_need = (int * self.mpd) / armor
		local mana = caster:GetMana() - mana_need
		if caster:GetMana() >= int then
			if caster:IsRealHero() then
				caster:SetMana(mana)
				caster:SetHealth(caster:GetHealth() + int)
			else caster:SetHealth(caster:GetHealth() + int / 2) caster:SetMana(mana - mana / 9) end
		else
			local caster = self:GetCaster()
			for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
		        local current_item = caster:GetItemInSlot(i)
		        if current_item == nil then
		            caster:AddItem(CreateItem(item, caster, caster))
		        end
		    end
		    
		    caster:RemoveItem(self:GetAbility())
		    local item_s = caster:AddItem(CreateItem("item_magic_shield", caster, caster))  --This should be put into the same slot that the removed item was in.
		    item_s:SetPurchaseTime(0)
		    item_s:StartCooldown(3)
		    for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
		        local current_item = caster:GetItemInSlot(i)
		        if current_item ~= nil then
		            if current_item:GetName() == "item_dummy" then
		                caster:RemoveItem(current_item)
		            end
		        end
		    end
		    if caster:GetHealth() >= dnm then
				ApplyDamage({attacker = caster,victim = caster, damage = dnm, damage_type = DAMAGE_TYPE_PURE})
			else
				caster:SetHealth(1)
			end
		end

		print("Damage get "..int.." | Mana Need "..mana_need.." | Current Mana" ..caster:GetMana())
	end
end