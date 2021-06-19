local _, Zero = ...

local module = Zero.Module('QuestTracker')

local function CheckObjectiveTrackerFrame()
  if ObjectiveTrackerFrame.collapsed then
    if not IsInInstance() then
      ObjectiveTracker_Expand()
    else
      C_Timer.After(1, CheckObjectiveTrackerFrame)
    end
  end
end

function module:PLAYER_ENTERING_WORLD()
  local inInstance, instanceType = IsInInstance()
  if inInstance and instanceType ~= 'none' then
    if not ObjectiveTrackerFrame.collapsed then
      ObjectiveTracker_Collapse()
    end
  else
    C_Timer.After(1, CheckObjectiveTrackerFrame)
  end
end

function module:OnPlayerLogin()
  self:RegisterEvent('PLAYER_ENTERING_WORLD')
end
