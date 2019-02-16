modifier_sponsor = class({})

--------------------------------------------------------------------------------

function modifier_sponsor:IsHidden()
	return false
end

--------------------------------------------------------------------------------

function modifier_sponsor:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_sponsor:IsPurgeException()
	return false
end

--------------------------------------------------------------------------------

function modifier_sponsor:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function modifier_sponsor:AllowIllusionDuplicate()
	return true
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function modifier_sponsor:OnIntervalThink()
--	self:GetCaster():CalculateStatBonus()
end

--------------------------------------------------------------------------------

function modifier_sponsor:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end
--------------------------------------------------------------------------------

function modifier_sponsor:OnDeath(params)
	if IsServer() then
		local hAttacker = params.attacker
		local hVictim = params.unit
		if hVictim == self:GetParent() and self:GetParent():IsRealHero() then
			local sEffect = "particles/items_fx/aegis_respawn.vpcf"
			local nFXIndex = ParticleManager:CreateParticle(sEffect, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
			ParticleManager:SetParticleControlEnt( nFXIndex, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), false )
			ParticleManager:SetParticleControlEnt( nFXIndex, 1, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), false )
			ParticleManager:ReleaseParticleIndex( nFXIndex )	
		end
	end
	
	if IsClient() then
		if self.particle then
			ParticleManager:DestroyParticle(self.particle, true)
		end
	end
	
	return 0	
end

function modifier_sponsor:GetTexture()
  return "sponsor"
end

--------------------------------------------------------------------------------