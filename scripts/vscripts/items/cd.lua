function CD(event)
if event.ability:IsCooldownReady() then
	event.ability:StartCooldown(event.ability:GetCooldown(event.ability:GetLevel()))			
	end
end