local _, Zero = ...

local module = Zero.Module('QuestTracker')

function module:OnPlayerLogin()
  self:RegisterEvent('PLAYER_ENTERING_WORLD', function()
    local inInstance, instanceType = IsInInstance()
    if inInstance and instanceType ~= 'none' then
      if not ObjectiveTrackerFrame.collapsed then
        ObjectiveTracker_Collapse()
      end
    elseif not inInstance then
      if ObjectiveTrackerFrame.collapsed then
        ObjectiveTracker_Collapse()
      end
    end
  end)
end
