local _, Zero = ...

local module = Zero.Module('ScreenShots')

local active
function module:ACHIEVEMENT_EARNED()
  if active then
    return
  end
  active = true
  local ssTime = 1 + GetTime()
  self:StartCoroutine(function()
    while ssTime >=GetTime() do
      coroutine.yield()
    end
    Screenshot()
    active = false
  end)
end

function module:OnPlayerLogin()
  self:RegisterEvent('ACHIEVEMENT_EARNED')
end
