sven_warcry = class{}
LinkLuaModifier( "modifier_sven_warcry_old", "heroes/sven/sven_warcry", 0 )

function sven_warcry:OnSpellStart()
	local radius = self:GetSpecialValueFor("radius")
	local duration = self:GetSpecialValueFor("duration")
	self.movespeed = self:GetSpecialValueFor("movespeed")
	
	local units = FindUnitsInRadius( self:GetCaster():GetTeam(), self:GetCaster():GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, 0, 0, false )
	for _, unit in pairs(units) do
		local mod = unit:AddNewModifier( self:GetCaster(), self, "modifier_sven_warcry_old", { duration = duration } )
		mod.health = self:GetSpecialValueFor("hp_shield")
		if unit == self:GetCaster() then
			mod.health = mod.health * ( 1 + self:GetSpecialValueFor("self_bonus")/100 )
		end
		local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_sven/sven_warcry_buff_shield.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, unit )
		ParticleManager:SetParticleControlEnt( particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true )
		ParticleManager:SetParticleControl( particle, 1, Vector( 128, 1, 1 ) )
		mod:AddParticle( particle, false, false, 0, false, false )
	end
	
	self:GetCaster():EmitSound("Hero_Sven.WarCry")
end

------------------------------------------------------------------------------------------

modifier_sven_warcry_old = class{}

function modifier_sven_warcry_old:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_sven_warcry_old:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility().movespeed
end

function modifier_sven_warcry_old:ModifyPhisicalDamagePost0( damage )
	self.health = self.health - damage
	if self.health <= 0 then
		self:Destroy()
		return -self.health
	end
	return 0
end