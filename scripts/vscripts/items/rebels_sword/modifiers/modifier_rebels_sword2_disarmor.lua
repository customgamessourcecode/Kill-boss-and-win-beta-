modifier_rebels_sword2_disarmor = class({})
--------------------------------------------------------------------------------

function modifier_rebels_sword2_disarmor:IsHidden() 			return false;  	end
function modifier_rebels_sword2_disarmor:IsDebuff() 			return true;   	end 
function modifier_rebels_sword2_disarmor:IsPurgable() 		return true; 	end
function modifier_rebels_sword2_disarmor:DestroyOnExpire() 	return true; 	end

--------------------------------------------------------------------------------

function modifier_rebels_sword2_disarmor:GetTexture()
	return "../items/custom/rebels_sword_big"
end

--------------------------------------------------------------------------------

function modifier_rebels_sword2_disarmor:DeclareFunctions() return 
{
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
}
end

--------------------------------------------------------------------------------

function modifier_rebels_sword2_disarmor:GetModifierPhysicalArmorBonus(kv)        
	return -self:GetStackCount()    
end 