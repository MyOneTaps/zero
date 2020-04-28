local _, Zero = ...

local module = Zero.Module('Errors')

local BLACK_LISTED_MESSAGE_TYPES = {
  [LE_GAME_ERR_ABILITY_COOLDOWN] = true,           -- Ability is not ready yet. (Ability)
  [LE_GAME_ERR_ITEM_COOLDOWN] = true,
  [LE_GAME_ERR_BADATTACKPOS] = true,
  [LE_GAME_ERR_OUT_OF_ENERGY] = true,              -- Not enough energy. (Err)
  [LE_GAME_ERR_OUT_OF_RANGE] = true,
  [LE_GAME_ERR_OUT_OF_RAGE] = true,                -- Not enough rage.
  [LE_GAME_ERR_OUT_OF_FOCUS] = true,                -- Not enough focus
  [LE_GAME_ERR_NO_ATTACK_TARGET] = true,           -- There is nothing to attack.
  [LE_GAME_ERR_NOT_WHILE_MOVING] = true,
  [LE_GAME_ERR_AFFECTING_COMBAT] = true,
  [LE_GAME_ERR_NOT_IN_COMBAT] = true,
--  [LE_GAME_SPELL_FAILED_UNIT_NOT_INFRONT] = true,
  [LE_GAME_ERR_BADATTACKFACING] = true,
--  [LE_GAME_SPELL_FAILED_TOO_CLOSE] = true,
  [LE_GAME_ERR_INVALID_ATTACK_TARGET] = true,      -- You cannot attack that target.
  [LE_GAME_ERR_SPELL_COOLDOWN] = true,             -- Spell is not ready yet. (Spell)
--  [LE_GAME_SPELL_FAILED_NO_COMBO_POINTS] = true,   -- That ability requires combo points.
--  [LE_GAME_SPELL_FAILED_TARGETS_DEAD] = true,      -- Your target is dead.
--  [LE_GAME_SPELL_FAILED_SPELL_IN_PROGRESS] = true, -- Another action is in progress. (Spell)
  -- [LE_GAME_SPELL_FAILED_TARGET_AURASTATE] = true,  -- You can't do that yet. (TargetAura)
  -- [LE_GAME_SPELL_FAILED_CASTER_AURASTATE] = true,  -- You can't do that yet. (CasterAura)
  -- [LE_GAME_SPELL_FAILED_NO_ENDURANCE] = true,      -- Not enough endurance
  -- [LE_GAME_SPELL_FAILED_BAD_TARGETS] = true,       -- Invalid target
  -- [LE_GAME_SPELL_FAILED_NOT_MOUNTED] = true,       -- You are mounted
  -- [LE_GAME_SPELL_FAILED_NOT_ON_TAXI] = true,       -- You are in flight
}

local function ShouldDisplayMessageType(messageType, message)
  if BLACK_LISTED_MESSAGE_TYPES[messageType] then
    return false
  end
  return UIErrorsFrame:ShouldDisplayMessageType(messageType, message)
end

local function TryDisplayMessage(messageType, message, r, g, b)
  if ShouldDisplayMessageType(messageType, nessage) then
    UIErrorsFrame:AddMessage(message, r, g, b, 1.0, messageType);
  end
end

function module:UI_ERROR_MESSAGE(messageType, message)
  TryDisplayMessage(messageType, message, RED_FONT_COLOR:GetRGB())
end

function module:OnPlayerLogin()
  UIErrorsFrame:UnregisterEvent('UI_ERROR_MESSAGE')
  module:RegisterEvent('UI_ERROR_MESSAGE')
end
