modifier_life_catcher_passive_exp_cd = class({})
--------------------------------------------------------------------------------

function modifier_life_catcher_passive_exp_cd:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_life_catcher_passive_exp_cd:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_life_catcher_passive_exp_cd:DestroyOnExpire()
	return true
end

--------------------------------------------------------------------------------