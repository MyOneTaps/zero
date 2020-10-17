local _, Zero = ...

local module = Zero.Module('Stats')

local function ColorGradient(pct, ...)
  if pct >= 1 then
    local r, g, b = select(select('#', ...) - 2, ...)
    return r, g, b
  elseif pct <= 0 then
    local r, g, b = ...
    return r, g, b
  end

  local num = select('#', ...) / 3

  local segment, relperc = math.modf(pct*(num-1))
  local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

  return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

local function CreateText()
  frame = CreateFrame('Frame')
  frame:SetFrameStrata('BACKGROUND')
  frame:SetSize(100, 10)
  frame:SetPoint('BOTTOMLEFT', 10, 1)

  local text = frame:CreateFontString(nil, 'OVERLAY')
  text:SetFont(STANDARD_TEXT_FONT, 8, 'THINOUTLINE')
  text:SetPoint('LEFT', frame, 'LEFT', 0, 0)
  return text
end

local text
local function SetText()
  if not text then
    text = CreateText()
  end

  local fps = GetFramerate()
  local r, g, b = ColorGradient(fps/60, 1,0,0, 1,1,0, 0,1,0)
  local _, _, lh, lw = GetNetStats()
  local rl, gl, bl = ColorGradient(((lh+lw)/2)/1000, 0,1,0, 1,1,0, 1,0,0)
  text:SetText(format("|cff%02x%02x%02x%.0f|r |cffE8D200fps|r |cff%02x%02x%02x%.0f|r |cffE8D200ms|r", r*255, g*255, b*255, fps, rl*255, gl*255, bl*255, lw))
end

function module:OnLoad()
  C_Timer.NewTicker(1, SetText)
end

