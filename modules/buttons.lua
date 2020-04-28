local _, Zero = ...

local module = Zero.Module('Buttons')

local buttons = {
  MicroButtonAndBagsBar,
  CharacterMicroButton,
  SpellbookMicroButton,
  TalentMicroButton,
  AchievementMicroButton,
  QuestLogMicroButton,
  GuildMicroButton,
  LFDMicroButton,
  CollectionsMicroButton,
  EJMicroButton,
  MainMenuMicroButton,
  StoreMicroButton,
}

function AchievementMicroButton_Update()
end

function module:OnPlayerLogin()
  MicroButtonAndBagsBar:Hide()
  hooksecurefunc('UpdateMicroButtons', function()
    for _, button in ipairs(buttons) do
      button:Hide()
    end
  end)
end
