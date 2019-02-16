if item_gold_transfer_2 == nil then item_gold_transfer_2 = class({}) end

function item_gold_transfer_2:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local gold = self:GetSpecialValueFor("gold")

	if target:IsHero() and target:IsRealHero() then
        if target == caster then gold = gold /2 end
    	target:ModifyGold(gold, false, 0)
    	SendOverheadEventMessage( target,  OVERHEAD_ALERT_GOLD , target, gold, nil )
    	if self then
    		caster:RemoveItem(self)
    	end
    end
end