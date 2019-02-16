if item_blink_dagger_two == nil then item_blink_dagger_two = class({}) end

LinkLuaModifier("modifier_blink_dagger_two_passive","items/item_blink_dagger_two.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_stun","libraries/modifiers/modifier_stun.lua",LUA_MODIFIER_MOTION_NONE)

function item_blink_dagger_two:OnSpellStart( event )
	local caster = self:GetCaster()
	local max_targets = self:GetSpecialValueFor("max_targets")
	local damage_range = self:GetSpecialValueFor("damage_range")
	local prc = self:GetSpecialValueFor("prc") * 0.01
	local current = 0
	
	ProjectileManager:ProjectileDodge(caster)

	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, caster)
    caster:EmitSound("DOTA_Item.BlinkDagger.Activate")

    local origin_point = caster:GetAbsOrigin()
    local target_points = self:GetCursorPosition()
    local target_point = target_points
    local difference_vector = target_point - origin_point
    
    if difference_vector:Length2D() > self:GetSpecialValueFor("max_range") then  --Clamp the target point to the BlinkRangeClamp range in the same direction.
        target_point = origin_point + (target_point - origin_point):Normalized() * self:GetSpecialValueFor(("clamp"))
    end

    caster:SetAbsOrigin(target_point)
    FindClearSpaceForUnit(caster, target_point, false)
    
    ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, caster)

    local Units = FindUnitsInRadius(caster:GetTeamNumber(),
                              caster:GetAbsOrigin(),
                              nil,
                              damage_range,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)

	for _,target in pairs(Units) do
		if current > max_targets then break end
		if target:IsRealHero() then
			current = current + 1
		end
		local caster_mana = caster:GetMana()
		local target_mana = target:GetMana()
		local differences = caster_mana - target_mana
		differences = math.abs(differences)
		differences = differences * prc
		if differences > target:GetHealth() * 0.2 then
			target:AddNewModifier(caster,self,"modifier_stun",{duration = self:GetSpecialValueFor("duration")})
		end
		ApplyDamage({victim = target, attacker = caster, damage = differences, damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
	end
end

function item_blink_dagger_two:GetIntrinsicModifierName(  )
	return "modifier_blink_dagger_two_passive"
end

if modifier_blink_dagger_two_passive == nil then modifier_blink_dagger_two_passive = class({}) end

function modifier_blink_dagger_two_passive:DeclareFunctions(  )
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_blink_dagger_two_passive:OnAttackLanded( params )
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local cooldown = ability:GetSpecialValueFor("cooldown")
	if params.attacker ~= caster and params.unit == caster then
		if params.damage > 0 and (IsBoss(params.attacker) or params.attacker:IsControllableByAnyPlayer()) then
			if ability:GetCooldownTimeRemaining() < cooldown then
				ability:StartCooldown(cooldown)
			end
		end
	end
end

function modifier_blink_dagger_two_passive:IsHidden(  )
	return true
end

function modifier_blink_dagger_two_passive:IsPurgable(  )
	return false
end