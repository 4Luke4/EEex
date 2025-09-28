
EEex_Options_Register("EEex_UncapFPS_AISpeed", EEex_Options_Option.new({
	["default"]  = 30,
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 1, ["max"] = 90 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "Program Options", ["key"] = "Maximum Frame Rate" }),
	["onChange"] = function(self) EEex_CChitin.TIMER_UPDATES_PER_SECOND = self:get() end,
}))

EEex_Options_Register("EEex_UncapFPS_BusyWaitThreshold", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1000 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "EEex", ["key"] = "Uncap FPS Busy Wait Threshold" }),
	["onChange"] = function(self) EEex.UncapFPS_BusyWaitThreshold = self:get() end,
}))

EEex_Options_Register("EEex_UncapFPS_Enable", EEex_Options_Option.new({
	["default"]  = 1,
	["type"]     = EEex_Options_ToggleType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "EEex", ["key"] = "Uncap FPS" }),
	["onChange"] = function(self) EEex.UncapFPS_Enabled = self:get() end,
}))

EEex_Options_Register("EEex_UncapFPS_FPSLimit", EEex_Options_Option.new({
	["default"]  = EEex.GetHighestRefreshRate(),
	["type"]     = EEex_Options_EditType.new(),
	["accessor"] = EEex_Options_ClampedAccessor.new({ ["min"] = 0, ["max"] = 1000 }),
	["storage"]  = EEex_Options_NumberLuaStorage.new({ ["section"] = "EEex", ["key"] = "Uncap FPS Limit" }),
	["onChange"] = function(self) EEex.UncapFPS_FPSLimit = self:get() end,
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
			["optionID"]    = "EEex_UncapFPS_AISpeed",
			["label"]       = "EEex_Options_TRANSLATION_UncapFPS_AISpeed",
			["description"] = "EEex_Options_TRANSLATION_UncapFPS_AISpeed_Description",
			["widget"]      = EEex_Options_EditWidget.new({
				["maxCharacters"] = 2,
				["number"] = true,
			}),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "EEex_UncapFPS_BusyWaitThreshold",
			["label"]       = "EEex_Options_TRANSLATION_UncapFPS_BusyWaitThreshold",
			["description"] = "EEex_Options_TRANSLATION_UncapFPS_BusyWaitThreshold_Description",
			["widget"]      = EEex_Options_EditWidget.new({
				["maxCharacters"] = 4,
				["number"] = true,
			}),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "EEex_UncapFPS_Enable",
			["label"]       = "EEex_Options_TRANSLATION_UncapFPS_Enable",
			["description"] = "EEex_Options_TRANSLATION_UncapFPS_Enable_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "EEex_UncapFPS_FPSLimit",
			["label"]       = "EEex_Options_TRANSLATION_UncapFPS_FPSLimit",
			["description"] = "EEex_Options_TRANSLATION_UncapFPS_FPSLimit_Description",
			["widget"]      = EEex_Options_EditWidget.new({
				["maxCharacters"] = 4,
				["number"] = true,
			}),
		}),
		EEex_Options_DisplayEntry.new({
			["optionID"]    = "EEex_UncapFPS_RemoveMiddleMouseScrollMultiplier",
			["label"]       = "EEex_Options_TRANSLATION_UncapFPS_RemoveMiddleMouseScrollMultiplier",
			["description"] = "EEex_Options_TRANSLATION_UncapFPS_RemoveMiddleMouseScrollMultiplier_Description",
			["widget"]      = EEex_Options_ToggleWidget.new(),
		}),
	},
} end)
