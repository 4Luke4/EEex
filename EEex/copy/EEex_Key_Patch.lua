
(function()

	EEex_DisableCodeProtection()

	-------------------------------------------
	-- [Lua] EEex_Key_Hook_AfterEventsPoll() --
	-------------------------------------------

	local afterEventsPollHook = EEex_JITNear(EEex_FlattenTable({
		{[[
			#STACK_MOD(8) ; This was called, the ret ptr broke alignment

			test eax, eax
			jnz call_hook
			ret

			call_hook:
			#MAKE_SHADOW_SPACE(40)
		]]},
		EEex_GenLuaCall("EEex_Key_Hook_AfterEventsPoll", {
			["args"] = {
				function(rspOffset) return {[[
					lea rcx, qword ptr ds:[rbp-51h]
					mov qword ptr ss:[rsp+#$(1)], rcx
				]], {rspOffset}}, "SDL_Event" end,
			},
			["returnType"] = EEex_LuaCallReturnType.Boolean,
		}),
		{[[
			xor rax, 1
			#DESTROY_SHADOW_SPACE(KEEP_ENTRY)
			ret

			call_error:
			#RESUME_SHADOW_ENTRY
			mov rax, 1
			#DESTROY_SHADOW_SPACE
			ret
		]]},
	}))

	EEex_HookRelativeBranch(EEex_Label("Hook-CChitin::ProcessEvents()-SDL_PollEvent()-1"), {[[
		call #L(original)
		call ]], afterEventsPollHook, [[ #ENDL
		jmp #L(return)
	]]})

	EEex_HookRelativeBranch(EEex_Label("Hook-CChitin::ProcessEvents()-SDL_PollEvent()-2"), {[[
		call #L(original)
		call ]], afterEventsPollHook, [[ #ENDL
		jmp #L(return)
	]]})

	EEex_EnableCodeProtection()

end)()
