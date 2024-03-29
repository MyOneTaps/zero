local _, Zero = ...

local module = Zero.Module('FCT')

local function UpdateDisplayedMessages()
  if COMBAT_TEXT_FLOAT_MODE == '1' then
    COMBAT_TEXT_LOCATIONS.startY = 484 * COMBAT_TEXT_Y_SCALE
    COMBAT_TEXT_LOCATIONS.endY = 709 * COMBAT_TEXT_Y_SCALE
  end
end

function module:OnLoad()
  COMBAT_TEXT_HEIGHT = 16
  COMBAT_TEXT_CRIT_MAXHEIGHT = 24
  COMBAT_TEXT_CRIT_MINHEIGHT = 16
  COMBAT_TEXT_SCROLLSPEED = 3
  hooksecurefunc('CombatText_UpdateDisplayedMessages', UpdateDisplayedMessages)
end
