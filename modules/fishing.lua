local _, Zero = ...

local module = Zero.Module('Fishing')

local BUTTON_NAME = 'ZeroFishingAnyWhereButton'
local FISHING = 'Fishing'
local FISHING_POLES = 'Fishing Poles'
local QUICK_FISHING_OFF = ('%sQuick fishing {OFF}%s'):format(RED_FONT_COLOR_CODE, FONT_COLOR_CODE_CLOSE)
local QUICK_FISHING_ON = ('%sQuick fishing {ON}%s'):format(GREEN_FONT_COLOR_CODE, FONT_COLOR_CODE_CLOSE)

local fishingSettings = {
  Sound_EnablePetSounds = 0,
  Sound_EnableEmoteSounds = 0,
  Sound_EnableMusic = 0,
  Sound_EnableAmbience = 0,
  Sound_EnableDialog = 0,
  Sound_EnableAllSound = 1,
  Sound_EnableSFX = 1,
  Sound_EnableErrorSpeech = 0,
  Sound_EnableEmoteSounds = 0,
  Sound_EnablePetSounds = 0,
  Sound_MasterVolume = 0.5,
  Sound_SFXVolume = 1,
  Sound_MusicVolume = 0.25,
  Sound_AmbienceVolume = 0,
  autointeract = 0,
  autoLootDefault = 1
}

local hasBinding

function module:ApplyFishingSettings()
  if self.previousSettings then return end
  self.previousSettings = {}
  for cvar, value in pairs(fishingSettings) do
    self.previousSettings[cvar] = GetCVar(cvar)
    SetCVar(cvar, value)
  end
end

function module:UnapplyFishingSettings()
  if not self.previousSettings then return end
  for cvar, value in pairs(self.previousSettings) do
    SetCVar(cvar, value)
  end
  self.previousSettings = nil
end

function module:EnableFishingMode()
  if self.isFishing then return end
  self.isFishing = true
  self:ApplyFishingSettings()
  print(QUICK_FISHING_ON)
end

function module:DisableFishingMode()
  if not self.isFishing then return end
  self.isFishing = false
  self:UnapplyFishingSettings()
  print(QUICK_FISHING_OFF)
end

function module:UNIT_INVENTORY_CHANGED()
  if IsEquippedItemType(FISHING_POLES) and self.hasPole then return end
  self.hasPole = IsEquippedItemType(FISHING_POLES)
  if self.hasPole and not self.isFishing then
    self:EnableFishingMode()
  elseif self.isFishing and not self.hasPole then
    self:DisableFishingMode()
  end
end

function module:UNIT_SPELLCAST_CHANNEL_START(unitID, spell, rank, lineID, spellID)
  if unitID == 'player' and spell == FISHING then
    self:ApplyFishingSettings()
  end
end

function module:UNIT_SPELLCAST_CHANNEL_STOP(unitID, spell, rank, lineID, spellID)
  if unitID == 'player' and spell == FISHING then
    self:UnapplyFishingSettings()
  end
end

local function WorldFrame_OnMouseDown(self, button)
  if not self.isFishing or button ~= 'RightButton' then return end
  local clickTime = GetTime()
  if self.lastClickTime then
    local clickInterval = clickTime - self.lastClickTime
    if clickInterval > 0.05 and clickInterval < 0.25 then
      if IsMouselooking() then
        MouselooksStop()
      end
      SetOverrideBindingClick(self.anyWhereButton, true, 'BUTTON2', BUTTON_NAME)
      hasBinding = true
    end
  end
  self.lastClickTime = clickTime
end

local function anyWhereButton_PostClick(self)
  if hasBinding then
    ClearOverrideBindings(self)
    hasBinding = false
  end
end

local function CreateAnyWhereButton()
  local button = CreateFrame('Button', BUTTON_NAME, UIParent, 'SecureActionButtonTemplate')
  button:SetAllPoints()
  button:EnableMouse(true)
  button:RegisterForClicks('RightButtonUp')
  button:Hide()
  button:SetAttribute('type', 'spell')
  button:SetAttribute('spell', FISHING)
  button:SetScript('PostClick', anyWhereButton_PostClick)
  return button
end

function module:Initialize()
  self.anyWhereButton = CreateAnyWhereButton()
  self:HookScript(WorldFrame, 'OnMouseDown', WorldFrame_OnMouseDown)
  self:RegisterEvent('UNIT_INVENTORY_CHANGED')
  self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_START')
  self:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP')
  self:UNIT_INVENTORY_CHANGED()
end

function module:SPELLS_CHANGED()
  if IsSpellKnown(131474) then
    self:UnregisterEvent('SPELLS_CHANGED')
    self:Initialize()
  end
end

function module:OnPlayerLogin()
  if IsSpellKnown(131474) then
    self:Initialize()
  else
    self:RegisterEvent('SPELLS_CHANGED')
  end
end
