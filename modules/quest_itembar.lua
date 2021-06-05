local _, Zero = ...

local UPDATE_DELAY = 0.25

local ANCHOR = { 'BOTTOMLEFT', 'ChatFrame3', 'TOPLEFT', 24, 24 }
local BUTTONS_PER_ROW = 6
local AUTO_KEYBIND_KEY = 'BUTTON4'
local BUTTON_SIZE = 30

local module = Zero.Module('QuestItemBar')

local frame = CreateFrame('Frame')
local questItems = {}
local questItemNames = {}
local activeQuestItems = {}
local usableQuestItems = {}
local startsQuestItems = {}

local tooltip = CreateFrame('GameTooltip', 'QuestItemBarScanToolTip', UIParent, 'GameTooltipTemplate')
local tooltipLines = setmetatable({}, {
  __index = function(self, i)
    self[i] = _G['QuestItemBarScanToolTipTextLeft' .. i]
    return self[i]
  end
})

local links = setmetatable({}, {__mode = 'v'})
local function IsStartQuestItem(itemID)
  GameTooltip_SetDefaultAnchor(tooltip, UIParent)
  local link = links[itemID]
  if not link then
    link = ('item:%d:0:0:0:0:0:0:0'):format(itemID)
    links[itemID] = link
  end
  tooltip:SetHyperlink(link)
  for i = 1, tooltip:NumLines() do
    local text = tooltipLines[i]:GetText()
    if text and text:match(ITEM_STARTS_QUEST) then
      tooltip:Hide()
      return true
    end
  end
  tooltip:Hide()
  return false
end

local function IsQuestItem(itemID)
  local _, _, _, _, _, class, subclass = GetItemInfo(itemID)
  return class == 'Quest' or subclass == 'Quest'
end

local function ProcessItem(bag, slot)
  local itemID = GetContainerItemID(bag, slot)
  if not itemID or questItems[itemID] then return end

  local isQuest, questID, isActive = GetContainerItemQuestInfo(bag, slot)
  if isQuest or IsQuestItem(itemID) then
    questItems[itemID] = true
    local itemSpell = GetItemSpell(itemID)
    if questID or itemSpell then
      usableQuestItems[itemID] = true
    end
    startsQuestItems[itemID] = questID
    activeQuestItems[itemID] = isActive
  elseif IsStartQuestItem(itemID) then
    questItems[itemID] = true
    usableQuestItems[itemID] = true
    startsQuestItems[itemID] = true
  end
  if questItems[itemID] then
    questItemNames[itemID] = GetItemInfo(itemID)
  end
end

local function ScanBag(bag)
  local slots = GetContainerNumSlots(bag)
  if not slots then return end
  for slot = 1, slots do
    ProcessItem(bag, slot)
  end
end

local function ScanBags()
  for bag = 0, NUM_BAG_SLOTS do
    ScanBag(bag)
  end
end

local ITEM_ID_PATTERN = 'item:(%-?%d+):%-?%d+:%-?%d+:%-?%d+:%-?%d+:%-?%d+:%-?%d+:%-?%d+:%-?%d+'
local function GetIDFromLink(link)
  if not link then return end
  if type(link) == 'number' then
    return link
  end
  local id = link:match(ITEM_ID_PATTERN)
  if not id then
    id = link
  end
  return tonumber(id)
end

local function ProcessQuest(questIndex)
  local itemLink = GetQuestLogSpecialItemInfo(questIndex)
  if not itemLink then return end
  local itemID = GetIDFromLink(itemLink)
    if not itemID then return end
  questItems[itemID] = true
  usableQuestItems[itemID] = true
  activeQuestItems[itemID] = true
end

local function ScanQuestLog()
  local numShownEntries, numQuests = C_QuestLog.GetNumQuestLogEntries()
  for questIndex = 1, numShownEntries do
    ProcessQuest(questIndex)
  end
end

