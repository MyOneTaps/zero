local _, Zero = ...

local module = Zero:Module('Fonts')
local strmatch = strmatch

local function SetFont(obj, font, size, style, sr, sg, sb, sa, sox, soy, r, g, b)
  if not obj then
    return
  end
  obj:SetFont(font, size, style)

  if sr and sg and sb then
    obj:SetShadowColor(sr, sg, sb, sa)
  end

  if sox and soy then
    obj:SetShadowOffset(sox, soy)
  end

  if r and g and b then
    obj:SetTextColor(r, g, b)
  elseif r then
    obj:SetAlpha(r)
  end
end

local function UpdateCooldown(self)
  if not GetCVar('countdownForCooldowns') then
    return
  end
  if self.patched then
    return
  end
  local regions = {self:GetRegions()}
  for _, region in ipairs(regions) do
    if region.GetText then
      region:SetFont(ZERO_UI_FONT, 12, 'OUTLINE')
    end
  end
  self.patched = true
end

function module:OnLoad()
  local NORMAL = ZERO_UI_FONT
  local NUMBER = ZERO_UI_FONT
  local COMBAT = ZERO_DAMAGE_FONT
  local NAMEFONT = ZERO_NAME_FONT

  UNIT_NAME_FONT = NAMEFONT
  DAMAGE_TEXT_FONT = COMBAT
  STANDARD_TEXT_FONT = NORMAL

  -- local size = 12;
  -- local enormous = size * 1.9
  -- local mega = size * 1.7
  -- local huge = size * 1.5
  -- local large = size * 1.3
  -- local medium = size * 1.1
  -- local small = size * 0.9
  -- local tiny = size * 0.8

  -- local s = true

  -- SetFont(AchievementFont_Small, NORMAL, s and small or size) -- 10 Achiev dates
  -- SetFont(BossEmoteNormalHuge, NORMAL, 24) -- Talent Title
  -- SetFont(CoreAbilityFont, NORMAL, 26) -- 32 Core abilities(title)
  -- SetFont(DestinyFontHuge, NORMAL, 32) -- Garrison Mission Report
  -- SetFont(DestinyFontMed, NORMAL, 14) -- Added in 7.3.5 used for ?
  -- SetFont(Fancy12Font, NORMAL, 12) -- Added in 7.3.5 used for ?
  -- SetFont(Fancy14Font, NORMAL, 14) -- Added in 7.3.5 used for ?
  -- SetFont(Fancy22Font, NORMAL, s and 22 or 20) -- Talking frame Title font
  -- SetFont(Fancy24Font, NORMAL, s and 24 or 20) -- Artifact frame - weapon name
  -- SetFont(FriendsFont_11, NORMAL, 11)
  -- SetFont(FriendsFont_Large, NORMAL, s and large or size) -- 14
  -- SetFont(FriendsFont_Normal, NORMAL, size) -- 12
  -- SetFont(FriendsFont_Small, NORMAL, s and small or size) -- 10
  -- SetFont(FriendsFont_UserText, NORMAL, size) -- 11
  -- SetFont(Game10Font_o1, NORMAL, 10, 'OUTLINE')
  -- SetFont(Game120Font, NORMAL, 120)
  -- SetFont(Game12Font, NORMAL, 12) -- PVP Stuff
  -- SetFont(Game13FontShadow, NORMAL, s and 13 or 14) -- InspectPvpFrame
  -- SetFont(Game15Font_o1, NORMAL, 15) -- CharacterStatsPane (ItemLevelFrame)
  -- SetFont(Game16Font, NORMAL, 16) -- Added in 7.3.5 used for ?
  -- SetFont(Game18Font, NORMAL, 18) -- MissionUI Bonus Chance
  -- SetFont(Game24Font, NORMAL, 24) -- Garrison Mission level (in detail frame)
  -- SetFont(Game30Font, NORMAL, 30) -- Mission Level
  -- SetFont(Game40Font, NORMAL, 40)
  -- SetFont(Game42Font, NORMAL, 42) -- PVP Stuff
  -- SetFont(Game46Font, NORMAL, 46) -- Added in 7.3.5 used for ?
  -- SetFont(Game48Font, NORMAL, 48)
  -- SetFont(Game48FontShadow, NORMAL, 48)
  -- SetFont(Game60Font, NORMAL, 60)
  -- SetFont(Game72Font, NORMAL, 72)
  -- SetFont(GameFont_Gigantic, NORMAL, 32) -- Used at the install steps
  -- SetFont(GameFontHighlightMedium, NORMAL, s and medium or 15) -- 14 Fix QuestLog Title mouseover
  -- SetFont(GameFontHighlightSmall2, NORMAL, s and small or size) -- 11 Skill or Recipe description on TradeSkill frame
  -- SetFont(GameFontNormalHuge2, NORMAL, s and huge or 24) -- 24 Mythic weekly best dungeon name
  -- SetFont(GameFontNormalLarge, NORMAL, s and large or 16) -- 16
  -- SetFont(GameFontNormalLarge2, NORMAL, s and large or 15) -- 18 Garrison Follower Names
  -- SetFont(GameFontNormalMed1, NORMAL, s and medium or 14) -- 13 WoW Token Info
  -- SetFont(GameFontNormalMed2, NORMAL, s and medium or medium) -- 14 Quest tracker
  -- SetFont(GameFontNormalMed3, NORMAL, s and medium or 15) -- 14
  -- SetFont(GameFontNormalSmall2, NORMAL, s and small or 12) -- 11 MissionUI Followers names
  -- SetFont(GameTooltipHeader, NORMAL, size) -- 14
  -- SetFont(InvoiceFont_Med, NORMAL, s and size or 12) -- 12 Mail
  -- SetFont(InvoiceFont_Small, NORMAL, s and small or size) -- 10 Mail
  -- SetFont(MailFont_Large, NORMAL, 14) -- 10 Mail
  -- SetFont(Number11Font, NORMAL, 11)
  -- SetFont(Number11Font, NUMBER, 11)
  -- SetFont(Number12Font, NORMAL, 12)
  -- SetFont(Number12Font_o1, NUMBER, 12, 'OUTLINE')
  -- SetFont(Number13Font, NUMBER, 13)
  -- SetFont(Number13FontGray, NUMBER, 13)
  -- SetFont(Number13FontWhite, NUMBER, 13)
  -- SetFont(Number13FontYellow, NUMBER, 13)
  -- SetFont(Number14FontGray, NUMBER, 14)
  -- SetFont(Number14FontWhite, NUMBER, 14)
  -- SetFont(Number15Font, NORMAL, 15)
  -- SetFont(Number18Font, NUMBER, 18)
  -- SetFont(Number18FontWhite, NUMBER, 18)
  -- SetFont(NumberFont_Outline_Huge, NUMBER, s and huge or 28, 'THICKOUTLINE') -- 30
  -- SetFont(NumberFont_Outline_Large, NUMBER, s and large or 15, 'OUTLINE') -- 16
  -- SetFont(NumberFont_Outline_Med, NUMBER, medium, 'OUTLINE') -- 14
  -- SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, size, 'OUTLINE') -- 12
  -- SetFont(NumberFont_Shadow_Med, NORMAL, s and medium or size) -- 14 Chat EditBox
  -- SetFont(NumberFont_Shadow_Small, NORMAL, s and small or size) -- 12
  -- SetFont(NumberFontNormalSmall, NORMAL, s and small or 11, 'OUTLINE') -- 12 Calendar, EncounterJournal
  -- SetFont(PriceFont, NORMAL, 13)
  -- SetFont(PVPArenaTextString, NORMAL, 22, 'OUTLINE')
  -- SetFont(PVPInfoTextString, NORMAL, 22, 'OUTLINE')
  -- SetFont(QuestFont, NORMAL, size) -- 13
  -- SetFont(QuestFont_Enormous, NORMAL, s and enormous or 24) -- 30 Garrison Titles
  -- SetFont(QuestFont_Huge, NORMAL, s and huge or 15) -- 18 Quest rewards title(Rewards)
  -- SetFont(QuestFont_Large, NORMAL, s and large or 14) -- 14
  -- SetFont(QuestFont_Shadow_Huge, NORMAL, s and huge or 15) -- 18 Quest Title
  -- SetFont(QuestFont_Shadow_Small, NORMAL, s and size or 14) -- 14
  -- SetFont(QuestFont_Super_Huge, NORMAL, s and mega or 22) -- 24
  -- SetFont(ReputationDetailFont, NORMAL, size) -- 10 Rep Desc when clicking a rep
  -- SetFont(SpellFont_Small, NORMAL, 10)
  -- SetFont(SubSpellFont, NORMAL, 10) -- Spellbook Sub Names
  -- SetFont(SubZoneTextFont, NORMAL, 24, 'OUTLINE') -- 26 World Map(SubZone)
  -- SetFont(SubZoneTextString, NORMAL, 25, 'OUTLINE') -- 26
  -- SetFont(SystemFont_Huge1, NORMAL, 20) -- Garrison Mission XP
  -- SetFont(SystemFont_Huge1_Outline, NORMAL, 18, 'OUTLINE') -- 20 Garrison Mission Chance
  -- SetFont(SystemFont_Large, NORMAL, s and 16 or 15)
  -- SetFont(SystemFont_Med1, NORMAL, size) -- 12
  -- SetFont(SystemFont_Med3, NORMAL, medium) -- 14
  -- SetFont(SystemFont_Outline, NORMAL, s and size or 13, 'OUTLINE') -- 13 Pet level on World map
  -- SetFont(SystemFont_Outline_Small, NUMBER, s and small or size, 'OUTLINE') -- 10
  -- SetFont(SystemFont_OutlineThick_Huge2, NORMAL, s and huge or 20, 'THICKOUTLINE') -- 22
  -- SetFont(SystemFont_OutlineThick_WTF, NORMAL, s and enormous or 32, 'OUTLINE') -- 32 World Map
  -- SetFont(SystemFont_Shadow_Huge1, NORMAL, 20, 'OUTLINE') -- Raid Warning, Boss emote frame too
  -- SetFont(SystemFont_Shadow_Huge3, NORMAL, 22) -- 25 FlightMap
  -- SetFont(SystemFont_Shadow_Huge4, NORMAL, 27, nil, nil, nil, nil, nil, 1, -1)
  -- SetFont(SystemFont_Shadow_Large, NORMAL, 15)
  -- SetFont(SystemFont_Shadow_Large2, NORMAL, 18) -- Auction House ItemDisplay
  -- SetFont(SystemFont_Shadow_Large_Outline, NUMBER, 20, 'OUTLINE') -- 16
  -- SetFont(SystemFont_Shadow_Med1, NORMAL, size) -- 12
  -- SetFont(SystemFont_Shadow_Med2, NORMAL, s and medium or 14.3) -- 14 Shows Order resourses on OrderHallTalentFrame
  -- SetFont(SystemFont_Shadow_Med3, NORMAL, medium) -- 14
  -- SetFont(SystemFont_Shadow_Small, NORMAL, small) -- 10
  -- SetFont(SystemFont_Small, NORMAL, s and small or size) -- 10
  -- SetFont(SystemFont_Tiny, NORMAL, s and tiny or size) -- 09
  -- SetFont(Tooltip_Med, NORMAL, size) -- 12
  -- SetFont(Tooltip_Small, NORMAL, s and small or size) -- 10
  -- SetFont(ZoneTextString, NORMAL, s and enormous or 32, 'OUTLINE') -- 32
end
