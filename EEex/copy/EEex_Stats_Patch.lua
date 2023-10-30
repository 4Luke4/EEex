
(function()

	EEex_DisableCodeProtection()

	-----------------------------------------------
	-- [EEex.dll] EEex::Stats_Hook_OnConstruct() --
	-----------------------------------------------

	EEex_HookAfterCallWithLabels(EEex_Label("Hook-CDerivedStats::Construct()-FirstCall"), {
		{"integrity_ignore_registers", {EEex_IntegrityRegister.RAX}}},
		{[[
			mov rcx, rsi ; pStats
			call #L(EEex::Stats_Hook_OnConstruct)
		]]}
	)

	----------------------------------------------
	-- [EEex.dll] EEex::Stats_Hook_OnDestruct() --
	----------------------------------------------

	EEex_HookAfterCallWithLabels(EEex_Label("Hook-CDerivedStats::Destruct()-FirstCall"), {
		{"integrity_ignore_registers", {EEex_IntegrityRegister.RAX}}},
		{[[
			mov rcx, rdi ; pStats
			call #L(EEex::Stats_Hook_OnDestruct)
		]]}
	)

	--------------------------------------------
	-- [EEex.dll] EEex::Stats_Hook_OnReload() --
	--------------------------------------------

	local statsReloadTemplate = function(spriteRegStr)
		return {[[
			mov rcx, #$(1) ]], {spriteRegStr}, [[ ; pSprite
			call #L(EEex::Stats_Hook_OnReload)
		]]}
	end

	local callStatsReloadRbx = {"call #$(1) #ENDL",
		{
			EEex_JITNear(EEex_FlattenTable({
				{[[
					#STACK_MOD(8) ; This was called, the ret ptr broke alignment
					#MAKE_SHADOW_SPACE
				]]},
				statsReloadTemplate("rbx"),
				{[[
					#DESTROY_SHADOW_SPACE
					ret
				]]},
			})),
		},
	}

	EEex_HookAfterCallWithLabels(EEex_Label("Hook-CGameSprite::QuickLoad()-CDerivedStats::Reload()"), {
		{"integrity_ignore_registers", {EEex_IntegrityRegister.RAX}}},
		statsReloadTemplate("rdi")
	)

	EEex_HookAfterCallWithLabels(EEex_Label("Hook-CGameSprite::Unmarshal()-CDerivedStats::Reload()-1"), {
		{"integrity_ignore_registers", {EEex_IntegrityRegister.RAX}}},
		callStatsReloadRbx
	)

	EEex_HookAfterCallWithLabels(EEex_Label("Hook-CGameSprite::Unmarshal()-CDerivedStats::Reload()-2"), {
		{"integrity_ignore_registers", {EEex_IntegrityRegister.RAX}}},
		callStatsReloadRbx
	)

	EEex_HookAfterCallWithLabels(EEex_Label("Hook-CGameSprite::ProcessEffectList()-CDerivedStats::Reload()"), {
		{"integrity_ignore_registers", {EEex_IntegrityRegister.RAX}}},
		statsReloadTemplate("rsi")
	)

	-----------------------------------------
	-- [EEex.dll] EEex::Stats_Hook_OnEqu() --
	-----------------------------------------

	EEex_HookAfterCallWithLabels(EEex_Label("Hook-CDerivedStats::operator_equ()-FirstCall"), {
		{"integrity_ignore_registers", {EEex_IntegrityRegister.RAX}}},
		{[[
			mov rdx, rsi ; pOtherStats
			mov rcx, r14 ; pStats
			call #L(EEex::Stats_Hook_OnEqu)
		]]}
	)

	---------------------------------------------
	-- [EEex.dll] EEex::Stats_Hook_OnPlusEqu() --
	---------------------------------------------

	EEex_HookBeforeCallWithLabels(EEex_Label("Hook-CDerivedStats::operator_plus_equ()-FirstCall"), {
		{"integrity_ignore_registers", {
			EEex_IntegrityRegister.RDX, EEex_IntegrityRegister.R8, EEex_IntegrityRegister.R9,
			EEex_IntegrityRegister.R10, EEex_IntegrityRegister.R11
		}}},
		{[[
			#MAKE_SHADOW_SPACE(8)
			mov qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)], rcx

			mov rdx, rdi ; pOtherStats
			mov rcx, rbx ; pStats
			call #L(EEex::Stats_Hook_OnPlusEqu)

			mov rcx, qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)]
			#DESTROY_SHADOW_SPACE
		]]}
	)

	----------------------------------------------------
	-- [EEex.dll] EEex::Stats_Hook_OnGettingUnknown() --
	----------------------------------------------------

	EEex_HookConditionalJumpOnSuccessWithLabels(EEex_Label("Hook-CDerivedStats::GetAtOffset()-OutOfBoundsJmp"), 0, {
		{"stack_mod", 8},
		{"integrity_ignore_registers", {
			EEex_IntegrityRegister.RAX, EEex_IntegrityRegister.RCX, EEex_IntegrityRegister.RDX, EEex_IntegrityRegister.R8,
			EEex_IntegrityRegister.R9, EEex_IntegrityRegister.R10, EEex_IntegrityRegister.R11
		}}},
		EEex_FlattenTable({
			{[[
				#MAKE_SHADOW_SPACE

				lea rdx, qword ptr ds:[rax+1] ; nStatId
											  ; rcx already pStats
				call #L(EEex::Stats_Hook_OnGettingUnknown)

				#DESTROY_SHADOW_SPACE
			]]},
			EEex_IntegrityCheck_HookExit(0),
			{[[
				ret
			]]},
		})
	)

	EEex_EnableCodeProtection()

end)()
