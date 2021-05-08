local _, Zero = ...

local module = Zero.Module('QuestSounds')

local Sounds = {
  QUEST_COMPLETE = 558132,
  OBJECTIVE_COMPLETE = 558137,
  OBJECTIVE_PROGRESS = 558127,
}

local firstScan = true
local quests, oldQuests = {}, {}
local completed, oldCompleted = {}, {}

local function ProcessQuest(questIndex)

  C_QuestLog.SetSelectedQuest(questIndex)

  local info = C_QuestLog.GetInfo(questIndex)
  if info.isHeader then return end

  quests[info.questID] = true

  local isComplete = C_QuestLog.IsComplete(info.questID)
  local numObjectives = C_QuestLog.GetNumQuestObjectives(info.questID)
  if isComplete or numObjectives == 0 then
    completed[info.questID] = true
    if not firstScan and not oldCompleted[info.questID] then
      if isComplete == -1 then
        UIErrorsFrame:AddMessage(ERR_QUEST_FAILED_S:format(info.title), 1, 0, 0)
      else
        UIErrorsFrame:AddMessage(ERR_QUEST_COMPLETE_S:format(info.title), 0, 1, 0)
        ChatFrame1:AddMessage(ERR_QUEST_COMPLETE_S:format(info.title), 0, 1, 0)
        PlaySoundFile(Sounds.QUEST_COMPLETE)
      end
    end
  end
end

local blockProcess = false

local function ProcessQuestLog()
  if blockProcess then return end
  blockProcess = true
  wipe(oldCompleted)
  wipe(oldQuests)
  completed, oldCompleted = oldCompleted, completed
  quests, oldQuests = oldQuests, quests
  local startingQuestLogSelection = C_QuestLog.GetSelectedQuest()
  local numEntries = C_QuestLog.GetNumQuestLogEntries()
  for index = 1, numEntries do
    ProcessQuest(index)
  end
  firstScan = numEntries < 1
  C_QuestLog.SetSelectedQuest(startingQuestLogSelection)
  blockProcess = false
end

function module:OnPlayerLogin()
  self:RegisterEvent('QUEST_LOG_UPDATE', ProcessQuestLog)
  self:RegisterEvent('PLAYER_LEAVING_WORLD', function()
    blockProcess = true
   end)
  self:RegisterEvent('PLAYER_ENTERING_WORLD', function()
    blockProcess = false
    ProcessQuestLog()
  end)
end
