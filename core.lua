local addOnName, Zero = ...

local pairs = pairs
local wipe = wipe
local coroutine = coroutine

local modules = {}
do
  local frame = CreateFrame('Frame')

  local eventCallbacks = {}
  local invokeAfterCombat = {}
  local registerQueue = {}
  local coroutines = {}
  local hooks = {}

  local deadCoroutines = {}
  frame:SetScript('OnUpdate', function()
    for thread, alive in pairs(coroutines) do
      if not alive or coroutine.status(thread) == 'dead' then
        deadCoroutines[#deadCoroutines + 1] = thread
      else
        coroutine.resume(thread)
      end
    end
    if #deadCoroutines > 0 then
      for i = 1, #deadCoroutines do
        local thread = deadCoroutines[i]
        coroutines[thread] = nil
        deadCoroutines[i] = nil
      end
    end
  end)

  local function ProcessQueue()
    for i = 1, #invokeAfterCombat do
      invokeAfterCombat[i]()
      invokeAfterCombat[i] = nil
    end
  end

  local nestingLevel = 0
  local function ProcessRegisterQueue()
    if not next(registerQueue) == 0 or nestingLevel > 0 then return end
    for event, callbacks in pairs(registerQueue) do
      for self, callback in pairs(callbacks) do
        if not eventCallbacks[event] then
          eventCallbacks[event] = {}
          frame:RegisterEvent(event)
        end
        eventCallbacks[event][self] = callback
      end
    end
    wipe(registerQueue)
  end

  local function FireEvent(event, ...)
    if not eventCallbacks[event] then return end

    nestingLevel = nestingLevel + 1
    for self, callback in pairs(eventCallbacks[event]) do
      if type(callback) == 'string' then
        self[callback](self, ...)
      else
        callback(self, ...)
      end
    end
    nestingLevel = nestingLevel - 1

    ProcessRegisterQueue()
  end

  local function CallbackHandler_OnEvent(_, event, ...)
    if event == 'PLAYER_REGEN_ENABLED' then
      ProcessQueue()
    end
    FireEvent(event, ...)
  end

  frame:SetScript('OnEvent', CallbackHandler_OnEvent)

  local prototype = {}
  local module_mt = {
    __index = prototype
  }

  function prototype:RegisterEvent(event, callback)
    callback = callback or event
    if nestingLevel > 0 then
      if not registerQueue[event] then
        registerQueue[event] = {}
      end
      registerQueue[event][self] = callback
    else
      if not eventCallbacks[event] then
        eventCallbacks[event] = {}
        frame:RegisterEvent(event)
      end
      eventCallbacks[event][self] = callback
    end
  end

  function prototype:UnregisterEvent(event)
    if eventCallbacks[event] then
      eventCallbacks[event][self] = nil
    end
    if not next(eventCallbacks[event]) then
      frame:UnregisterEvent(event)
    end
  end

  local function CreateHook(self, hooks)
    return function(_, ...)
      for hook in pairs(hooks) do
        hook(self, ...)
      end
    end
  end

  local function GetHooks(target, name)
    if target then
      return hooks[target] and hooks[target][name]
    end
    return hooks[name]
  end

  local function SetHooks(target, name, targetHooks)
    if target then
      hooks[target] = hooks[target] or {}
      hooks[target][name] = targetHooks
    else
      hooks[name] = targetHooks
    end
  end

  local function Hook_Function(self, target, name, hook)
    local targetHooks = GetHooks(target, name)
    if not targetHooks then
      targetHooks = {}
      SetHooks(target, name, targetHooks)
      if target then
        hooksecurefunc(target, name, CreateHook(self, targetHooks))
      else
        hooksecurefunc(name, CreateHook(self, targetHooks))
      end
    end
    targetHooks[hook] = true
  end

  local function Hook_Script(self, target, script, hook)
    local targetHooks = GetHooks(target, script)
    if not targetHooks then
      targetHooks = {}
      SetHooks(target, script, targetHooks)
      target:HookScript(script, CreateHook(self, targetHooks))
    end
    targetHooks[hook] = true
  end

  function prototype:Hook(target, name, hook)
    if type(target) == 'string' then
      name, hook, target = target, name, nil
    end
    Hook_Function(self, target, name, hook)
  end

  function prototype:HookScript(target, script, hook)
    if type(target) == 'string' then
      target = _G[target]
    end
    Hook_Script(self, target, script, hook)
  end

  local function Unhook_Function(target, hook)
    local targetHooks = hooks[target]
    if not targetHooks then return end
    targetHooks[hook] = nil
  end

  local function Unhook_Script(target, script, hook)
    local targetHooks = hooks[target]
    if not targetHooks then return end
    local targetScriptHooks = targetHooks[script]
    if not targetScriptHooks then return end
    targetScriptHooks[hook] = nil
  end

  function prototype:Unhook(target, script, hook)
    if type(target) == 'string' then
      target = _G[target]
    end
    if type(target) == 'function' then
      Unhook_Function(target, script)
    else
      Unhook_Script(target, script, hook)
    end
  end

  local function IsHooked_Function(target, hook)
    local targetHooks = hooks[target]
    if not targetHooks then
      return false
    end
    if not hook then
      return true
    end
    return targetHooks[hook]
  end

  local function IsHooked_Script(target, script, hook)
    local targetHooks = hooks[target]
    if not targetHooks then
      return false
    end
    local targetScriptHooks = targetHooks[script]
    if not targetScriptHooks then
      return false
    end
    if not hook then
      return true
    end
    return targetScriptHooks[hook]
  end

  function prototype:IsHooked(target, script, hook)
    if type(target) == 'string' then
      target = _G[target]
    end
    if type(target) == 'function' then
      return IsHooked_Function(target, script)
    end
    return IsHooked_Script(target, script, hook)
  end

  function prototype:SafeInvoke(func)
    if type(func) == 'string' then
      func = function(...)
        self[func](self, ...)
      end
    end
    if not func then return end
    if InCombatLockdown() then
      invokeAfterCombat[#invokeAfterCombat + 1] = func
    else
      func()
    end
  end

  function prototype:StartCoroutine(f)
    local thread = coroutine.create(f)
    coroutines[thread] = true
    return thread
  end

  function prototype:StopCoroutine(thread)
    coroutines[thread] = false
  end

  function prototype:ScheduleTimer(delay, action, onComplete)
    local timer = {}
    timer.delay = delay
    if type(action) == 'function' then
      timer.action = action
    else
      local f = self[action]
      timer.action = function()
        f(self)
      end
    end

    local function callback()
      if not timer.cancelled and timer.action() then
        C_Timer.After(delay, callback)
      elseif onComplete and not timer.completed then
        timer.completed = true
        onComplete()
      end
    end

    C_Timer.After(delay, callback)
    return timer
  end

  function prototype:OnAddOnLoaded(name)
    -- do nothing
  end

  function prototype:OnLoad()
    -- do nothing
  end

  function prototype:OnPlayerLogin()
    -- do nothing
  end

  function prototype:RegisterChatCommand(command, f)
    local name = 'ZERO_CMD_' .. command:upper()

    if type(f) == 'string' then
      SlashCmdList[name] = function(input, editBox)
        self[f](self, input, editBox)
      end
    else
      SlashCmdList[name] = f
    end
    _G['SLASH_' .. name .. '1'] = '/' .. command:lower()
  end

  function Zero.Module(name)
    if modules[name] then
      error(('module %s already registered'):format(name))
    end
    local module = setmetatable({ name = name }, module_mt)
    modules[name] = module
    return module
  end
end

local frame = CreateFrame('Frame')

local loadedModules = {}
local function Zero_OnAddOnLoaded(name)
  for _, module in pairs(modules) do
    if name == addOnName then
        module:OnLoad()
        loadedModules[#loadedModules + 1] = module
    else
      module:OnAddOnLoaded(name)
    end
  end
  wipe(modules)
end

local function Zero_OnPlayerLogin()
  for _, module in ipairs(loadedModules) do
    module:OnPlayerLogin()
  end
  wipe(loadedModules)
end

local eventCallbacks = {
  ADDON_LOADED = Zero_OnAddOnLoaded,
  PLAYER_LOGIN = Zero_OnPlayerLogin,
}

local function Zero_OnEvent(_, event, ...)
  if eventCallbacks[event] then
    eventCallbacks[event](...)
  end
end

frame:SetScript('OnEvent', Zero_OnEvent)

for event in pairs(eventCallbacks) do
  frame:RegisterEvent(event)
end

function Zero.IsTaintable()
  return InCombatLockdown() or UnitAffectingCombat('player') or UnitAffectingCombat('pet')
end

function Zero.FormatMoney(c)
  local g, s
  g, c = floor(c / 10000), c % 10000
  s, c = floor(c / 100 ), c % 100
  return ('|cffffffff%dg |cffffffff%ss |cffffffff%dc.'):format(g, s, c)
end
