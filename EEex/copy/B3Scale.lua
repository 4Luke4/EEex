
B3Scale_Percentage = nil

EEex_GameState_AddInitializedListener(function()
	B3Scale_Percentage = tonumber(Infinity_GetINIString("B3Scale", "Percentage", -1))
end)

-- p = [0-1], where 0 is minimum scaling and 1 is maximum scaling
function B3Scale_SetPercentage(p)
	B3Scale_Percentage = math.min(math.max(0, p), 1)
	Infinity_SetINIValue("B3Scale", "Percentage", B3Scale_Percentage)
	B3Scale_PokeEngine()
end

function B3Scale_GetVideoSize()
	local pVidMode = EEex_EngineGlobal_CBaldurChitin.cVideo.pCurrentMode
	return pVidMode.nWidth, pVidMode.nHeight
end

function B3Scale_PokeEngine()
	local w, h = B3Scale_GetVideoSize()
	EEex_EngineGlobal_CBaldurChitin:OnResizeWindow(w, h)
end

function B3Scale_Hook_DoSizeChange()

	if B3Scale_Percentage == -1 then
		return
	end

	local w, h = B3Scale_GetVideoSize()
	local ratio = math.max(1.25, math.min(w / h, 2.6))

	if ratio <= 4/3 then
		-- UI wasn't designed for this ratio, no scaling.
		return
	end

	local scaledH = w >= 1024 and h >= 768
		and 768 + (1 - B3Scale_Percentage) * (h - 768)
		or 768

	CVidMode.SCREENWIDTH = math.floor(scaledH * ratio)
	CVidMode.SCREENHEIGHT = math.floor(scaledH)
end

(function()

	EEex_DisableCodeProtection()

	--[[
	+---------------------------------------------------+
	| Tweak the UI scale whenever the window is resized |
	+---------------------------------------------------+
	|   [Lua] B3Scale_Hook_DoSizeChange()               |
	+---------------------------------------------------+
	--]]

	EEex_HookAfterCallWithLabels(EEex_Label("Hook-CChitin::OnResizeWindow()-B3Scale"), {
		{"hook_integrity_watchdog_ignore_registers", {EEex_HookIntegrityWatchdogRegister.RAX}}},
		EEex_FlattenTable({[[
			#MAKE_SHADOW_SPACE(32)
			]], EEex_GenLuaCall("B3Scale_Hook_DoSizeChange"), [[
			call_error:
			#DESTROY_SHADOW_SPACE
		]]})
	)

	EEex_EnableCodeProtection()

end)()
