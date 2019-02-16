require('libraries/timers')

if item_tranquil_boots_two == nil then
	item_tranquil_boots_two = class({})
end

LinkLuaModifier("modifier_tranquil_boots_two_passive","items/item_tranquil_boots_two.lua",LUA_MODIFIER_MOTION_NONE)

function item_tranquil_boots_two:GetIntrinsicModifierName(  )
	return "modifier_tranquil_boots_two_passive"
end

---------------------

if modifier_tranquil_boots_two_passive == nil then
	modifier_tranquil_boots_two_passive = class({})
end

function modifier_tranquil_boots_two_passive:IsHidden(  )
	return true
end

function modifier_tranquil_boots_two_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_tranquil_boots_two_passive:DeclareFunctions(  )
	local hFuncs = { MODIFIER_EVENT_ON_ATTACK,MODIFIER_EVENT_ON_TAKEDAMAGE,MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE,MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
	return hFuncs
end

function modifier_tranquil_boots_two_passive:OnCreated(  )
	local ability = self:GetAbility()
	ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))

	local cooldown_timer = Timers:CreateTimer(0,function()
		if ability:IsCooldownReady() then
			local caster = self:GetCaster()
			for i=0, 5, 1 do  --Fill all empty slots in the player's inventory with "dummy" items.
		        local current_item = caster:GetItemInSlot(i)
		        if current_item == nil then
		            caster:AddItem(CreateItem("item_dummy", caster, caster))
		        end
		    end
		    
		    caster:RemoveItem(self:GetAbility())
		    local item_s = caster:AddItem(CreateItem("item_tranquil_boots_two_active", caster, caster))  --This should be put into the same slot that the removed item was in.
		    item_s:SetPurchaseTime(0)
		    for i=0, 5, 1 do  --Remove all dummy items from the player's inventory.
		        local current_item = caster:GetItemInSlot(i)
		        if current_item ~= nil then
		            if current_item:GetName() == "item_dummy" then
		                caster:RemoveItem(current_item)
		            end
		        end
		    end
		    Timers:RemoveTimer(cooldown_timer)
		end
		return 0.1
		end)
end

function modifier_tranquil_boots_two_passive:OnRefresh(  )
	local ability = self:GetAbility()

	self.armor = ability:GetSpecialValueFor("armor")
	self.movespeed = ability:GetSpecialValueFor("speed")
end

function modifier_tranquil_boots_two_passive:OnAttack( params )
	if IsServer() and params.attacker == self:GetCaster() or params.target == self:GetCaster() then
		local ability = self:GetAbility()
		ability:StartCooldown(ability:GetCooldown(ability:GetLevel()))
	end
end

function modifier_tranquil_boots_two_passive:GetModifierPhysicalArmorBonus(  )
	return self:GetAbility():GetSpecialValueFor("armor")
end

function modifier_tranquil_boots_two_passive:GetModifierMoveSpeedBonus_Special_Boots(  )
	return self:GetAbility():GetSpecialValueFor("speed")
end