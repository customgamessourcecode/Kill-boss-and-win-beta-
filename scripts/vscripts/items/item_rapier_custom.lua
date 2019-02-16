function OnDeath( keys )
	local caster = keys.caster
	local ability = keys.ability

	if not caster:IsReincarnating() then
		for i=0, 5 do
        local current_item = caster:GetItemInSlot(i)
        local name = current_item:GetName()
	        if name == "item_rapier_custom" then
	        	caster:RemoveItem(current_item)
	        	local item = LaunchItem(name,caster:GetAbsOrigin())
	        	item:SetPurchaseTime(0)
	        end
	    end
	end
end

function LaunchItem(itemName,point)
   	local newItem = CreateItem(itemName, nil, nil)
   	newItem:SetPurchaseTime(0)
   	local drop = CreateItemOnPositionSync( point, newItem )
   	newItem:LaunchLoot(false, 300, 0.75, point + RandomVector(RandomFloat(20, 80)))
	--newItem:SetStacksWithOtherOwners(true)
   	TimerThing(drop)
end
