local _, Zero = ...

local module = Zero.Module('UnitFrames')

local function UpdatePlayerFrameVisibility()
  if InCombatLockdown() then return end

  local atMaxHealth = UnitHealth('player') == UnitHealthMax('player')
  local hasTarget = UnitExists('target')

  if hasTarget or not atMaxHealth then
    PlayerFrame:Show()
  else
    PlayerFrame:Hide()
  end
end

local function CreateDragFrame(name, width, height)

  local frame = CreateFrame('Frame', name, UIParent)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:SetPoint('CENTER')
  frame:SetSize(width, height)

  -- Hide it
  frame:Hide()

  return frame
end

local function SetUnitFrame(frame, dragFrame, x, y)
  dragFrame:ClearAllPoints()
  dragFrame:SetPoint('BOTTOM', x, y)

  frame:SetMovable(true)
  frame:ClearAllPoints()
  frame:SetPoint('CENTER', dragFrame, 'CENTER')
  frame:SetUserPlaced(true)
  frame:SetMovable(false)
end

function module:UpdateUnitFrames()
  SetUnitFrame(PlayerFrame, self.playerDragFrame, -265, 250)
  SetUnitFrame(TargetFrame, self.targetDragFrame, 265, 250)
end

function module:OnLoad()
  self.playerDragFrame = CreateDragFrame('Zero_Player_DragFrame', 205, 90)
  self.targetDragFrame = CreateDragFrame('Zero_Target_DragFrame', 205, 90)
  self:UpdateUnitFrames()
end

function module:OnPlayerLogin()
  self:SafeInvoke('UpdateUnitFrames')

  -- self:RegisterEvent('UNIT_HEALTH', UpdatePlayerFrameVisibility)
  self:RegisterEvent('PLAYER_TARGET_CHANGED', UpdatePlayerFrameVisibility)
  self:RegisterEvent('UNIT_POWER_UPDATE', UpdatePlayerFrameVisibility)
  self:RegisterEvent('PLAYER_REGEN_DISABLED', UpdatePlayerFrameVisibility)
  self:RegisterEvent('PLAYER_REGEN_ENABLED', UpdatePlayerFrameVisibility)
  self:RegisterEvent('UNIT_EXITED_VEHICLE', UpdatePlayerFrameVisibility)
  self:RegisterEvent('UNIT_ENTERED_VEHICLE', UpdatePlayerFrameVisibility)

  UpdatePlayerFrameVisibility()
end
