
----------------------------------------------------------------------------------------------------------
-- Fix quick spell slots not updating when a special ability is added (for example, by op171 or act279) --
----------------------------------------------------------------------------------------------------------

function EEex_Fix_Hook_OnAddSpecialAbility(sprite, spell)
	EEex_RunWithStackManager({
		{ ["name"] = "abilityId", ["struct"] = "CAbilityId" } },
		function(manager)
			local abilityId = manager:getUD("abilityId")
			abilityId.m_itemType = 1 -- spell, not an item
			abilityId.m_res:copy(spell.cResRef)
			-- CAbilityId* ab, short changeAmount, int remove, int removeSpellIfZero
			sprite:CheckQuickLists(abilityId, 1, 0, 0);
		end)
end

--------------------------------------------------------------------------------------------------------------------------
-- Fix Spell() and SpellPoint() not being disruptable if the creature is facing SSW(1), SWW(3), NWW(5), NNW(7), NNE(9), --
-- NEE(11), SEE(13), or SSE(15)                                                                                         --
--------------------------------------------------------------------------------------------------------------------------

function EEex_Fix_Hook_ShouldForceMainSpellActionCode(sprite, point)

	local forcing = EEex_GetUDAux(sprite)["EEex_Fix_HasSpellOrSpellPointStartedCasting"] == 1

	-- If I force the main spell action code, the direction-setting code
	-- isn't run. Manually do that here so sprites still turn to face
	-- their target after they have started the casting glow.
	if forcing then
		local message = EEex_NewUD("CMessageSetDirection")
		message:Construct(point, sprite.m_id, sprite.m_id)
		EngineGlobals.g_pBaldurChitin.m_cMessageHandler:AddMessage(message, 0)
	end

	return forcing
end

function EEex_Fix_Hook_OnSpellOrSpellPointStartedCastingGlow(sprite)
	EEex_GetUDAux(sprite)["EEex_Fix_HasSpellOrSpellPointStartedCasting"] = 1
end

--------------------------------------------
-- Fix Baldur.lua values not escaping '\' --
--------------------------------------------

EEex_GameState_AddInitializedListener(function()
	local oldNeedsEscape = needsEscape
	needsEscape = function(str)
		return str:find("\\") or oldNeedsEscape(str)
	end
end)

-------------------------------------------------------------
-- Fix combined scrolling key behavior when releasing keys --
-------------------------------------------------------------

EEex_Fix_Private_ScrollDirection = {
	["UP"]           = 0,
	["TOP_RIGHT"]    = 1,
	["RIGHT"]        = 2,
	["BOTTOM_RIGHT"] = 3,
	["DOWN"]         = 4,
	["BOTTOM_LEFT"]  = 5,
	["LEFT"]         = 6,
	["TOP_LEFT"]     = 7,
}

EEex_Fix_Private_HardcodedScrollKeys = {
	[0x4000004F] = EEex_Fix_Private_ScrollDirection.RIGHT,        -- SDLK_RIGHT
	[0x40000050] = EEex_Fix_Private_ScrollDirection.LEFT,         -- SDLK_LEFT
	[0x40000051] = EEex_Fix_Private_ScrollDirection.DOWN,         -- SDLK_DOWN
	[0x40000052] = EEex_Fix_Private_ScrollDirection.UP,           -- SDLK_UP
	[0x40000059] = EEex_Fix_Private_ScrollDirection.BOTTOM_LEFT,  -- SDLK_KP_1
	[0x4000005A] = EEex_Fix_Private_ScrollDirection.DOWN,         -- SDLK_KP_2
	[0x4000005B] = EEex_Fix_Private_ScrollDirection.BOTTOM_RIGHT, -- SDLK_KP_3
	[0x4000005C] = EEex_Fix_Private_ScrollDirection.LEFT,         -- SDLK_KP_4
	[0x4000005E] = EEex_Fix_Private_ScrollDirection.RIGHT,        -- SDLK_KP_6
	[0x4000005F] = EEex_Fix_Private_ScrollDirection.TOP_LEFT,     -- SDLK_KP_7
	[0x40000060] = EEex_Fix_Private_ScrollDirection.UP,           -- SDLK_KP_8
	[0x40000061] = EEex_Fix_Private_ScrollDirection.TOP_RIGHT,    -- SDLK_KP_9
}

