local _, Zero = ...

local module = Zero.Module('UnitFrames')

local function SetUnitFrame(frame, x, y)
  if not frame:IsUserPlaced() then
    frame:ClearAllPoints()
    frame:SetPoint('BOTTOM', x, y)
    frame:SetUserPlaced(true)
  end
end

function module:UpdateUnitFrames()
  SetUnitFrame(PlayerFrame, -265, 250)
  SetUnitFrame(TargetFrame, 265, 250)
  UIParent_UpdateTopFramePositions()
end

function module:OnLoad()
  self:UpdateUnitFrames()
end

function module:OnVariablesLoaded()
  self:SafeInvoke('UpdateUnitFrames')
end
