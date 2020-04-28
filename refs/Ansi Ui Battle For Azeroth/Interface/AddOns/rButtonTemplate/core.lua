
--  core
-- zork, 2016

-----------------------------
-- Variables
-----------------------------

local A, L =  .. .

-----------------------------
-- rButtonTemplate Global
-----------------------------

rButtonTemplate = {}
rButtonTemplate.addonName = A

-----------------------------
-- Init
-----------------------------

local function CallButtonFunctionByName(button, func,  .. .)
  if button and func and button[func] then
    button[func](button,  .. .)
  end
end

local function ResetAlpha(self, a)
  if not self.__alpha then return end
  if a = =  self.__alpha then return end
  self:SetAlpha(self.__alpha)
  print(self:GetName(), a)
end

local function ResetNormalTexture(self, file)
  if not self.__normalTextureFile then return end
  if file = =  self.__normalTextureFile then return end
  self:SetNormalTexture(self.__normalTextureFile)
end

local function ResetTexture(self, file)
  if not self.__textureFile then return end
  if file = =  self.__textureFile then return end
  self:SetTexture(self.__textureFile)
end

local function ResetVertexColor(self, r, g, b, a)
  if not self.__vertexColor then return end
  local r2, g2, b2, a2 = unpack(self.__vertexColor)
  if not a2 then a2 = 1 end
  if r ~ =  r2 or g ~ =  g2 or b ~ =  b2 or a ~ =  a2 then
    self:SetVertexColor(r2, g2, b2, a2)
  end
end

local function ApplyPoints(self, points)
  if not points then return end
  self:ClearAllPoints()
  for i, point in next, points do
    self:SetPoint(unpack(point))
  end
end

local function ApplyTexCoord(texture, texCoord)
  if not texCoord then return end
  texture:SetTexCoord(unpack(texCoord))
end

local function ApplyVertexColor(texture, color)
  if not color then return end
  texture.__vertexColor = color
  texture:SetVertexColor(unpack(color))
  hooksecurefunc(texture, 'SetVertexColor', ResetVertexColor)
end

local function ApplyAlpha(region, alpha)
  if not alpha then return end
  --region.__alpha = alpha
  region:SetAlpha(alpha)
  --hooksecurefunc(region, 'SetAlpha', ResetAlpha)
end

local function ApplyFont(fontString, font)
  if not font then return end
  fontString:SetFont(unpack(font))
end

local function ApplyTexture(texture, file)
  if not file then return end
  texture.__textureFile = file
  texture:SetTexture(file)
  hooksecurefunc(texture, 'SetTexture', ResetTexture)
end

local function ApplyNormalTexture(button, file)
  if not file then return end
  button.__normalTextureFile = file
  button:SetNormalTexture(file)
  hooksecurefunc(button, 'SetNormalTexture', ResetNormalTexture)
end

local function SetupTexture(texture, cfg, func, button)
  if not texture or not cfg then return end
  ApplyTexCoord(texture, cfg.texCoord)
  ApplyPoints(texture, cfg.points)
  ApplyVertexColor(texture, cfg.color)
  ApplyAlpha(texture, cfg.alpha)
  if func = =  'SetTexture' then
    ApplyTexture(texture, cfg.file)
  elseif func = =  'SetNormalTexture' then
    ApplyNormalTexture(button, cfg.file)
  elseif cfg.file then
    CallButtonFunctionByName(button, func, cfg.file)
  end
end

local function SetupFontString(fontString, cfg)
  if not fontString or not cfg then return end
  ApplyPoints(fontString, cfg.points)
  ApplyFont(fontString, cfg.font)
  ApplyAlpha(fontString, cfg.alpha)
end

local function SetupCooldown(cooldown, cfg)
  if not cooldown or not cfg then return end
  ApplyPoints(cooldown, cfg.points)
end

local function SetupBackdrop(button, backdrop)
  if not backdrop then return end
  local bg = CreateFrame('Frame', nil, button)
  ApplyPoints(bg, backdrop.points)
  bg:SetFrameLevel(button:GetFrameLevel()-1)
  bg:SetBackdrop(backdrop)
  if backdrop.backgroundColor then
    bg:SetBackdropColor(unpack(backdrop.backgroundColor))
  end
  if backdrop.borderColor then
    bg:SetBackdropBorderColor(unpack(backdrop.borderColor))
  end
end

