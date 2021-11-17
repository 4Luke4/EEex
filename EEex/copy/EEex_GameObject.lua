
function EEex_GameObject_Get(objectID)

	local CGameObject
	EEex_RunWithStack(EEex_PointerSize, function(mem)
		ptr = EEex_PtrToUD(mem, "Pointer<CGameObject>")
		CGameObjectArray.GetShare(objectID, ptr)
		CGameObject = ptr.reference
	end)

	if not CGameObject then return nil end

	local usertype = ({
		[CGameObjectType.NONE]          = nil,
		[CGameObjectType.AIBASE]        = "CGameAIBase",
		[CGameObjectType.SOUND]         = "CGameSound",
		[CGameObjectType.CONTAINER]     = "CGameContainer",
		[CGameObjectType.SPAWNING]      = "CGameSpawning",
		[CGameObjectType.DOOR]          = "CGameDoor",
		[CGameObjectType.STATIC]        = "CGameStatic",
		[CGameObjectType.SPRITE]        = "CGameSprite",
		[CGameObjectType.OBJECT_MARKER] = "CObjectMarker",
		[CGameObjectType.TRIGGER]       = "CGameTrigger",
		[CGameObjectType.TILED_OBJECT]  = "CGameTiledObject",
		[CGameObjectType.TEMPORAL]      = "CGameTemporal",
		[CGameObjectType.AREA_AI]       = "CGameAIArea",
		[CGameObjectType.FIREBALL]      = "CGameFireball3d",
		[CGameObjectType.GAME_AI]       = "CGameAIGame",
	})[CGameObject.m_objectType]

	return usertype and EEex_CastUD(CGameObject, usertype) or CGameObject
end

function EEex_GameObject_GetSelectedID()
	local node = EEex_EngineGlobal_CBaldurChitin.m_pObjectGame.m_group.m_memberList.m_pNodeHead
	if not node then return -1 end
	return node.data
end

function EEex_GameObject_GetSelected()
	local debug = EEex_GameObject_GetSelectedID()
	return EEex_GameObject_Get(EEex_GameObject_GetSelectedID())
end

function EEex_GameObject_GetAllSelectedIDs()
	local toReturn = {}
	local node = EEex_EngineGlobal_CBaldurChitin.m_pObjectGame.m_group.m_memberList.m_pNodeHead
	while node do
		table.insert(toReturn, node.data)
		node = node.pNext
	end
	return toReturn
end

function EEex_GameObject_IsSprite(object, allowDead)
	if object and object.m_objectType == CGameObjectType.SPRITE then
		return allowDead or EEex_BAnd(object.m_baseStats.m_generalState, 0xFC0) == 0
	end
	return false
end

function EEex_GameObject_IsSpriteID(objectID, allowDead)
	return EEex_GameObject_IsSprite(EEex_GameObject_Get(objectID), allowDead)
end

function EEex_GameObject_GetClass(object)
	return object.m_typeAI.m_Class
end

