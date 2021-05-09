local _, Zero = ...

local module = Zero.Module('Chat')

local FontSize = 10

local function UpdatePosition(i, chatFrame)
  chatFrame = chatFrame or _G[format('ChatFrame%s', i)]
  if i == 1 then
    chatFrame:ClearAllPoints()
    chatFrame:SetPoint('BOTTOMLEFT', UIParent, 'BOTTOMLEFT', 32, 125)
  elseif i == 3 then
    chatFrame:ClearAllPoints()
    local xOffset = 10 + 45 - 7 + 45
    chatFrame:SetPoint('BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -xOffset, 125)
  end
  FCF_SavePositionAndDimensions(chatFrame)
  FCF_StopDragging(chatFrame)
  if chatFrame:IsMovable() then
    chatFrame:SetUserPlaced(true)
  end
end

local function SetupChat()
  -- Hide Battle.net Social Button and Toasts
  ChatFrameMenuButton:HookScript('OnShow', ChatFrameMenuButton.Hide)
  ChatFrameMenuButton:Hide()
  ChatFrameChannelButton:HookScript('OnShow', ChatFrameMenuButton.Hide)
  ChatFrameChannelButton:Hide()
  local button = QuickJoinToastButton or FriendsMicroButton
  button:HookScript('OnShow', button.Hide)
  button:Hide()
  BNToastFrame:SetClampedToScreen(true)
  BNToastFrame:SetClampRectInsets(-15,15,15,-15)

  -- Change Edit Box Font
  ChatFontNormal:SetFont(ZERO_CHAT_FONT, FontSize, 'THINOUTLINE')
  ChatFontNormal:SetShadowOffset(1,-1)
  ChatFontNormal:SetShadowColor(0,0,0,0.6)

  FCF_ResetChatWindows()
  FCF_SetLocked(ChatFrame1, 1)
  FCF_DockFrame(ChatFrame2)
  FCF_SetLocked(ChatFrame2, 1)

  FCF_OpenNewWindow(LOOT)
  FCF_UnDockFrame(ChatFrame3)
  FCF_SetLocked(ChatFrame3, 1)
  ChatFrame3:Show()
  ChatFrame3.buttonFrame:SetScript('OnShow', function(self)
    self:Hide()
  end)
  ChatFrame3.buttonFrame:Hide()

  for i = 1, NUM_CHAT_WINDOWS do
    local chatFrameName = 'ChatFrame' .. i
    local chatFrame = _G[chatFrameName]
    local name, size, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i);

    FCF_SetChatWindowFontSize(nil, chatFrame, 12)

    -- Remove Screen Clamping
    chatFrame:SetClampRectInsets(0, 0, 0, 0)
    chatFrame:SetMinResize(100, 50)
    chatFrame:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())

    -- Style Tab Fonts
    local tab = _G[chatFrameName..'Tab'];
    local tabFont = tab:GetFontString();
    tab:SetAlpha(1)
    tabFont:SetFont(ZERO_UI_FONT, FontSize, 'THINOUTLINE');
    tabFont:SetShadowOffset( 1, -1 );
    tabFont:SetShadowColor( 0, 0, 0, 0.6 );

    --Hide Tab Backgrounds
    _G[chatFrameName..'TabLeft']:SetTexture( nil );
    _G[chatFrameName..'TabMiddle']:SetTexture( nil );
    _G[chatFrameName..'TabRight']:SetTexture( nil );
    _G[chatFrameName..'TabSelectedLeft']:SetTexture(nil)
    _G[chatFrameName..'TabSelectedMiddle']:SetTexture(nil)
    _G[chatFrameName..'TabSelectedRight']:SetTexture(nil)

    -- Stop Chat Arrows Coming Back
    _G[chatFrameName..'ButtonFrame']:Hide();
    _G[chatFrameName..'ButtonFrame']:HookScript('OnShow', _G[chatFrameName..'ButtonFrame'].Hide);

    -- Skin Edit Text Box
    _G[chatFrameName..'EditBoxLeft']:Hide();
    _G[chatFrameName..'EditBoxMid']:Hide();
    _G[chatFrameName..'EditBoxRight']:Hide();

    -- Allow arrow keys in Edit Box
    _G[chatFrameName..'EditBox']:SetAltArrowKeyMode(false);

    -- Position Edit Box
    _G[chatFrameName..'EditBox']:ClearAllPoints();
    if(chatFrameName == 'ChatFrame2') then -- Kind hacky. Fixes positioning of its a combat log entry
    _G[chatFrameName..'EditBox']:SetPoint('BOTTOM',_G[chatFrameName],'TOP',0,44);
    else
      _G[chatFrameName..'EditBox']:SetPoint('BOTTOM',_G[chatFrameName],'TOP',0,22);
    end
    _G[chatFrameName..'EditBox']:SetPoint('LEFT',_G[chatFrameName],-5,0);
    _G[chatFrameName..'EditBox']:SetPoint('RIGHT',_G[chatFrameName],10,0);

    -- Change Chat Font
    _G[chatFrameName]:SetFont(ZERO_CHAT_FONT, FontSize, 'THINOUTLINE');
    _G[chatFrameName]:SetShadowOffset( 1, -1 );
    _G[chatFrameName]:SetShadowColor( 0, 0, 0, 0.6 )

    -- rename windows general because moved to chat #3
    chatFrame:SetSize(430, 120)

    UpdatePosition(i, chatFrame)

    if i == 1 then
      FCF_SetWindowName(chatFrame, GENERAL)
    elseif i == 2 then
      FCF_SetWindowName(chatFrame, GUILD_EVENT_LOG)
    elseif i == 3 then
      FCF_SetWindowName(chatFrame, LOOT ..' / '..TRADE)
    end
  end

  ChatFrame_RemoveAllMessageGroups(ChatFrame1)
  ChatFrame_AddMessageGroup(ChatFrame1, 'SAY')
  ChatFrame_AddMessageGroup(ChatFrame1, 'EMOTE')
  ChatFrame_AddMessageGroup(ChatFrame1, 'YELL')
  ChatFrame_AddMessageGroup(ChatFrame1, 'GUILD')
  ChatFrame_AddMessageGroup(ChatFrame1, 'OFFICER')
  ChatFrame_AddMessageGroup(ChatFrame1, 'GUILD_ACHIEVEMENT')
  ChatFrame_AddMessageGroup(ChatFrame1, 'WHISPER')
  ChatFrame_AddMessageGroup(ChatFrame1, 'MONSTER_SAY')
  ChatFrame_AddMessageGroup(ChatFrame1, 'MONSTER_EMOTE')
  ChatFrame_AddMessageGroup(ChatFrame1, 'MONSTER_YELL')
  ChatFrame_AddMessageGroup(ChatFrame1, 'MONSTER_BOSS_EMOTE')
  ChatFrame_AddMessageGroup(ChatFrame1, 'PARTY')
  ChatFrame_AddMessageGroup(ChatFrame1, 'PARTY_LEADER')
  ChatFrame_AddMessageGroup(ChatFrame1, 'RAID')
  ChatFrame_AddMessageGroup(ChatFrame1, 'RAID_LEADER')
  ChatFrame_AddMessageGroup(ChatFrame1, 'RAID_WARNING')
  ChatFrame_AddMessageGroup(ChatFrame1, 'INSTANCE_CHAT')
  ChatFrame_AddMessageGroup(ChatFrame1, 'INSTANCE_CHAT_LEADER')
  ChatFrame_AddMessageGroup(ChatFrame1, 'BATTLEGROUND')
  ChatFrame_AddMessageGroup(ChatFrame1, 'BATTLEGROUND_LEADER')
  ChatFrame_AddMessageGroup(ChatFrame1, 'BG_HORDE')
  ChatFrame_AddMessageGroup(ChatFrame1, 'BG_ALLIANCE')
  ChatFrame_AddMessageGroup(ChatFrame1, 'BG_NEUTRAL')
  ChatFrame_AddMessageGroup(ChatFrame1, 'SYSTEM')
  ChatFrame_AddMessageGroup(ChatFrame1, 'ERRORS')
  ChatFrame_AddMessageGroup(ChatFrame1, 'AFK')
  ChatFrame_AddMessageGroup(ChatFrame1, 'DND')
  ChatFrame_AddMessageGroup(ChatFrame1, 'IGNORED')
  ChatFrame_AddMessageGroup(ChatFrame1, 'ACHIEVEMENT')
  ChatFrame_AddMessageGroup(ChatFrame1, 'BN_WHISPER')
  ChatFrame_AddMessageGroup(ChatFrame1, 'BN_CONVERSATION')
  ChatFrame_AddMessageGroup(ChatFrame1, 'BN_INLINE_TOAST_ALERT')


  ChatFrame_RemoveAllMessageGroups(ChatFrame3)
  -- ChatFrame_AddMessageGroup(ChatFrame3, 'COMBAT_FACTION_CHANGE')
  ChatFrame_AddMessageGroup(ChatFrame3, 'SKILL')
  ChatFrame_AddMessageGroup(ChatFrame3, 'LOOT')
  ChatFrame_AddMessageGroup(ChatFrame3, 'MONEY')
  ChatFrame_AddMessageGroup(ChatFrame3, 'COMBAT_XP_GAIN')
  ChatFrame_AddMessageGroup(ChatFrame3, 'COMBAT_HONOR_GAIN')
  ChatFrame_AddMessageGroup(ChatFrame3, 'COMBAT_GUILD_XP_GAIN')
  ChatFrame_AddMessageGroup(ChatFrame3, 'CURRENCY')
  ChatFrame_AddChannel(ChatFrame1, GENERAL)
  ChatFrame_RemoveChannel(ChatFrame1, 'Trade')
  ChatFrame_AddChannel(ChatFrame3, 'Trade')


  ToggleChatColorNamesByClassGroup(true, 'SAY')
  ToggleChatColorNamesByClassGroup(true, 'EMOTE')
  ToggleChatColorNamesByClassGroup(true, 'YELL')
  ToggleChatColorNamesByClassGroup(true, 'GUILD')
  ToggleChatColorNamesByClassGroup(true, 'OFFICER')
  ToggleChatColorNamesByClassGroup(true, 'GUILD_ACHIEVEMENT')
  ToggleChatColorNamesByClassGroup(true, 'ACHIEVEMENT')
  ToggleChatColorNamesByClassGroup(true, 'WHISPER')
  ToggleChatColorNamesByClassGroup(true, 'PARTY')
  ToggleChatColorNamesByClassGroup(true, 'PARTY_LEADER')
  ToggleChatColorNamesByClassGroup(true, 'RAID')
  ToggleChatColorNamesByClassGroup(true, 'RAID_LEADER')
  ToggleChatColorNamesByClassGroup(true, 'RAID_WARNING')
  ToggleChatColorNamesByClassGroup(true, 'BATTLEGROUND')
  ToggleChatColorNamesByClassGroup(true, 'BATTLEGROUND_LEADER')
  ToggleChatColorNamesByClassGroup(true, 'INSTANCE_CHAT')
  ToggleChatColorNamesByClassGroup(true, 'INSTANCE_CHAT_LEADER')
  ToggleChatColorNamesByClassGroup(true, 'CHANNEL1')
  ToggleChatColorNamesByClassGroup(true, 'CHANNEL2')
  ToggleChatColorNamesByClassGroup(true, 'CHANNEL3')
  ToggleChatColorNamesByClassGroup(true, 'CHANNEL4')
  ToggleChatColorNamesByClassGroup(true, 'CHANNEL5')
  ToggleChatColorNamesByClassGroup(true, 'CHANNEL6')
  ToggleChatColorNamesByClassGroup(true, 'CHANNEL7')
  ToggleChatColorNamesByClassGroup(true, 'CHANNEL8')
  ToggleChatColorNamesByClassGroup(true, 'CHANNEL9')
  ToggleChatColorNamesByClassGroup(true, 'CHANNEL10')
  ToggleChatColorNamesByClassGroup(true, 'CHANNEL11')

  ChangeChatColor('CHANNEL1', 195/255, 230/255, 232/255)
  ChangeChatColor('CHANNEL2', 232/255, 158/255, 121/255)
  ChangeChatColor('CHANNEL3', 232/255, 228/255, 121/255)
