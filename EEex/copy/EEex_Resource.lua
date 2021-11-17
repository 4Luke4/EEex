
-- Mirrors chExtToType, (chTypeToExt would be reverse)
function EEex_Resource_ExtToType(extension)
	return ({
		["2DA"]  = 0x3F4, -- CResText
		["ARE"]  = 0x3F2, -- CResArea
		["BAM"]  = 0x3E8, -- CResCell
		["BCS"]  = 0x3EF, -- CResText
		["BIO"]  = 0x3FE, -- CResBIO
		["BMP"]  = 0x1  , -- CResBitmap
		["BS"]   = 0x3F9, -- CResText
		["CHR"]  = 0x3FA, -- CResCHR
		["CHU"]  = 0x3EA, -- CResUI
		["CRE"]  = 0x3F1, -- CResCRE
		["DLG"]  = 0x3F3, -- CResDLG
		["EFF"]  = 0x3F8, -- CResEffect
		["GAM"]  = 0x3F5, -- CResGame
		["GLSL"] = 0x405, -- CResText
		["GUI"]  = 0x402, -- CResText
		["IDS"]  = 0x3F0, -- CResText
		["INI"]  = 0x802, -- CRes(???)
		["ITM"]  = 0x3ED, -- CResItem
		["LUA"]  = 0x409, -- CResText
		["MENU"] = 0x408, -- CResText
		["MOS"]  = 0x3EC, -- CResMosaic
		["MVE"]  = 0x2  , -- CRes(???)
		["PLT"]  = 0x6  , -- CResPLT
		["PNG"]  = 0x40B, -- CResPng
		["PRO"]  = 0x3FD, -- CResBinary
		["PVRZ"] = 0x404, -- CResPVR
		["SPL"]  = 0x3EE, -- CResSpell
		["SQL"]  = 0x403, -- CResText
		["STO"]  = 0x3F6, -- CResStore
		["TGA"]  = 0x3  , -- CRes(???)
		["TIS"]  = 0x3EB, -- CResTileSet
		["TOH"]  = 0x407, -- CRes(???)
		["TOT"]  = 0x406, -- CRes(???)
		["TTF"]  = 0x40A, -- CResFont
		["VEF"]  = 0x3FC, -- CResBinary
		["VVC"]  = 0x3FB, -- CResBinary
		["WAV"]  = 0x4  , -- CResWave
		["WBM"]  = 0x3FF, -- CResWebm
		["WED"]  = 0x3E9, -- CResWED
		["WFX"]  = 0x5  , -- CResBinary
		["WMP"]  = 0x3F7, -- CResWorldMap
	})[extension:upper()]
end

function EEex_Resource_ExtToUserType(extension)
	return ({
		["2DA"]  = "CResText",
		["ARE"]  = "CResArea",
		["BAM"]  = "CResCell",
		["BCS"]  = "CResText",
		["BIO"]  = "CResBIO",
		["BMP"]  = "CResBitmap",
		["BS"]   = "CResText",
		["CHR"]  = "CResCHR",
		["CHU"]  = "CResUI",
		["CRE"]  = "CResCRE",
		["DLG"]  = "CResDLG",
		["EFF"]  = "CResEffect",
		["GAM"]  = "CResGame",
		["GLSL"] = "CResText",
		["GUI"]  = "CResText",
		["IDS"]  = "CResText",
		["INI"]  = "CRes",
		["ITM"]  = "CResItem",
		["LUA"]  = "CResText",
		["MENU"] = "CResText",
		["MOS"]  = "CResMosaic",
		["MVE"]  = "CRes",
		["PLT"]  = "CResPLT",
		["PNG"]  = "CResPng",
		["PRO"]  = "CResBinary",
		["PVRZ"] = "CResPVR",
		["SPL"]  = "CResSpell",
		["SQL"]  = "CResText",
		["STO"]  = "CResStore",
		["TGA"]  = "CRes",
		["TIS"]  = "CResTileSet",
		["TOH"]  = "CRes",
		["TOT"]  = "CRes",
		["TTF"]  = "CResFont",
		["VEF"]  = "CResBinary",
		["VVC"]  = "CResBinary",
		["WAV"]  = "CResWave",
		["WBM"]  = "CResWebm",
		["WED"]  = "CResWED",
		["WFX"]  = "CResBinary",
		["WMP"]  = "CResWorldMap",
	})[extension:upper()]
end

function EEex_Resource_Fetch(resref, extension)
	local toReturn
	EEex_RunWithStack(CRes.sizeof + #resref + 1, function(rsp)
	
		local resObj = EEex_PtrToUD(rsp, "CRes")
		resObj:Construct()
		local resrefStr = EEex_CastUD(resObj.resref, "CharString")
		resrefStr:pointTo(rsp + CRes.sizeof)
		resrefStr:write(resref)
		resObj.type = EEex_Resource_ExtToType(extension)

		toReturn = EngineGlobals.bsearch(
			resObj:getReference(),
			EngineGlobals.resources.m_pData,
			EngineGlobals.resources.m_nSize,
			EEex_PointerSize,
			EngineGlobals.reference_CompareCResByTypeThenName
		)

		if toReturn then toReturn = EEex_CastUD(toReturn.reference, EEex_Resource_ExtToUserType(extension)) end
		resObj:Destruct()
	end)
	return toReturn
end

function EEex_Resource_Demand(resref, extension)

	local res = EEex_Resource_Fetch(resref, extension)
	if not res then return end
	local demanded = res:Demand()
	if not demanded then return end

	local castType = ({
		["SPL"] = "Spell_Header_st",
	})[extension:upper()]

	if castType then demanded = EEex_CastUD(demanded, castType) end
	return demanded
end

function EEex_Resource_GetSpellAbility(spellHeader, abilityIndex)
	if spellHeader.abilityCount <= abilityIndex then return end
	return EEex_PtrToUD(EEex_UDToPtr(spellHeader) + spellHeader.abilityOffset + Spell_ability_st.sizeof * abilityIndex, "Spell_ability_st")
end
