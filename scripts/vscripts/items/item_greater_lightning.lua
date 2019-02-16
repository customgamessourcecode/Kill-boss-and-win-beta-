if item_greater_lightning == nil then item_greater_lightning = class({}) end

LinkLuaModifier("modifier_greater_lightning_passive","items/item_greater_lightning.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_greater_lightning_static","items/item_greater_lightning.lua",LUA_MODIFIER_MOTION_NONE)

function item_greater_lightning:GetIntrinsicModifierName(  )
	return "modifier_greater_lightning_passive"
end

function item_greater_lightning:OnSpellStart(  )
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:AddNewModifier(caster,self,"modifier_greater_lightning_static",{duration = 10})
end

if not modifier_greater_lightning_passive then modifier_greater_lightning_passive = class({}) end

function modifier_greater_lightning_passive:IsHidden(  )
	return true
end

function modifier_greater_lightning_passive:IsPurgable(  )
	return false
end

function modifier_greater_lightning_passive:DeclareFunctions(  )
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_greater_lightning_passive:OnCreated(  )
	local ability = self:GetAbility()
	self.dmg = ability:GetSpecialValueFor("dmg")
	self.atk = ability:GetSpecialValueFor("atk")
	self.lightning_damage = ability:GetSpecialValueFor("lightning_damage")
	self.lightning_range = ability:GetSpecialValueFor("lightning_range")
	self.chance = ability:GetSpecialValueFor("chance")
	self.jump_count = ability:GetSpecialValueFor("jump_count")
end

function modifier_greater_lightning_passive:GetModifierPreAttack_BonusDamage(  )
	return self.dmg
end

function modifier_greater_lightning_passive:GetModifierAttackSpeedBonus_Constant(  )
	return self.atk
end

function modifier_greater_lightning_passive:GetModifierOrbPriority(  )
	if self.succes == true then
		return DOTA_ORB_PRIORITY_ITEM_UNIQUE
	else
		return DOTA_ORB_PRIORITY_FALSE
	end
	return DOTA_ORB_PRIORITY_FALSE
end

function modifier_greater_lightning_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	if params.attacker == caster then
		self.succes = false
		if not caster:IsRealHero() then self.chance = self.chance / 2 self.jump_count = self.jump_count / 2 end
		if RollPercentage(self.chance) then
			self.succes = true
			if self:IsActiveOrb() then
				print("Start Lightning")
				caster:CreateLightning(ability, 
					self.lightning_damage, 
					self.lightning_range, 
					self.jump_count,
					DAMAGE_TYPE_MAGICAL,
					params.target)
				print("Damage = "..self.lightning_damage.." | Range = "..self.lightning_range.." | Jumps count = "..self.jump_count)
			end
		end
	end
end

if modifier_greater_lightning_static == nil then modifier_greater_lightning_static = class({}) end

function modifier_greater_lightning_static:IsPurgable(  )
	return false
end

function modifier_greater_lightning_static:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_greater_lightning_static:GetTexture(  )
	return "item_greater_lightning"
end

function modifier_greater_lightning_static:OnCreated(  )
	local ability = self:GetAbility()
	self.lightning_damage = ability:GetSpecialValueFor("static_damage")
	self.lightning_range = ability:GetSpecialValueFor("static_range")
	self.chance = ability:GetSpecialValueFor("static_chance")
	self.jump_count = ability:GetSpecialValueFor("static_targets")
	self.id0 = ParticleManager:CreateParticle("particles/items2_fx/mjollnir_shield.vpcf",PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
end

function modifier_greater_lightning_static:OnDestroy(  )
	ParticleManager:DestroyParticle(self.id0,false)
end

function modifier_greater_lightning_static:OnAttackLanded( params )
	local caster = self:GetCaster()
	local parent = self:GetParent()
	if params.target == parent then
		if RollPercentage(self.chance) then
			local count = 0
			local Units = FindUnitsInRadius(parent:GetTeamNumber(),
                        parent:GetAbsOrigin(),
                        nil,
                        self.lightning_range,
                        DOTA_UNIT_TARGET_TEAM_ENEMY,
                        DOTA_UNIT_TARGET_ALL,
                        DOTA_UNIT_TARGET_FLAG_NONE,
                        FIND_ANY_ORDER,
                        false)
			for _,target in pairs(Units) do 
				count = count + 1
				if count < self.jump_count then
					parent:EmitSound("Hero_Leshrac.Lightning_Storm")
		            local id1 = ParticleManager:CreateParticle("particles/static_custom.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
		            local id2 = ParticleManager:CreateParticle("particles/econ/items/dazzle/dazzle_darkclaw/dazzle_darkclaw_talon_explosion_flash.vpcf",PATTACH_ABSORIGIN_FOLLOW, target)
		            ParticleManager:SetParticleControl(id1, 1, Vector(parent:GetAbsOrigin().x,parent:GetAbsOrigin().y,parent:GetAbsOrigin().z+parent:GetBoundingMaxs().z * 2))
		            ParticleManager:SetParticleControl(id1, 0, Vector(target:GetAbsOrigin().x,target:GetAbsOrigin().y,target:GetAbsOrigin().z+target:GetBoundingMaxs().z * 2))
		            ParticleManager:SetParticleControl(id2, 5, target:GetAbsOrigin())
		            ApplyDamage({victim = target, attacker = caster, damage = self.lightning_damage, damage_type = DAMAGE_TYPE_MAGICAL,ability = self:GetAbility()})
				end
			end
		end
	end
end