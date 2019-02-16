LinkLuaModifier( "modifier_spartacus_leader_blood", "heroes/hero_spartacus/spartacus_leader_blood.lua", LUA_MODIFIER_MOTION_NONE )			-- Owner's bonus attributes, stackable

if spartacus_leader_blood == nil then spartacus_leader_blood = class({}) end


function spartacus_leader_blood:GetIntrinsicModifierName()
	return "modifier_spartacus_leader_blood" end

----------------------------------------
----------------------------------------

modifier_spartacus_leader_blood = class({})

----------------------------------------


----------------------------------------
function modifier_spartacus_leader_blood:IsHidden() return true end
function modifier_spartacus_leader_blood:IsDebuff() return false end
function modifier_spartacus_leader_blood:IsPurgable() return false end

function modifier_spartacus_leader_blood:OnCreated( kv )
		print("created_leader_blood")
	self.convert_pct = self:GetAbility():GetSpecialValueFor( "dmg_convert" )
end

----------------------------------------

function modifier_spartacus_leader_blood:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

----------------------------------------

----------------------------------------

function modifier_spartacus_leader_blood:OnTakeDamage( params )
	if IsServer() then
		local Target = params.unit
		local Attacker = params.attacker
		print("ggg1")
		if Attacker ~= nil and Target == self:GetParent() and Target ~= nil then
			print("ggg2")
			local ability = self:GetAbility()
			local radius = ability:GetSpecialValueFor("radius")
			local allies = FindUnitsInRadius( Target:GetTeamNumber(), self:GetCaster():GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
			for _,ally in pairs( allies ) do
				--if ally ~= nil and ally:FindModifierByName( "modifier_item_unhallowed_icon_effect" ) then
					if ally ~= Target then 
						local heal = ( params.damage * self.convert_pct / 100 )  --/ #allies 
						ally:Heal( heal, ability )
						local nFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally )
						ParticleManager:ReleaseParticleIndex( nFXIndex )
					end
				--end
			end
		end
	end
	return 0
end