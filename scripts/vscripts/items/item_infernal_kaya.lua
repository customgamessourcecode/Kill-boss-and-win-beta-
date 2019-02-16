if item_infernal_kaya == nil then item_infernal_kaya = class({}) end

LinkLuaModifier("modifier_infernal_kaya_passive","items/item_infernal_kaya.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_infernal_kaya_active","items/item_infernal_kaya.lua",LUA_MODIFIER_MOTION_NONE)

function item_infernal_kaya:GetIntrinsicModifierName(  )
	return "modifier_infernal_kaya_passive"
end

function item_infernal_kaya:OnSpellStart() 
	local caster = self:GetCaster()
	if IsServer() and caster:IsRealHero() and not caster:HasModifier("modifier_infernal_kaya_active") then
		caster:AddNewModifier(caster,self,"modifier_infernal_kaya_active",{duration = self:GetSpecialValueFor("duration")})
	end
end

if modifier_infernal_kaya_passive == nil then modifier_infernal_kaya_passive = class({}) end

function modifier_infernal_kaya_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_infernal_kaya_passive:IsHidden() return true end

function modifier_infernal_kaya_passive:IsPurgable() return false end

function modifier_infernal_kaya_passive:DeclareFunctions()
	local funcs = {MODIFIER_PROPERTY_MANACOST_PERCENTAGE,MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
	return funcs
end

function modifier_infernal_kaya_passive:OnCreated() 
	local ability = self:GetAbility()
	self.manacost = ability:GetSpecialValueFor("manacost")
	self.act_manacost = ability:GetSpecialValueFor("act_manacost")
	self.amp = ability:GetSpecialValueFor("amp")
	self.act_amp = ability:GetSpecialValueFor("act_amp")
	self.int = ability:GetSpecialValueFor("int")
end

function modifier_infernal_kaya_passive:GetModifierPercentageManacost() 
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_infernal_kaya_active") then
		return -1000
	end
	return self.manacost
end

function modifier_infernal_kaya_passive:GetModifierBonusStats_Intellect() 
	return self.int 
end

function modifier_infernal_kaya_passive:GetModifierSpellAmplify_Percentage() 
	local caster = self:GetCaster()
	if caster:HasModifier("modifier_infernal_kaya_active") then
		return self.act_amp + self.amp
	end
	return self.amp 
end

if modifier_infernal_kaya_active == nil then modifier_infernal_kaya_active = class({}) end

function modifier_infernal_kaya_active:IsPurgable() return true end

function modifier_infernal_kaya_active:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_infernal_kaya_active:OnCreated()	
	local ability = self:GetAbility()
	self.manacost = ability:GetSpecialValueFor("act_manacost")
end

function modifier_infernal_kaya_active:DeclareFunctions()
	local funcs = {MODIFIER_EVENT_ON_ABILITY_START}
	return funcs
end

function modifier_infernal_kaya_active:GetTexture(  )
	return self:GetAbility():GetName()
end

function modifier_infernal_kaya_active:OnAbilityStart(params) 
	local caster = self:GetCaster()
	if params.unit == caster then 
		local ability = self:GetAbility()
		local manatospend = params.ability:GetManaCost(params.ability:GetLevel()) * (self.manacost*0.01) - params.ability:GetManaCost(params.ability:GetLevel())
		print("manatospend"..manatospend)
		if caster:GetMana() >= manatospend + params.ability:GetManaCost(params.ability:GetLevel()) then
			caster:SpendMana(manatospend,params.ability)
			return UF_SUCCESS
		else
			caster:Interrupt()
			params.ability:StartCooldown(2)
		end
	end
end