local function ScanItems()

  wipe(questItems)
  wipe(questItemNames)
  wipe(activeQuestItems)
  wipe(usableQuestItems)
  wipe(startsQuestItems)

  ScanBags()
  ScanQuestLog()

  module:UpdateQuestItemBar()
end

local timeSinceLastUpdate = 0
local function ItemScanner_OnUpdate(frame, elapsed)
  timeSinceLastUpdate = timeSinceLastUpdate + elapsed
  if timeSinceLastUpdate > UPDATE_DELAY then
        frame:SetScript('OnUpdate', nil)
        module:SafeInvoke(ScanItems)
    end
end

local keyboundItemID = nil

function module:ClearKeyBinding()
  for i, button in ipairs(self.buttons) do
    button.hotkey:Hide()
  end
  SetBinding(AUTO_KEYBIND_KEY)
end

function module:SetKeyBinding(button)
  if InCombatLockdown() then return end
  if not button then return end
  if not keyboundItemID or not usableQuestItems[keyboundItemID] then return end

  self:ClearKeyBinding()

  local key = AUTO_KEYBIND_KEY
  SetBindingClick(key, button:GetName(), 'LeftButton')
  key = key:gsub('ALT%-', 'A')
  key = key:gsub('CTRL%-', 'C')
  key = key:gsub('SHIFT%-', 'S')
  key = key:gsub('BUTTON', 'B')
  button.hotkey:SetText(key)
  button.hotkey:Show()
end

local function Button_OnEnter(self)
  if GetCVar('UberTooltips') == '1' then
    GameTooltip_SetDefaultAnchor(GameTooltip, self)
  else
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
  end
  GameTooltip:SetHyperlink(self:GetAttribute('item'))
  GameTooltip:Show()
end

local function Button_OnLeave(self)
  GameTooltip:Hide()
end

local function Button_OnClick(self)
  if self.itemLink == keyboundItemID then return end
  keyboundItemID = self.itemLink
  module:SetKeyBinding(self)
end

function CreateButton(index)

  local name = ('QuestItemBarButton%d'):format(index)
  local button = CreateFrame('Button', name, UIParent, 'SecureActionButtonTemplate')

  button:SetSize(BUTTON_SIZE, BUTTON_SIZE)

  button.icon = button:CreateTexture(name .. 'Icon', 'BACKGROUND')
  button.icon:SetAllPoints()

  button.flash = button:CreateTexture(name .. 'Flash', 'ARTWORK', nil, 1)
  button.flash:Hide()
  button.flash:SetTexture([[Interface\Buttons\UI-QuickslotRed]])

  button.hotkey = button:CreateFontString(name .. 'Hotkey', 'ARTWORK', 'NumberFontNormalSmallGray', 2)
  button.hotkey:SetSize(BUTTON_SIZE, 10)
  button.hotkey:SetJustifyH('RIGHT')
  button.hotkey:SetPoint('TOPLEFT', 1, -3)

  button.count = button:CreateFontString(name .. 'Count', 'ARTWORK', 'NumberFontNormal', 2)
  button.count:SetJustifyH('RIGHT')
  button.count:SetPoint('BOTTOMRIGHT', -2, 2)

  -- button.border = button:CreateTexture(name .. 'Border', 'OVERLAY')
  -- button.border:SetTexture([[Interface\Buttons\UI-Quickslot2]])
  -- button.border:Show()
  -- button.border:SetPoint('TOPLEFT', -15, 15)
  -- button.border:SetPoint('BOTTOMRIGHT', 15, -15)
  -- button.border:SetVertexColor(1, 1, 1, 0.7)

  button.cooldown = CreateFrame('Cooldown', name .. 'Cooldown', button, 'CooldownFrameTemplate')
  button.cooldown:SetSize(BUTTON_SIZE, BUTTON_SIZE)
  button.cooldown:SetPoint('CENTER', 0, -1)
  button.cooldown:SetSwipeColor(1, 1, 1, 0.8)

  button.questMark = button:CreateTexture(name..'QuestMark', 'OVERLAY', nil, 1)
  button.questMark:SetTexture(TEXTURE_ITEM_QUEST_BANG);
  button.questMark:Hide()
  button.questMark:SetSize(BUTTON_SIZE, BUTTON_SIZE)
  button.questMark:SetPoint('TOP', 0, 0)

  button:SetScript('OnEnter', Button_OnEnter)
  button:SetScript('OnLeave', Button_OnLeave)
  button:HookScript('OnClick', Button_OnClick)

  return button
