local _, Zero = ...

local module = Zero.Module('QuestCount')

function module:OnLoad()
  self:RegisterEvent('QUEST_LOG_UPDATE', function()
    local _, numQuests = GetNumQuestLogEntries()
    ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetText(('%d/%d %s'):format(numQuests, MAX_QUESTS, TRACKER_HEADER_QUESTS))
    WorldMapFrame.BorderFrame.TitleText:SetText(('%s (%d/%d)'):format(MAP_AND_QUEST_LOG, numQuests, MAX_QUESTS))
  end)
end
