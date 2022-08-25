
EEex_DerivedStats_DisabledButtonType = {
	["BUTTON_STEALTH"] = 0,
	["BUTTON_THIEVING"] = 1,
	["BUTTON_CASTSPELL"] = 2,
	["BUTTON_QUICKSPELL0"] = 3,
	["BUTTON_QUICKSPELL1"] = 4,
	["BUTTON_QUICKSPELL2"] = 5,
	["BUTTON_TURNUNDEAD"] = 6,
	["BUTTON_DIALOG"] = 7,
	["BUTTON_USEITEM"] = 8,
	["BUTTON_QUICKITEM1"] = 9,
	["BUTTON_BATTLESONG"] = 10,
	["BUTTON_QUICKITEM2"] = 11,
	["BUTTON_QUICKITEM3"] = 12,
	["BUTTON_INNATEBUTTON"] = 13,
	["SCREEN_INVENTORY"] = 14,
}

function EEex_Sprite_GetInPortrait(portraitIndex)
	return EEex_GameObject_Get(EEex_EngineGlobal_CBaldurChitin.m_pObjectGame.m_charactersPortrait:get(portraitIndex))
end

function EEex_Sprite_GetInPortraitID(portraitIndex)
	return EEex_EngineGlobal_CBaldurChitin.m_pObjectGame.m_charactersPortrait:get(portraitIndex)
end

function EEex_Sprite_GetPortraitIndex(sprite)
	local spriteID = sprite.m_id
	local portraitsArray = EngineGlobals.g_pBaldurChitin.m_pObjectGame.m_charactersPortrait
	for i = 0, 5 do
		if portraitsArray:get(i) == spriteID then
			return i
		end
	end
	return -1
end
CGameSprite.getPortraitIndex = EEex_Sprite_GetPortraitIndex

function EEex_Sprite_GetActiveStats(sprite)
	return sprite.m_bAllowEffectListCall and sprite.m_derivedStats or sprite.m_tempStats
end
CGameSprite.getActiveStats = EEex_Sprite_GetActiveStats

function EEex_Sprite_GetExtendedStat(sprite, id)
	return EEex_GetUDAux(sprite:getActiveStats())["EEex_ExtendedStats"][id]
end
CGameSprite.getExtendedStat = EEex_Sprite_GetExtendedStat

function EEex_Sprite_GetName(sprite)
	return sprite.m_sName.m_pchData:get()
end
CGameSprite.getName = EEex_Sprite_GetName

function EEex_Sprite_GetState(sprite)
	return sprite:getActiveStats().m_generalState
end
CGameSprite.getState = EEex_Sprite_GetState

function EEex_Sprite_GetSpellState(sprite, spellStateID)
	return sprite:getActiveStats():GetSpellState(spellStateID) ~= 0
end
CGameSprite.getSpellState = EEex_Sprite_GetSpellState

function EEex_Sprite_GetLocalInt(sprite, variableName)
	return sprite.m_pLocalVariables:getInt(variableName)
end
CGameSprite.getLocalInt = EEex_Sprite_GetLocalInt

function EEex_Sprite_GetLocalString(sprite, variableName)
	return sprite.m_pLocalVariables:getString(variableName)
end
CGameSprite.getLocalString = EEex_Sprite_GetLocalString

function EEex_Sprite_SetLocalInt(sprite, variableName, value)
	sprite.m_pLocalVariables:setInt(variableName, value)
end
CGameSprite.setLocalInt = EEex_Sprite_SetLocalInt

function EEex_Sprite_SetLocalString(sprite, variableName, value)
	sprite.m_pLocalVariables:setString(variableName, value)
end
CGameSprite.setLocalString = EEex_Sprite_SetLocalString

-- Returns the sprite's current modal state, (as defined in MODAL.IDS; stored at offset 0x28 of the global-creature structure).
function EEex_Sprite_GetModalState(sprite)
	if not sprite then return 0 end
	return sprite.m_nModalState
end
CGameSprite.getModalState = EEex_Sprite_GetModalState

