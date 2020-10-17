local _, Zero = ...

local module = Zero.Module('Items')

local MIN_ITEM_LEVEL = 800
local GRANTS_ARTIFACT_POWER = "Grants [,%d]+ Artifact Power"
local GAIN_ANCIENT_MANA = "Gain [,%d]+ Ancient Mana"
local ITEM_LEVEL = "Item Level (%d+)"

local tooltip = CreateFrame('GameTooltip', 'ZeroItemsScanToolTip', UIParent, 'GameTooltipTemplate')
local tooltip_lines = setmetatable({}, {
  __index = function(self, i)
    self[i] = _G['ZeroItemsScanToolTipTextLeft' .. i]
    return self[i]
  end
})

local function CheckItem(bag, slot)
  local is_soulbound, item_level
  GameTooltip_SetDefaultAnchor(tooltip, UIParent)
  tooltip:SetBagItem(bag, slot)
  for i = 1, tooltip:NumLines() do
    local text = tooltip_lines[i]:GetText()
    if text then
      if text:match(ITEM_SOULBOUND) then
        is_soulbound = true
      else
        local t = text:match(ITEM_LEVEL)
        if t then
          item_level = t
        end
      end
    end
  end
  tooltip:Hide()
  return is_soulbound,item_level
end

local function GetMark(button)
  if not button.mark then
    button.mark = button:CreateFontString(button:GetName() .. 'Mark', 'OVERLAY', 'NumberFontNormal')
    button.mark:SetPoint('TOPRIGHT', 0, 0)
    button.mark:SetText('●')
  end
  return button.mark
end

local function ShowItemLevel(button, level)
  if not button.item_level then
    button.item_level = button:CreateFontString(button:GetName() .. 'ItemLevel', 'OVERLAY', 'NumberFontNormalSmall')
    button.item_level:SetPoint('BOTTOMLEFT', 4, 4)
  end
  button.item_level:SetText(level)
  button.item_level:Show()
end

local function HideItemLevel(button)
  if button.item_level then
    button.item_level:Hide()
  end
end

local function ShowMark(button, r, g, b)
  local mark = GetMark(button)
  mark:SetVertexColor(r, g, b, 1)
  mark:Show()
end

local function HideMark(button)
  if button.mark then
    button.mark:Hide()
  end
end

local function GetItemLevel(bag, slot)
  local item_id = GetContainerItemID(bag, slot)
  if item_id then
    local _, _, _, item_level, _, _, _, _, itemEquipLoc = GetItemInfo(item_id)
    return itemEquipLoc ~= '' and item_level
  end
end

local function UpdateItemButton(button)
  local bag = button:GetParent():GetID()
  local slot = button:GetID()

  local is_soulbound, item_level = CheckItem(bag, slot)
  if C_NewItems.IsNewItem(bag, slot) then
    ShowMark(button, 0, 1, 0)
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
  for i = 1, frame.size do
    UpdateItemButton(_G[name .. 'Item' .. i])
  end
end

function module:UpdateBag(bag)
  for i = 1, NUM_CONTAINER_FRAMES do
    local frame = _G['ContainerFrame' .. i]
    if frame:GetID() == bag and frame:IsShown() then
      module:UpdateContainerFrame(frame)
    end
  end
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
