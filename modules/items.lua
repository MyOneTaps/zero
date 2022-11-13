local _, Zero = ...

local module = Zero.Module('Items')

local MIN_ITEM_LEVEL = 800
local GRANTS_ARTIFACT_POWER = "Grants [,%d]+ Artifact Power"
local GAIN_ANCIENT_MANA = "Gain [,%d]+ Ancient Mana"
local ITEM_LEVEL = "Item Level (%d+)"
local EQUIPMENT_SETS = "Equipment Sets:"

local marks = {}
local item_levels = {}

local tooltip = CreateFrame('GameTooltip', 'ZeroItemsScanToolTip', UIParent, 'GameTooltipTemplate')
local tooltip_lines = setmetatable({}, {
  __index = function(self, i)
    self[i] = _G['ZeroItemsScanToolTipTextLeft' .. i]
    return self[i]
  end
})

local function CheckItem(bag, slot)
  local is_soulbound, item_level, is_in_equipment_set
  GameTooltip_SetDefaultAnchor(tooltip, UIParent)
  tooltip:SetBagItem(bag, slot)
  for i = 1, tooltip:NumLines() do
    local text = tooltip_lines[i]:GetText()
    if text then
      if text:match(ITEM_SOULBOUND) then
        is_soulbound = true
      elseif text:match(EQUIPMENT_SETS) then
        is_in_equipment_set = true
      else
        local t = text:match(ITEM_LEVEL)
        if t then
          item_level = t
        end
      end
    end
  end
  tooltip:Hide()
  return is_soulbound,item_level, is_in_equipment_set
end

local function GetMarkDecoration(button)
  local id = button:GetID()
  if not marks[id] then
    marks[id] = button:CreateFontString(button:GetName() .. 'Mark', 'OVERLAY', 'NumberFontNormal')
    marks[id]:SetPoint('TOPRIGHT', 0, 0)
    marks[id]:SetText('●')
  end
  return marks[id]
end

local function GetItemLevelDecoration(button)
  local id = button:GetID()
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
  local id = button:GetID()
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
  local id = button:GetID()
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

local function UpdateItemButton(button)
  local slot, bag = button:GetSlotAndBagID()

  local is_soulbound, item_level, is_in_equipment_set = CheckItem(bag, slot)
  if C_NewItems.IsNewItem(bag, slot) then
    ShowMark(button, 0, 1, 0)
  elseif is_in_equipment_set then
    ShowMark(button, 0.5, 1, 1)
  elseif is_soulbound then
    ShowMark(button, 1, 0.5, 0)
  else
    HideMark(button)
  end

  if item_level then
    ShowItemLevel(button, item_level)
  else
    HideItemLevel(button)
  end
end

function module:UpdateContainerFrame(frame)
  local name = frame:GetName()
  local numBagSlots = ContainerFrame_GetContainerNumSlots(frame:GetID())
  for i = 1, numBagSlots do
    UpdateItemButton(frame.Items[i])
  end
end

function module:UpdateBag(bag)
  local containerFrame = UIParent.ContainerFrames[bag + 1]
  module:UpdateContainerFrame(containerFrame)
end

local function ContainerFrame_OnShow(frame)
  module:UpdateContainerFrame(frame)
end

local function ContainerFrame_OnHide(frame)
  local bag = frame:GetID()
  for i = 1, frame.size do
     C_NewItems.RemoveNewItem(bag, i)
  end
end

function module:BAG_UPDATE(bag)
  self.updatedBags[bag] = true
end

function module:BAG_UPDATE_DELAYED()
  for bag in pairs(self.updatedBags) do
    self:UpdateBag(bag)
  end
  wipe(self.updatedBags)
end

function module:OnPlayerLogin()
  self.updatedBags = {}
  self:RegisterEvent('BAG_UPDATE')
  self:RegisterEvent('BAG_UPDATE_DELAYED')
  hooksecurefunc('ContainerFrame_OnShow', ContainerFrame_OnShow)
  hooksecurefunc('ContainerFrame_OnHide', ContainerFrame_OnHide)
end
