local _, Zero = ...

local module = Zero.Module('Delete')

local function ConfirmDelete(_, which)
  if which == 'DELETE_GOOD_ITEM' then
    for index = 1, 4 do
      local frame = _G['StaticPopup' .. index];
      if frame:IsShown() and frame.which == which then
        _G['StaticPopup' .. index .. 'EditBox']:Hide()
        _G['StaticPopup' .. index .. 'Button1']:Enable()
      end
    end
  end
end

function module:OnPlayerLogin()
  self:Hook('StaticPopup_Show', ConfirmDelete)
end
