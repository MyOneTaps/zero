local _, Zero = ...

local module = Zero.Module('Castbars')

function module:OnPlayerLogin()
  PlayerCastingBarFrame:SetMovable(true)
  PlayerCastingBarFrame:ClearAllPoints()
  PlayerCastingBarFrame:SetPoint('CENTER', 0, -265)
  PlayerCastingBarFrame:SetScale(1)
  PlayerCastingBarFrame:SetUserPlaced(true)
  PlayerCastingBarFrame:SetMovable(false)
end
