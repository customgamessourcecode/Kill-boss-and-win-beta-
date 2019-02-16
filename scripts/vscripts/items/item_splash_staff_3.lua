if item_splash_staff_3 == nil then item_splash_staff_3 = class({}) end

LinkLuaModifier("modifier_splash_staff_3_passive","items/item_splash_staff_3.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_splash_staff_3_splash","items/item_splash_staff_3.lua",LUA_MODIFIER_MOTION_NONE)


function item_splash_staff_3:GetIntrinsicModifierName(  )
	return "modifier_splash_staff_3_passive"
end

if modifier_splash_staff_3_passive == nil then modifier_splash_staff_3_passive = class({}) end

function modifier_splash_staff_3_passive:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_splash_staff_3_passive:IsHidden()
	return true
end

function modifier_splash_staff_3_passive:IsPurgable(  )
	return false
end

function modifier_splash_staff_3_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_splash_staff_3_passive:OnCreated(  )
	local ability = self:GetAbility()
	
	local modifier = self:GetCaster():AddNewModifier(self:GetCaster(),self:GetCaster(),"modifier_splash_staff_3_splash",{duration = 10*60^2})
	modifier.ability = ability
end

function modifier_splash_staff_3_passive:GetModifierBonusStats_Intellect(  )
	return self:GetAbility():GetSpecialValueFor("int")
end

function modifier_splash_staff_3_passive:GetModifierConstantManaRegen(  )
	return self:GetAbility():GetSpecialValueFor("manaregen")
end

function modifier_splash_staff_3_passive:GetModifierAttackSpeedBonus_Constant(  )
	return self:GetAbility():GetSpecialValueFor("attackspeed")
end

function modifier_splash_staff_3_passive:GetModifierPreAttack_BonusDamage(  )
	return self:GetAbility():GetSpecialValueFor("damage")
end

function modifier_splash_staff_3_passive:OnDestroy(  )
	if self:GetCaster():HasModifier("modifier_splash_staff_3_splash") then
		self:GetCaster():RemoveModifierByName("modifier_splash_staff_3_splash")
	end
end

if modifier_splash_staff_3_splash == nil then modifier_splash_staff_3_splash = class({}) end

function modifier_splash_staff_3_splash:GetAttributes(  )
	return MODIFIER_ATTRIBUTE_NONE
end

function modifier_splash_staff_3_splash:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_splash_staff_3_splash:IsHidden()
	return true
end

function modifier_splash_staff_3_splash:OnAttackLanded( params )
	local caster = self:GetParent()
	if params.attacker == caster and caster:GetAttackCapability() == 2 then

		if caster:HasModifier("modifier_splash_staff_splash") then 
			caster:RemoveModifierByName("modifier_splash_staff_splash")
		end

		if caster:HasModifier("modifier_splash_staff_2_splash") then 
			caster:RemoveModifierByName("modifier_splash_staff_2_splash")
		end

		local unit = params.target
		local ability = self.ability
		if not unit then unit = params.unit end
		if not unit then unit = params.victim end


		local Units = FindUnitsInRadius(caster:GetTeamNumber(),
	                              unit:GetAbsOrigin(),
	                              nil,
	                              ability:GetSpecialValueFor("range"),
	                              DOTA_UNIT_TARGET_TEAM_ENEMY,
	                              DOTA_UNIT_TARGET_ALL,
	                              DOTA_UNIT_TARGET_FLAG_NONE,
	                              FIND_ANY_ORDER,
	                              false)
		for _,target in pairs(Units) do
		    if target:GetTeamNumber() ~= caster:GetTeamNumber() and not target:IsMagicImmune() then
		    	local tracking_info = {
			    	Target = target,
			    	Source = unit,
			    	Ability = ability,
			    	EffectName = caster:GetRangedProjectileName(),
			    	iMoveSpeed = ability:GetSpecialValueFor("projectilespeed"),
			    	--vSourceLoc = caster:GetAbsOrigin(),
			    	bDrawsOnMinimap = false,
			    	bDodgeable = true,
			    	bIsAttack = false,
			    	bVisibleToEnemies = true,
			    	bReplaceExisting = false,
			    	--flExpireTime = math.floor(GameRules:GetDOTATime(false,false)) + 15,
			    	bProvidesVision = false,
		    	}
		    	projectile = ProjectileManager:CreateTrackingProjectile(tracking_info)
			end
		end
	end
end

function item_splash_staff_3:OnProjectileHit( target, location )
	local target = target
	local pos = location
	if target then 
		local caster = self:GetCaster()
		local damage = caster:GetMainAttribute() * self:GetSpecialValueFor("damagepct")*0.01

		local damage_type = 0

		if caster:GetPrimaryAttribute() == 0 then damage_type = 4 end

		if caster:GetPrimaryAttribute() == 1 then damage_type = 1 end

		if caster:GetPrimaryAttribute() == 2 then damage_type = 2 end
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = damage_type, ability = self})
	end
end