-- [0-99], 0 = modal check pending
-- yes, this timer is faster than the others by 1 tick
function EEex_Sprite_GetModalTimer(sprite)
	if not sprite then return 0 end
	local idRemainder = sprite.m_id % 100
	local timerRemainder = sprite.m_PAICallCounterNoMod % 100
	if idRemainder >= timerRemainder then
		return idRemainder - timerRemainder
	else
		return 100 - timerRemainder + idRemainder
	end
end
CGameSprite.getModalTimer = EEex_Sprite_GetModalTimer

-- [0-100], 0 = contingency check pending
function EEex_Sprite_GetContingencyTimer(sprite)
	if not sprite then return 0 end
	return sprite.m_nLastContingencyCheck
end
CGameSprite.getContingencyTimer = EEex_Sprite_GetContingencyTimer

-- [-1-99], -1 = aura free
function EEex_Sprite_GetCastTimer(sprite)
	if not sprite then return 0 end
	return sprite.m_castCounter
end
CGameSprite.getCastTimer = EEex_Sprite_GetCastTimer

-- [0-1]
function EEex_Sprite_GetModalTimerPercentage(sprite)
	if not sprite then return 0 end
	return (99 - sprite:getModalTimer()) / 99
end
CGameSprite.getModalTimerPercentage = EEex_Sprite_GetModalTimerPercentage

-- [0-1]
function EEex_Sprite_GetContingencyTimerPercentage(sprite)
	if not sprite then return 0 end
	return (100 - sprite:getContingencyTimer()) / 100
end
CGameSprite.getContingencyTimerPercentage = EEex_Sprite_GetContingencyTimerPercentage

-- [0-1]
function EEex_Sprite_GetCastTimerPercentage(sprite)
	if not sprite then return 0 end
	return (sprite:getCastTimer() + 1) / 100
end
CGameSprite.getCastTimerPercentage = EEex_Sprite_GetCastTimerPercentage

function EEex_Sprite_GetCasterLevelForSpell(sprite, spellResRef, includeWildMage)
	return EEex_RunWithStackManager({
		{ ["name"] = "resref", ["struct"] = "CResRef", ["constructor"] = { ["args"] = { spellResRef } } },
		{ ["name"] = "spell",  ["struct"] = "CSpell",  ["constructor"] = { ["args"] = function(manager) return manager:getUD("resref") end } } },
		function(manager)
			return sprite:GetCasterLevel(manager:getUD("spell"), includeWildMage and 1 or 0)
		end)
end
CGameSprite.getCasterLevelForSpell = EEex_Sprite_GetCasterLevelForSpell

---------------
-- Listeners --
---------------

EEex_Sprite_QuickListsCheckedListeners = {}

function EEex_Sprite_AddQuickListsCheckedListener(listener)
	table.insert(EEex_Sprite_QuickListsCheckedListeners, listener)
end

EEex_Sprite_QuickListCountsResetListeners = {}

function EEex_Sprite_AddQuickListCountsResetListener(listener)
	table.insert(EEex_Sprite_QuickListCountsResetListeners, listener)
end

EEex_Sprite_MarshalHandlers = {}

function EEex_Sprite_AddMarshalHandlers(handlerName, exporter, importer)
	EEex_Sprite_MarshalHandlers[handlerName] = {
		["exporter"] = exporter,
		["importer"] = importer,
	}
end

-----------
-- Hooks --
-----------

function EEex_Sprite_Hook_CheckSuppressTooltip()
	return false
end

function EEex_Sprite_Hook_OnCheckQuickLists(sprite, abilityId, changeAmount)
	local resref = abilityId.m_res:get()
	if changeAmount == 0 or resref == "" then return end
	for _, listener in ipairs(EEex_Sprite_QuickListsCheckedListeners) do
		listener(sprite, resref, changeAmount)
	end
end

function EEex_Sprite_Hook_OnResetQuickListCounts(sprite)
	for _, listener in ipairs(EEex_Sprite_QuickListCountsResetListeners) do
		listener(sprite)
	end
