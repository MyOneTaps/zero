local _, Zero = ...

local module = Zero.Module('AutoRoll')

function module:OnPlayerLogin()
  self:RegisterEvent('START_LOOT_ROLL', function(_, id)
    if not id then return end
    local _, _, _, quality, bindOnPickUp, _, canGreed, canDisenchant = GetLootRollItemInfo(id)
    if quality == 2 and canGreed and not bindOnPickUp then
      RollOnLoot(id, canDisenchant and 3 or 2)
    end
  end)
end