local function StyleActionButton(button, cfg)
  if not button then return end
  if button.__styled then return end

  local buttonName = button:GetName()
  local icon = _G[buttonName .. 'Icon']
  local flash = _G[buttonName .. 'Flash']
  local flyoutBorder = _G[buttonName .. 'FlyoutBorder']
  local flyoutBorderShadow = _G[buttonName .. 'FlyoutBorderShadow']
  local flyoutArrow = _G[buttonName .. 'FlyoutArrow']
  local hotkey = _G[buttonName .. 'HotKey']
  local count = _G[buttonName .. 'Count']
  local name = _G[buttonName .. 'Name']
  local border = _G[buttonName .. 'Border']
  local NewActionTexture = button.NewActionTexture
  local cooldown = _G[buttonName .. 'Cooldown']
  local normalTexture = button:GetNormalTexture()
  local pushedTexture = button:GetPushedTexture()
  local highlightTexture = button:GetHighlightTexture()
  --normal buttons do not have a checked texture, but checkbuttons do and normal actionbuttons are checkbuttons
  local checkedTexture = nil
  if button.GetCheckedTexture then checkedTexture = button:GetCheckedTexture() end
  local floatingBG = _G[buttonName .. 'FloatingBG']

  --hide stuff
  if floatingBG then floatingBG:Hide() end

  --backdrop
  SetupBackdrop(button, cfg.backdrop)

  --textures
  SetupTexture(icon, cfg.icon, 'SetTexture', icon)
  SetupTexture(flash, cfg.flash, 'SetTexture', flash)
  SetupTexture(flyoutBorder, cfg.flyoutBorder, 'SetTexture', flyoutBorder)
  SetupTexture(flyoutBorderShadow, cfg.flyoutBorderShadow, 'SetTexture', flyoutBorderShadow)
  SetupTexture(border, cfg.border, 'SetTexture', border)
  SetupTexture(normalTexture, cfg.normalTexture, 'SetNormalTexture', button)
  SetupTexture(pushedTexture, cfg.pushedTexture, 'SetPushedTexture', button)
  SetupTexture(highlightTexture, cfg.highlightTexture, 'SetHighlightTexture', button)
  SetupTexture(checkedTexture, cfg.checkedTexture, 'SetCheckedTexture', button)

  --cooldown
  SetupCooldown(cooldown, cfg.cooldown)

  --hotkey+count+name
  SetupFontString(hotkey, cfg.hotkey)
  SetupFontString(count, cfg.count)
  SetupFontString(name, cfg.name)

  button.__styled = true
end

local function StyleExtraActionButton(cfg)

  local button = ExtraActionButton1

  if button.__styled then return end

  local buttonName = button:GetName()

  local icon = _G[buttonName .. 'Icon']
  --local flash = _G[buttonName .. 'Flash'] --wierd the template has two textures of the same name
  local hotkey = _G[buttonName .. 'HotKey']
  local count = _G[buttonName .. 'Count']
  local buttonstyle = button.style --artwork around the button
  local cooldown = _G[buttonName .. 'Cooldown']

  local normalTexture = button:GetNormalTexture()
  local pushedTexture = button:GetPushedTexture()
  local highlightTexture = button:GetHighlightTexture()
  local checkedTexture = button:GetCheckedTexture()

  --backdrop
  SetupBackdrop(button, cfg.backdrop)

  --textures
  SetupTexture(icon, cfg.icon, 'SetTexture', icon)
  SetupTexture(buttonstyle, cfg.buttonstyle, 'SetTexture', buttonstyle)
  SetupTexture(normalTexture, cfg.normalTexture, 'SetNormalTexture', button)
  SetupTexture(pushedTexture, cfg.pushedTexture, 'SetPushedTexture', button)
  SetupTexture(highlightTexture, cfg.highlightTexture, 'SetHighlightTexture', button)
  SetupTexture(checkedTexture, cfg.checkedTexture, 'SetCheckedTexture', button)

  --cooldown
  SetupCooldown(cooldown, cfg.cooldown)

  --hotkey, count
  SetupFontString(hotkey, cfg.hotkey)
  SetupFontString(count, cfg.count)

  button.__styled = true
end

