local _, Zero = ...

local module = Zero.Module('Bank')

function module:OnPlayerLogin()
  self:RegisterEvent('BANKFRAME_OPENED', ToggleAllBags)
end
