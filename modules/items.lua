local _, Zero = ...

local module = Zero.Module('Items')

local EQUIPMENT_SETS = "Equipment Sets:"
local MIN_ITEM_QUALITY = Enum.ItemQuality.Uncommon

local marks = {}
local item_levels = {}

local tooltip = CreateFrame('GameTooltip', 'ZeroItemsScanToolTip', UIParent, 'GameTooltipTemplate')
tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
local tooltip_lines = setmetatable({}, {
  __index = function(self, i)
    self[i] = _G['ZeroItemsScanToolTipTextLeft' .. i]
    return self[i]
  end
})

local function IsBound(item)
  local location = item:GetItemLocation()
  ItemLocation:ApplyLocationToTooltip(location, tooltip)
  for i = 1, tooltip:NumLines() do
    local text = tooltip_lines[i]:GetText()
    if text then
      if text:match(ITEM_SOULBOUND) then
        return true
      end
    end
  end
  tooltip:Hide()
  return false
end

local function GetUniqueID(button)
  local bag_id, id = button:GetBagID(), button:GetID()
  return bag_id * 1000 + id
end

local function GetMarkDecoration(button)
  local id = GetUniqueID(button)
  if not marks[id] then
    marks[id] = button:CreateFontString(button:GetName() .. 'Mark', 'OVERLAY', 'NumberFontNormalLarge')
    marks[id]:SetPoint('TOPRIGHT', 0, 0)
    marks[id]:SetText('●')
  end
  return marks[id]
end

local function GetItemLevelDecoration(button)
  local id = GetUniqueID(button)
  if not item_levels[id] then
    item_levels[id] = button:CreateFontString(button:GetName() .. 'ItemLevel', 'OVERLAY', 'NumberFontNormalSmall')
    item_levels[id]:SetPoint('BOTTOMLEFT', 4, 4)
  end
  return item_levels[id]
end

local function ShowItemLevel(button, level)
  local item_level = GetItemLevelDecoration(button)
  item_level:SetText(level)
  item_level:Show()
end

local function HideItemLevel(button)
  local id = GetUniqueID(button)
  if item_levels[id] then
    item_levels[id]:Hide()
  end
end

local function ShowMark(button, r, g, b)
  local mark = GetMarkDecoration(button)
  mark:SetVertexColor(r, g, b, 1)
  mark:Show()
end

local function HideMark(button)
  local id = GetUniqueID(button)
  if marks[id] then
    marks[id]:Hide()
  end
end

local function GetItemLevel(bag, slot)
  local item_id = GetContainerItemID(bag, slot)
  if item_id then
    local _, _, _, item_level, _, _, _, _, item_equip_loc = GetItemInfo(item_id)
    return item_equip_loc ~= '' and item_level
  end
end

local function ShouldShowOnItem(item)
  local quality = item:GetItemQuality()
  if quality < MIN_ITEM_QUALITY then
      return false
  end
  local _, _, _, _, _, item_class, _ = GetItemInfoInstant(item:GetItemID())
  return item_class == Enum.ItemClass.Weapon or item_class == Enum.ItemClass.Armor
end

local function UpdateContainerButton(button)
  HideMark(button)
  HideItemLevel(button)

  local slot, bag = button:GetSlotAndBagID()
  local item = Item:CreateFromBagAndSlot(bag, slot)

  if item:IsItemEmpty() then return end

  item:ContinueOnItemLoad(function()
    if not ShouldShowOnItem(item) then return end

    local item_level = item:GetCurrentItemLevel()
    ShowItemLevel(button, item_level)
    if C_NewItems.IsNewItem(bag, slot) then
      ShowMark(button, 0, 1, 0)
    elseif C_Container.GetContainerItemEquipmentSetInfo(bag, slot) then
      ShowMark(button, 0.5, 1, 1)
    elseif IsBound(item) then
      ShowMark(button, 1, 0.5, 0)
    end
  end)
end

local function UpdateContainerFrame(frame)
  for _, button in frame:EnumerateValidItems() do
      UpdateContainerButton(button)
  end
end

function module:OnPlayerLogin()
  hooksecurefunc(ContainerFrameCombinedBags, 'UpdateItems', UpdateContainerFrame)
  for _, frame in ipairs(UIParent.ContainerFrames) do
    hooksecurefunc(frame, 'UpdateItems', UpdateContainerFrame)
  end
end
