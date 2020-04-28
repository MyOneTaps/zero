local _, Zero = ...

local module = Zero:Module('Fonts')

local function UpdateCooldown(self)
  if not GetCVar('countdownForCooldowns') then return end
  if self.patched then return end
  local regions = { self:GetRegions() }
  for _, region in ipairs(regions) do
    if region.GetText then
      region:SetFont(ZERO_UI_FONT, 12, 'OUTLINE')
    end
  end
  self.patched = true
end

function module:OnLoad()
  UNIT_NAME_FONT = ZERO_UI_FONT
  STANDARD_TEXT_FONT = ZERO_UI_FONT
  DAMAGE_TEXT_FONT = ZERO_DAMAGE_FONT
end
