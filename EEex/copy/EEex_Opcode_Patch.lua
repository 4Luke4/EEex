
(function()

	EEex_DisableCodeProtection()

	------------------------------------------------
	-- Clean up extended CGameEffect values       --
	--  [EEex.dll] EEex::Opcode_Hook_OnDestruct() --
	------------------------------------------------

	EEex_HookAfterCall(EEex_Label("Hook-CGameEffect::Destruct()_FirstCall"), {[[
		mov rcx, rdi ; pEffect
		call #L(EEex::Opcode_Hook_OnDestruct)
	]]})

	--------------------------------------------------
	-- Copy CGameEffect extended CGameEffect values --
	--  [EEex.dll] EEex::Opcode_Hook_OnCopy()       --
	--------------------------------------------------

	EEex_HookAfterCall(EEex_Label("Hook-CGameEffect::CopyFromBase()-FirstCall"), {[[

		; This is the only caller that isn't working with a CGameEffect.
		mov rax, #$(1) ]], {EEex_Label("Data-CGameEffect::DecodeEffectFromBase()-After-CGameEffect::CopyFromBase()")}, [[ #ENDL
		cmp qword ptr ss:[rsp+0x38], rax
		je #L(return)

		mov rdx, rdi                                             ; pDstEffect
		lea rcx, qword ptr ds:[rsi-#$(1)] ]], {EEex_PtrSize}, [[ ; pSrcEffect
		call #L(EEex::Opcode_Hook_OnCopy)
	]]})

	-------------------------------------------------------
	-- [EEex.dll] EEex::Opcode_Hook_AfterListsResolved() --
	-- [Lua] EEex_Opcode_LuaHook_AfterListsResolved()    --
	-------------------------------------------------------

	EEex_HookAfterCall(EEex_Label("Hook-CGameSprite::ProcessEffectList()-AfterListsResolved"), {[[
		mov rcx, rsi ; pSprite
		call #L(EEex::Opcode_Hook_AfterListsResolved)
	]]})

	--------------------------------------
	--          Opcode Changes          --
	--------------------------------------

	------------------------------------------------------------
	-- Opcode #248 (Special BIT0 allows .EFF to bypass op120) --
	--  [EEex.dll] EEex::Opcode_Hook_OnOp248AddTail()         --
	--  [Lua] EEex_Opcode_Hook_OnAfterSwingCheckedOp248()     --
	------------------------------------------------------------

	EEex_HookAfterCall(EEex_Label("Hook-CGameEffectMeleeEffect::ApplyEffect()-AddTail"), {[[
		mov rdx, rbx
		mov rcx, rdi
		call #L(EEex::Opcode_Hook_OnOp248AddTail)
	]]})

	EEex_HookAfterCall(EEex_Label("Hook-CGameSprite::Swing()-CImmunitiesWeapon::OnList()-Melee"), EEex_FlattenTable({
		{[[
			#MAKE_SHADOW_SPACE(64)
			mov qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)], rax
		]]},
		EEex_GenLuaCall("EEex_Opcode_Hook_OnAfterSwingCheckedOp248", {
			["args"] = {
				function(rspOffset) return {"mov qword ptr ss:[rsp+#$(1)], rbx #ENDL", {rspOffset}}, "CGameSprite" end,
				function(rspOffset) return {"mov qword ptr ss:[rsp+#$(1)], r15 #ENDL", {rspOffset}}, "CGameSprite" end,
				function(rspOffset) return {"mov qword ptr ss:[rsp+#$(1)], rax #ENDL", {rspOffset}}, "boolean" end,
			},
		}),
		{[[
			call_error:
			mov rax, qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)]
			#DESTROY_SHADOW_SPACE
		]]},
	}))

	------------------------------------------------------------
	-- Opcode #249 (Special BIT0 allows .EFF to bypass op120) --
	--  [EEex.dll] EEex::Opcode_Hook_OnOp249AddTail()         --
	--  [Lua] EEex_Opcode_Hook_OnAfterSwingCheckedOp249()     --
	------------------------------------------------------------

	local op249SavedEffect = EEex_Malloc(EEex_PtrSize)

	EEex_HookBeforeRestore(EEex_Label("Hook-CGameEffectRangeEffect::ApplyEffect()"), 0, 6, 6, {[[
		mov qword ptr ds:[#$(1)], rcx ]], {op249SavedEffect}, [[ #ENDL
	]]})

	EEex_HookAfterCall(EEex_Label("Hook-CGameEffectRangeEffect::ApplyEffect()-AddTail"), {[[
		mov rdx, rbx
		mov rcx, qword ptr ss:[#$(1)] ]], {op249SavedEffect}, [[ #ENDL
		call #L(EEex::Opcode_Hook_OnOp249AddTail)
	]]})

	EEex_HookAfterCall(EEex_Label("Hook-CGameSprite::Swing()-CImmunitiesWeapon::OnList()-Ranged"), EEex_FlattenTable({
		{[[
			#MAKE_SHADOW_SPACE(64)
			mov qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)], rax
		]]},
		EEex_GenLuaCall("EEex_Opcode_Hook_OnAfterSwingCheckedOp249", {
			["args"] = {
				function(rspOffset) return {"mov qword ptr ss:[rsp+#$(1)], rbx #ENDL", {rspOffset}}, "CGameSprite" end,
				function(rspOffset) return {"mov qword ptr ss:[rsp+#$(1)], r15 #ENDL", {rspOffset}}, "CGameSprite" end,
				function(rspOffset) return {"mov qword ptr ss:[rsp+#$(1)], rax #ENDL", {rspOffset}}, "boolean" end,
			},
		}),
		{[[
			call_error:
			mov rax, qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)]
			#DESTROY_SHADOW_SPACE

			test rax, rax
			jz #L(return)
		]]},
		EEex_IntegrityCheck_HookExit,
		{[[
			; The consequence of not running the else block is that this boilerplate is not executed
			mov rsi, qword ptr ss:[rsp+0x70]
			lea r13, qword ptr ds:[r15+0xC]
			jmp #L(Hook-CGameSprite::Swing()-NoCImmunitiesWeaponElseContinue)
		]]},
	}))

	---------------------------------------------------------------------------------
	-- Opcode #326 (Special BIT0 flips SPLPROT.2DA's "source" and "target")        --
	--  [EEex.dll] EEex::Opcode_Hook_ApplySpell_ShouldFlipSplprotSourceAndTarget() --
	---------------------------------------------------------------------------------

	EEex_HookAfterRestore(EEex_Label("Hook-CGameEffectApplySpell::ApplyEffect()-OverrideSplprotContext"), 0, 7, 7, EEex_FlattenTable({
		{[[
			#MAKE_SHADOW_SPACE(32)
			mov qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)], rcx
			mov qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-16)], rdx
			mov qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-24)], r8
			mov qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-32)], r9

			mov rcx, rbx ; pEffect
			call #L(EEex::Opcode_Hook_ApplySpell_ShouldFlipSplprotSourceAndTarget)

			test rax, rax
			mov r9, qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-32)]
			mov r8, qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-24)]
			mov rdx, qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-16)]
			mov rcx, qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)]
			#DESTROY_SHADOW_SPACE
			jz #L(return)

			mov rax, r8
			mov r8, r9
			mov r9, rax
		]]},
	}))

	-----------------------------------
	--          New Opcodes          --
	-----------------------------------

	local genOpcodeDecode = function(args)

		local writeConstructor = function(vftable)
			return EEex_JITNear({[[
				push rbx
				sub rsp, 40h
				mov rax, qword ptr ss:[rsp+70h]
				mov rbx, rcx
				mov dword ptr ss:[rsp+30h], 0xFFFFFFFF
				mov dword ptr ss:[rsp+28h], 0x0
				mov qword ptr ss:[rsp+20h], rax
				call #L(CGameEffect::Construct)
				lea rax, qword ptr ds:[#$(1)] ]], {vftable}, [[ #ENDL
				mov qword ptr ds:[rbx], rax
				mov rax, rbx
				add rsp, 40h
				pop rbx
				ret
			]]})
		end

		local writeCopy = function(vftable)
			return EEex_JITNear({[[
				mov qword ptr ss:[rsp+8h], rbx
				mov qword ptr ss:[rsp+10h], rbp
				mov qword ptr ss:[rsp+18h], rsi
				push rdi
				sub rsp, 40h
				mov rsi, rcx
				call #L(CGameEffect::GetItemEffect)
				mov ecx, 158h
				mov rbp, rax
				call #L(operator_new)
				xor edi, edi
				mov rbx, rax
				test rax, rax
				je _1
				mov rdx, qword ptr ds:[rsi+88h]
				lea r8, qword ptr ds:[rsi+80h]
				mov r9d, dword ptr ds:[rsi+110h]
				mov rcx, rax
				mov dword ptr ss:[rsp+30h], 0xFFFFFFFF
				mov dword ptr ss:[rsp+28h], edi
				mov qword ptr ss:[rsp+20h], rdx
				mov rdx, rbp
				call #L(CGameEffect::Construct)
				lea rax, qword ptr ds:[#$(1)] ]], {vftable}, [[ #ENDL
				mov qword ptr ds:[rbx], rax
				jmp _2
				_1:
				mov rbx, rdi
				_2:
				mov edx, 30h
				mov rcx, rbp
				call #L(Hardcoded_free)                             ; SDL_FreeRW
				test rsi, rsi
				lea rdx, qword ptr ds:[rsi+8h]
				mov rcx, rbx
				cmove rdx, rdi
				call #L(CGameEffect::CopyFromBase)
				mov rbp, qword ptr ss:[rsp+58h]
				mov rax, rbx
				mov rbx, qword ptr ss:[rsp+50h]
				mov rsi, qword ptr ss:[rsp+60h]
				add rsp, 40h
				pop rdi
				ret
			]]})
		end

		local genDecode = function(constructor)
			return {[[
				mov ecx, #$(1) ]], {CGameEffect.sizeof}, [[ #ENDL
				call #L(operator_new)
				mov rcx, rax                                     ; this
				test rax, rax
				jz #L(Hook-CGameEffect::DecodeEffect()-Fail)
				mov rax, qword ptr ds:[rsi]                      ; target
				mov qword ptr [rsp+20h], rax
				mov r9d, ebp                                     ; sourceID
				mov r8, r14                                      ; source
				mov rdx, rdi                                     ; effect
				call #$(1) ]], {constructor}, [[ #ENDL
				jmp #L(Hook-CGameEffect::DecodeEffect()-Success)
			]]}
		end

		local vtblsize = _G["CGameEffect::vtbl"].sizeof
		local newvtbl = EEex_Malloc(vtblsize)
		EEex_Memcpy(newvtbl, EEex_Label("Data-CGameEffect::vftable"), vtblsize)

		EEex_WriteArgs(newvtbl, args, {
			{ "__vecDelDtor",  0  * EEex_PtrSize, EEex_WriteType.JIT, EEex_WriteFailType.NOTHING                     },
			{ "Copy",          1  * EEex_PtrSize, EEex_WriteType.JIT, EEex_WriteFailType.DEFAULT, writeCopy(newvtbl) },
			{ "ApplyEffect",   2  * EEex_PtrSize, EEex_WriteType.JIT, EEex_WriteFailType.NOTHING                     },
			{ "ResolveEffect", 3  * EEex_PtrSize, EEex_WriteType.JIT, EEex_WriteFailType.NOTHING                     },
			{ "OnAdd",         4  * EEex_PtrSize, EEex_WriteType.JIT, EEex_WriteFailType.NOTHING                     },
			{ "OnAddSpecific", 5  * EEex_PtrSize, EEex_WriteType.JIT, EEex_WriteFailType.NOTHING                     },
			{ "OnLoad",        6  * EEex_PtrSize, EEex_WriteType.JIT, EEex_WriteFailType.NOTHING                     },
			{ "CheckSave",     7  * EEex_PtrSize, EEex_WriteType.JIT, EEex_WriteFailType.NOTHING                     },
			{ "UsesDice",      8  * EEex_PtrSize, EEex_WriteType.JIT, EEex_WriteFailType.NOTHING                     },
			{ "DisplayString", 9  * EEex_PtrSize, EEex_WriteType.JIT, EEex_WriteFailType.NOTHING                     },
			{ "OnRemove",      10 * EEex_PtrSize, EEex_WriteType.JIT, EEex_WriteFailType.NOTHING                     },
		})

		return genDecode(writeConstructor(newvtbl))
	end

	----------------------------------------------------------------------
	-- New Opcode #400 (SetTemporaryAIScript)                           --
	--  [EEex.dll] EEex::Opcode_Hook_SetTemporaryAIScript_ApplyEffect() --
	--  [EEex.dll] EEex::Opcode_Hook_SetTemporaryAIScript_OnRemove()    --
	----------------------------------------------------------------------

	local EEex_SetTemporaryAIScript = genOpcodeDecode({

		["ApplyEffect"] = {[[
			#STACK_MOD(8) ; This was called, the ret ptr broke alignment
			#MAKE_SHADOW_SPACE
			call #L(EEex::Opcode_Hook_SetTemporaryAIScript_ApplyEffect)
			#DESTROY_SHADOW_SPACE
			ret
		]]},

		["OnRemove"] = {[[
			#STACK_MOD(8) ; This was called, the ret ptr broke alignment
			#MAKE_SHADOW_SPACE
			call #L(EEex::Opcode_Hook_SetTemporaryAIScript_OnRemove)
			#DESTROY_SHADOW_SPACE
			ret
		]]},
	})

	-----------------------------------------------------------------
	-- New Opcode #401 (SetExtendedStat)                           --
	--  [EEex.dll] EEex::Opcode_Hook_SetExtendedStat_ApplyEffect() --
	-----------------------------------------------------------------

	local EEex_SetExtendedStat = genOpcodeDecode({

		["ApplyEffect"] = {[[

			#STACK_MOD(8) ; This was called, the ret ptr broke alignment
			#MAKE_SHADOW_SPACE
			call #L(EEex::Opcode_Hook_SetExtendedStat_ApplyEffect)
			#DESTROY_SHADOW_SPACE
			ret
		]]},
	})

	---------------------------------------
	-- [JIT] New Opcode #402 (InvokeLua) --
	---------------------------------------

	local EEex_InvokeLua = genOpcodeDecode({

		["ApplyEffect"] = EEex_FlattenTable({[[

			#STACK_MOD(8) ; This was called, the ret ptr broke alignment
			#MAKE_SHADOW_SPACE(64)
			mov rax, qword ptr ds:[rcx+30h] ; res
			mov qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-16)], rax
			mov byte ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)], 0

			]], EEex_GenLuaCall(nil, {
				["functionSrc"] = {[[
					lea rdx, qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-16)]
					mov rcx, rbx
					#ALIGN
					call #L(Hardcoded_lua_getglobal)
					#ALIGN_END
				]]},
				["args"] = {
					function(rspOffset) return {"mov qword ptr ss:[rsp+#$(1)], rcx", {rspOffset}, "#ENDL"}, "CGameEffect" end,
					function(rspOffset) return {"mov qword ptr ss:[rsp+#$(1)], rdx", {rspOffset}, "#ENDL"}, "CGameSprite" end,
				},
			}), [[

			call_error:
			#DESTROY_SHADOW_SPACE
			mov rax, 1
			ret
		]]}),
	})

	---------------------------------------------------------------
	-- New Opcode #403 (ScreenEffects)                           --
	--  [EEex.dll] EEex::Opcode_Hook_ScreenEffects_ApplyEffect() --
	--  [EEex.dll] EEex::Opcode_Hook_OnCheckAdd()                --
	---------------------------------------------------------------

	local EEex_ScreenEffects = genOpcodeDecode({

		["ApplyEffect"] = {[[
			#STACK_MOD(8) ; This was called, the ret ptr broke alignment
			#MAKE_SHADOW_SPACE
			call #L(EEex::Opcode_Hook_ScreenEffects_ApplyEffect)
			#DESTROY_SHADOW_SPACE
			ret
		]]},
	})

	local effectBlockedHack = EEex_Malloc(0x8)

	EEex_HookConditionalJumpOnFail(EEex_Label("Hook-CGameEffect::CheckAdd()-LastProbabilityJmp"), 0, EEex_FlattenTable({
		{[[
			#MAKE_SHADOW_SPACE(8)
			mov qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)], rdx

			mov rdx, r14 ; pSprite
			mov rcx, rdi ; pEffect
			call #L(EEex::Opcode_Hook_OnCheckAdd)

			mov qword ptr ds:[#$(1)], rax ]], {effectBlockedHack}, [[ #ENDL

			mov rdx, qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)]
			#DESTROY_SHADOW_SPACE
			test rax, rax

			jz #L(jmp_fail)
		]]},
		EEex_IntegrityCheck_HookExit,
		{[[
			jmp #L(Hook-CGameEffect::CheckAdd()-ProbabilityFailed)
		]]},
	}))

	EEex_HookConditionalJumpOnSuccess(EEex_Label("Hook-CGameSprite::AddEffect()-noSave-Override"), 3, {[[
		cmp qword ptr ds:[#$(1)], 0 ]], {effectBlockedHack}, [[ #ENDL
		jnz #L(jmp_fail)
	]]})

	-------------------------------------------------------------------
	-- New Opcode #408 (ProjectileMutator)                           --
	--  [EEex.dll] EEex::Opcode_Hook_ProjectileMutator_ApplyEffect() --
	-------------------------------------------------------------------

	local EEex_ProjectileMutator = genOpcodeDecode({

		["ApplyEffect"] = {[[
			#STACK_MOD(8) ; This was called, the ret ptr broke alignment
			#MAKE_SHADOW_SPACE
			call #L(EEex::Opcode_Hook_ProjectileMutator_ApplyEffect)
			#DESTROY_SHADOW_SPACE
			ret
		]]},
	})

	----------------------------------------------------------------------
	-- New Opcode #409 (EnableActionListener)                           --
	--  [EEex.dll] EEex::Opcode_Hook_EnableActionListener_ApplyEffect() --
	----------------------------------------------------------------------

	local EEex_EnableActionListener = genOpcodeDecode({

		["ApplyEffect"] = {[[
			#STACK_MOD(8) ; This was called, the ret ptr broke alignment
			#MAKE_SHADOW_SPACE
			call #L(EEex::Opcode_Hook_EnableActionListener_ApplyEffect)
			#DESTROY_SHADOW_SPACE
			ret
		]]},
	})

	-------------------------
	-- [JIT] Decode Switch --
	-------------------------

	EEex_HookConditionalJumpOnSuccess(EEex_Label("Hook-CGameEffect::DecodeEffect()-DefaultJmp"), 0, EEex_FlattenTable({[[

		mov qword ptr ss:[rsp+60h], r15 ; save non-volatile register since I resume control flow from an EEex
										; opcode to somewhere that expects this stack location to be filled

		cmp eax, 400
		jne _401
		]], EEex_SetTemporaryAIScript, [[

		_401:
		cmp eax, 401
		jne _402
		]], EEex_SetExtendedStat, [[

		_402:
		cmp eax, 402
		jne _403
		]], EEex_InvokeLua, [[

		_403:
		cmp eax, 403
		jne _408
		]], EEex_ScreenEffects, [[

		_408:
		cmp eax, 408
		jne _409
		]], EEex_ProjectileMutator, [[

		_409:
		cmp eax, 409
		jne #L(jmp_success)
		]], EEex_EnableActionListener, [[
	]]}))

	EEex_EnableCodeProtection()

end)()
