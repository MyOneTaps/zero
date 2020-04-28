local FONT_SIZE = 16

CombatTextFont:SetFont(ZERO_DAMAGE_FONT, FONT_SIZE, '')
CombatTextFont:SetShadowOffset(1,-1)
CombatTextFont:SetShadowColor(0,0,0,0.6)

CombatTextFontOutline:SetFont(ZERO_DAMAGE_FONT, FONT_SIZE, 'OUTLINE')
CombatTextFontOutline:SetShadowOffset(1,-1)
CombatTextFontOutline:SetShadowColor(0,0,0,0.6)

COMBAT_TEXT_HEIGHT = FONT_SIZE
COMBAT_TEXT_CRIT_MAXHEIGHT = FONT_SIZE * 2
COMBAT_TEXT_CRIT_MINHEIGHT = FONT_SIZE * 2
COMBAT_TEXT_SCROLLSPEED = 4
