if item_tranquil_boots_two_active == nil then
	item_tranquil_boots_two_active = class({})
end

LinkLuaModifier("modifier_tranquil_boots_two_active_passive","items/item_tranquil_boots_two_active.lua",LUA_MODIFIER_MOTION_NONE)

function item_tranquil_boots_two_active:GetIntrinsicModifierName(  )
	return "modifier_tranquil_boots_two_active_passive"
end

---------------------

if modifier_tranquil_boots_two_active_passive == nil then
	modifier_tranquil_boots_two_active_passive = class({})
end

function modifier_tranquil_boots_two_active_passive:IsHidden(  )
	return true
end

function modifier_tranquil_boots_two_active_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_tranquil_boots_two_active_passive:DeclareFunctions(  )
	local hFuncs = { MODIFIER_EVENT_ON_ATTACK,MODIFIER_EVENT_ON_TAKEDAMAGE,MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
	return hFuncs
end

function modifier_tranquil_boots_two_active_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.armor = ability:GetSpecialValueFor("armor")
	self.movespeed = ability:GetSpecialValueFor("speed_act")
	self.regen = ability:GetSpecialValueFor("hp_regen")
end

function modifier_tranquil_boots_two_active_passive:GetModifierPhysicalArmorBonus(  )
	return self.armor
end

function modifier_tranquil_boots_two_active_passive:GetModifierMoveSpeedBonus_Special_Boots(  )
	return self.movespeed
end

function modifier_tranquil_boots_two_active_passive:GetModifierConstantHealthRegen(  )
	return self.regen
end

function modifier_tranquil_boots_two_active_passive:OnAttack( params )
	if IsServer() and params.attacker == self:GetCaster() or params.target == self:GetCaster() then
		local caster = self:GetCaster()
		for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
		    local current_item = caster:GetItemInSlot(i)
			if current_item == nil then
		    	caster:AddItem(CreateItem(item, caster, caster))
		    end
		end
			    
		caster:RemoveItem(self:GetAbility())
		local item_s = caster:AddItem(CreateItem("item_tranquil_boots_two", caster, caster))  --This should be put into the same slot that the removed item was in.
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
end