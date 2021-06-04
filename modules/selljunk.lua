local _, Zero = ...

local module = Zero.Module('SellJunk')

local merchantFrameShown = false

local function GetJunk()
  local items = {}
  for bag = 0, 4 do
    for slot = 1, GetContainerNumSlots(bag) do
      local itemLink = GetContainerItemLink(bag, slot)
      if itemLink then
        local _, _, quality, _, _, _, _, _, _, _, price = GetItemInfo(itemLink)
        local _, count = GetContainerItemInfo(bag, slot)
        if quality == 0 then
          items[#items+1] = {
            bag = bag,
            slot = slot,
            count = count,
            price = price,
          }
        end
      end
    end
  end
  return items
end

local function PrintJunkValue(data)
  if data.totalPrice > 0 then
    print('Sold gray items for: ' .. Zero.FormatMoney(data.totalPrice))
  end
end

local function SellJunk(data)
  if #data.items > 0 then
    local item = table.remove(data.items, #data.items)
    UseContainerItem(item.bag, item.slot)
    data.totalPrice = data.totalPrice + item.count * item.price
  end

  return #data.items > 0
end

function module:OnPlayerLogin()
  MerchantFrame:HookScript('OnShow', function()
    merchantFrameShown = true
    local data = {
      items = GetJunk(),
      totalPrice = 0
    }
    self.timer = self:ScheduleTimer(0.1, function()
      return SellJunk(data)
    end, function()
      PrintJunkValue(data)
    end)
  end)
  MerchantFrame:HookScript('OnHide', function()
    merchantFrameShown = false
    if self.timer then
      self.timer.cancelled = true
      self.timer = nil
    end
  end)
end
