local _, Zero = ...

local module = Zero.Module('Minimap')

local numbers = {}

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
  x, y = floor(x * 1000 + 0.5), floor(y * 1000 + 0.5)
  if not numbers[x] then
    numbers[x] = ('%1.1f'):format(x / 10)
  end
  if not numbers[y] then
    numbers[y] = ('%1.1f'):format(y / 10)
  end
  return numbers[x], numbers[y]
end

function module:UpdateMinimapCoords()
  local isInInstance = IsInInstance()
  if isInInstance then
    self.coords.textX:SetText('')
    self.coords.textY:SetText('')
    return true
  end

  local x, y = GetPlayerPosition()
  if x then
    self.coords.textX:SetText(x)
    self.coords.textY:SetText(y)
  else
    self.coords.textX:SetText('')
    self.coords.textY:SetText('')
  end

  return true
end

function module:OnLoad()
  if Zero.IsClassic then
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

  local coords = CreateFrame('Frame', 'Zero_coords')

  local w = 96
  coords:SetSize(w, 12)
  if Zero.IsClassic then
    coords:SetPoint('TOP', 0, -50)
  else
    coords:SetPoint('TOP', Minimap, 0, 12)
  end

  coords.textX = coords:CreateFontString('Zero_coords_x', 'OVERLAY', 'GameFontNormalTiny')
  coords.textX:SetJustifyH('RIGHT')
  coords.textX:SetSize(w / 2, 12)
  coords.textX:SetPoint('TOPRIGHT', coords, 'TOP', -8, 0)

  coords.textY = coords:CreateFontString('Zero_coords_y', 'OVERLAY', 'GameFontNormalTiny')
  coords.textY:SetJustifyH('LEFT')
  coords.textY:SetSize(w / 2, 12)
  coords.textY:SetPoint('TOPLEFT', coords, 'TOP', 8, 0)

  self.coords = coords
  self:ScheduleTimer(1, 'UpdateMinimapCoords')
end
