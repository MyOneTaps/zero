local _, Zero = ...

local module = Zero.Module('Castbars')

function module:OnPlayerLogin()
  CastingBarFrame:SetMovable(true)
  CastingBarFrame:ClearAllPoints()
  CastingBarFrame:SetPoint('CENTER', 0, -265)
  CastingBarFrame:SetScale(1)
  CastingBarFrame:SetUserPlaced(true)
  CastingBarFrame:SetMovable(false)
end
