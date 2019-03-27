
function EEex_InstallOpcodeChanges()

	EEex_DisableCodeProtection()

	--------------------------------------------------
	-- Opcode #42 (Remove "at least 1 slot" checks) --
	--------------------------------------------------

	EEex_WriteAssembly(EEex_Label("Opcode42DisableCheck1"), {"!nop !nop"})
	EEex_WriteAssembly(EEex_Label("Opcode42DisableCheck2"), {"!nop !nop"})
	EEex_WriteAssembly(EEex_Label("Opcode42DisableCheck3"), {"!nop !nop"})
	EEex_WriteAssembly(EEex_Label("Opcode42DisableCheck4"), {"!nop !nop"})
	EEex_WriteAssembly(EEex_Label("Opcode42DisableCheck5"), {"!nop !nop"})
	EEex_WriteAssembly(EEex_Label("Opcode42DisableCheck6"), {"!nop !nop"})
	EEex_WriteAssembly(EEex_Label("Opcode42DisableCheck7"), {"!nop !nop"})
	EEex_WriteAssembly(EEex_Label("Opcode42DisableCheck8"), {"!nop !nop"})
	EEex_WriteAssembly(EEex_Label("Opcode42DisableCheck9"), {"!nop !nop !nop !nop !nop !nop"})

	--------------------------------------------------
	-- Opcode #218 (Fire subspell when layers lost) --
	--------------------------------------------------

	local fireSubspellAddress = EEex_WriteAssemblyAuto({[[

		!build_stack_frame
		!sub_esp_byte 0C
		!push_all_registers

		!mov_esi_ecx

		!lea_edi_[esi+byte] 2C
		!mov_ecx_edi
		!call >CResRef::IsValid

		!test_eax_eax
		!jne_dword >fire_spell

		!push_dword *aB_1
		!lea_eax_[ebp+byte] F8
		!push_eax
		!lea_ecx_[esi+dword] #90
		!call >CResRef::GetResRefStr
		!push_eax
		!lea_eax_[ebp+byte] F4
		!push_eax
		!call >(CString)_operator+
		!add_esp_byte 0C
		!mov_ecx_edi
		!push_eax
		!lea_eax_[ebp+byte] FC
		!push_eax
		!call >CResRef::operator_equ
		!lea_ecx_[ebp+byte] F4
		!call >CString::~CString
		!lea_ecx_[ebp+byte] F8
		!call >CString::~CString

		@fire_spell

		!push_[esi+dword] #10C
		!mov_ecx_esi
		!push_[esi+dword] #C4
		!push_byte 00
		!push_[ebp+byte] 08
		!push_edi
		!call >CGameEffect::FireSpell
		!mov_[esi+dword]_dword #110 #01

		!pop_all_registers
		!destroy_stack_frame
		!ret_word 04 00

	]]})

	local fireSubspellHook1 = EEex_WriteAssemblyAuto({[[
		!push_complete_state
		!push_esi
		!mov_ecx_edi
		!call ]], {fireSubspellAddress, 4, 4}, [[
		!pop_complete_state
		!ret
	]]})

	EEex_WriteAssembly(EEex_Label("Opcode218LostLayersHook"), {"!call", {fireSubspellHook1, 4, 4}, "!nop !nop !nop !nop !nop"})

	----------------------------------------------
	-- Opcode #280 (Param1 overrides surge num) --
	----------------------------------------------

	local opcode280Override = EEex_Label("Opcode280Override")
	local opcode280Surge = EEex_WriteAssemblyAuto({[[
		!mov_[eax+dword]_edx #D58
		!mov_edx_[ecx+byte] 18 ; Param1 (Surge Override) ;
		!test_edx_edx
		!jz_dword >skip_num_override
		!mov_edi_[eax+dword] #3B18
		!mov_[edi+dword]_edx #184
		@skip_num_override
		!mov_edx_[ecx+byte] 44 ; Special (Suppress Graphics) ;
		!test_edx_edx
		!jz_dword >ret
		!mov_edi_[eax+dword] #3B18
		!mov_[edi+dword]_edx #188
		@ret
		!jmp_dword ]], {opcode280Override + 0x6, 4, 4},
	})
	EEex_WriteAssembly(opcode280Override, {"!jmp_dword ", {opcode280Surge, 4, 4}, "!nop"})

	local overrideJump = EEex_Label("WildSurgeOverride")
	local wildSurgeOverride = EEex_WriteAssemblyAuto({[[
		!push_dword #12C
		!mov_ecx_edi
		!call >EEex_AccessStat
		!test_eax_eax
		!cmovnz_ebx_eax
		!cmp_[ebp+dword]_byte #FFFFFB08 00
		!jmp_dword ]], {overrideJump + 0x7, 4, 4},
	})
	EEex_WriteAssembly(overrideJump, {"!jmp_dword ", {wildSurgeOverride, 4, 4}, "!nop !nop"})

	-- NOP 0x7435B9
		-- REASON: (Disables Feedback String)
		-- HOW: (add esp,0x1C  and  NOP*2)
		-- REQUIRED FIXES: (None)

	local wildSurgeFeedbackAddress = EEex_Label("WildSurgeFeedback")
	local opcode280Feedback = EEex_WriteAssemblyAuto({[[
		!push_dword #12D
		!call >EEex_AccessStat
		!test_eax_eax
		!jnz_dword >skip_feedback
		!call >CGameSprite::FeedBack
		!jmp_dword >ret
		@skip_feedback
		!add_esp_byte 1C
		@ret
		!jmp_dword ]], {wildSurgeFeedbackAddress + 0x5, 4, 4},
	})
	EEex_WriteAssembly(wildSurgeFeedbackAddress, {"!jmp_dword ", {opcode280Feedback, 4, 4}})

	-- Force 0x743608 - (Disables Random Visual Effect)

	local wildSurgeVisualJump = EEex_Label("WildSurgeSkipRandomVisual")
	local opcode280Visual = EEex_WriteAssemblyAuto({[[
		!push_dword #12D
		!mov_ecx_edi
		!call >EEex_AccessStat
		!test_eax_eax
		!jz_dword >normal_execution
		; Set the ZF manually ;
		!xor_eax_eax
		!jmp_dword >ret
		@normal_execution
		!cmp_[ebp+dword]_byte #FFFFFB50 00
		@ret
		!ret
	]]})
	EEex_WriteAssembly(wildSurgeVisualJump, {"!call", {opcode280Visual, 4, 4}, "!nop !nop"})

	-- NOP 0x744132
		-- REASON: (Prevents SPFLESHS From Loading)
		-- HOW: (NOP*4),
		-- REQUIRED FIXES: (Free "name" CString)

	local wildSurgeSwirlLoadAddress = EEex_Label("WildSurgeSkipSwirlLoad")
	local opcode280SwirlLoad = EEex_WriteAssemblyAuto({[[
		!push_dword #12D
		!mov_ecx_edi
		!call >EEex_AccessStat
		!test_eax_eax
		!jnz_dword >skip_swirl
		!call >CVisualEffect::Load
		!jmp_dword >ret
		@skip_swirl
		!mov_ecx_esp
		!call >CString::~CString
		@ret
		!jmp_dword ]], {wildSurgeSwirlLoadAddress + 0x5, 4, 4},
	})
	EEex_WriteAssembly(wildSurgeSwirlLoadAddress, {"!jmp_dword ", {opcode280SwirlLoad, 4, 4}})

	-- NOP 0x744207
		-- REASON: (Prevents SPFLESHS From Being Sent To Multiplayer)
		-- HOW: (add esp,0x8  and  NOP*2),
		-- REQUIRED FIXES: (None)

	local wildSurgeSwirlSendAddress = EEex_Label("WildSurgeSkipSwirlSend")
	local opcode280SwirlSend = EEex_WriteAssemblyAuto({[[
		!push_dword #12D
		!mov_ecx_[esp+byte] 10
		!call >EEex_AccessStat
		!test_eax_eax
		!jnz_dword >skip_swirl
		!call >CMessageHandler::AddMessage
		!jmp_dword >ret
		@skip_swirl
		!add_esp_byte 08
		@ret
		!jmp_dword ]], {wildSurgeSwirlSendAddress + 0x5, 4, 4},
	})
	EEex_WriteAssembly(wildSurgeSwirlSendAddress, {"!jmp_dword ", {opcode280SwirlSend, 4, 4}})

	-----------------------------------------
	-- Opcode #324 (Set strref to Special) --
	-----------------------------------------

	local opcode324StrrefOverride = EEex_WriteAssemblyAuto({[[
		!mov_edi_[esi+byte] 44
		!test_edi_edi
		!jnz_dword >ret
		!mov_edi #0F00080
		!cmp_eax_dword #109
		@ret
		!ret
	]]})
	EEex_WriteAssembly(EEex_Label("Opcode324StrrefHook"), {"!call", {opcode324StrrefOverride, 4, 4}})

	-----------------------------------
	-- New Opcode #400 (SetAIScript) --
	-----------------------------------

	local setAIScript = EEex_WriteAssemblyAuto({[[

		!push_state
		!mov_esi_ecx

		!push_dword *NullString
		!call >CResRef::operator_notequ

		!test_eax_eax
		!je_dword >no_script

		!push_byte 24
		!call >operator_new
		!add_esp_byte 04

		!test_eax_eax
		!je_dword >no_script

		!push_byte 00
		!mov_ecx_[ebp+byte] 08
		!push_[ecx+byte] 04
		!push_[ecx]

		!mov_ecx_eax
		!call >CAIScript::CAIScript
		!jmp_dword >new_script

		@no_script
		!xor_eax_eax

		@new_script

		!push_eax
		!push_[ebp+byte] 0C
		!mov_ecx_esi

		!mov_eax_[esi]
		!call_[eax+dword] #90

		!pop_state
		!ret_word 08 00

	]]})

	local newOpcode400 = EEex_WriteOpcode({

		["ApplyEffect"] = {[[

			!push_state

			!mov_esi_ecx

			!cmp_[esi+dword]_byte #C8 00
			!je_dword >do_nothing

			!mov_[esi+dword]_dword #C8 #00

			!movzx_eax_word:[esi+byte] 1C
			!cmp_eax_byte 07
			!ja_dword >do_nothing

			!cmp_eax_byte 04
			!jb_dword >do_lookup

			!dec_eax

			@do_lookup

			!mov_ecx_[ebp+byte] 08
			!lea_ecx_[ecx+eax*4+dword] #268
			!mov_ecx_[ecx]
			!test_ecx_ecx
			!je_dword >undefined_script

			!mov_eax_[ecx]
			!mov_[esi+byte]_eax 6C
			!mov_eax_[ecx+byte] 04
			!mov_[esi+byte]_eax 70
			!jmp_dword >defined_script

			@undefined_script

			!mov_[esi+byte]_dword 6C #00
			!mov_[esi+byte]_dword 70 #00

			@defined_script

			!movzx_eax_word:[esi+byte] 1C
			!push_eax
			!lea_eax_[esi+byte] 2C
			!push_eax
			!mov_ecx_[ebp+byte] 08
			!call ]], {setAIScript, 4, 4}, [[

			@do_nothing

			!pop_state
			!ret_word 04 00

		]]},

		["OnRemove"] = {[[

			!push_state

			!mov_esi_ecx

			!movzx_eax_word:[esi+byte] 1C
			!push_eax
			!lea_eax_[esi+byte] 6C
			!push_eax
			!mov_ecx_[ebp+byte] 08
			!call ]], {setAIScript, 4, 4}, [[

			!pop_state
			!ret_word 04 00

		]]},
	})

	----------------------------------
	-- New Opcode #401 (SetNewStat) --
	----------------------------------

	local EEex_SetNewStat = EEex_WriteOpcode({

		["ApplyEffect"] = {[[

			!build_stack_frame
			!push_registers

			!mov_esi_ecx
			!mov_edi_[esi+byte] 44 ; Special (Stat Num) ;
			!mov_ecx_[ebp+byte] 08 ; CGameSprite ;

			!sub_edi_dword #CB
			!cmp_edi_dword ]], {EEex_NewStatsCount, 4}, [[
			!jae_dword >ret

			!mov_ecx_[ecx+dword] #3B18
			!mov_eax_[esi+byte] 1C ; Param2 (Type) ;

			!sub_eax_byte 00
			!jz_dword >type_cumulative
			!dec_eax
			!jz_dword >type_flat
			!dec_eax
			!jnz_dword >ret

			@type_percentage
			!mov_edx_[ecx+edi*4]
			!imul_edx_[esi+byte] 18
			!mov_eax #51EB851F ; Magic number for division by 100 ;
			!imul_edx
			!sar_edx 05
			!mov_eax_edx
			!shr_eax 1F
			!add_edx_eax
			!jmp_dword >set_stat

			@type_cumulative
			!mov_edx_[ecx+edi*4]
			!add_edx_[esi+byte] 18 ; Param1 (Statistic Modifier) ;
			!jmp_dword >set_stat

			@type_flat
			!mov_edx_[esi+byte] 18 ; Param1 (Statistic Modifier) ;

			@set_stat
			!mov_[ecx+edi*4]_edx

			@ret
			!mov_eax #1
			!restore_stack_frame
			!ret_word 04 00
		]]},
	})

	---------------------------------
	-- New Opcode #402 (InvokeLua) --
	---------------------------------

	local EEex_InvokeLua = EEex_WriteOpcode({

		["ApplyEffect"] = {[[

			!build_stack_frame
			!sub_esp_byte 0C
			!push_registers

			!mov_esi_ecx

			; Copy resref field into null-terminated stack space ;
			!mov_eax_[esi+byte] 2C
			!mov_[ebp+byte]_eax F4
			!mov_eax_[esi+byte] 30
			!mov_[ebp+byte]_eax F8
			!mov_byte:[ebp+byte]_byte FC 0

			!lea_eax_[ebp+byte] F4
			!push_eax
			!push_[dword] *_g_lua
			!call >_lua_getglobal
			!add_esp_byte 08
	
			!push_esi
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_[dword] *_g_lua
			!call >_lua_pushnumber
			!add_esp_byte 0C
	
			!push_[ebp+byte] 08
			!fild_[esp]
			!sub_esp_byte 04
			!fstp_qword:[esp]
			!push_[dword] *_g_lua
			!call >_lua_pushnumber
			!add_esp_byte 0C
	
			!push_byte 00
			!push_byte 00
			!push_byte 00
			!push_byte 00
			!push_byte 02
			!push_[dword] *_g_lua
			!call >_lua_pcallk
			!add_esp_byte 18

			@ret
			!mov_eax #1
			!restore_stack_frame
			!ret_word 04 00
		]]},
	})

	-----------------------------
	-- Opcode Definitions Hook --
	-----------------------------

	local opcodesHook = EEex_WriteAssemblyAuto(EEex_ConcatTables({[[

		!cmp_eax_dword #190
		!jne_dword >401

		]], newOpcode400, [[

		@401
		!cmp_eax_dword #191
		!jne_dword >402

		]], EEex_SetNewStat, [[

		@402
		!cmp_eax_dword #192
		!jne_dword >fail

		]], EEex_InvokeLua, [[

		@fail
		!jmp_dword >CGameEffect::DecodeEffect()_default_label

	]]}))

	EEex_WriteAssembly(EEex_Label("CGameEffect::DecodeEffect()_default_jump"), {{opcodesHook, 4, 4}})

	EEex_EnableCodeProtection()

end
EEex_InstallOpcodeChanges()
