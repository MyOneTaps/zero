local _, Zero = ...

local module = Zero.Module('NamePlates')

function module:OnLoad()
  self:RegisterEvent('PLAYER_REGEN_ENABLED', function()
    SetCVar('nameplateShowEnemies', 0)
  end)
  self:RegisterEvent('PLAYER_REGEN_DISABLED', function()
    SetCVar('nameplateShowEnemies', 1)
  end)
end
