Filters = {}

function Filters:BoutyRune( kv )
	if BOUNTY_CUSTOM.USE_CUSTOM_BEHAVIOR then
		if PlayerResource:GetSelectedHeroEntity(kv.player_id_const) then
			local team = PlayerResource:GetSelectedHeroEntity( kv.player_id_const ):GetTeam()

			if BOUNTY_CUSTOM.player_number == 0 then
				BOUNTY_CUSTOM.player_count = 0
				for i = 0, PlayerResource:GetPlayerCount() - 1 do
					if PlayerResource:IsValidPlayerID(i) then
						local hero = PlayerResource:GetSelectedHeroEntity(i)
						if hero and hero:GetTeam() == team then
							BOUNTY_CUSTOM.player_count = BOUNTY_CUSTOM.player_count + 1
						end
					end
				end
			end

			BOUNTY_CUSTOM.player_number = BOUNTY_CUSTOM.player_number + 1

			if BOUNTY_CUSTOM.player_number == BOUNTY_CUSTOM.player_count then
				BOUNTY_CUSTOM.player_number = 0

				local k = GameRules:GetDOTATime( false, false )
				local gold = BOUNTY_CUSTOM.GOLD_BASE  +  BOUNTY_CUSTOM.GOLD_INC * k
				local xp = BOUNTY_CUSTOM.XP_BASE  +  BOUNTY_CUSTOM.XP_INC * k

				for i = 0, PlayerResource:GetPlayerCount() - 1 do
					if PlayerResource:IsValidPlayerID(i) then
						local hero = PlayerResource:GetSelectedHeroEntity(i)
						if hero and hero:GetTeam() == team then
							local gold_grant = math.floor(gold)
							local xp_grant = math.floor(xp)
							if i ~= kv.player_id_const then
								gold_grant = math.floor( gold / 2 )
								xp_grant = math.floor( xp / 2 )
							end
							hero:ModifyGold( gold_grant, false, 0 )
							hero:AddExperience( xp_grant, 0, false, true )

							for i2 = 0, PlayerResource:GetPlayerCount() - 1 do
								if PlayerResource:IsValidPlayerID(i2) then
									local hero2 = PlayerResource:GetSelectedHeroEntity(i2)
									if hero2 and hero2:GetTeam() == team then
										SendOverheadEventMessage( PlayerResource:GetPlayer(i2), OVERHEAD_ALERT_GOLD, hero, gold_grant, PlayerResource:GetPlayer( kv.player_id_const ) )
									end
								end
							end
						end
					end
				end
			end
		end
		kv.gold_bounty = 0
		return true
	end
	return true
end