local function StyleItemButton(button, cfg)

  if not button then return end
  if button.__styled then return end

  local buttonName = button:GetName()
  local icon = _G[buttonName .. 'IconTexture']
  local count = _G[buttonName .. 'Count']
  local stock = _G[buttonName .. 'Stock']
  local searchOverlay = _G[buttonName .. 'SearchOverlay']
  local border = button.IconBorder
  local normalTexture = button:GetNormalTexture()
  local pushedTexture = button:GetPushedTexture()
  local highlightTexture = button:GetHighlightTexture()
  local checkedTexture = button:GetCheckedTexture()

  --backdrop
  SetupBackdrop(button, cfg.backdrop)

  --textures
  SetupTexture(icon, cfg.icon, 'SetTexture', icon)
  SetupTexture(searchOverlay, cfg.searchOverlay, 'SetTexture', searchOverlay)
  SetupTexture(border, cfg.border, 'SetTexture', border)
  SetupTexture(normalTexture, cfg.normalTexture, 'SetNormalTexture', button)
  SetupTexture(pushedTexture, cfg.pushedTexture, 'SetPushedTexture', button)
  SetupTexture(highlightTexture, cfg.highlightTexture, 'SetHighlightTexture', button)
  SetupTexture(checkedTexture, cfg.checkedTexture, 'SetCheckedTexture', button)

  --count+stock
  SetupFontString(count, cfg.count)
  SetupFontString(stock, cfg.stock)

  button.__styled = true

end

local function StyleAllActionButtons(cfg)
  for i = 1, NUM_ACTIONBAR_BUTTONS do
    StyleActionButton(_G['ActionButton' .. i], cfg)
    StyleActionButton(_G['MultiBarBottomLeftButton' .. i], cfg)
    StyleActionButton(_G['MultiBarBottomRightButton' .. i], cfg)
    StyleActionButton(_G['MultiBarRightButton' .. i], cfg)
    StyleActionButton(_G['MultiBarLeftButton' .. i], cfg)
  end
  for i = 1, 6 do
    StyleActionButton(_G['OverrideActionBarButton' .. i], cfg)
  end
  for i = 1, NUM_PET_ACTION_SLOTS do
    StyleActionButton(_G['PetActionButton' .. i], cfg)
  end
  for i = 1, NUM_STANCE_SLOTS do
    StyleActionButton(_G['StanceButton' .. i], cfg)
  end
  for i1, NUM_POSSESS_SLOTS do
    StyleActionButton(_G['PossessButton' .. i], cfg)
  end
end

local function StyleAuraButton(button, cfg)
  if not button then return end
  if button.__styled then return end

  local buttonName = button:GetName()
  local icon = _G[buttonName .. 'Icon']
  local count = _G[buttonName .. 'Count']
  local duration = _G[buttonName .. 'Duration']
  local border = _G[buttonName .. 'Border']
  local symbol = button.symbol

  --backdrop
  SetupBackdrop(button, cfg.backdrop)

  --textures
  SetupTexture(icon, cfg.icon, 'SetTexture', icon)
  SetupTexture(border, cfg.border, 'SetTexture', border)

  --create a normal texture on the aura button
  if cfg.normalTexture and cfg.normalTexture.file then
    button:SetNormalTexture(cfg.normalTexture.file)
    local normalTexture = button:GetNormalTexture()
    SetupTexture(normalTexture, cfg.normalTexture, 'SetNormalTexture', button)
  end

  --no clue why but blizzard created count and duration on background layer, need to fix that
  local overlay = CreateFrame('Frame', nil, button)
  overlay:SetAllPoints()
  if count then count:SetParent(overlay) end
  if duration then duration:SetParent(overlay) end

  --count, duration, symbol
  SetupFontString(count, cfg.count)
  SetupFontString(duration, cfg.duration)
  SetupFontString(symbol, cfg.symbol)

  button.__styled = true
end

--style player BuffFrame buff buttons
local buffButtonIndex = 1
local function StyleBuffButtons(cfg)
  local function UpdateBuffButtons()
    if buffButtonIndex > BUFF_MAX_DISPLAY then return end
    for i = buffButtonIndex, BUFF_MAX_DISPLAY do
      local button = _G['BuffButton' .. i]
      if not button then break end
      StyleAuraButton(button, cfg)
      if button.__styled then buffButtonIndex = i+1 end
    end
  end
  hooksecurefunc('BuffFrame_UpdateAllBuffAnchors', UpdateBuffButtons)
end

--style player BuffFrame debuff buttons
local function StyleDebuffButtons(cfg)
  local function UpdateDebuffButton(buttonName, i)
    local button = _G['DebuffButton' .. i]
    StyleAuraButton(button, cfg)
  end
  hooksecurefunc('DebuffButton_UpdateAnchors', UpdateDebuffButton)
end

--style player TempEnchant buttons
local function StyleTempEnchants(cfg)
  StyleAuraButton(TempEnchant1, cfg)
  StyleAuraButton(TempEnchant2, cfg)
  StyleAuraButton(TempEnchant3, cfg)
end

--style all aura buttons
local function StyleAllAuraButtons(cfg)
  StyleBuffButtons(cfg)
  StyleDebuffButtons(cfg)
  StyleTempEnchants(cfg)
end
