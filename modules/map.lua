  local _, Zero = ...

local module = Zero.Module('Map')

local worldMapCoordsFrame, minimapCoordsFrame

local function GetPlayerPosition()
  local mapID = C_Map.GetBestMapForUnit('player')
  if not mapID then
    return 0, 0
  end
  local pos = C_Map.GetPlayerMapPosition(mapID, 'player')
  if not pos then
    return 0, 0
  end
  local x, y = pos:GetXY()
  return floor((1000 * x + 0.5)) / 10, floor((1000 * y + 0.5)) / 10
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

local minimapTimeSinceUpdate = 0
local isInInstance
local lastMiniMapX, lastMiniMapY
local function UpdateMinimapCoords(self, elapsed)
  minimapTimeSinceUpdate = minimapTimeSinceUpdate + elapsed
  if minimapTimeSinceUpdate < 0.25 then return end
  minimapTimeSinceUpdate = 0

  if isInInstance and not IsInInstance() then
    isInInstance = false
  elseif not isInInstance and IsInInstance() then
    isInInstance = true
    minimapCoordsFrame.text:SetText('')
  else
    local x, y = GetPlayerPosition()
    if lastMiniMapX == nil
      or lastMiniMapY == nil
      or math.abs(lastMiniMapX - x) > 0.1
      or math.abs(lastMiniMapY - y) > 0.1 then
      minimapCoordsFrame.text:SetFormattedText('%1.1f : %1.1f', x, y)
      lastMiniMapX, lastMiniMapY = x, y
    end
  end
end

local mapTimeSinceUpdate = 0
local lastMapCursorX, lastMapCursorY
local lastMapPlayerX, lastMapPlayerY
local function UpdateWorldMapCoords(self, elapsed)
  mapTimeSinceUpdate = mapTimeSinceUpdate + elapsed
  if mapTimeSinceUpdate < 0.1 then return end
  mapTimeSinceUpdate = 0

  if isInInstance and not IsInInstance() then
    isInInstance = false
  elseif not isInInstance and IsInInstance() then
    isInInstance = true
    worldMapCoordsFrame.cursorText:SetText('')
    worldMapCoordsFrame.playerText:SetText('')
    return
  end
  local cx, cy = GetCursorPosition()
  if lastMapCursorX == nil
      or lastMapCursorY == nil
      or math.abs(lastMapCursorX - cx) > 0.1
      or math.abs(lastMapCursorY - cy) > 0.1 then
    worldMapCoordsFrame.cursorText:SetFormattedText('C: %1.1f : %1.1f', cx, cy)
    lastMapCursorX, lastMapCursorY = cx, cy
  end
  local px, py = GetPlayerPosition()
  if lastMapPlayerX == nil
      or lastMapPlayerY == nil
      or math.abs(lastMapPlayerX - px) > 0.1
      or math.abs(lastMapPlayerY - py) > 0.1 then
    worldMapCoordsFrame.playerText:SetFormattedText('P: %1.1f : %1.1f', px, py)
    lastMapPlayerX, lastMapPlayerY = px, py
  end
end

function module:OnPlayerLogin()
  worldMapCoordsFrame = CreateFrame('Frame', 'Zero_WorldMapCoordsFrame', WorldMapFrame)
  worldMapCoordsFrame:SetSize(100, 32)
  worldMapCoordsFrame:SetPoint('BOTTOMRIGHT', WorldMapFrame.BorderFrame, 'BOTTOMRIGHT', -10, 10)
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
