local _, Zero = ...

local module = Zero:Module('Fonts')

function module:OnLoad()
  UNIT_NAME_FONT = ZERO_UI_FONT
  DAMAGE_TEXT_FONT = ZERO_DAMAGE_FONT
  STANDARD_TEXT_FONT = ZERO_UI_FONT
end
