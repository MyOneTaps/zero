local _, Zero = ...

local module = Zero.Module('QuestSounds')

local GetSelectedQuest = C_QuestLog.GetSelectedQuest or GetQuestLogSelection
local GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries or GetNumQuestLogEntries
local SetSelectedQuest = C_QuestLog.SetSelectedQuest or SelectQuestLogEntry

local Sounds = {
  QUEST_COMPLETE = 558132,
  OBJECTIVE_COMPLETE = 558137,
  OBJECTIVE_PROGRESS = 558127,
}

local firstScan = true
local quests, oldQuests = {}, {}
local completed, oldCompleted = {}, {}

local function GetQuestInfo(questIndex)
  if Zero.IsRetail then
    local info = C_QuestLog.GetInfo(questIndex)
    info.isComplete = C_QuestLog.IsComplete(info.questID)
    info.numObjectives = C_QuestLog.GetNumQuestObjectives(info.questID)
    return info
  else
    local title, _, _, isHeader, _, isComplete, _, questID, _, _, _, _, isTask = GetQuestLogTitle(questIndex)
    return {
      title = title,
      questID = questID,
      isComplete = isComplete,
      isHeader = isHeader,
      numObjectives = GetNumQuestLeaderBoards(questIndex)
    }
  end
end

local function ProcessQuest(questIndex)
  SetSelectedQuest(questIndex)
  local info = GetQuestInfo(questIndex)

  if info.isHeader then return end
  quests[info.questID] = true
  if info.isComplete or info.numObjectives == 0 then
    completed[info.questID] = true
    if not firstScan and not oldCompleted[info.questID] then
      if info.isComplete == -1 then
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
  local startingQuestLogSelection = GetSelectedQuest()
  local numEntries = GetNumQuestLogEntries()
  for index = 1, numEntries do
    ProcessQuest(index)
  end
  firstScan = numEntries < 1
  SetSelectedQuest(startingQuestLogSelection)
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
