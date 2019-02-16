ability_demotion = class{}
LinkLuaModifier( "modifier_demotion", "ability_demotion", 0 )
function ability_demotion:GetIntrinsicModifierName()
	return "modifier_demotion"
end

modifier_demotion = class{}
function modifier_demotion:IsHidden()
	return true
end
function modifier_demotion:OnCreated()
	if IsServer() then
		self:StartIntervalThink(1/30)
		self:OnIntervalThink()
	end
end
function modifier_demotion:OnIntervalThink()
	self:GetParent():InterruptMotionControllers(true)
end