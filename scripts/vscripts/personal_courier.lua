local bPreviewAllModels = false

LinkLuaModifier( "courier_model_controller", "personal_courier", 0 )
item_personal_courier = class{}

function item_personal_courier:GetIntrinsicModifierName()
	if not self.activated then
		self.activated = true
		self:GetCaster():SetThink( function()
			if self:GetCaster():IsAlive() then
				self:CreatePersonalCourier()
				self:RemoveSelf()
			else
				return 1/30
			end
		end, "timed_courier_activator", 1 )
	end
	return nil
end

function item_personal_courier:CreatePersonalCourier()
	local playerID = self:GetCaster():GetPlayerOwnerID()
	local steamID = PlayerResource:GetSteamAccountID( playerID )
	
	if IsInToolsMode() and bPreviewAllModels then
		for model, info in pairs( PersonalWithCourier.Models ) do
			if info.fly then
				local courier = CreateUnitByName( "npc_dota_courier", self:GetCaster():GetOrigin(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeam() )
				courier:SetControllableByPlayer( playerID, false )
				SetCustomCourierModel( courier, info )
			end
		end
	else
		local vOffset = RandomVector( math.sqrt( math.random() ) * 322 )
		local courier = CreateUnitByName( "npc_dota_courier", self:GetCaster():GetOrigin() + vOffset, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeam() )
		courier:SetControllableByPlayer( playerID, false )
		courier.personal_owner = self:GetCaster()
		PlayerPersonalCouriers[ playerID ] = courier
		local model = PersonalWithCourier[ steamID ]
		if model then
			SetCustomCourierModel( courier, model )
		end
	end
end

function _G.SetCustomCourierModel( unit, model, bFly )
	if model == nil then return end
	
	local mod = unit:FindModifierByName("courier_model_controller") or unit:AddNewModifier( unit, nil, "courier_model_controller", {} )
	mod.model = model
	mod.fly_upgraded = bFly
	mod.gesture_removed = nil
	mod.recursion = true
	
	local info
	if type( model ) == "table" then
		info = model
	else
		info = PersonalWithCourier.Models[ model ]
	end
	
	if bFly then
		info = info and info.fly
		if info == nil then return end
		if type( info ) ~= "table" then
			model = info
			info = PersonalWithCourier.Models[ info ]
		end
	end
	
	if info then
		unit:SetOriginalModel( info.model )
		unit:SetModel( info.model )
		if info.material then
			unit:SetMaterialGroup( info.material )
		end
		if info.particle then
			mod.particle = ParticleManager:CreateParticle( info.particle, PATTACH_ABSORIGIN_FOLLOW, unit )
			if info.particle == "particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient.vpcf" or
			   info.particle == "particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient_flying.vpcf" or
			   info.particle == "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon.vpcf" or
			   info.particle == "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon_flying.vpcf" or
			   info.particle == "particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf" or
			   info.particle == "particles/econ/courier/courier_roshan_ti8/courier_roshan_ti8.vpcf" or
			   info.particle == "particles/econ/courier/courier_roshan_ti8/courier_roshan_ti8_flying.vpcf" then
				ParticleManager:SetParticleControlEnt( mod.particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_eye_l", Vector(0,0,0), true )
			end
			if info.particle == "particles/econ/courier/courier_roshan_lava/courier_roshan_lava.vpcf" or
			   info.particle == "particles/econ/courier/courier_golden_roshan/golden_roshan_ambient.vpcf" or
			   info.particle == "particles/econ/courier/courier_roshan_frost/courier_roshan_frost_ambient.vpcf" then
				ParticleManager:SetParticleControlEnt( mod.particle, 0, unit, PATTACH_POINT_FOLLOW, "attach_eye_m", Vector(0,0,0), true )
				ParticleManager:SetParticleControlEnt( mod.particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_eye_l", Vector(0,0,0), true )				
			end
		end
		if info.scale then
			unit:SetModelScale( info.scale )
		end
	else
		unit:SetOriginalModel( model )
		unit:SetModel( model )
	end
	unit:StartGesture(ACT_DOTA_IDLE)

	mod.recursion = nil
end

----------------------------------------------------------------------------------------------------

courier_model_controller = courier_model_controller or class{}
function courier_model_controller:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end
function courier_model_controller:IsHidden()
	return true
end
function courier_model_controller:DeclareFunctions()
	return { 
		MODIFIER_EVENT_ON_UNIT_MOVED,
		MODIFIER_EVENT_ON_MODEL_CHANGED,
	}
end
function courier_model_controller:OnUnitMoved(kv)
	if self.gesture_removed or kv.unit ~= self:GetParent() then return end
	self:GetParent():RemoveGesture(ACT_DOTA_IDLE)
	self.gesture_removed = true
end
function courier_model_controller:OnModelChanged(kv)
	if kv.attacker ~= self:GetParent() or self.recursion then return end
	if self:GetParent():HasModifier("modifier_courier_flying") then
		if self.particle then
			ParticleManager:DestroyParticle( self.particle, false )
		end
		SetCustomCourierModel( self:GetParent(), self.model, true )
	end
end