end

function EEex_Sprite_Hook_OnConstruct(sprite)

end

function EEex_Sprite_Hook_OnDestruct(sprite)

end

EEex_Sprite_MarshalHandlerFieldType = {
	["TABLE_END"]   = 0,
	["TABLE_START"] = 1,
	["STRING"]      = 2,
	["INT8"]        = 3,
	["INTU8"]       = 4,
	["INT16"]       = 5,
	["INTU16"]      = 6,
	["INT32"]       = 7,
	["INTU32"]      = 8,
	["INT64"]       = 9,
	["INTU64"]      = 10,
}

EEex_Sprite_CurrentSpriteMarshalHandlerData = {}
EEex_Sprite_CurrentSpriteMarshalHandlerData_TableSize = 0
EEex_Sprite_CurrentSpriteMarshalHandlerData_TableToMeta = {}
EEex_Sprite_CurrentSpriteMarshalHandlerData_MemorySize = 0

function EEex_Sprite_DetermineSpriteMarshalHandlerNumberInfo(number)
	if number >= 0 then
		if number <= 0xFF then
			return EEex_Sprite_MarshalHandlerFieldType.INTU8, EEex_Write8, 1
		elseif number <= 0xFFFF then
			return EEex_Sprite_MarshalHandlerFieldType.INTU16, EEex_Write16, 2
		elseif number <= 0xFFFFFFFF then
			return EEex_Sprite_MarshalHandlerFieldType.INTU32, EEex_Write32, 4
		elseif number <= 0xFFFFFFFFFFFFFFFF then
			return EEex_Sprite_MarshalHandlerFieldType.INTU64, EEex_Write64, 8
		else
			EEex_Error("Number too large to be marshalled in creature handler")
		end
	else
		if number >= -0x100 then
			return EEex_Sprite_MarshalHandlerFieldType.INT8, EEex_Write8, 1
		elseif number >= -0x10000 then
			return EEex_Sprite_MarshalHandlerFieldType.INT16, EEex_Write16, 2
		elseif number >= -0x100000000 then
			return EEex_Sprite_MarshalHandlerFieldType.INT32, EEex_Write32, 4
		elseif number >= -0x10000000000000000 then
			return EEex_Sprite_MarshalHandlerFieldType.INT64, EEex_Write64, 8
		else
			EEex_Error("Number too large to be marshalled in creature handler")
		end
	end
end

function EEex_Sprite_CalculateSpriteMarshalHandlerDataSize(t)

	local accumulator = 0
	local lengthTypeSwitch = {
		["string"] = function(v)
			return #v + 1
		end,
		["number"] = function(v)
			local _, _, writeAdvance = EEex_Sprite_DetermineSpriteMarshalHandlerNumberInfo(v)
			return writeAdvance
		end,
	}

	local processStack = {{t, nil}} -- toProcessT, iterK
	local stackTop = 1

	while true do

		::continue::
		local toProcess = processStack[stackTop]
		local toProcessT = toProcess[1]

		while true do

			local k, v = next(toProcessT, toProcess[2])
			if k == nil then
				break
			end
			local kType = type(k)
			if kType ~= "number" and kType ~= "string" then
				EEex_Error("Only numbers / strings can be used as keys in creature marshal")
			end

			toProcess[2] = k

			if stackTop == 1 then
				local handlerName = EEex_Sprite_CurrentSpriteMarshalHandlerData_TableToMeta[v].handlerName
				-- HANDLER_STRING_LENGTH
				accumulator = accumulator + #handlerName + 1
				stackTop = stackTop + 1
				processStack[stackTop] = {v, nil}
				goto continue
			else
				local vType = type(v)
				if vType ~= "number" and vType ~= "string" and vType ~= "table" then
					EEex_Error("Only numbers / strings / tables can be used as values in creature marshal")
				end
				if vType == "table" then
					-- KEY_FIELD_TYPE + KEY_LENGTH + TABLE_START
					accumulator = accumulator + 1 + lengthTypeSwitch[kType](k) + 1
					stackTop = stackTop + 1
					processStack[stackTop] = {v, nil}
					goto continue
				end
				-- KEY_FIELD_TYPE + KEY_LENGTH + VALUE_FIELD_TYPE + VALUE_LENGTH
				accumulator = accumulator + 1 + lengthTypeSwitch[kType](k) + 1 + lengthTypeSwitch[vType](v)
			end
		end

		accumulator = accumulator + 1 -- TABLE_END

		processStack[stackTop] = nil
		stackTop = stackTop - 1

		if stackTop == 0 then
			break
		end
	end

	return accumulator
