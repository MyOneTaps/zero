local _, Zero = ...

local module = Zero.Module('Loot')

local function LootAll()
  local numberOfItems = GetNumLootItems()
  if numberOfItems == 0 then
    CloseLoot()
  else
    for slot = 1, numberOfItems do
      LootSlot(slot)
      ConfirmLootSlot(slot)
    end
  end
end

local function ConfirmLoot(self, id, roll)
  StaticPopup_Hide('CONFIRM_LOOT_ROLL')
  ConfirmLootRoll(id, roll)
end

local function ConfirmDisenchantRoll(self, id, roll)
  StaticPopup_Hide('CONFIRM_DISENCHANT_ROLL')
  ConfirmLootRoll(id, roll)
end

function module:OnPlayerLogin()
  self:RegisterEvent('LOOT_OPENED', LootAll)
  self:RegisterEvent('CONFIRM_LOOT_ROLL', ConfirmLoot)
  self:RegisterEvent('CONFIRM_DISENCHANT_ROLL', ConfirmDisenchantRoll)
end
