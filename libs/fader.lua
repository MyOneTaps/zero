local _, Zero = ...

local defaultConfig = {
  fadeInDelay = 0,
  fadeInDuration = 0.3,
  fadeOutDelay = 1.5,
  fadeOutDuration = 0.3,
}

local function OnFadeInPlay(self)
  self:GetParent().fadeOut:Stop()
end

local function OnFadeInFinished(self)
  self:GetParent():SetAlpha(1)
end

local function OnFadeOutPlay(self)
  self:GetParent().fadeIn:Stop()
end

local function OnFadeOutFinished(self)
  self:GetParent():SetAlpha(0)
end

local function CreateFadeInAnimation(frame, config)
  frame.fadeIn = frame:CreateAnimationGroup()
  frame.fadeIn.anim = frame.fadeIn:CreateAnimation('Alpha')
  frame.fadeIn.anim:SetFromAlpha(0)
  frame.fadeIn.anim:SetToAlpha(1)
  frame.fadeIn.anim:SetSmoothing('IN')
  frame.fadeIn.anim:SetDuration(config.fadeInDuration or defaultConfig.fadeInDuration)
  frame.fadeIn.anim:SetStartDelay(config.fadeInDelay or defaultConfig.fadeInDelay)
  frame.fadeIn:HookScript('OnPlay', OnFadeInPlay)
  frame.fadeIn:HookScript('OnFinished', OnFadeInFinished)
  frame.fadeIn.parent = frame
end

local function CreateFadeOutAnimation(frame, config)
  frame.fadeOut = frame:CreateAnimationGroup()
  frame.fadeOut.anim = frame.fadeOut:CreateAnimation('Alpha')
  frame.fadeOut.anim:SetFromAlpha(1)
  frame.fadeOut.anim:SetToAlpha(0)
  frame.fadeOut.anim:SetSmoothing('OUT')
  frame.fadeOut.anim:SetDuration(config.fadeOutDuration or defaultConfig.fadeOutDuration)
  frame.fadeOut.anim:SetStartDelay(config.fadeOutDelay or defaultConfig.fadeOutDelay)
  frame.fadeOut:HookScript('OnPlay', OnFadeOutPlay)
  frame.fadeOut:HookScript('OnFinished', OnFadeOutFinished)
  frame.fadeOut.parent = frame
end


local function FadeIn(frame)
  if frame.fadeIn and not frame.fadeIn:IsPlaying() then
    frame.fadeIn:Play()
  end
end

local function FadeOut(frame)
  if frame.fadeOut and not frame.fadeOut:IsPlaying() then
    frame.fadeOut:Play()
  end
end

local function IsMouseOverFrame(frame)
  if MouseIsOver(frame) then
    return true
  end
  if not SpellFlyout:IsShown() then
    return false
  end
  if not SpellFlyout.__fadeParent then
    return false
  end
  return SpellFlyout.__fadeParent == frame and MouseIsOver(SpellFlyout)
end

local function FrameHandler(frame)
  if IsMouseOverFrame(frame) then
    FadeIn(frame)
  else
    FadeOut(frame)
  end
end

local function ButtonHandler(self)
  if self.__fadeParent then
    FrameHandler(self.__fadeParent)
  end
end

local function OnButtonEnter(self)
  if self.__fadeParent then
    FadeIn(self.__fadeParent)
  end
end

local function OnButtonLeave(self)
  if self.__fadeParent then
    FadeOut(self.__fadeParent)
  end
end

local function SpellFlyoutOnShow(self)
  local actionBar = self:GetParent():GetParent():GetParent()
  if not actionBar.fadeIn then
    return
  end
  self.__fadeParent = frame
  local i = 1
  local button = _G['SpellFlyoutButton' .. i]
  while button and button:IsShown() do
    button.__fadeParent = frame
    if not button.__fadeHooked then
      button:HookScript('OnEnter', OnButtonEnter)
      button:HookScript('OnLeave', OnButtonLeave)
      button.__fadeHooked = true
    end
    i = i+1
    button = _G['SpellFlyoutButton'..i]
  end
end
SpellFlyout:HookScript('OnShow', SpellFlyoutOnShow)
SpellFlyout:HookScript('OnEnter', OnButtonEnter)
SpellFlyout:HookScript('OnLeave', OnButtonLeave)

local function CreateFrameFader(frame, config)
  if frame.fader then
    return
  end
  CreateFadeInAnimation(frame, config or defaultConfig)
  CreateFadeOutAnimation(frame, config or defaultConfig)
  frame:EnableMouse(true)
  frame:HookScript('OnEnter', FadeIn)
  frame:HookScript('OnLeave', FadeOut)
end

local function CreateButtonFrameFader(frame, buttonList, config)
  CreateFadeInAnimation(frame, config or defaultConfig)
  CreateFadeOutAnimation(frame, config or defaultConfig)
  for i, button in next, buttonList do
    if not button.__fadeParent then
      button.__fadeParent = frame
      button:HookScript('OnEnter', OnButtonEnter)
      button:HookScript('OnLeave', OnButtonLeave)
    end
  end
end

Zero.LibFader = {
  FadeIn = FadeIn,
  FadeOut = FadeOut,
  CreateFrameFader = CreateFrameFader,
  CreateButtonFrameFader = CreateButtonFrameFader,
}