end

function EEex_Sprite_WriteSpriteMarshalHandlerData(memoryPtr, t)

	local writeNumber = function(number)
		local typeByte, writeFunc, writeAdvance = EEex_Sprite_DetermineSpriteMarshalHandlerNumberInfo(number)
		EEex_Write8(memoryPtr, typeByte)
		memoryPtr = memoryPtr + 1
		writeFunc(memoryPtr, number)
		memoryPtr = memoryPtr + writeAdvance
	end

	local writeTypeSwitch = {
		["string"] = function(v)
			EEex_Write8(memoryPtr, EEex_Sprite_MarshalHandlerFieldType.STRING)
			memoryPtr = memoryPtr + 1
			EEex_WriteString(memoryPtr, v)
			memoryPtr = memoryPtr + #v + 1
		end,
		["number"] = writeNumber,
		["table"] = function(v)
			EEex_Write8(memoryPtr, EEex_Sprite_MarshalHandlerFieldType.TABLE_START)
			memoryPtr = memoryPtr + 1
		end
	}

	local processStack = {{t, nil}} -- toProcessT, iterK
	local stackTop = 1

	while true do

		::continue::
		local toProcess = processStack[stackTop]
		local toProcessT = toProcess[1]

		while true do

			local k, v = next(toProcessT, toProcess[2])
			if k == nil then
				break
			end

			toProcess[2] = k

			if stackTop == 1 then
				local handlerName = EEex_Sprite_CurrentSpriteMarshalHandlerData_TableToMeta[v].handlerName
				EEex_WriteString(memoryPtr, handlerName)
				memoryPtr = memoryPtr + #handlerName + 1
			else
				writeTypeSwitch[type(k)](k)
				writeTypeSwitch[type(v)](v)
			end

			if type(v) == "table" then
				stackTop = stackTop + 1
				processStack[stackTop] = {v, nil}
				goto continue
			end
		end

		EEex_Write8(memoryPtr, EEex_Sprite_MarshalHandlerFieldType.TABLE_END)
		memoryPtr = memoryPtr + 1

		processStack[stackTop] = nil
		stackTop = stackTop - 1

		if stackTop == 0 then
			break
		end
	end
end

function EEex_Sprite_Hook_CalculateExtraEffectListMarshalSize(sprite)

	for handlerName, handler in pairs(EEex_Sprite_MarshalHandlers) do
		local exported = handler.exporter(sprite)
		if type(exported) ~= "table" then
			EEex_Error("Creature marshal handler must export table")
		end
		EEex_Sprite_CurrentSpriteMarshalHandlerData_TableSize = EEex_Sprite_CurrentSpriteMarshalHandlerData_TableSize + 1
		EEex_Sprite_CurrentSpriteMarshalHandlerData[EEex_Sprite_CurrentSpriteMarshalHandlerData_TableSize] = exported
		EEex_Sprite_CurrentSpriteMarshalHandlerData_TableToMeta[exported] = {
			["handlerName"] = handlerName,
		}
	end

	local extraMarshalSize = 8 + EEex_Sprite_CalculateSpriteMarshalHandlerDataSize(EEex_Sprite_CurrentSpriteMarshalHandlerData)
	EEex_Sprite_CurrentSpriteMarshalHandlerData_MemorySize = (extraMarshalSize ~= 8 and
		EEex_RoundUp(extraMarshalSize, CGameEffectBase.sizeof)
		or 0) - 8
	return EEex_Sprite_CurrentSpriteMarshalHandlerData_MemorySize + 8
