local _, Zero = ...

local module = Zero.Module('Items')

local MIN_ILEVEL = 800
local GRANTS_ARTIFACT_POWER = "Grants [,%d]+ Artifact Power"
local GAIN_ANCIENT_MANA = "Gain [,%d]+ Ancient Mana"
local ITEM_LEVEL = "Item Level (%d+)"
local OBLITERATABLE = "Obliteratable"

local tooltip = CreateFrame('GameTooltip', 'ZeroItemsScanToolTip', UIParent, 'GameTooltipTemplate')
local tooltipLines = setmetatable({}, {
	__index = function(self, i)
		self[i] = _G['ZeroItemsScanToolTipTextLeft' .. i]
		return self[i]
	end
})

local function CheckItem(bag, slot)
  local is_soulbound, grants_ap, gain_ac, ilevel, obliteratable
	GameTooltip_SetDefaultAnchor(tooltip, UIParent)
	tooltip:SetBagItem(bag, slot)
	for i = 1, tooltip:NumLines() do
		local text = tooltipLines[i]:GetText()
		if text then
      if text:match(ITEM_SOULBOUND) then
        is_soulbound = true
      elseif text:match(GRANTS_ARTIFACT_POWER) then
        grants_ap = true
      elseif text:match(GAIN_ANCIENT_MANA) then
        gain_ac = true
      elseif text:match(OBLITERATABLE) then
        obliteratable = true
      else
        local t = text:match(ITEM_LEVEL)
        if t then
          ilevel = t
        end
      end
		end
	end
	tooltip:Hide()
	return is_soulbound, grants_ap, gain_ac, ilevel, obliteratable
end

local function GetMark(button, id)
  if not button.marks then
    button.marks = {}
  end
  if not button.marks[id] then
    button.marks[id] = button:CreateFontString(button:GetName() .. 'Mark' .. id, 'OVERLAY', 'NumberFontNormal')
    button.marks[id]:SetText('●')
  end
  return button.marks[id]
end

local function ShowItemLevel(button, level)
  if not button.ilevel then
    button.ilevel = button:CreateFontString(button:GetName() .. 'ItemLevel', 'OVERLAY', 'NumberFontNormalSmall')
    button.ilevel:SetPoint('BOTTOMLEFT', 4, 4)
  end
  button.ilevel:SetText(level)
  button.ilevel:Show()
end

local function HideItemLevel(button)
  if button.ilevel then
    button.ilevel:Hide()
  end
end

local function HideMarks(button, from)
  if button.marks then
    local i = from
    while button.marks[i] do
      button.marks[i]:Hide()
      i = i + 1
    end
  end
end

local function GetItemLevel(bag, slot)
  local item_id = GetContainerItemID(bag, slot)
  if item_id then
    local _, _, _, ilevel, _, _, _, _, itemEquipLoc = GetItemInfo(item_id)
    return itemEquipLoc ~= '' and ilevel
  end
end

local function UpdateItemButton(button)
  local bag = button:GetParent():GetID()
  local slot = button:GetID()

  local markCount = 0
  local function ShowMark(r, g, b)
    local mark = GetMark(button, markCount)
    mark:SetPoint('TOPRIGHT', 0, markCount * -8)
    mark:SetVertexColor(r, g, b, 1)
    mark:Show()
    markCount = markCount + 1
  end

  if C_NewItems.IsNewItem(bag, slot) then
    ShowMark(0, 1, 0)
  end
  local is_soulbound, grants_ap, gain_ac, ilevel, obliteratable = CheckItem(bag, slot)
  if is_soulbound then
    ShowMark(1, 0.5, 0)
  end
  if grants_ap then
    ShowMark(0, 0.5, 1)
  end
  if gain_ac then
    ShowMark(0, 1, 1)
  end
  if obliteratable then
    ShowMark(0, 1, 0.5)
  end

  HideMarks(button, markCount)

  if ilevel then
    ShowItemLevel(button, ilevel)
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
