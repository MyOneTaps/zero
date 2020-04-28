local _, Zero = ...

local module = Zero.Module('Action Bars')
local LibFader = Zero.LibFader

local function CreateActionBarFader(barName)
  local bar = _G[barName]
  local buttons = {}
  for i = 1, NUM_MULTIBAR_BUTTONS do
    buttons[i] = _G[barName .. 'Button' .. i]
  end
  LibFader.CreateButtonFrameFader(bar, buttons)
end

function module:OnPlayerLogin()
  CreateActionBarFader('MultiBarLeft')
  CreateActionBarFader('MultiBarRight')
  C_Timer.After(3, function()
    LibFader.FadeOut(MultiBarLeft)
    LibFader.FadeOut(MultiBarRight)
  end)
end
