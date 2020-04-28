local _, Zero = ...

local module = Zero.Module('Minimap')

function module:OnLoad()
  MinimapZoomIn:Hide()
  MinimapZoomOut:Hide()
  Minimap:EnableMouseWheel(true)
  Minimap:SetScript('OnMouseWheel', function(_, delta)
    if delta > 0 then
      Minimap_ZoomIn()
    else
      Minimap_ZoomOut()
    end
  end)
end
