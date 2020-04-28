local _, Zero = ...

local module = Zero.Module('QuestSounds')

local SOUNDS = {
  MORE_WORK = [[Sound\Creature\Peasant\PeasantWhat3.ogg]],
  JOBS_DONE = [[Interface\AddOns\Zero\media\SOUNDS\Jobs Done.ogg]]
}

local firstScan = true
local quests, oldQuests = {}, {}
local completed, oldCompleted = {}, {}

local function ProcessQuest(questIndex)

  SelectQuestLogEntry(questIndex)

  local title, _, _, isHeader, _, isComplete, _, questID, _, _, _, _, isTask = GetQuestLogTitle(questIndex)
  if isHeader then return end

  quests[questID] = true

  local numObjectives = GetNumQuestLeaderBoards(index)
  if isComplete or numObjectives == 0 then
    completed[questID] = true
    if not firstScan and not oldCompleted[questID] then
      if isComplete == -1 then
        UIErrorsFrame:AddMessage(ERR_QUEST_FAILED_S:format(title), 1, 0, 0)
      else
        UIErrorsFrame:AddMessage(ERR_QUEST_COMPLETE_S:format(title), 0, 1, 0)
        ChatFrame1:AddMessage(ERR_QUEST_COMPLETE_S:format(title), 0, 1, 0)
        PlaySoundFile(SOUNDS.JOBS_DONE)
        if IsQuestWatched(questIndex) then
          RemoveQuestWatch(questIndex)
        end
      end
    end
  end

  local function ProcessObjective(objectiveIndex)
    local _, _, finished = GetQuestLogLeaderBoard(objectiveIndex, questIndex)

    local key = ('%d:%d'):format(questID, objectiveIndex)

    if finished then
      completed[key] = true
    end

    if firstScan then return end
    if completed[questID] or oldCompleted[key] then return end
    if not finished then return end
    if isTask and not oldQuests[questID] then return end
    PlaySoundFile(SOUNDS.MORE_WORK)
  end

  local numObjectives = GetNumQuestLeaderBoards(questIndex)
  for objectiveIndex = 1, numObjectives do
    ProcessObjective(objectiveIndex)
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
  local startingQuestLogSelection = GetQuestLogSelection()
  local numEntries = GetNumQuestLogEntries()
  for index = 1, numEntries do
    ProcessQuest(index)
  end
  firstScan = numEntries < 1
  SelectQuestLogEntry(startingQuestLogSelection)
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
