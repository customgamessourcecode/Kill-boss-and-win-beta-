if not modifier_rainbow then
	modifier_rainbow = class({})
end
function modifier_rainbow:IsHidden()
    return false
end
function modifier_rainbow:GetEffectName()
  return "particles/rainbow.vpcf"
end
function modifier_rainbow:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_rainbow:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
function modifier_rainbow:GetTexture()
  	return "rainbow"
end
function modifier_rainbow:AllowIllusionDuplicate()
return true
end