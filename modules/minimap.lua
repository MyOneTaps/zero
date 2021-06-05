local _, Zero = ...

local module = Zero.Module('Minimap')

local function GetPlayerPosition()
  local mapID = C_Map.GetBestMapForUnit('player')
  if not mapID then
    return
  end
  local pos = C_Map.GetPlayerMapPosition(mapID, 'player')
  if not pos then
    return
  end
  local x, y = pos:GetXY()
  return floor((1000 * x + 0.5)) / 10, floor((1000 * y + 0.5)) / 10
end

function module:UpdateMinimapCoords(elapsed)

  local isInInstance = IsInInstance()
  if isInInstance then
    self.coords.text:SetText('')
    return
  end

  local x, y = GetPlayerPosition()
  if x then
    self.coords.text:SetFormattedText('%1.1f : %1.1f', x, y)
  else
    self.coords.text:SetText('')
  end
end

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

  local coords = CreateFrame('Frame', 'Zero_coords', Minimap)
  coords:SetSize(100, 16)
  coords:SetPoint('TOP', 0, -10)
  coords.text = coords:CreateFontString(nil, 'OVERLAY', 'GameFontWhiteSmall')
  coords.text:SetPoint('CENTER')
  self.coords = coords
  self:ScheduleTimer(0.5, 'UpdateMinimapCoords')
end
