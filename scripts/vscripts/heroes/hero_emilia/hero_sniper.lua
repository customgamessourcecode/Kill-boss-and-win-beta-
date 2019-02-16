function GetlPoints( keys)
        -- 从keys中获取数据，这里为什么能有keys.Radius和keys.Count呢？        -- 请回到KV文件中看调用这个函数的位置。
        local radius = keys.radius        
        local caster = keys.caster
        local ability = keys.ability
        local point = keys.target_points[1]
        local caster_location = caster:GetAbsOrigin()
        caster.axe_range = (point - caster_location):Length()
end
function ReimuPoints( keys)
        -- 从keys中获取数据，这里为什么能有keys.Radius和keys.Count呢？        -- 请回到KV文件中看调用这个函数的位置。
         local radius = keys.Radius or 400        local count = keys.Count
        local caster = keys.caster
        local angle = 60 / count
        local angle_count = math.floor(count / 2) -- Number of axes for each direction
        -- 之后我们获取施法者，也就是火枪面向的单位向量，和他的原点
        -- 之后把他的面向单位向量*2000，乘出来的结果就是英雄所面向的
        -- 2000距离的向量，再加上原点的位置，那么得到的就是英雄前方2000的那个点。
        local caster_fv = caster:GetForwardVector()
        local caster_origin = caster:GetOrigin()
        local center = caster_origin + caster_fv * caster.axe_range
	local angle_left = QAngle(0, angle, 0) -- Rotation angle to the left
	local angle_right = QAngle(0, -angle, 0) -- Rotation angle to the right
        local renumber = 0 -- Rotation angle to the right
        print("castRange =",caster.axe_range)
        print("center",center)
        -- 我们要做的散弹是发射Count个弹片，所以我们就进行Count次循环
        -- 之后在center，也就是我们上面所计算出来的，英雄面前2000距离的位置
        -- 周围radius距离里面随机一个点，并把他放到result这个表里面去
	local target_point = center
	local new_angle = QAngle(0,0,0) -- Rotation angle
        local result = {}
	-- Create axes that spread to the right
	for i = 1, count do
		-- Angle calculation		
		
                 if i == 1 then
                 caster.vec = center
		-- Calculate the new position after applying the angle and then get the direction of it	
                elseif count % 2 ~= 0 then
                new_angle.y = angle_right.y * (i - 1) / 2	
		caster.vec = RotatePosition(caster_origin, new_angle, center)
                else
                new_angle.y = angle_left.y * i / 2 
                caster.vec = RotatePosition(caster_origin, new_angle, center)
                end
                table.insert(result,caster.vec)
	end
        PrintTable(table.insert)
      --[[ 
          for i = 1, count do
                -- 这里先使用一个RandomFloat来获取一个从0到半径值的随机半径
                --  之后用RandomVector函数来在这个半径的圆周上获取随机一个点，
                -- 这样最后得到的vec就是那么一个圆形范围里面的随机一个点了。
                local random = RandomFloat(0, radius)
                local vec = center + RandomVector(random)
                table.insert(result,vec)
        end
        PrintTable(table.insert)
        ]]
        -- 之后我们把这个地点列表返回给KV
        -- 举一反三的话，我们也可以做出比如说，向周围三百六十度，每间隔60度的方向各释放一个线性投射物的东西
        -- 这个大家自己试验就好
        return result
end

function GenerateShrapnelPoints( keys)
        -- 从keys中获取数据，这里为什么能有keys.Radius和keys.Count呢？        -- 请回到KV文件中看调用这个函数的位置。
        local radius = keys.Radius or 400        local count = keys.Count
        local caster = keys.caster
 
        -- 之后我们获取施法者，也就是火枪面向的单位向量，和他的原点
        -- 之后把他的面向单位向量*2000，乘出来的结果就是英雄所面向的
        -- 2000距离的向量，再加上原点的位置，那么得到的就是英雄前方2000的那个点。
        local caster_fv = caster:GetForwardVector()
        local caster_origin = caster:GetOrigin()
        local center = caster_origin + caster_fv * 2000
        -- 我们要做的散弹是发射Count个弹片，所以我们就进行Count次循环
        -- 之后在center，也就是我们上面所计算出来的，英雄面前2000距离的位置
        -- 周围radius距离里面随机一个点，并把他放到result这个表里面去
        local result = {}
        for i = 1, count do
                -- 这里先使用一个RandomFloat来获取一个从0到半径值的随机半径
                --  之后用RandomVector函数来在这个半径的圆周上获取随机一个点，
                -- 这样最后得到的vec就是那么一个圆形范围里面的随机一个点了。
                local random = RandomFloat(0, radius)
                local vec = center + RandomVector(random)
                table.insert(result,vec)
        end
        -- 之后我们把这个地点列表返回给KV
        -- 举一反三的话，我们也可以做出比如说，向周围三百六十度，每间隔60度的方向各释放一个线性投射物的东西
        -- 这个大家自己试验就好
        return result
end


function OnShrapnelStart(keys)
        local caster = keys.caster
        local point = keys.target_points[1]
        local ability = keys.ability
        if not ( caster and point and ability ) then return end
        CreateDummyAndCastAbilityAtPosition(caster, "sniper_shrapnel", ability:GetLevel(), point, 30, false)
end

function CreateDummyAndCastAbilityAtPosition(owner, ability_name, ability_level, position, release_delay, scepter)
        local dummy = CreateUnitByNameAsync("npc_dummy", owner:GetOrigin(), false, owner, owner, owner:GetTeam(),
                function(unit)
                        print("unit created")
                        unit:AddAbility(ability_name)
                        unit:SetForwardVector((position - owner:GetOrigin()):Normalized())
                        local ability = unit:FindAbilityByName(ability_name)
                        ability:SetLevel(ability_level)
                        ability:SetOverrideCastPoint(0)
 
                        if scepter then
                                local item = CreateItem("item_ultimate_scepter", unit, unit)        
                                unit:AddItem(item)
                        end
 
                        unit:SetContextThink(DoUniqueString("cast_ability"),
                                function()
                                        unit:CastAbilityOnPosition(position, ability, owner:GetPlayerID())
                                end,
                        0)
                        unit:SetContextThink(DoUniqueString("Remove_Self"),function() print("removing dummy units", release_delay) unit:RemoveSelf() end, release_delay)
 
                        return unit
                end
        )
end
