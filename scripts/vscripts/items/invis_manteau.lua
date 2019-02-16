--[[ ============================================================================================================
	Author: Rook
	Date: February 3, 2015
	Called when Shadow Blade is cast.  Turns the caster invisible after a delay.
	Additional parameters: keys.WindwalkFadeTime
================================================================================================================= ]]
function item_invis_sword_datadriven_on_spell_start(keys)
	keys.caster:EmitSound("DOTA_Item.InvisibilitySword.Activate")
	
	--Start Shadow Blade's effect after the fade delay.
	Timers:CreateTimer({
		endTime = keys.WindwalkFadeTime,
		callback = function()
			keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_invis_sword_datadriven_active", nil)
		end
	})
end