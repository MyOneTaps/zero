local _, Zero = ...

local module = Zero.Module('Tooltip')

function module:OnLoad()
  hooksecurefunc('GameTooltip_SetDefaultAnchor', function(tooltip, parent)
    tooltip:SetPoint('BOTTOMRIGHT', ChatFrame4, 'TOPRIGHT', 0, 10)
  end)
end
