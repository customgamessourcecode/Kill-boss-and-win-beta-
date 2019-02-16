function Spawn( entityKeyValues )
	ABILILTY_invisible = thisEntity:FindAbilityByName("Pet_invis_ability")

	Timers:CreateTimer(function()
			PetPremiumThink()
		return 1.0
	end)
end

function PetPremiumThink()
	local OWNER = thisEntity:GetOwner()
	local Owner_location = OWNER:GetAbsOrigin()
	local Pet_location = thisEntity:GetAbsOrigin()
	local vector_distance = Owner_location - Pet_location
	local distance = vector_distance:Length2D()
	
	if distance > 400 and distance < 900 then
		local order = 
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
			TargetIndex = OWNER:entindex()
		}	
		ExecuteOrderFromTable(order)
	elseif distance < 325 then
		thisEntity:Stop()
		local order = 
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = Owner_location + RandomVector( RandomFloat(0, 300))
		}	
		ExecuteOrderFromTable(order)
	elseif distance > 900 then
		thisEntity:SetAbsOrigin(Owner_location + RandomVector( RandomFloat(0, 100)))
	end
	
	if OWNER:IsInvisible() then
		if (not thisEntity:HasModifier("modifier_pet_invis")) then
			ABILILTY_invisible:ApplyDataDrivenModifier(thisEntity, thisEntity, "modifier_pet_invis", {Duration = inf})
			thisEntity:AddNewModifier(thisEntity, thisEntity, "modifier_invisible", {Duration = inf})
		end
	else
		if thisEntity:HasModifier("modifier_pet_invis") then
			thisEntity:RemoveModifierByName("modifier_pet_invis")
			thisEntity:RemoveModifierByName("modifier_invisible")
		end
	end
end