local _, Zero = ...

ZeroDB = ZeroDB or {}

do
  local realmKey = GetRealmName()
  local charKey = UnitName('player') .. ' - ' .. realmKey
  local _, classKey = UnitClass('player')
  local _, raceKey = UnitRace('player')
  local factionKey = UnitFactionGroup('player')
  local factionRealmKey = factionKey .. ' - ' .. realmKey

  local keys = {
    ['char'] = charKey,
    ['realm'] = realmKey,
    ['class'] = classKey,
    ['race'] = raceKey,
    ['faction'] = factionKey,
    ['factionrealm'] = factionRealmKey,
    ['profile'] = profileKey,
    ['global'] = true,
    ['profiles'] = true,
  }

  Zero.db = setmetatable(ZeroDB, {
    __index = function(db, section)
      local key = keys[section]
      if not key then
        return rawget(db, section)
      end
      db[section] = {}
      return db[section]
    end
  })
end
