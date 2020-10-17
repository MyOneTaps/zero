local _, Zero = ...

local module = Zero.Module('SellJunk')

local selling = false
local function SellJunk(self)
  if selling then return end
  selling = true
  self:StartCoroutine(function()
    local c = 0
    local sold = 0
    for bag = 0, 4 do
      for slot = 1, GetContainerNumSlots(bag) do
        local itemLink = GetContainerItemLink(bag, slot)
        if itemLink then
          local _, _, quality, _, _, _, _, _, _, _, price = GetItemInfo(itemLink)
          local _, count = GetContainerItemInfo(bag, slot)
          if quality == 0 and price ~= 0 then
            c = c + price * count
            UseContainerItem(bag, slot)
            sold = sold + 1
          end
          if sold == 4 then
            coroutine.yield()
          end
        end
      end
    end
    if c > 0 then
      print('Sold gray items for: ' .. Zero.FormatMoney(c))
    end
    selling = false
  end)
end

function module:OnPlayerLogin()
  self:RegisterEvent('MERCHANT_SHOW', SellJunk)
end
