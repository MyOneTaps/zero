local _, Zero = ...

local module = Zero.Module('UnitFrames')

local function SetUnitFrame(frame, x, y)
  frame:SetMovable(true)
  frame:ClearAllPoints();
  frame:SetUserPlaced(true);
  frame:SetPoint('BOTTOM', x, y)
  frame:SetMovable(false)
end

function module:UpdateUnitFrames()
  SetUnitFrame(PlayerFrame, -265, 250)
  SetUnitFrame(TargetFrame, 265, 250)
  UIParent_UpdateTopFramePositions()
end

function module:OnLoad()
  self:UpdateUnitFrames()
end

function module:OnPlayerLogin()
  self:SafeInvoke('UpdateUnitFrames')
end
