
---------------
-- Constants --
---------------

-- The missing flag values probably meant something in the classic engine, but are unused in the EEs.
EEex_GameState_InputMode = {
	["FLAG_WORLD_SCREEN_ALLOW_ALL_INPUT"]           = 0x00000001,
	["VALUE_DIALOG_NO_CONTROL"]                     = 0x00000182, --         0x100 |  0x80 | 0x2
	["VALUE_DIALOG_IN_CONTROL"]                     = 0x00000502, -- 0x400 | 0x100 |       | 0x2
	["FLAG_WORLD_SCREEN_ALLOW_KEY_INPUT"]           = 0x00000800,
	["VALUE_PICK_PARTY"]                            = 0x00000802, -- 0x800 (FLAG_WORLD_SCREEN_ALLOW_KEY_INPUT) | 0x2
	["VALUE_DEATH"]                                 = 0x00001000,
	["FLAG_WORLD_SCREEN_ALLOW_MOUSE_INTERACTION"]   = 0x00004000,
	["FLAG_WORLD_SCREEN_ALLOW_INTERFACE_AUTO_HIDE"] = 0x00010000,
	["VALUE_FULL_CUTSCENE"]                         = 0x0001016E, --           0x10000 (FLAG_WORLD_SCREEN_ALLOW_INTERFACE_AUTO_HIDE) | 0x100 | 0x40 | 0x20 | 0x8 | 0x4 | 0x2
	["VALUE_LIGHT_CUTSCENE"]                        = 0x0003016E, -- 0x20000 | 0x10000 (FLAG_WORLD_SCREEN_ALLOW_INTERFACE_AUTO_HIDE) | 0x100 | 0x40 | 0x20 | 0x8 | 0x4 | 0x2
	["VALUE_NORMAL"]                                = 0xFFFFFFFF,
}

-------------
-- General --
-------------

-- @bubb_doc { EEex_GameState_GetGlobalInt }
--
-- @summary: Returns the integer value of the ``variableName`` Global scoped to ``GLOBAL``.
--           If no variable named ``variableName`` exists, returns ``0``.
--
-- @param { variableName / type=string }: The name of the variable to fetch.
--
-- @return { type=number }: See summary.

function EEex_GameState_GetGlobalInt(variableName)
	return EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_variables:getInt(variableName)
end

-- @bubb_doc { EEex_GameState_GetGlobalString }
--
-- @summary: Returns the string value of the ``variableName`` Global scoped to ``GLOBAL``.
--           If no variable named ``variableName`` exists, returns ``""``.
--
-- @note: Global string values can only be accessed through EEex functions.
--
-- @param { variableName / type=string }: The name of the variable to fetch.
--
-- @return { type=string }: See summary.

function EEex_GameState_GetGlobalString(variableName)
	return EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_variables:getString(variableName)
end

function EEex_GameState_GetInputMode()
	return EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_gameSave.m_inputMode
end

-- @bubb_doc { EEex_GameState_WouldWorldScreenProcessInput }
--
-- @summary: Returns ``true`` if the world screen would currently process a keypress.
--
-- @note: It is the caller's responsibility to check if the active engine is the world screen and if a text edit is currently focused.
--
-- @return { type=boolean }: See summary.

function EEex_GameState_WouldWorldScreenProcessInput()

	-- Detects a top-level modal window. Hack because I'm not sending the keypress through the entire menu stack.
	if EngineGlobals.popupActive() then
		return false
	end

	-- Ensure not in cutscene or dialog mode
	local inputMode = EEex_GameState_GetInputMode()
	if inputMode == EEex_GameState_InputMode.VALUE_FULL_CUTSCENE or inputMode == EEex_GameState_InputMode.VALUE_LIGHT_CUTSCENE then
		return false
	end

	local inputFlags = EEex_Flags({ EEex_GameState_InputMode.FLAG_WORLD_SCREEN_ALLOW_KEY_INPUT, EEex_GameState_InputMode.FLAG_WORLD_SCREEN_ALLOW_ALL_INPUT })
	return EEex_BAnd(inputMode, inputFlags) ~= 0
end

-- @bubb_doc { EEex_GameState_SetGlobalInt }
--
-- @summary: Sets the integer value of the ``variableName`` Global scoped to ``GLOBAL`` to ``value``.
--
-- @param { variableName / type=string }: The name of the variable to set.
--
-- @param { value / type=number }: The value to set the variable to.

function EEex_GameState_SetGlobalInt(variableName, value)
	EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_variables:setInt(variableName, value)
end

