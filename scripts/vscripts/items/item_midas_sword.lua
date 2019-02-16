if item_midas_sword == nil then item_midas_sword = class({}) end

LinkLuaModifier("modifier_midas_sword_passive","items/item_midas_sword.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_midas_sword_gold","items/item_midas_sword.lua",LUA_MODIFIER_MOTION_NONE)

function item_midas_sword:OnSpellStart(  )
	if IsClient() then ClientLoadGridNav() end
	local target = self:GetCursorTarget()
	
	local caster = self:GetCaster()
	local hero = caster:GetPlayerOwner():GetAssignedHero()
	local target_gold = caster:GetLevel() * 0.3 * RandomFloat(target:GetMinimumGoldBounty(),target:GetMaximumGoldBounty())
	local gold = self:GetSpecialValueFor("gold_active") + target_gold
	local exp = self:GetSpecialValueFor("exp")

	if target:IsBoss() or target:IsAncient() or target:IsMagicImmune() then return end


		hero:AddExperience(target:GetDeathXP() * exp * 0.01, false,false) 
		hero:ModifyGold(gold,true,0)
		SendOverheadEventMessage( caster,  OVERHEAD_ALERT_GOLD , target, gold, nil )
	target:EmitSound("DOTA_Item.Hand_Of_Midas")

	local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)  
    ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)

    target:SetDeathXP(0)
    target:SetMinimumGoldBounty(0)
    target:SetMaximumGoldBounty(0)
    target:Kill(self, caster)
end

function item_midas_sword:GetIntrinsicModifierName(  )
	return "modifier_midas_sword_passive"
end

if modifier_midas_sword_passive == nil then modifier_midas_sword_passive = class({}) end

function modifier_midas_sword_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_midas_sword_passive:IsHidden(  )
	return true
end

function modifier_midas_sword_passive:IsPurgable(  )
	return false
end

function modifier_midas_sword_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_MANA_BONUS,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_midas_sword_passive:GetModifierAttackSpeedBonus_Constant(  )
	return self:GetAbility():GetSpecialValueFor("atk")
end

function modifier_midas_sword_passive:GetModifierManaBonus(  )
	return self:GetAbility():GetSpecialValueFor("mana")
end

function modifier_midas_sword_passive:OnCreated(  )
	self:GetCaster():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_midas_sword_gold",{})
end

function modifier_midas_sword_passive:OnDestroy(  )
	self:GetCaster():RemoveModifierByName("modifier_midas_sword_gold")
end

if modifier_midas_sword_gold == nil then modifier_midas_sword_gold = class({}) end

function modifier_midas_sword_gold:IsHidden(  )
	return true
end

function modifier_midas_sword_gold:IsPurgable(  )
	return false
end

function modifier_midas_sword_gold:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_midas_sword_gold:GetModifierOrbPriority()
	return DOTA_ORB_CUSTOM
end

require('libraries/timers')

function modifier_midas_sword_gold:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	if ability == nil then caster:RemoveModifierByName("modifier_midas_sword_gold") return nil; end
	if params.attacker == caster then 
	
	local condition = RollPercentage(ability:GetSpecialValueFor("gold_chance"))
			if caster:IsRealHero() and condition then
					local vec1 = RandomFloat(0,360)
					local vec2 = RandomFloat(0,360)
					local id0 = ParticleManager:CreateParticle("particles/courier_flopjaw_ambient_coins_gold_custom.vpcf",PATTACH_OVERHEAD_FOLLOW, caster)
					ParticleManager:SetParticleControlEnt(id0, 1, caster, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
					ParticleManager:SetParticleControlForward(id0, 1, Vector(vec1,vec2,0))
					caster:ModifyGold(ability:GetSpecialValueFor("gold"),true,0)
					Timers:CreateTimer({endTime = 0.3, callback = function() ParticleManager:DestroyParticle(id0,false) end})
			end
	end
end