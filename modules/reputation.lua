local _, Zero = ...

local module = Zero.Module('Reputation')

local factions = {}
local labels = setmetatable({}, {
  __index = function(self, n)
    self[n] = _G['FACTION_STANDING_LABEL' ..  n]
    return self[n]
  end
})

local lastNumFactions
local currentUpdater
function module:UpdateFactions(dump)
  if currentUpdater ~= nil then
    self:StopCoroutine(currentUpdater)
  end
  self.watchedFaction = GetWatchedFactionInfo()
  currentUpdater = self:StartCoroutine(function()
    for i = 1, GetNumFactions() do
      self:ProcessFaction(i, dump)
      coroutine.yield()
    end
    currentUpdater = nil
  end)
end

function module:ProcessFaction(i, dump)
  local name, _, standingID, _, barMax, barValue, _, _, isHeader, _, hasRep = GetFactionInfo(i)
  if isHeader and not hasRep then return end
  if not factions[name] then
    factions[name] = {
      initalReputation = barValue,
      reputation = barValue,
      standing = standingID
    }
  elseif dump then
    local faction = factions[name]
    local left = barMax - barValue
    if barValue > faction.reputation then
      local message = FACTION_STANDING_INCREASED:format(name, barValue - faction.reputation)
      message = ('|cFF7F7FFF%s (Total: %d, Left: %d)'):format(message, barValue - faction.initalReputation, left)
      self:Print(message)
    elseif barValue < faction.reputation then
      local message = FACTION_STANDING_INCREASED:format(name, faction.reputation - barValue)
      message = ('|cFF7F7FFF%s (Total: %d, Left: %d)'):format(message, barValue - faction.initalReputation, left)
      self:Print(message)
    end
    if UnitLevel('player') == 120 and barValue ~= faction.reputation and i ~= self.watchedFaction then
      SetWatchedFactionIndex(i)
    end

    if faction.standing ~= standingID then
      local message = FACTION_STANDING_CHANGED:format(labels[standingID], name)
      message = ('|cFF6060C0%s'):format(message)
      self:Print(message)
    end

    if standingID == 8 and left == 1 then
      SetFactionInactive(i)
    end

    faction.reputation = barValue
    faction.standing = standingID
  end
end

function module:UPDATE_FACTION()
  self:UpdateFactions(true)
end

function module:Print(...)
  self.chatFrame:AddMessage(...)
end

function module:OnPlayerLogin()
  if ChatFrame3 and ChatFrame3:IsShown() then
    self.chatFrame = ChatFrame3
  else
    self.chatFrame = ChatFrame1
  end
  self:UpdateFactions()
  self:RegisterEvent('UPDATE_FACTION')
end
