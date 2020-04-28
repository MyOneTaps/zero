local _, Zero = ...

local module = Zero.Module('UnitFrames')

local function SetUnitFrame(frame, x, y)
  frame:StartMoving()
  frame:SetUserPlaced(true)
  frame:ClearAllPoints()
  frame:SetPoint('BOTTOM', x, y)
  frame:StopMovingOrSizing()
end

local function UpdatePlayerFrame()
  SetUnitFrame(PlayerFrame, -265, 250)
end

local function UpdateUnitFrames()
  SetUnitFrame(PlayerFrame, -265, 250)
  SetUnitFrame(TargetFrame, 265, 250)
  TargetFrame.buffsOnTop = true
end

function module:OnPlayerLogin()
  self:SafeInvoke(UpdateUnitFrames)
  hooksecurefunc('PlayerFrame_UpdateArt', function()
    self:SafeInvoke(UpdatePlayerFrame)
  end)
  hooksecurefunc('PlayerFrame_SequenceFinished', function()
    self:SafeInvoke(UpdatePlayerFrame)
  end)
end
