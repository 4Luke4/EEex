
(function()

	EEex_DisableCodeProtection()

	--------------------------------------------------
	-- [Lua] EEex_Action_Hook_OnEvaluatingUnknown() --
	--------------------------------------------------

	EEex_HookConditionalJumpOnSuccess(EEex_Label("Hook-CGameAIBase::ExecuteAction()-DefaultJmp"), 0, EEex_FlattenTable({
		{[[
			#MAKE_SHADOW_SPACE(48)
		]]},
		EEex_GenLuaCall("EEex_Action_Hook_OnEvaluatingUnknown", {
			["args"] = {
				function(rspOffset) return {[[
					mov qword ptr ss:[rsp+#$(1)], rbx
				]], {rspOffset}}, "CGameAIBase", "EEex_GameObject_CastUT" end,
			},
			["returnType"] = EEex_LuaCallReturnType.Number,
		}),
		{[[
			mov esi, eax
			#DESTROY_SHADOW_SPACE(KEEP_ENTRY)
		]]},
		EEex_IntegrityCheck_HookExit,
		{[[
			jmp #L(Hook-CGameAIBase::ExecuteAction()-NormalBranch)

			call_error:
			#RESUME_SHADOW_ENTRY
			#DESTROY_SHADOW_SPACE
		]]}
	}))

	---------------------------------------------------------------
	-- [EEex.dll] EEex::Action_Hook_OnAfterSpriteStartedAction() --
	---------------------------------------------------------------

	EEex_HookAfterCall(EEex_Label("CGameSprite::SetCurrAction()-LastCall"), {[[

		cmp word ptr ds:[r14], 0 ; Don't call the hook for NoAction() since the engine spams it
		jz #L(return)

		mov rcx, rdi ; pSprite
		call #L(EEex::Action_Hook_OnAfterSpriteStartedAction)
	]]})

	EEex_EnableCodeProtection()

end)()
