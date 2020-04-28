local _, Zero = ...

local module = Zero.Module('Resurrect')

function module:OnPlayerLogin()
  self:RegisterEvent('RESURRECT_REQUEST', function()
    StaticPopup_Hide('RESURRECT_REQUEST')
    AcceptResurrect()
  end)
end
