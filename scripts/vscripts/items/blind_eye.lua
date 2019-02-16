function manaspent(event)
local caster = event.caster
local ability = event.ability
local manaspent = ability:GetManaCost(-1)
print(manaspent)
caster:AddExperience(55, false, false)
end