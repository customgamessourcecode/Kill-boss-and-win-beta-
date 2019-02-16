if item_ethereal_blade_2 == nil then item_ethereal_blade_2 = class({})end
LinkLuaModifier("modifier_ethereal_blade_passive","items/item_ethereal_blade_2.lua",LUA_MODIFIER_MOTION_NONE)LinkLuaModifier("modifier_ethereal_blade_enemy","items/item_ethereal_blade_2.lua",LUA_MODIFIER_MOTION_NONE)LinkLuaModifier("modifier_ethereal_blade_particle","items/item_ethereal_blade_2.lua",LUA_MODIFIER_MOTION_NONE)LinkLuaModifier("modifier_ethereal_blade_team","items/item_ethereal_blade_2.lua",LUA_MODIFIER_MOTION_NONE)
function item_ethereal_blade_2:OnSpellStart(  )local damage = 0 local target = self:GetCursorTarget()local caster = self:GetCaster()
if caster:GetPrimaryAttribute() == 0 then damage = (caster:GetStrength() * 2.5) + 130 
elseif caster:GetPrimaryAttribute() == 1 then damage = (caster:GetAgility() * 2.5) + 130
elseif caster:GetPrimaryAttribute() == 2 then damage = (caster:GetIntellect() * 2.5) + 130
else damage = 0	end local caster_team = caster:GetTeamNumber()if IsServer() then if target:GetTeamNumber() ~= caster_team then
target:EmitSound("DOTA_Item.GhostScepter.Activate")target:EmitSound("sounds/items/item_ghost_etherealblade.vsnd")
ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
target:AddNewModifier(caster,self,"modifier_ethereal_blade_enemy",{duration = self:GetLevelSpecialValueFor("duration",self:GetLevel())})target:AddNewModifier(caster,self,"modifier_ethereal_blade_particle",{duration = 0.1})
elseif target:GetTeamNumber() == caster_team then target:EmitSound("DOTA_Item.GhostScepter.Activate")target:AddNewModifier(caster,self,"modifier_ethereal_blade_team",{duration = self:GetLevelSpecialValueFor("duration_team",self:GetLevel())})target:AddNewModifier(caster,self,"modifier_ethereal_blade_particle",{duration = 0.1})
elseif target == caster then caster:EmitSound("DOTA_Item.GhostScepter.Activate")target:AddNewModifier(caster,self,"modifier_ethereal_blade_team",{duration = self:GetLevelSpecialValueFor("duration_team",self:GetLevel())})target:AddNewModifier(caster,self,"modifier_ethereal_blade_particle",{duration = 0.1})
end	end end function item_ethereal_blade_2:GetIntrinsicModifierName(  )return"modifier_ethereal_blade_passive"end
if modifier_ethereal_blade_passive == nil then modifier_ethereal_blade_passive = class({})end function modifier_ethereal_blade_passive:IsPurgable()return false end
function modifier_ethereal_blade_passive:GetAttributes()return MODIFIER_ATTRIBUTE_MULTIPLE end function modifier_ethereal_blade_passive:IsHidden()return true end
function modifier_ethereal_blade_passive:DeclareFunctions()local funcs = { MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,	MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }return funcs end
function modifier_ethereal_blade_passive:OnCreated(  )local ability = self:GetAbility()self.str = ability:GetSpecialValueFor("str")self.int = ability:GetSpecialValueFor("int")self.agi = ability:GetSpecialValueFor("agi")end
function modifier_ethereal_blade_passive:GetModifierBonusStats_Strength()return self.str end function modifier_ethereal_blade_passive:GetModifierBonusStats_Agility()return self.agi end
function modifier_ethereal_blade_passive:GetModifierBonusStats_Intellect()return self.int end if modifier_ethereal_blade_enemy == nil then modifier_ethereal_blade_enemy = class({})end
function modifier_ethereal_blade_enemy:GetTexture()return"item_ethereal_blade_2"end function modifier_ethereal_blade_enemy:GetEffectName()return"particles/items_fx/ghost.vpcf"end
function modifier_ethereal_blade_enemy:DeclareFunctions()local funcs={MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}return funcs end
function modifier_ethereal_blade_enemy:OnCreated(  )self.resistance = self:GetAbility():GetSpecialValueFor("resistance")self.slow = self:GetAbility():GetSpecialValueFor("slow")end
function modifier_ethereal_blade_enemy:GetModifierMagicalResistanceBonus()return self.resistance end function modifier_ethereal_blade_enemy:GetModifierMoveSpeedBonus_Percentage()return self.slow end
function modifier_ethereal_blade_enemy:CheckState()local states={[MODIFIER_STATE_ATTACK_IMMUNE]=true,[MODIFIER_STATE_DISARMED]=true,[MODIFIER_STATE_NO_UNIT_COLLISION]=true}return states end
function modifier_ethereal_blade_enemy:GetAttributes ()return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE+MODIFIER_ATTRIBUTE_MULTIPLE end
if modifier_ethereal_blade_team==nil then modifier_ethereal_blade_team=class({})end
function modifier_ethereal_blade_team:GetTexture()return"item_ethereal_blade_2"end function modifier_ethereal_blade_team:GetEffectName()return"particles/items_fx/ghost.vpcf"end
function modifier_ethereal_blade_team:DeclareFunctions()local funcs={MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}return funcs end
function modifier_ethereal_blade_team:OnCreated()self.resistance=self:GetAbility():GetSpecialValueFor("resistance")end
function modifier_ethereal_blade_team:GetModifierMagicalResistanceBonus()return self.resistance end
function modifier_ethereal_blade_team:CheckState()local states={[MODIFIER_STATE_ATTACK_IMMUNE]=true,[MODIFIER_STATE_DISARMED]=true,[MODIFIER_STATE_NO_UNIT_COLLISION]=true}return states end
function modifier_ethereal_blade_team:GetAttributes()return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE+MODIFIER_ATTRIBUTE_MULTIPLE end
if modifier_ethereal_blade_particle==nil then modifier_ethereal_blade_particle=class({})end
function modifier_ethereal_blade_particle:IsHidden()return true end function modifier_ethereal_blade_particle:GetEffectAttachType()return PATTACH_ABSORIGIN end function modifier_ethereal_blade_particle:GetEffectName()return"particles/items_fx/ethereal_blade.vpcf"end