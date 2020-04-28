local _, Zero = ...

local module = Zero.Module('PicoMenu')

local x, x2, n = nil, false
local v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11
local BLOCKED_IN_COMBAT = 'UI Action Blocked'

local visibleAlerts = {}
local ALERT_PRIORITY = {
  'TalentPicoMenuButtonAlert',
  'CharacterPicoMenuButtonAlert',
}

local ICONS = {
  ['WARRIOR'] = [[interface\icons\classicon_warrior]],
  ['MAGE'] = [[interface\icons\classicon_mage]],
  ['ROGUE'] = [[interface\icons\classicon_rogue]],
  ['DRUID']	= [[interface\icons\classicon_druid]],
  ['HUNTER'] = [[interface\icons\classicon_hunter]],
  ['SHAMAN'] = [[interface\icons\classicon_shaman]],
  ['PRIEST'] = [[interface\icons\classicon_priest]],
  ['WARLOCK'] = [[interface\icons\classicon_warlock]],
  ['PALADIN'] = [[interface\icons\classicon_paladin]],
  ['DEATHKNIGHT']	= [[interface\icons\classicon_deathknight]],
  ['MONK'] = [[interface\icons\classicon_monk]],
  ['DEMONHUNTER'] = [[interface\icons\classicon_demonhunter]],
}

local function GetClassIcon()
  local _, class = UnitClass('player')
  return ICONS[class]
end

local menuList = {
  {
    text = MAINMENU_BUTTON,
    isTitle = true,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = CHARACTER_BUTTON,
    icon = 'Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle',
    func = function()
      ToggleCharacter('PaperDollFrame')
    end,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = SPELLBOOK_ABILITIES_BUTTON,
    icon = 'Interface\\MINIMAP\\TRACKING\\Class',
    func = function()
      if not Zero:IsTaintable() then
        ToggleSpellBook(BOOKTYPE_SPELL)
      else
        UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
      end
    end,
    notCheckable = true,
    disabled = Zero:IsTaintable(),
    fontObject = Game13Font,
  },
  {
    text = TALENTS,
    icon = 'Interface\\AddOns\\Zero\\Media\\textures\\picomenu\\picomenuTalent',
    func = ToggleTalentFrame,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = ACHIEVEMENT_BUTTON,
    icon = 'Interface\\AddOns\\Zero\\Media\\textures\\picomenu\\picomenuAchievement',
    func = ToggleAchievementFrame,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = QUESTLOG_BUTTON,
    icon = 'Interface\\GossipFrame\\ActiveQuestIcon',
    func = ToggleQuestLog,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = COMMUNITIES_FRAME_TITLE,
    icon = 'Interface\\GossipFrame\\TabardGossipIcon',
    arg1 = IsInGuild('player'),
    func = ToggleGuildFrame,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = SOCIAL_BUTTON,
    icon = 'Interface\\FriendsFrame\\PlusManz-BattleNet',
    func = ToggleFriendsFrame,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = PLAYER_V_PLAYER,
    icon = 'Interface\\MINIMAP\\TRACKING\\BattleMaster',
    func = TogglePVPUI,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = DUNGEONS_BUTTON,
    icon = 'Interface\\LFGFRAME\\BattleNetWorking0',
    func = ToggleLFDParentFrame,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = CHALLENGES,
    icon = 'Interface\\BUTTONS\\UI-GroupLoot-DE-Up',
    func = function()
      PVEFrame_ToggleFrame('ChallengesFrame',nil)
    end,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = RAID,
    icon = 'Interface\\TARGETINGFRAME\\UI-TargetingFrame-Skull',
    func = ToggleRaidFrame,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = MOUNTS,
    icon = 'Interface\\MINIMAP\\TRACKING\\StableMaster',
    func = function()
      if not Zero:IsTaintable() then
        ToggleCollectionsJournal(1)
      else
        UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
      end
    end,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = PETS,
    icon = 'Interface\\MINIMAP\\TRACKING\\StableMaster',
    func = function()
      if not Zero:IsTaintable() then
        ToggleCollectionsJournal(2)
      else
        UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
      end
    end,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = TOY_BOX,
    icon = 'Interface\\MINIMAP\\TRACKING\\Reagents',
    func = function()
      if not Zero:IsTaintable() then
        ToggleCollectionsJournal(3)
      else
        UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
      end
    end,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = HEIRLOOMS,
    icon = 'Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle',
    func = function()
      if not Zero:IsTaintable() then
        ToggleCollectionsJournal(4)
      else
      UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
      end
    end,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = WARDROBE,
    icon = 'Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle',
    func = function()
      if not Zero:IsTaintable() then
        ToggleCollectionsJournal(5)
      else
        UIErrorsFrame:AddMessage(BLOCKED_IN_COMBAT, 1, 0, 0)
      end
    end,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = ENCOUNTER_JOURNAL,
    icon = 'Interface\\MINIMAP\\TRACKING\\Profession',
    func = ToggleEncounterJournal,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = GM_EMAIL_NAME,
    icon = 'Interface\\CHATFRAME\\UI-ChatIcon-Blizz',
    func = ToggleHelpFrame,
    notCheckable = true,
    fontObject = Game13Font,
  },
  {
    text = BATTLEFIELD_MINIMAP,
    func = ToggleBattlefieldMap,
    notCheckable = true,
    fontObject = Game13Font,
  },
}

