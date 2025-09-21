
EEex_Options_Register("EEex_UncapFPS_Enable", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "EEex", ["key"] = "Uncap FPS" }),
    ["onChange"] = function(self) EEex.UncapFPS_Enabled = self:get() end,
}))

EEex_Options_Register("EEex_UncapFPS_RemoveMiddleMouseScrollMultiplier", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "EEex", ["key"] = "Remove Middle Mouse Scroll Multiplier" }),
    ["onChange"] = function(self) EEex.UncapFPS_RemoveMiddleMouseScrollMultiplier = self:get() end,
}))

EEex_Options_AddTab("Uncap FPS", function() return {
	{
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "EEex_UncapFPS_Enable",
			["label"]       = "EEex_Options_TRANSLATION_UncapFPS_Enable",
			["description"] = "EEex_Options_TRANSLATION_UncapFPS_Enable_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "EEex_UncapFPS_RemoveMiddleMouseScrollMultiplier",
			["label"]       = "EEex_Options_TRANSLATION_UncapFPS_RemoveMiddleMouseScrollMultiplier",
			["description"] = "EEex_Options_TRANSLATION_UncapFPS_RemoveMiddleMouseScrollMultiplier_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
	},
} end)