end

local function OverrideStrings()
    -- Local Player Loot
  CURRENCY_GAINED = '|cffFFFF00+ %s'
  CURRENCY_GAINED_MULTIPLE = '|cffFFFF00+ %s |cffFFFF00(%d)'
  CURRENCY_GAINED_MULTIPLE_BONUS = '|cffFFFF00+ %s |cffFFFF00(%d)'
  YOU_LOOT_MONEY = '|cffFFFF00+ %s'
  LOOT_ITEM_SELF = '|cffFFFF00+ %s'
  LOOT_ITEM_SELF_MULTIPLE = '|cffFFFF00+ %s |cffFFFF00(%d)'
  LOOT_ITEM_CREATED_SELF = '|cffFFFF00+ %s'
  LOOT_ITEM_CREATED_SELF_MULTIPLE = '|cffFFFF00+ %s |cffFFFF00(%d)'
  LOOT_ITEM_BONUS_ROLL_SELF = '|cffFFFF00+ %s'
  LOOT_ITEM_BONUS_ROLL_SELF_MULTIPLE = '|cffFFFF00+ %s |cffFFFF00(%d)'
  LOOT_ITEM_REFUND = '|cffFFFF00+ %s'
  LOOT_ITEM_REFUND_MULTIPLE = '|cffFFFF00+ %s |cffFFFF00(%d)'
  LOOT_ITEM_PUSHED_SELF = '|cffFFFF00+ %s'
  LOOT_ITEM_PUSHED_SELF_MULTIPLE = '|cffFFFF00+ %s |cffFFFF00(%d)'
  TRADESKILL_LOG_FIRSTPERSON = '' -- Hidden. Useless Info.
  ERR_QUEST_REWARD_ITEM_S = '|cffFFFF00+ %s'
  ERR_QUEST_REWARD_ITEM_MULT_IS = '|cffFFFF00+ %d |cffFFFF00%s'
  ERR_QUEST_REWARD_MONEY_S = '|cffFFFF00+ %s'
  ERR_QUEST_REWARD_EXP_I = '|cffFFFF00+ %d EXP'

  -- Remote Players Loot
  LOOT_ITEM = '%s |cffFFFF00+ %s'
  LOOT_ITEM_BONUS_ROLL = '%s |cffFFFF00+ %s'
  LOOT_ITEM_BONUS_ROLL_MULTIPLE = '%s |cffFFFF00+ %s |cffFFFF00(%d)'
  LOOT_ITEM_MULTIPLE = '%s |cffFFFF00+ %s |cffFFFF00(%d)'
  LOOT_ITEM_PUSHED = '%s |cffFFFF00+ %s'
  LOOT_ITEM_PUSHED_MULTIPLE = '%s |cffFFFF00+ %s |cffFFFF00(%d)'
  CREATED_ITEM = '%s |cffFFFF00+ %s'
  TRADESKILL_LOG_THIRDPERSON = '%s |cffFFFF00+ %s'
  CREATED_ITEM_MULTIPLE = '%s |cffFFFF00+ %s |cffFFFF00(%d)'

  -- Chat Channels
  CHAT_SAY_GET = '%s '
  CHAT_YELL_GET = '%s '
  CHAT_WHISPER_INFORM_GET = 'w to %s '
  CHAT_WHISPER_GET = 'w from %s '
  CHAT_BN_WHISPER_INFORM_GET = 'w to %s '
  CHAT_BN_WHISPER_GET = 'w from %s '
  CHAT_PARTY_GET = '|Hchannel:PARTY|hp|h %s '
  CHAT_PARTY_LEADER_GET =  '|Hchannel:PARTY|hpl|h %s '
  CHAT_PARTY_GUIDE_GET =  '|Hchannel:PARTY|hpg|h %s '
  CHAT_INSTANCE_CHAT_GET = '|Hchannel:Battleground|hi|h %s: '
  CHAT_INSTANCE_CHAT_LEADER_GET = '|Hchannel:Battleground|hil|h %s: '
  CHAT_GUILD_GET = '|Hchannel:GUILD|hg|h %s '
  CHAT_OFFICER_GET = '|Hchannel:OFFICER|ho|h %s '
  CHAT_FLAG_AFK = '[AFK] '
  CHAT_FLAG_DND = '[DND] '
  CHAT_FLAG_GM = '[GM] '

  -- Skill Ups
  ERR_SKILL_UP_SI = '|cffFFFF00+ |cff00FFFF%s Skill |cffFFFF00(%d)'
end

function module:OnPlayerLogin()
  CHAT_FONT_HEIGHTS = {
    7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24
  }
  SetupChat()
  OverrideStrings()
end