local function ShouldShowAzeriteAlert()
  if AzeriteEmpoweredItemUI and AzeriteEmpoweredItemUI:IsShown() then
    return false
  end
  return IsPlayerInWorld() and AzeriteUtil.DoEquippedItemsHaveUnselectedPowers()
end

local function HasTalentAlertToShow()
  return not AreTalentsLocked() and GetNumUnspentTalents() > 0
end

local function HasPvpTalentAlertToShow()
  local hasEmptySlot, hasNewTalent = C_SpecializationInfo.GetPvpTalentAlertStatus()
  if hasEmptySlot then
    return true, TALENT_MICRO_BUTTON_UNSPENT_PVP_TALENT_SLOT
  elseif hasNewTalent then
    return true, TALENT_MICRO_BUTTON_NEW_PVP_TALENT
  end
  return false
end

local function ShowAlert(alert, text)
  local isHighestPriority = false
  for i, priorityFrameName in ipairs(ALERT_PRIORITY) do
    local priorityFrame = _G[priorityFrameName]
    if alert == priorityFrame then
      isHighestPriority = true
    end
    if priorityFrame:IsShown() then
      if not isHighestPriority then
        return false
      end
      priorityFrame:Hide();
    end
  end
  alert.Text:SetText(text)
  alert:Show()
  return alert:IsShown()
end

local function EvaluateAlertVisibility()
  if ShouldShowAzeriteAlert() then
    ShowAlert(CharacterPicoMenuButtonAlert, CHARACTER_SHEET_MICRO_BUTTON_AZERITE_AVAILABLE)
  elseif HasTalentAlertToShow() and (not PlayerTalentFrame or not PlayerTalentFrame:IsShown()) then
    ShowAlert(TalentPicoMenuButtonAlert, TALENT_MICRO_BUTTON_UNSPENT_TALENTS)
  else
    local hasAlert, text = HasPvpTalentAlertToShow();
    if hasAlert and (not PlayerTalentFrame or not PlayerTalentFrame:IsShown()) then
      ShowAlert(TalentPicoMenuButtonAlert, text)
    end
  end
end

function module:AddOnLoaded(name)
  if name == 'Blizzard_AzeriteUI' then
    AzeriteEmpoweredItemUI:RegisterCallback(AzeriteEmpoweredItemUIMixin.Event.OnShow, EvaluateAlertVisibility)
    AzeriteEmpoweredItemUI:RegisterCallback(AzeriteEmpoweredItemUIMixin.Event.OnHide, EvaluateAlertVisibility)
  end
end

function module:OnLoad()
  PicoMenuButtonDropDown.displayMode = 'MENU'
  PicoMenuButtonDropDown.initialize = EasyMenu_Initialize

  HelpOpenWebTicketButton:ClearAllPoints()
  HelpOpenWebTicketButton:SetPoint('LEFT', 'PicoMenuButton', 'RIGHT', 0, 0)
  HelpOpenWebTicketButton:SetScale(0.8)
  HelpOpenWebTicketButton:SetParent('PicoMenuButton')

  module:RegisterEvent('PLAYER_LEVEL_UP', EvaluateAlertVisibility)
  module:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED', EvaluateAlertVisibility)
  module:RegisterEvent('PLAYER_TALENT_UPDATE', EvaluateAlertVisibility)
  module:RegisterEvent('AZERITE_ITEM_POWER_LEVEL_CHANGED', EvaluateAlertVisibility)
  module:RegisterEvent('AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED', EvaluateAlertVisibility)
end

function module:OnPlayerLogin()
  EvaluateAlertVisibility()
end


function PicoMenuButtonAlert_OnShow(self)
  visibleAlerts[self] = true
  self:SetHeight(self.Text:GetHeight() + 42)
end

function PicoMenuButtonAlert_OnHide(self)
  visibleAlerts[self] = nil
  MainMenuMicroButton_UpdateAlertsEnabled(self)
end

function PicoMenuButton_OnClick(self, button, down)
  if button == 'LeftButton' then
    ToggleDropDownMenu(1, nil, PicoMenuButtonDropDown, 'PicoMenuButton', 5, 265, menuList, nil, 5)
  end
end

local function MainMenuMicroButton_UpdateAlertsEnabled(frameToSkip)
  for i, priorityFrameName in ipairs(ALERT_PRIORITY) do
    local priorityFrame = _G[priorityFrameName]
    if priorityFrame:IsShown() then
      return
    end
  end
  for i, priorityFrameName in ipairs(ALERT_PRIORITY) do
    local priorityFrame = _G[priorityFrameName]
    if frameToSkip ~= priorityFrame then
      EvaluateAlertVisibility()
      if priorityFrame:IsShown() then
        break
      end
    end
  end
end
