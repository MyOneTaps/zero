local _, Zero = ...

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local ldbIcon = LibStub("LibDBIcon-1.0")

local defaults = {
  ['hide'] = false,
}

local function IconUpdate(name)
  local dataObject = ldb:GetDataObjectByName(name)
  if ldbIcon then
    local db = dataObject['zero']['db']
    db[name] = db[name] or CopyTable(defaults)
    if(db[name]['hide']) then
      ldbIcon:Hide(name)
    else
      ldbIcon:Show(name)
    end
  end
end

local function ldbOnClick(self, button)
  local name = ldb:GetNameByDataObject(self)
  if(IsShiftKeyDown() and button == "LeftButton") then
    if(not ldbIcon) then return end
    local db = self['zero']['db']
    db[name]['hide'] = not db[name]['hide']
    IconUpdate(name)
  else
    if(InterfaceOptionsFrame:IsVisible() and not InCombatLockdown()) then
      InterfaceOptionsFrame:Hide()
    else
      InterfaceOptionsFrame_OpenToCategory(name)
      InterfaceOptionsFrame_OpenToCategory(name) -- Twice because of a bug in InterfaceOptionsFrame_OpenToCategory
    end
  end
end

local function minimapGet(pref)
  local name = pref[#pref - 2]
  local dataObject = ldb:GetDataObjectByName(name)
  local db = dataObject['zero']['db']
  return db[name][pref[#pref]]
end

local function minimapSet(pref,value)
  local name = pref[#pref - 2]
  local dataObject = ldb:GetDataObjectByName(name)
  local db = dataObject['zero']['db']
  db[name][pref[#pref]] = value
  IconUpdate(name)
end

local lib = {}
function lib:AddLDB(name, obj)
  obj = obj or {}
  local icon = (self['name'] and "Interface\\AddOns\\"..self['parentName'].."\\"..name.."\\icon2.tga" or "Interface\\AddOns\\"..name.."\\icon2.tga")
  local dataObject = ldb:GetDataObjectByName(name) or ldb:NewDataObject(name, {
    ['type'] = obj['type'] or 'launcher',
    ['text'] = obj['text'] or name,
    ['icon'] = obj['icon'] or icon,
    ['zero'] = {}
  })
  dataObject['OnClick'] = type(obj['OnClick']) == 'function' and function(_, button) obj['OnClick'](dataObject, button) end or function(_, button) ldbOnClick(dataObject, button) end
  dataObject['OnTooltipShow'] = type(obj['OnTooltipShow']) == 'function' and obj['OnTooltipShow'] or nil
  if(dataObject and ldbIcon) then
    self['db']['global']['ldbicons'] = self['db']['global']['ldbicons'] or {}
    local db = self['db']['global']['ldbicons']
    dataObject['zero']['db'] = self['db']['global']['ldbicons']
    db[name] = db[name] or CopyTable(defaults)
    if(not ldbIcon:IsRegistered(name)) then
      ldbIcon:Register(name,dataObject,db[name])
    end
    IconUpdate(name)
  end
end
function lib:OnText(name, message)
  ldb:GetDataObjectByName(name)['text'] = message
end
function lib:AddLDBIconOptions()
   return {
    ['name']="Minimapicon",
    ['type']='group',
    ['inline']=true,
    ['get'] = minimapGet,
    ['set'] = minimapSet,
    ['order'] = 100,
    ['args']={
      ['hide'] ={
        ['type'] = 'toggle',
        ['name'] = "Hide Minimapicon",
      },
      ['minimapPos'] ={
        ['type'] = 'range',
        ['name'] = "Minimapicon Position",
        ['min'] = 1,
        ['max'] = 250,
        ['step']=1,
      }
    }
  }
end
embed(lib)