end

function EEex_Sprite_Hook_WriteExtraEffectListMarshal(memory)
	if EEex_Sprite_CurrentSpriteMarshalHandlerData_MemorySize > 0 then
		EEex_WriteLString(memory, "X-BIV1.0", 8)
		local marshalPtr = memory + 8
		EEex_Memset(marshalPtr, 0, EEex_Sprite_CurrentSpriteMarshalHandlerData_MemorySize)
		EEex_Sprite_WriteSpriteMarshalHandlerData(marshalPtr, EEex_Sprite_CurrentSpriteMarshalHandlerData)
	end
	EEex_Sprite_CurrentSpriteMarshalHandlerData = {}
	EEex_Sprite_CurrentSpriteMarshalHandlerData_TableSize = 0
	EEex_Sprite_CurrentSpriteMarshalHandlerData_TableToMeta = {}
	EEex_Sprite_CurrentSpriteMarshalHandlerData_MemorySize = 0
end

function EEex_Sprite_Hook_ReadExtraEffectListUnmarshal(sprite, memory)

	memory = memory + 8
	local toFill = {}

	local handlerStr = EEex_ReadString(memory)
	memory = memory + #handlerStr + 1

	local fieldReadSwitch = {
		[EEex_Sprite_MarshalHandlerFieldType.STRING] = function()
			local read = EEex_ReadString(memory)
			memory = memory + #read + 1
			return read
		end,
		[EEex_Sprite_MarshalHandlerFieldType.INT8] = function()
			local read = EEex_Read8(memory)
			memory = memory + 1
			return read
		end,
		[EEex_Sprite_MarshalHandlerFieldType.INTU8] = function()
			local read = EEex_ReadU8(memory)
			memory = memory + 1
			return read
		end,
		[EEex_Sprite_MarshalHandlerFieldType.INT16] = function()
			local read = EEex_Read16(memory)
			memory = memory + 2
			return read
		end,
		[EEex_Sprite_MarshalHandlerFieldType.INTU16] = function()
			local read = EEex_ReadU16(memory)
			memory = memory + 2
			return read
		end,
		[EEex_Sprite_MarshalHandlerFieldType.INT32] = function()
			local read = EEex_Read32(memory)
			memory = memory + 4
			return read
		end,
		[EEex_Sprite_MarshalHandlerFieldType.INTU32] = function()
			local read = EEex_ReadU32(memory)
			memory = memory + 4
			return read
		end,
		[EEex_Sprite_MarshalHandlerFieldType.INT64] = function()
			local read = EEex_Read64(memory)
			memory = memory + 8
			return read
		end,
		[EEex_Sprite_MarshalHandlerFieldType.INTU64] = function()
			local read = EEex_ReadU64(memory)
			memory = memory + 8
			return read
		end,
	}

	local tableStack = {}
	local tableStackTop = 0

	while true do

		local keyFieldType = EEex_Read8(memory)
		memory = memory + 1

		if keyFieldType == EEex_Sprite_MarshalHandlerFieldType.TABLE_END then
			if tableStackTop == 0 then
				break
			end
			toFill = tableStack[tableStackTop]
			tableStackTop = tableStackTop - 1
		else
			local key = fieldReadSwitch[keyFieldType]()
			local valueFieldType = EEex_Read8(memory)
			memory = memory + 1
			if valueFieldType == EEex_Sprite_MarshalHandlerFieldType.TABLE_START then
				local subTable = {}
				toFill[key] = subTable
				tableStackTop = tableStackTop + 1
				tableStack[tableStackTop] = toFill
				toFill = subTable
			else
				toFill[key] = fieldReadSwitch[valueFieldType]()
			end
		end
	end

	EEex_Sprite_MarshalHandlers[handlerStr].importer(sprite, toFill)
end
