local _, Zero = ...

local module = Zero.Module('Duels')

function module:OnPlayerLogin()
  self:RegisterEvent('DUEL_REQUESTED', function()
    HideUIPanel('DUEL_REQUESTED')
    CancelDuel()
  end)
end
