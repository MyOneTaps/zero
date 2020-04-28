local _, Zero = ...

local module = Zero.Module('Repair')

function module:OnPlayerLogin()
  self:RegisterEvent('MERCHANT_SHOW', function()
    if not CanMerchantRepair() then return end
    local cost, possible = GetRepairAllCost()
    if cost == 0 then return end
    if possible then
      RepairAllItems()
      print('Your items have been repaired for: ' .. Zero.FormatMoney(cost))
    else
      print('You do not have enough money to repair.')
    end
  end)
end
