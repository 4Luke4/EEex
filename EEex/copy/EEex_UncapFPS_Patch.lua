
(function()

	EEex_DisableCodeProtection()

	--[[
	+--------------------------------------------------------------------------------------------+
	| Override main game loop to run "light" (render only) ticks in-between the usual game ticks |
	+--------------------------------------------------------------------------------------------+
	|   [EEex.dll] CChitin::Override_Update()                                                    |
	+--------------------------------------------------------------------------------------------+
	--]]

	EEex_JITAt(EEex_Label("Hook-CChitin::Update()-FirstInstruction"), {"jmp #L(CChitin::Override_Update)"})

	--[[
	+----------------------------------------------------------------------------------------------+
	| Override middle-mouse area scrolling to remove the weird multiplier applied to area movement |
	+----------------------------------------------------------------------------------------------+
	|   [EEex.dll] EEex::Fix_Hook_HandleMiddleMouseDrag(pEvent: SDL_Event*)                        |
	+----------------------------------------------------------------------------------------------+
	--]]

	EEex_HookConditionalJumpOnFailWithLabels(EEex_Label("Hook-CScreenWorld::OnEvent()-OnHandleMiddleMouseDragJmp"), 0, {
		{"hook_integrity_watchdog_ignore_registers", {
			EEex_HookIntegrityWatchdogRegister.RAX, EEex_HookIntegrityWatchdogRegister.RCX, EEex_HookIntegrityWatchdogRegister.RDX,
			EEex_HookIntegrityWatchdogRegister.R8, EEex_HookIntegrityWatchdogRegister.R9, EEex_HookIntegrityWatchdogRegister.R10,
			EEex_HookIntegrityWatchdogRegister.R11
		}}},
		{[[
			mov rcx, rdi ; pEvent
			call #L(EEex::Fix_Hook_HandleMiddleMouseDrag)
			jmp #L(jmp_success)
		]]}
	)

	--[[
	+---------------------------------------------------------------------------------------------------+
	| Override area edge/keyboard scrolling to use exact (finer-grained) movement, improving smoothness |
	+---------------------------------------------------------------------------------------------------+
	|   [EEex.dll] CInfinity::Override_AdjustViewPosition(nScrollState: byte)                           |
	+---------------------------------------------------------------------------------------------------+
	--]]

	EEex_JITAt(EEex_Label("Hook-CInfinity::AdjustViewPosition()-FirstInstruction"), {"jmp #L(CInfinity::Override_AdjustViewPosition)"})

	--[[
	+------------------------------------------------------------------------------------------+
	| Override area auto-scrolling to use exact (finer-grained) movement, improving smoothness |
	+------------------------------------------------------------------------------------------+
	|   [EEex.dll] CInfinity::Override_Scroll(ptDest: CPoint, speed: short)                    |
	|   [EEex.dll] CInfinity::Override_SetScrollDest(ptDest: CPoint*)                          |
	|   [EEex.dll] CScreenWorld::Override_StartScroll(dest: CPoint, speed: short)              |
	+------------------------------------------------------------------------------------------+
	--]]

	EEex_JITAt(EEex_Label("Hook-CInfinity::Scroll()-FirstInstruction"), {"jmp #L(CInfinity::Override_Scroll)"})
	EEex_JITAt(EEex_Label("Hook-CInfinity::SetScrollDest()-FirstInstruction"), {"jmp #L(CInfinity::Override_SetScrollDest)"})
	EEex_JITAt(EEex_Label("Hook-CScreenWorld::StartScroll()-FirstInstruction"), {"jmp #L(CScreenWorld::Override_StartScroll)"})

	--[[
	+------------------------------------------------------------------------------------------+
	| Override local map auto-zoom to use exact (finer-grained) movement, improving smoothness |
	+------------------------------------------------------------------------------------------+
	|   [EEex.dll] CScreenWorld::Override_ResetZoom()                                          |
	|   [EEex.dll] CScreenWorld::Override_ZoomToMap(bOverwriteOriginal: bool)                  |
	|   [EEex.dll] EEex::UncapFPS_Hook_HandleAreaAutoZoom()                                    |
	+------------------------------------------------------------------------------------------+
	--]]

	-- Disable the vanilla local map auto-zoom logic
	EEex_ForceJump(EEex_Label("Hook-CScreenWorld::AsynchronousUpdate()-AutoZoomJmp"))

	EEex_JITAt(EEex_Label("Hook-CScreenWorld::ResetZoom()-FirstInstruction"), {"jmp #L(CScreenWorld::Override_ResetZoom)"})
	EEex_JITAt(EEex_Label("Hook-CScreenWorld::ZoomToMap()-FirstInstruction"), {"jmp #L(CScreenWorld::Override_ZoomToMap)"})

	EEex_HookBeforeRestoreWithLabels(EEex_Label("Hook-CGameArea::RenderZoomed()-FirstInstruction"), 0, 5, 5, {
		{"stack_mod", 8},
		{"hook_integrity_watchdog_ignore_registers", {
			EEex_HookIntegrityWatchdogRegister.RAX, EEex_HookIntegrityWatchdogRegister.RDX, EEex_HookIntegrityWatchdogRegister.R8,
			EEex_HookIntegrityWatchdogRegister.R9, EEex_HookIntegrityWatchdogRegister.R10, EEex_HookIntegrityWatchdogRegister.R11
		}}},
		{[[
			#MAKE_SHADOW_SPACE(8)
			mov qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)], rcx

			call #L(EEex::UncapFPS_Hook_HandleAreaAutoZoom)

			mov rcx, qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)]
			#DESTROY_SHADOW_SPACE
		]]}
	)

	--[[
	+----------------------------------------------------------------------------------------------------------------------------+
	| Prevent the cursor from changing into a screen-edge scrolling animation if the viewport cannot move in that direction      |
	+----------------------------------------------------------------------------------------------------------------------------+
	| This is usually reverted on a subsequent tick, but due to the uncapped render tps, the invalid cursor shape can be briefly |
	| displayed without this preventative fix.                                                                                   |
	+----------------------------------------------------------------------------------------------------------------------------+
	|   [EEex.dll] EEex::UncapFPS_Hook_OnAfterAreaEdgeScrollPossiblyStarted(pArea: CGameArea*)                                   |
	+----------------------------------------------------------------------------------------------------------------------------+
	--]]

	EEex_HookBeforeCallWithLabels(EEex_Label("Hook-CGameArea::OnMouseMove()-OnAfterAreaEdgeScrollPossiblyStarted"), {
		{"hook_integrity_watchdog_ignore_registers", {
			EEex_HookIntegrityWatchdogRegister.RDX, EEex_HookIntegrityWatchdogRegister.R8, EEex_HookIntegrityWatchdogRegister.R9,
			EEex_HookIntegrityWatchdogRegister.R10, EEex_HookIntegrityWatchdogRegister.R11
		}}},
		{[[
			#MAKE_SHADOW_SPACE(8)
			mov qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)], rcx

			mov rcx, rbx ; pArea
			call #L(EEex::UncapFPS_Hook_OnAfterAreaEdgeScrollPossiblyStarted)

			mov rcx, qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)]
			#DESTROY_SHADOW_SPACE
		]]}
	)

	--[[
	+-------------------------------------------------------------------------------------------------------------------------+
	| Override how the engine forces the viewport to stay within bounds to fix a ton of vanilla bugs                          |
	+-------------------------------------------------------------------------------------------------------------------------+
	| * Don't force bounds when the map screen is auto-zooming                                                                |
	| * Use the proper zoom value to calculate bounds when on the map screen                                                  |
	| * On forcing the viewport into bounds, only reset the cursor shape if it was edge-scrolling                             |
	| * Consider the state of various GUI elements *from before the map screen was opened* when enforcing new viewport bounds |
	| * Only force viewport bounds "in theory" for several operations that shouldn't actually move the viewport               |
	| * Enforce the exact viewport coordinates in addition to the normal viewport coordinates                                 |
	| * ... and many more                                                                                                     |
	+-------------------------------------------------------------------------------------------------------------------------+
	|   [EEex.dll] CInfinity::Override_FitViewPosition(pX: int*, pY: int*, pViewPort: CRect*)                                 |
	|   [EEex.dll] CScreenMap::Override_CenterViewPort(ptPoint: CPoint*)                                                      |
	|   [EEex.dll] EEex::UncapFPS_Hook_OnBeforeWorldScreenDeactivated()                                                       |
	+-------------------------------------------------------------------------------------------------------------------------+
	--]]

	EEex_JITAt(EEex_Label("Hook-CInfinity::FitViewPosition()-FirstInstruction"), {"jmp #L(CInfinity::Override_FitViewPosition)"})
	EEex_JITAt(EEex_Label("Hook-CScreenMap::CenterViewPort()-FirstInstruction"), {"jmp #L(CScreenMap::Override_CenterViewPort)"})

	EEex_HookBeforeCallWithLabels(EEex_Label("Hook-CScreenWorld::EngineDeactivated()-FirstCall"), {
		{"hook_integrity_watchdog_ignore_registers", {
			EEex_HookIntegrityWatchdogRegister.RCX, EEex_HookIntegrityWatchdogRegister.RDX, EEex_HookIntegrityWatchdogRegister.R8,
			EEex_HookIntegrityWatchdogRegister.R9, EEex_HookIntegrityWatchdogRegister.R10, EEex_HookIntegrityWatchdogRegister.R11
		}}},
		{[[
			call #L(EEex::UncapFPS_Hook_OnBeforeWorldScreenDeactivated)
		]]}
	)

	--[[
	+-------------------------------------------------------------------------------------------------+
	| Adjust Infinity_TransitionMenu()'s fade to last the correct amount of time with an uncapped FPS |
	+-------------------------------------------------------------------------------------------------+
	|   [EEex.dll] EEex::Override_Infinity_TransitionMenu(L: lua_State*) -> int                       |
	|   [EEex.dll] EEex::UncapFPS_Hook_HandleTransitionMenuFade()                                     |
	+-------------------------------------------------------------------------------------------------+
	--]]

	EEex_JITAt(EEex_Label("Hook-Infinity_TransitionMenu()-FirstInstruction"), {"jmp #L(EEex::Override_Infinity_TransitionMenu)"})

	EEex_HookConditionalJumpOnFailWithLabels(EEex_Label("Hook-drawTop()-HandleTransitionMenuFadeJmp"), 0, {
		{"hook_integrity_watchdog_ignore_registers", {
			EEex_HookIntegrityWatchdogRegister.RAX, EEex_HookIntegrityWatchdogRegister.RCX, EEex_HookIntegrityWatchdogRegister.RDX,
			EEex_HookIntegrityWatchdogRegister.R8, EEex_HookIntegrityWatchdogRegister.R9, EEex_HookIntegrityWatchdogRegister.R10,
			EEex_HookIntegrityWatchdogRegister.R11
		}}},
		{[[
			call #L(EEex::UncapFPS_Hook_HandleTransitionMenuFade)
			jmp #L(jmp_success)
		]]}
	)

	--[[
	+-------------------------------------------------------------------------------------------+
	| Switching areas while the local map is open shouldn't cause the viewport / zoom to glitch |
	+-------------------------------------------------------------------------------------------+
	|   [EEex.dll] EEex::UncapFPS_Hook_OnAfterAreaActivated(pArea: CGameArea*)                  |
	|   [EEex.dll] EEex::UncapFPS_Hook_OnBeforeAreaDeactivated(pArea: CGameArea*)               |
	+-------------------------------------------------------------------------------------------+
	--]]

	EEex_HookRelativeJumpWithLabels(EEex_Label("Hook-CGameArea::OnActivation()-LastCall"), {
		{"stack_mod", 8},
		{"hook_integrity_watchdog_ignore_registers", {
			EEex_HookIntegrityWatchdogRegister.RAX, EEex_HookIntegrityWatchdogRegister.RCX, EEex_HookIntegrityWatchdogRegister.RDX,
			EEex_HookIntegrityWatchdogRegister.R8, EEex_HookIntegrityWatchdogRegister.R9, EEex_HookIntegrityWatchdogRegister.R10,
			EEex_HookIntegrityWatchdogRegister.R11
		}},
		{"manual_continue", true}},
		{[[
			#MAKE_SHADOW_SPACE(8)
			mov qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)], rdx

			call #L(original)

			mov rcx, qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)] ; pArea
			call #L(EEex::UncapFPS_Hook_OnAfterAreaActivated)

			#DESTROY_SHADOW_SPACE
			#MANUAL_HOOK_EXIT(0)
			ret
		]]}
	)

	EEex_HookBeforeRestoreWithLabels(EEex_Label("Hook-CGameArea::OnDeactivation()-FirstInstruction"), 0, 6, 6, {
		{"stack_mod", 8},
		{"hook_integrity_watchdog_ignore_registers", {
			EEex_HookIntegrityWatchdogRegister.RAX, EEex_HookIntegrityWatchdogRegister.RDX, EEex_HookIntegrityWatchdogRegister.R8,
			EEex_HookIntegrityWatchdogRegister.R9, EEex_HookIntegrityWatchdogRegister.R10, EEex_HookIntegrityWatchdogRegister.R11
		}}},
		{[[
			#MAKE_SHADOW_SPACE(8)
			mov qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)], rcx

																 ; rcx already pArea
			call #L(EEex::UncapFPS_Hook_OnBeforeAreaDeactivated)

			mov rcx, qword ptr ss:[rsp+#SHADOW_SPACE_BOTTOM(-8)]
			#DESTROY_SHADOW_SPACE
		]]}
	)

	--[[
	+---------------------------------------------------------------------------------------+
	| Fix dialog autoscroll resulting in the viewport being incorrectly fit near area edges |
	+---------------------------------------------------------------------------------------+
	|   [EEex.dll] CScreenWorld::Override_EndDialog(bForceExecution: byte, fullEnd: byte)   |
	+---------------------------------------------------------------------------------------+
	--]]

	EEex_JITAt(EEex_Label("Hook-CScreenWorld::EndDialog()-FirstInstruction"), {"jmp #L(CScreenWorld::Override_EndDialog)"})

	EEex_EnableCodeProtection()

end)()
