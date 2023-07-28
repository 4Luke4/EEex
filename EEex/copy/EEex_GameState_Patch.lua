
(function()

	EEex_DisableCodeProtection()

	-----------------------------------------------------
	-- [EEex.dll] EEex::GameState_Hook_OnInitialized() --
	-----------------------------------------------------

	EEex_HookAfterCall(EEex_Label("Hook-SDL_main()-CLUAConsole::LuaInit()"), {[[
		call #L(EEex::GameState_Hook_OnInitialized)
	]]})

	---------------------------------------------
	-- [Lua] EEex_GameState_Hook_OnDestroyed() --
	---------------------------------------------

	EEex_HookAfterCall(EEex_Label("Hook-CInfGame::DestroyGame()-LastCall"), EEex_FlattenTable({
		{[[
			#MAKE_SHADOW_SPACE(32)
		]]},
		EEex_GenLuaCall("EEex_GameState_Hook_OnDestroyed"),
		{[[
			call_error:
			#DESTROY_SHADOW_SPACE
		]]},
	}))

	EEex_EnableCodeProtection()

end)()