function Filters:Order( kv )
	local unit = kv.units["0"] and EntIndexToHScript( kv.units["0"] )
	local ability = EntIndexToHScript( kv.entindex_ability ) 
	if unit and not unit:IsNull() then
		if unit:GetUnitName() == "npc_dota_courier" and unit.personal_owner and ability and ability:GetName() == "courier_return_stash_items" then
			ExecuteOrderFromTable{
				UnitIndex = unit:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = unit:FindAbilityByName("courier_return_to_base"):entindex(),
				Queue = kv.queue
			}
			return false
		end
	end
	if kv.queue == 0 then
        if ( not ( ability and not ability:IsNull() and ability.GetAbilityName ) or ability:GetAbilityName() ~= "courier_take_stash_and_transfer_items" ) and PlayerResource:GetSelectedHeroEntity( kv.issuer_player_id_const ) then
			local bIsAlienCourierSelected = false
			for _, unitID in pairs( kv.units ) do
				local unit = EntIndexToHScript(unitID)
				if unit:GetUnitName() == "npc_dota_courier" then
					if unit.personal_owner and unit.personal_owner ~= PlayerResource:GetSelectedHeroEntity( kv.issuer_player_id_const ) then
						bIsAlienCourierSelected = true
					end
				end
			end
			if bIsAlienCourierSelected then
				for _, unitID in pairs( kv.units ) do
					local unit = EntIndexToHScript(unitID)
					local b = true
					if unit:GetUnitName() == "npc_dota_courier" then
						if unit.personal_owner and unit.personal_owner ~= PlayerResource:GetSelectedHeroEntity( kv.issuer_player_id_const ) then
							b = false
						end
					end
					if b then
						ExecuteOrderFromTable{
							UnitIndex = unitID,
							OrderType = kv.order_type,
							TargetIndex = kv.entindex_target,
							AbilityIndex = kv.entindex_ability,
							Position = Vector( kv.position_x, kv.position_y, kv.position_z ),
							Queue = kv.queue
						}
					end
				end
				return false
			end
		end
		if kv.order_type == DOTA_UNIT_ORDER_PICKUP_RUNE then
			local rune = EntIndexToHScript( kv.entindex_target )
			if rune and IsRuneOverrded( GetRuneType(rune) ) then
				for _, unitID in pairs( kv.units ) do
					local unit = EntIndexToHScript(unitID)
					if unit and not unit:IsNull() and unit:IsRealHero() then
						if #( unit:GetOrigin() - rune:GetOrigin() ) > 128 then
							unit.rune_to_pickup = rune
							unit:SetThink( "RunePickupThink", unit, "RunePickupThink", 0.03 )
							kv.order_type = DOTA_UNIT_ORDER_MOVE_TO_POSITION
							local v = rune:GetOrigin()
							kv.position_x = v.x
							kv.position_y = v.y
							kv.position_z = v.z
							return true
						else
							OnPickupRuneC( unit, GetRuneType(rune) )
							rune:Kill()
						end
						return false
					end
				end
			end
		elseif ( kv.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or
				 kv.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or
				 kv.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or
				 kv.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET or
				 kv.order_type == DOTA_UNIT_ORDER_CAST_POSITION or
				 kv.order_type == DOTA_UNIT_ORDER_CAST_TARGET or
				 kv.order_type == DOTA_UNIT_ORDER_HOLD_POSITION or
				 kv.order_type == DOTA_UNIT_ORDER_DROP_ITEM or
				 kv.order_type == DOTA_UNIT_ORDER_GIVE_ITEM or
				 kv.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM or
				 kv.order_type == DOTA_UNIT_ORDER_STOP ) then

			for _, unitID in pairs( kv.units ) do
				local unit = EntIndexToHScript(unitID)
				if unit and not unit:IsNull() and unit.rune_to_pickup and not unit.rune_to_pickup:IsNull() then
					local bInterruptRunePickup = true
					local ability = EntIndexToHScript( kv.entindex_ability )
					if kv.entindex_ability ~= 0 and ability and math.floor( ability:GetBehavior() / DOTA_ABILITY_BEHAVIOR_IMMEDIATE ) % 2 == 1 then
						bInterruptRunePickup = false
					end
					if kv.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION and ( unit.rune_to_pickup:GetOrigin() - Vector( kv.position_x, kv.position_y, 0 ) ):Length2D() < 1 then
						bInterruptRunePickup = false
					end

					if bInterruptRunePickup then
						unit.rune_to_pickup = nil
					end
				end
			end
		end
	end
	local hero = PlayerResource:GetSelectedHeroEntity( kv.issuer_player_id_const )
	if hero and not hero:IsNull() then
		if ability and not ability:IsNull() and ability.GetAbilityName then
			if ability:GetAbilityName() == "courier_take_stash_and_transfer_items" then
				local personal_courier = PlayerPersonalCouriers[ kv.issuer_player_id_const ]
				if personal_courier and personal_courier:IsAlive() then
					kv.units["0"] = personal_courier:entindex()
					kv.entindex_ability = personal_courier:FindAbilityByName("courier_take_stash_and_transfer_items"):entindex()
				else
					for _, courier in pairs( Entities:FindAllByName("npc_dota_courier") ) do
						if courier:IsAlive() and courier.personal_owner == nil and courier:GetTeam() == hero:GetTeam() then
							kv.units["0"] = courier:entindex()
							kv.entindex_ability = courier:FindAbilityByName("courier_take_stash_and_transfer_items"):entindex()
							return true
						end
					end
                    return false	
				end
			end
		end
	end
	if kv.order_type == DOTA_UNIT_ORDER_PURCHASE_ITEM then
		if kv.entindex_ability == 10186 then
			if PersonalCouriersMaps[ GetMapName() ] then
				if PlayerPersonalCouriers[ kv.issuer_player_id_const ] ~= nil then
					return false
				else
					PlayerPersonalCouriers[ kv.issuer_player_id_const ] = false
				end
			else
				return false
			end
		end
	end
	return true
end

function Filters:Damage( kv )
	local ability = kv.entindex_inflictor_const and EntIndexToHScript( kv.entindex_inflictor_const )
	local victim = kv.entindex_victim_const	and EntIndexToHScript( kv.entindex_victim_const )
	if ability and victim then
		local k1 = ReflectorAbilities[ ability:GetName() ]
		local k2 = ReflectDamagePercentage[ victim:GetUnitName() ]
		if k1 and k2 then
			kv.damage = kv.damage * k1 * k2 / 10000
		end
	end
	return true
end