end

local function CreateButtons()
  local buttons = {}
  for i = 1, 12 do
    buttons[i] = CreateButton(i)
    if i == 1 then
      buttons[i]:SetPoint(unpack(ANCHOR))
    elseif i % BUTTONS_PER_ROW == 1 then
      buttons[i]:SetPoint('BOTTOM', buttons[i - BUTTONS_PER_ROW], 'TOP', 0, 2)
    else
      buttons[i]:SetPoint('LEFT', buttons[i - 1], 'RIGHT', -2, 0)
    end
  end
  return buttons
end

function module:UpdateButton(button, itemID)

  button.icon:SetTexture(GetItemIcon(itemID))
  local count = GetItemCount(itemID)
  if count and count > 1 then
     button.count:SetText(count)
  else
    button.count:SetText('')
  end

  button:SetAttribute('type*','item')
  button:SetAttribute('item', ('item:%d:0:0:0:0:0:0:0'):format(itemID))

  if startsQuestItems[itemID] and not activeQuestItems[itemID] then
    button.questMark:Show()
  else
    button.questMark:Hide()
  end

  button.itemLink = itemID

  if itemID == keyboundItemID then
    self:SetKeyBinding(button)
  end
  button:Show()
end

function module:UpdateQuestItemBar()

  local function sortedkeys(t)
    local keys = {}
    for key in pairs(t) do
      keys[#keys + 1] = key
    end

    table.sort(keys, function(itemID1, itemID2)
      local name1 = questItemNames[itemID1] or ''
      local name2 = questItemNames[itemID2] or ''
      return name1 < name2
    end)

    local i = 0
    return function()
      i = i + 1
      return keys[i]
    end
  end

  self:ClearKeyBinding()

  local index, buttons = 1, self.buttons
  for itemID in sortedkeys(usableQuestItems) do
    if index < #buttons and not startsQuestItems[itemID] then
      self:UpdateButton(buttons[index], itemID)
      index = index + 1
    end
  end
  for itemID in sortedkeys(questItems) do
    if index < #buttons and startsQuestItems[itemID] then
      self:UpdateButton(buttons[index], itemID)
      index = index + 1
    end
  end
  for i = index, #buttons do
    buttons[i]:Hide()
  end
end

function module:ACTIONBAR_UPDATE_COOLDOWN()
  for _, button in ipairs(self.buttons) do
    if button:IsShown() then
      local itemLink = button:GetAttribute('item')
      if itemLink then
        local _, itemID = strsplit(':', itemLink)
        CooldownFrame_Set(button.cooldown, GetItemCooldown(itemID))
      end
    end
  end
end

local function RequestUpdate()
  timeSinceLastUpdate = 0
  frame:SetScript('OnUpdate', ItemScanner_OnUpdate)
end

function module:UNIT_INVENTORY_CHANGED(unit)
  if unit == 'player' then
    RequestUpdate()
  end
end

function module:OnPlayerLogin()
  self:SafeInvoke(function()
    self.buttons = CreateButtons()
    self:RegisterEvent('ACTIONBAR_UPDATE_COOLDOWN')
    self:RegisterEvent('BAG_UPDATE', RequestUpdate)
    self:RegisterEvent('UNIT_INVENTORY_CHANGED')
    self:RegisterEvent('QUEST_ACCEPTED', RequestUpdate)
    self:RegisterEvent('PLAYER_REGEN_ENABLED', RequestUpdate)
    self:RegisterEvent('ZONE_CHANGED_NEW_AREA', RequestUpdate)
    RequestUpdate()
  end)
end
