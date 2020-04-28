local _, Zero = ...

local module = Zero.Module('Delete')

local function ConfirmDelete(which)
  if which == 'DELETE_GOOD_ITEM' then
    for index = 1, 4 do
      local frame = _G['StaticPopup' .. index];
      if frame:IsShown() and frame.which == which then
        local editBox = _G['StaticPopup' .. index .. 'EditBox']
        local button1 = _G['StaticPopup' .. index .. 'Button1']

        editBox:Hide()
        button1:Enable()
      end
    end
  end
end

function module:OnPlayerLogin()
  self:Hook('StaticPopup_Show', ConfirmDelete)
end