function EEex_Fix_Private_GetKeyScrollDirection(mappedKeys, key)

	local hardcodedDirection = EEex_Fix_Private_HardcodedScrollKeys[key]
	if hardcodedDirection then
		return hardcodedDirection
	end

	if not mappedKeys then
		return
	end

	if key == mappedKeys[1] then return EEex_Fix_Private_ScrollDirection.UP    end
	if key == mappedKeys[2] then return EEex_Fix_Private_ScrollDirection.RIGHT end
	if key == mappedKeys[3] then return EEex_Fix_Private_ScrollDirection.DOWN  end
	if key == mappedKeys[4] then return EEex_Fix_Private_ScrollDirection.LEFT  end
end

EEex_Fix_Private_ResolveScrollStateSwitch = {
	[EEex_Fix_Private_ScrollDirection.UP] = function(state)
		if state == 3 or state == 4 then     -- RIGHT / BOTTOM-RIGHT
			return 2                         -- => TOP-RIGHT
		elseif state == 6 or state == 7 then -- BOTTOM-LEFT / LEFT
			return 8                         -- => TOP-LEFT
		else
			return 1                         -- => UP
		end
	end,
	[EEex_Fix_Private_ScrollDirection.TOP_RIGHT] = function(state)
		return 2                             -- => TOP-RIGHT
	end,
	[EEex_Fix_Private_ScrollDirection.RIGHT] = function(state)
		if state == 1 or state == 8 then     -- UP / TOP-LEFT
			return 2                         -- => TOP-RIGHT
		elseif state == 5 or state == 6 then -- DOWN / BOTTOM-LEFT
			return 4                         -- => BOTTOM-RIGHT
		else
			return 3                         -- => RIGHT
		end
	end,
	[EEex_Fix_Private_ScrollDirection.BOTTOM_RIGHT] = function(state)
		return 4                             -- => BOTTOM-RIGHT
	end,
	[EEex_Fix_Private_ScrollDirection.DOWN] = function(state)
		if state == 2 or state == 3 then     -- TOP-RIGHT / RIGHT
			return 4                         -- => BOTTOM-RIGHT
		elseif state == 7 or state == 8 then -- LEFT / TOP-LEFT
			return 6                         -- => BOTTOM-LEFT
		else
			return 5                         -- => DOWN
		end
	end,
	[EEex_Fix_Private_ScrollDirection.BOTTOM_LEFT] = function(state)
		return 6                             -- => BOTTOM-LEFT
	end,
	[EEex_Fix_Private_ScrollDirection.LEFT] = function(state)
		if state == 1 or state == 2 then     -- UP / TOP-RIGHT
			return 8                         -- => TOP-LEFT
		elseif state == 4 or state == 5 then -- BOTTOM-RIGHT / DOWN
			return 6                         -- => BOTTOM-LEFT
		else
			return 7                         -- => LEFT
		end
	end,
	[EEex_Fix_Private_ScrollDirection.TOP_LEFT] = function(state)
		return 8                             -- => TOP-LEFT
	end,
}

function EEex_Fix_Private_ResolveScrollState(mappedKeys)
	local state = 0
	for _, key in ipairs(EEex_Key_GetPressedStack()) do
		local scrollDirection = EEex_Fix_Private_GetKeyScrollDirection(mappedKeys, key)
		if scrollDirection then
			state = EEex_Fix_Private_ResolveScrollStateSwitch[scrollDirection](state)
		end
	end
	return state
end

function EEex_Fix_Private_HandleScrollKeyEvent(key)

	if worldScreen ~= e:GetActiveEngine() then
		-- Not in world screen
		return
	end

	local chitin = EngineGlobals.g_pBaldurChitin
	local game = chitin.m_pObjectGame
	local inputMode = game.m_gameSave.m_inputMode

	if EEex_BAnd(inputMode - 0x1016E, 0xFFFDFFFF) == 0 or EEex_BAnd(inputMode, 0x801) == 0 then
		-- In cutscene or dialog
		return
	end

	local mappedKeys = nil

	if chitin.m_pEngineWorld.m_bCtrlKeyDown == 0 then
		local keymap = game.m_pKeymap
		mappedKeys = {
			[1] = keymap:get(33), -- Up
			[2] = keymap:get(34), -- Right
			[3] = keymap:get(35), -- Down
			[4] = keymap:get(36), -- Left
		}
	elseif game.m_options.m_bDebugMode ~= 0 then
		-- Handling cheat keys
		return
	end

	if EEex_Fix_Private_GetKeyScrollDirection(mappedKeys, key) then
		EEex_Area_GetVisible().m_nKeyScrollState = EEex_Fix_Private_ResolveScrollState(mappedKeys)
		return true -- consume event
	end
end

EEex_Key_AddPressedListener(EEex_Fix_Private_HandleScrollKeyEvent)
EEex_Key_AddReleasedListener(EEex_Fix_Private_HandleScrollKeyEvent)
