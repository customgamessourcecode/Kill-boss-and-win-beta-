modifier_rebels_sword3_disarmor = class({})
--------------------------------------------------------------------------------

function modifier_rebels_sword3_disarmor:IsHidden() 			return false;  	end
function modifier_rebels_sword3_disarmor:IsDebuff() 			return true;   	end 
function modifier_rebels_sword3_disarmor:IsPurgable() 		return true; 	end
function modifier_rebels_sword3_disarmor:DestroyOnExpire() 	return true; 	end

--------------------------------------------------------------------------------

function modifier_rebels_sword3_disarmor:GetTexture()
	return "../items/custom/rebels_sword_big"
end

--------------------------------------------------------------------------------

function modifier_rebels_sword3_disarmor:DeclareFunctions() return 
{
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
}
end

--------------------------------------------------------------------------------

function modifier_rebels_sword3_disarmor:GetModifierPhysicalArmorBonus(kv)        
	return -self:GetStackCount()    
end 