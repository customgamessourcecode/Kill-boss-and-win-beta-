gun_joe_explosive = class({})
LinkLuaModifier( "modifier_gun_joe_explosive", 'heroes/gun_joe/modifiers/modifier_gun_joe_explosive', LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

local talent_name_1 = "gun_joe_special_bonus_explosive_bullets_cd"
local talent_name_2 = "gun_joe_special_bonus_explosive_bullets_stack"

function gun_joe_explosive:OnSpellStart( keys )
	local caster = self:GetCaster()

	local talent_ability = caster:FindAbilityByName(talent_name_2)

	caster:AddNewModifier(caster, self, "modifier_gun_joe_explosive", { duration = self:GetSpecialValueFor("duration") } ) 

	local stack_count = self:GetSpecialValueFor("stack_count")

	if caster:HasAbility(talent_name_2) then
		stack_count = stack_count + talent_ability:GetSpecialValueFor("value")
	end
	caster:SetModifierStackCount("modifier_gun_joe_explosive", caster, stack_count )
end

function gun_joe_explosive:GetCooldown( nLevel )
	if IsServer() then
		local cd = self:GetSpecialValueFor("cooldown")

		if self:GetCaster():HasAbility(talent_name_1) then
			local talent_ability = self:GetCaster():FindAbilityByName(talent_name_1)
			
			cd = cd + talent_ability:GetSpecialValueFor("value")

			CustomNetTables:SetTableValue( "heroes", "gun_joe_explosive", {cooldown = cd } )

			return cd
		end
		return cd
	else
		local net_table = CustomNetTables:GetTableValue( "heroes", "gun_joe_explosive" )

		if(net_table) then
			return net_table.cooldown
		else
			return self.BaseClass.GetCooldown(self, nLevel)
		end
	end
end