-- @bubb_doc { EEex_GameState_SetGlobalString }
--
-- @summary: Sets the string value of the ``variableName`` Global scoped to ``GLOBAL`` to ``value``.
--
-- @note: Global string values can only be accessed through EEex functions.
--
-- @warning: Global string values can be a maximum of 32 characters. Attempting to set a value
--           that is longer than 32 characters will result in the value being truncated.
--
-- @param { variableName / type=string }: The name of the variable to set.
--
-- @param { value / type=string }: The value to set the variable to.

function EEex_GameState_SetGlobalString(variableName, value)
	EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_variables:setString(variableName, value)
end

function EEex_GameState_SetInputMode(mode)
	EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_gameSave:SetInputMode(mode)
end

-- @bubb_doc { EEex_GameState_TogglePause }
--
-- @summary: Toggles the pause status of the game.
--
-- @param { bLogPause / type=boolean / default=true }: Determines whether a message is written to the combat log.
--
-- @param { bVisualPause / type=boolean / default=true }:
--
--     Determines whether the engine renders screen-edge arrows and forces party markers during pause.
--
-- @param { bRequireHostUnpause / type=boolean / default=false }: Unknown.
--
-- @param { nIdPlayerPause / type=number / default=0 }: Unknown.
--
-- @param { bSendMessage / type=boolean / default=true }: Unknown.

function EEex_GameState_TogglePause(bLogPause, bVisualPause, bRequireHostUnpause, nIdPlayerPause, bSendMessage)
	EngineGlobals.g_pBaldurChitin.m_pEngineWorld:TogglePauseGame(
		EEex_Utility_Default(bVisualPause, true),
		EEex_Utility_Default(bSendMessage, true),
		nIdPlayerPause or 0,
		EEex_Utility_Default(bLogPause, true),
		bRequireHostUnpause or false
	)
end

---------------
-- Listeners --
---------------

EEex_GameState_Private_BeforeIncludesListeners = {}

function EEex_GameState_AddBeforeIncludesListener(listener)
	table.insert(EEex_GameState_Private_BeforeIncludesListeners, listener)
end

EEex_GameState_Private_AfterIncludesListeners = {}

function EEex_GameState_AddAfterIncludesListener(listener)
	table.insert(EEex_GameState_Private_AfterIncludesListeners, listener)
end

EEex_GameState_Private_AlreadyInitialized = false
EEex_GameState_Private_InitializedListeners = {}

-- @bubb_doc { EEex_GameState_AddInitializedListener }
--
-- @summary: Registers a listener function that is called immediately after the engine's Lua environment has been initialized.
--           This only occurs once during the engine's early start up process. If the engine has already been initialized,
--           ``listener`` is called immediately.
--
-- @param { listener / type=function }: The listener to register.

function EEex_GameState_AddInitializedListener(listener)
	if EEex_GameState_Private_AlreadyInitialized then
		listener()
	else
		table.insert(EEex_GameState_Private_InitializedListeners, listener)
	end
end

EEex_GameState_DestroyedListeners = {}

-- @bubb_doc { EEex_GameState_AddDestroyedListener }
--
-- @summary: Registers a listener function that is called immediately after the engine has cleaned up a game session.
--           Examples of when this occurs include the user quitting to the main menu, loading a save, etc.
--
-- @param { listener / type=function }: The listener to register.

function EEex_GameState_AddDestroyedListener(listener)
	table.insert(EEex_GameState_DestroyedListeners, listener)
end

EEex_GameState_ShutdownListeners = {}

function EEex_GameState_AddShutdownListener(listener)
	table.insert(EEex_GameState_ShutdownListeners, listener)
end

-----------
-- Hooks --
-----------

function EEex_GameState_Hook_OnBeforeIncludes()
	for _, listener in ipairs(EEex_GameState_Private_BeforeIncludesListeners) do
		EEex_Utility_TryIgnore(listener)
	end
end

function EEex_GameState_Hook_OnAfterIncludes()
	for _, listener in ipairs(EEex_GameState_Private_AfterIncludesListeners) do
		EEex_Utility_TryIgnore(listener)
	end
end

function EEex_GameState_LuaHook_OnInitialized()
	for _, listener in ipairs(EEex_GameState_Private_InitializedListeners) do
		EEex_Utility_TryIgnore(listener)
	end
	EEex_GameState_Private_AlreadyInitialized = true
	EEex_GameState_Private_InitializedListeners = {}
	-- So EEex files using EEex_GameState_AddInitializedListener() always run before options initialization.
	EEex_Options_Private_OnAfterGameStateInitialized()
end

function EEex_GameState_Hook_OnDestroyed()
	for _, listener in ipairs(EEex_GameState_DestroyedListeners) do
		EEex_Utility_TryIgnore(listener)
	end
end

function EEex_GameState_Hook_OnBeforeShutdown()
	for _, listener in ipairs(EEex_GameState_ShutdownListeners) do
		EEex_Utility_TryIgnore(listener)
	end
end
