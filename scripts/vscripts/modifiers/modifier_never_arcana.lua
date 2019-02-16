modifier_never_arcana = class({})

--------------------------------------------------------------------------------

function modifier_never_arcana:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_never_arcana:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_never_arcana:IsPurgeException()
	return false
end

--------------------------------------------------------------------------------

function modifier_never_arcana:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function modifier_never_arcana:AllowIllusionDuplicate()
	return true
end

--------------------------------------------------------------------------------

function modifier_never_arcana:OnCreated()
	if IsServer() then
		local sEffect = "particles/econ/items/shadow_fiend/sf_ferrum/shadow_fiend_ferrum_shoulder_ambient.vpcf"
		self.particle = ParticleManager:CreateParticle(sEffect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		local sEffect2 = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_ambient_head.vpcf"
		self.particle2 = ParticleManager:CreateParticle(sEffect2, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		local sEffect3 = "particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_trail.vpcf"
		self.particle3 = ParticleManager:CreateParticle(sEffect3, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		local sEffect4 = "particles/units/heroes/hero_morphling/morphling_ambient_new.vpcf"
		self.particle4 = ParticleManager:CreateParticle(sEffect4, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		local sEffect5 = "particles/units/heroes/hero_morphling/morphling_ambient.vpcf"
		self.particle5 = ParticleManager:CreateParticle(sEffect5, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	end
end

--------------------------------------------------------------------------------

function modifier_never_arcana:OnIntervalThink()
--	self:GetCaster():CalculateStatBonus()
end

--------------------------------------------------------------------------------

function modifier_never_arcana:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end
--------------------------------------------------------------------------------

function modifier_never_arcana:OnDeath(params)
	if IsServer() then
		local hAttacker = params.attacker
		local hVictim = params.unit
		if hVictim == self:GetParent() and self:GetParent():IsRealHero() then
			local sEffect = "particles/never_arcana/sf_fire_arcana_death.vpcf"
			local nFXIndex = ParticleManager:CreateParticle(sEffect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), false )
			ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), false )
			ParticleManager:ReleaseParticleIndex( nFXIndex )	
		end
	end	
	return 0	
end

--------------------------------------------------------------------------------