local _, Zero = ...

local module = Zero.Module('Map')

local MINIMAP_STYLE = {
  bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
  tile = true,
  tileSize = 16,
  backdropColor = TOOLTIP_DEFAULT_BACKGROUND_COLOR,
}

local worldMapCoordsFrame, minimapCoordsFrame

local function GetPlayerPosition()
  local mapID = C_Map.GetBestMapForUnit('player')
  if mapID then
    local pos = C_Map.GetPlayerMapPosition(mapID, 'player')
    if pos then
      local x, y = pos:GetXY()
      return floor((1000 * x + 0.5)) / 10, floor((1000 * y + 0.5)) / 10
    end
  end
  return 0, 0
end

local function GetCursorPosition()
  if WorldMapFrame:IsVisible() then
    local x, y = WorldMapFrame:GetNormalizedCursorPosition()
    if x and x > 0 and y > 0 then
      return floor((1000 * x + 0.5)) / 10, floor((1000 * y + 0.5)) / 10
    end
  end
  return 0, 0
end

local isInInstance
local function UpdateMinimapCoords()
  if isInInstance then
    isInInstance = IsInInstance()
  elseif IsInInstance() then
    isInInstance = true
    minimapCoordsFrame.text:SetText('')
  else
    local x, y = GetPlayerPosition()
    minimapCoordsFrame.text:SetFormattedText('%1.1f : %1.1f', x, y)
  end
end

local function UpdateWorldMapCoords(self, elapsed)
  if isInInstance and not IsInInstance() then
    isInInstance = false
  elseif not isInInstance and IsInInstance() then
    isInInstance = true
    worldMapCoordsFrame.cursorText:SetText('')
    worldMapCoordsFrame.playerText:SetText('')
    return
  end
  local cx, cy = GetCursorPosition()
  worldMapCoordsFrame.cursorText:SetFormattedText('C: %1.1f : %1.1f', cx, cy)
  local px, py = GetPlayerPosition()
  worldMapCoordsFrame.playerText:SetFormattedText('P: %1.1f : %1.1f', px, py)
end

function module:OnPlayerLogin()
  worldMapCoordsFrame = CreateFrame('Frame', 'Zero_WorldMapCoordsFrame', WorldMapFrame)
  worldMapCoordsFrame:SetSize(100, 32)
  worldMapCoordsFrame:SetPoint('BOTTOMLEFT', WorldMapFrame.BorderFrame, 'BOTTOMLEFT', 10, 10)
  worldMapCoordsFrame:SetFrameStrata('HIGH')
  worldMapCoordsFrame.cursorText = worldMapCoordsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmallLeft')
  worldMapCoordsFrame.cursorText:SetPoint('TOPLEFT')
  worldMapCoordsFrame.playerText = worldMapCoordsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmallLeft')
  worldMapCoordsFrame.playerText:SetPoint('BOTTOMLEFT')
  worldMapCoordsFrame:SetScript('OnUpdate', UpdateWorldMapCoords)

  minimapCoordsFrame = CreateFrame('Frame', 'Zero_MinimapCoordsFrame', Minimap)
  minimapCoordsFrame:SetSize(100, 16)
  minimapCoordsFrame:SetPoint('TOP', 0, -10)
  minimapCoordsFrame.text = minimapCoordsFrame:CreateFontString(nil, 'OVERLAY', 'GameFontWhiteSmall')
  minimapCoordsFrame.text:SetPoint('CENTER')
  minimapCoordsFrame:SetScript('OnUpdate', UpdateMinimapCoords)
end
