local _, Zero = ...

local module = Zero.Module('Far Clip')

local farclip = GetCVar('farclip')
SetCVar('farclip', 185)
function module:OnPlayerLogin()
  C_Timer.After(3, function()
    SetCVar('farclip', farclip)
    farclip = nil
  end)
end
