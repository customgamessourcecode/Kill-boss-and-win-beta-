if item_suzzwke == nil then item_suzzwke = class({}) end

LinkLuaModifier("modifier_suzzwke_passive","items/item_suzzwke.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_suzzwke_slow","items/item_suzzwke.lua",LUA_MODIFIER_MOTION_NONE)

function item_suzzwke:OnSpellStart(  )
	local target = self:GetCursorTarget()
	target:EmitSound("n_creep_SatyrTrickster.Cast")
	if target:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		target:Purge(false,true,false,true,false)
		target.Suzzwke_purge = ParticleManager:CreateParticle("particles/generic_gameplay/generic_purge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	else
		if target:TriggerSpellAbsorb(self) then return end
		target:TriggerSpellReflect(self) 
		target:AddNewModifier(self:GetCaster(),self,"modifier_suzzwke_slow",{duration = self:GetSpecialValueFor("duration")})
		target:Purge(true,false,false,false,false)
	end
end

function item_suzzwke:CastFilterResultTarget( hTarget )
	if hTarget:IsMagicImmune() then return UF_FAIL_MAGIC_IMMUNE_ENEMY end
	return UF_SUCCESS
end

function item_suzzwke:GetIntrinsicModifierName(  )
	return "modifier_suzzwke_passive"
end

if modifier_suzzwke_passive == nil then modifier_suzzwke_passive = class({}) end

function modifier_suzzwke_passive:IsHidden(  )
	return true
end

function modifier_suzzwke_passive:IsPurgable(  )
	return false
end	

function modifier_suzzwke_passive:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function modifier_suzzwke_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_suzzwke_passive:GetModifierBonusStats_Agility(  )
	return self:GetAbility():GetSpecialValueFor("agi")
end

function modifier_suzzwke_passive:GetModifierBonusStats_Intellect(  )
	return self:GetAbility():GetSpecialValueFor("int")
end

function modifier_suzzwke_passive:GetModifierOrbPriority(  )
	return DOTA_ORB_CUSTOM
end

function modifier_suzzwke_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local target = params.target
	local ability = self:GetAbility()
	if params.attacker == caster then 
		if self:IsActiveOrb() then 
			if RollPercentage(ability:GetSpecialValueFor("chance")) and caster:IsRealHero() then

				-- Purge a random positive modifier from the target
				local modifier_list = target:FindAllModifiers()
				local modifier_found = false
				for _,modifier in pairs(modifier_list) do
					local modifier_name = modifier:GetName()
					for _,modifier_name_compare in pairs(PURGE_BUFF_LIST) do
						if modifier_name == modifier_name_compare then
							if not target:IsRealHero() then target:ForceKill() end
							target:RemoveModifierByName(modifier_name)
							local source_ability = modifier:GetAbility()
							local source_caster = modifier:GetCaster()
							local remaining_duration = modifier:GetRemainingTime()
							if not remaining_duration then remaining_duration = 10 end
							if remaining_duration >= 10 then remaining_duration = 10 end
							caster:AddNewModifier(source_caster, source_ability, modifier_name, {duration = remaining_duration * 0.75})

								modifier_found = true
							break
						end
					end
					if modifier_found then
						break
					end
				end
			end
			target:ManaBurn(ability:GetSpecialValueFor("burn"),"particles/mana_burn_burn.vpcf",true,0,ability:GetSpecialValueFor("burn_damage"),ability,caster)
		end
	end
end

if modifier_suzzwke_slow == nil then modifier_suzzwke_slow = class({}) end

function modifier_suzzwke_slow:IsDebuff(  )
	return true
end

function modifier_suzzwke_slow:GetTexture(  )
	return "item_suzzwke"
end

function modifier_suzzwke_slow:GetEffectName(  )
	return "particles/items_fx/diffusal_slow.vpcf"
end

function modifier_suzzwke_slow:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

require('libraries/timers')

function modifier_suzzwke_slow:OnCreated(  )
	self.D01 = ParticleManager:CreateParticle("particles/generic_gameplay/generic_purge.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.D01, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), false)
	self.slow = -100
	self.timer = Timers:CreateTimer(0, function() self.slow = self.slow + 1.5 return 0.1 end)
end

function modifier_suzzwke_slow:OnDestroy(  )
	Timers:RemoveTimer(self.timer)
	ParticleManager:DestroyParticle(self.D01,false)
end

function modifier_suzzwke_slow:GetModifierMoveSpeedBonus_Percentage(  )	
	return self.slow
end