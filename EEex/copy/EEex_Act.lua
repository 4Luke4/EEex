--[[

Installs the EEex_Lua action into the exe.
No new Lua functionality is defined in this file.

--]]

function EEex_InstallNewActions()

	local luaActorName = "EEex_LuaActorID"
	local luaActorAddress = EEex_Malloc(#luaActorName + 1)
	EEex_WriteString(luaActorAddress, luaActorName)

	local hookAddress = EEex_WriteAssemblyAuto({[[
		!cmp_eax_dword #1D8
		!je_dword >EEex_Lua
		!jmp_dword >not_defined

		@EEex_Lua

		!push_[esi+dword] #344
		!push_[dword] *_g_lua
		; TODO: Cache Lua chunks ;
		!call >_luaL_loadstring
		!add_esp_byte 08

		!push_[esi+byte] 34
		!fild_[esp]
		!sub_esp_byte 04
		!fstp_qword:[esp]
		!push_[dword] *_g_lua
		!call >_lua_pushnumber
		!add_esp_byte 0C

		!push_dword ]], {luaActorAddress, 4}, [[
		!push_[dword] *_g_lua
		!call >_lua_setglobal
		!add_esp_byte 08

		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_byte 00
		!push_[dword] *_g_lua
		!call >_lua_pcallk
		!add_esp_byte 18

		!mov_bx FF FF
		!jmp_dword >CGameAIBase::ExecuteAction()_success_label

		@not_defined
		!jmp_dword >CGameAIBase::ExecuteAction()_fail_label
	]]})

	EEex_DisableCodeProtection()
	EEex_WriteAssembly(EEex_Label("CGameAIBase::ExecuteAction()_default_jump"), {{hookAddress, 4, 4}})
	EEex_EnableCodeProtection()
end
EEex_InstallNewActions()
