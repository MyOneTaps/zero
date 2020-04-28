local _, Zero = ...

local module = Zero.Module('Xp')

local infoFrame

local NSAMPLES = 4

local samples = {}
local sampleIndex = 0
local function AddSample(time, xp)
  sampleIndex = sampleIndex + 1
  if sampleIndex > NSAMPLES then
    sampleIndex = 1
  end
  if samples[sampleIndex] then
    samples[sampleIndex].time = time
    samples[sampleIndex].xp = xp
  else
    samples[sampleIndex] = {
      time = time,
      xp = xp,
    }
  end
end

local function FormatTime(label, seconds, delta)
  local minutes = math.floor (seconds / 60)
  seconds = math.floor (seconds - (minutes * 60))
  return string.format('%s %d:%.2d', label, minutes, seconds)
end

local function FormatXpPerHour(label, xpPerHour, delta)
  local result
  if xpPerHour > 1000 then
    xpPerHour = xpPerHour / 1000
    return string.format('%s %.1fK', label, xpPerHour)
  end
  return string.format('%s %d', label, xpPerHour)
end

local startTime
local xpGained = 0
local playerLevel, playerXp, playerXpMax

local xpPerSecond, smoothedXpPerSecond
local lastXpPerSecond, lastSmoothedXpPerSecond
local timeToLevel, smoothedTimeToLevel

local function SetTextColor(text1, text2, lastXpPerSecond, xpPerSecond)
  if not lastXpPerSecond or lastXpPerSecond == xpPerSecond then
    text1:SetTextColor(1, 1, 1)
    text2:SetTextColor(1, 1, 1)
  elseif lastXpPerSecond > xpPerSecond then
    text1:SetTextColor(1, 0, 0)
    text2:SetTextColor(1, 0, 0)
  else
    text1:SetTextColor(0, 1, 0)
    text2:SetTextColor(0, 1, 0)
  end
end

local function UpdatePanel()
  local xpPerHour = FormatXpPerHour('XPH', xpPerSecond * 3600)
  local timeToLevel = FormatTime('TTL', (playerXpMax - playerXp) / xpPerSecond)
  frame.xpPerHour:SetText(xpPerHour)
  frame.timeToLevel:SetText(timeToLevel)
  SetTextColor(frame.xpPerHour, frame.timeToLevel, lastXpPerSecond, xpPerSecond)
  if smoothedXpPerSecond then
    xpPerHour = FormatXpPerHour('XPH3', xpPerSecond * 3600)
    timeToLevel = FormatTime('TTL3', (playerXpMax - playerXp) / smoothedXpPerSecond)
    frame.smoothedxpPerHour:SetText(xpPerHour)
    frame.smoothedTimeToLevel:SetText(timeToLevel)
    SetTextColor(frame.smoothedxpPerHour, frame.smoothedTimeToLevel, lastSmoothedXpPerSecond, smoothedXpPerSecond)
  end
end

local function CalculateSmoothedXpPerSecond()
  local index = sampleIndex - 3
  if index < 1 then
    index = index + NSAMPLES
  end
  local s0 = samples[index]
  if not s0 then
    return
  end
  local sum = 0
  for i = 1, 3 do
    local j = index + 1
    if index == NSAMPLES then
      index = 1
    end
    local s1 = samples[index + 1]

    local xpDiff = s1.xp - s0.xp
    local timeDiff = s1.time - s0.time
    sum = sum + (xpDiff / timeDiff)

    s0 = s1
    index = index + 1
  end
  return sum / 3
end

function module:PLAYER_XP_UPDATE()
  local now = GetTime()
  local level = UnitLevel('player')
  local xp = UnitXP('player')
  local xpMax = UnitXPMax('player')

  local xpDiff
  if level > playerLevel then
    xpDiff = playerXpMax - playerXp + xp
    playerLevel = level
    playerXpMax = xpMax
  else
    xpDiff = xp - playerXp
  end
  xpGained = xpGained + xpDiff
  local timeDiff = now - startTime
  if xpDiff > 0 and timeDiff > 0 then
    AddSample(now, xpGained)
    lastXpPerSecond = xpPerSecond
    lastSmoothedXpPerSecond = smoothedXpPerSecond
    xpPerSecond = xpGained / timeDiff
    smoothedXpPerSecond =  CalculateSmoothedXpPerSecond()
  end
  playerXp = xp
  UpdatePanel()
end

function module:OnLoad()
  frame = CreateFrame('Frame', 'Zero_Xp')
  frame:SetSize(100, 64)
  frame:SetPoint('TOPLEFT', 10, -10)

  local function CreateFontString()
    local fs = frame:CreateFontString(nil, 'OVERLAY')
    fs:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
    return fs
  end

  frame.xpPerHour = CreateFontString()
  frame.xpPerHour:SetPoint('TOPLEFT', 0, 0)

  frame.timeToLevel = CreateFontString()
  frame.timeToLevel:SetPoint('TOPLEFT', 0, -10)

  frame.smoothedxpPerHour = CreateFontString()
  frame.smoothedxpPerHour:SetPoint('TOPLEFT', 0, -20)

  frame.smoothedTimeToLevel = CreateFontString()
  frame.smoothedTimeToLevel:SetPoint('TOPLEFT', 0, -30)
end

function module:OnPlayerLogin()
  playerLevel = UnitLevel('player')
  if playerLevel == MAX_PLAYER_LEVEL or IsXPUserDisabled() then
    return
  end
  startTime = GetTime()
  playerXp = UnitXP('player')
  playerXpMax = UnitXPMax('player')
  AddSample(startTime, 0)
  self:RegisterEvent('PLAYER_XP_UPDATE')
end
