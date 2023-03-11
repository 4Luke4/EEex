
-------------
-- Options --
-------------

B3Timer_ShowModalTimer = false
B3Timer_ShowContingencyTimer = false
B3Timer_ShowCastTimer = false

B3Timer_HugPortraits = false

-----------------------
-- Template Handling --
-----------------------

B3Timer_TemplateInstances = {}

function B3Timer_CreateInstance(menuName, templateName, x, y, w, h)

	local menuEntry = B3Timer_TemplateInstances[menuName]
	if not menuEntry then
		menuEntry = {}
		B3Timer_TemplateInstances[menuName] = menuEntry
	end

	local entry = menuEntry[templateName]
	if not entry then
		entry = {["maxID"] = 0, ["instanceData"] = {}}
		menuEntry[templateName] = entry
	end

	local newID = entry.maxID + 1
	entry.maxID = newID

	local instanceEntry = {["id"] = newID}
	entry.instanceData[newID] = instanceEntry

	local oldAnimationID = currentAnimationID
	currentAnimationID = newID
	EEex_Menu_InjectTemplate(menuName, templateName, x, y, w, h)
	currentAnimationID = oldAnimationID

	return instanceEntry
end

B3Timer_TemplateInstancesByPortrait = {}

function B3Timer_CreateInstanceForPortrait(menuName, templateName, x, y, w, h, portraitItem)
	local instanceEntry = B3Timer_CreateInstance(menuName, templateName, x, y, w, h)
	instanceEntry.portraitItem = portraitItem
	instanceEntry.portraitEnabledFunc = EEex_Menu_GetItemFunction(portraitItem.reference_enabled)
	instanceEntry.portraitIndex = EEex_Menu_GetItemVariant(portraitItem.button.portrait)
	instanceEntry.enabled = false
	local portraitEntry = EEex_Utility_GetOrCreate(B3Timer_TemplateInstancesByPortrait, instanceEntry.portraitIndex, {})
	local instanceEntries = EEex_Utility_GetOrCreate(portraitEntry, templateName, {})
	table.insert(instanceEntries, instanceEntry)
end

---------------
-- Listeners --
---------------

B3Timer_InjectingMenu = "RIGHT_SIDEBAR"

function B3Timer_InstallBars()

	-- Dragonspear UI++
	B3Timer_HugPortraits = B3Timer_HugPortraits or nameToItem["portrait1ButtonBig"] ~= nil

	EEex_Menu_LoadFile("B3Timer")

	local item = EEex_Menu_Find(B3Timer_InjectingMenu).items
	while item do
		local portrait = item.button.portrait
		if portrait then
			local area = item.area
			B3Timer_CreateInstanceForPortrait(B3Timer_InjectingMenu, "B3Timer_Menu_TEMPLATE_Background",       nil, nil, 10, nil, item)
			B3Timer_CreateInstanceForPortrait(B3Timer_InjectingMenu, "B3Timer_Menu_TEMPLATE_TimerModal",       nil, nil, 2,  nil, item)
			B3Timer_CreateInstanceForPortrait(B3Timer_InjectingMenu, "B3Timer_Menu_TEMPLATE_TimerContingency", nil, nil, 2,  nil, item)
			B3Timer_CreateInstanceForPortrait(B3Timer_InjectingMenu, "B3Timer_Menu_TEMPLATE_TimerCast",        nil, nil, 2,  nil, item)
		end
		item = item.next
	end
end
EEex_Menu_AddMainFileLoadedListener(B3Timer_InstallBars)

function B3Timer_PushMenuListener()
	Infinity_PushMenu("B3Timer_Menu")
end
EEex_GameState_AddInitializedListener(B3Timer_PushMenuListener)
EEex_Menu_AddAfterMainFileReloadedListener(B3Timer_PushMenuListener)

--------------------
-- Menu Functions --
--------------------

B3Timer_NextUpdateTick = -1

function B3Timer_Menu_Tick()

	-- Game lags when this function is spammed, limit to 30tps.
	local curTick = Infinity_GetClockTicks()
	if curTick < B3Timer_NextUpdateTick then
		return
	end
	B3Timer_NextUpdateTick = curTick + 33

	for portraitIndex = 0, 5, 1 do

		local portraitEntry = B3Timer_TemplateInstancesByPortrait[portraitIndex]
		local sprite = EEex_Sprite_GetInPortrait(portraitIndex)

		if sprite then

			local portraitInstanceStartX = {}
			local portraitInstanceCurX = {}

			local updateTimerBar = function(templateName, condition)

				for i, instanceEntry in ipairs(portraitEntry[templateName]) do

					local portraitArea = instanceEntry.portraitItem.area

					local curX = portraitInstanceCurX[i]
					if not curX then
						local startX = (B3Timer_HugPortraits and portraitArea.x or 0) - 3
						curX = startX
						portraitInstanceStartX[i] = startX
						portraitInstanceCurX[i] = curX
					end

					local portraitEnabledFunc = instanceEntry.portraitEnabledFunc
					if (not portraitEnabledFunc or portraitEnabledFunc()) and condition then
						instanceEntry.enabled = true
						portraitInstanceCurX[i] = curX - 3
						EEex_Menu_SetTemplateArea(B3Timer_InjectingMenu, templateName, instanceEntry.id, curX, portraitArea.y, nil, portraitArea.h)
					else
						instanceEntry.enabled = false
					end
				end
			end

			updateTimerBar( "B3Timer_Menu_TEMPLATE_TimerCast",        B3Timer_ShowCastTimer        and sprite:getCastTimerPercentage() > 0                     )
			updateTimerBar( "B3Timer_Menu_TEMPLATE_TimerContingency", B3Timer_ShowContingencyTimer and sprite:getActiveStats().m_cContingencyList.m_nCount > 0 )
			updateTimerBar( "B3Timer_Menu_TEMPLATE_TimerModal",       B3Timer_ShowModalTimer       and sprite:getModalState() ~= 0                             )

			for i, backgroundEntry in ipairs(portraitEntry["B3Timer_Menu_TEMPLATE_Background"]) do
				local startX = portraitInstanceStartX[i]
				local curX = portraitInstanceCurX[i]
				if curX ~= startX then
					backgroundEntry.enabled = true
					local portraitArea = backgroundEntry.portraitItem.area
					EEex_Menu_SetTemplateArea(B3Timer_InjectingMenu, "B3Timer_Menu_TEMPLATE_Background", backgroundEntry.id, curX + 2, portraitArea.y, startX - curX + 1, portraitArea.h)
				else
					backgroundEntry.enabled = false
				end
			end
		else
			for _, templateName in ipairs({
				"B3Timer_Menu_TEMPLATE_Background",
				"B3Timer_Menu_TEMPLATE_TimerModal",
				"B3Timer_Menu_TEMPLATE_TimerContingency",
				"B3Timer_Menu_TEMPLATE_TimerCast"
			})
			do
				for _, instanceEntry in ipairs(portraitEntry[templateName]) do
					instanceEntry.enabled = false
				end
			end
		end
	end
end

function B3Timer_Menu_TEMPLATE_Background_Enabled()
	return B3Timer_TemplateInstances[B3Timer_InjectingMenu]["B3Timer_Menu_TEMPLATE_Background"].instanceData[instanceId].enabled
end

function B3Timer_Menu_TEMPLATE_TimerModal_Enabled()
	return B3Timer_TemplateInstances[B3Timer_InjectingMenu]["B3Timer_Menu_TEMPLATE_TimerModal"].instanceData[instanceId].enabled
end

function B3Timer_Menu_TEMPLATE_TimerModal_Frame()
	local portraitIndex = B3Timer_TemplateInstances[B3Timer_InjectingMenu]["B3Timer_Menu_TEMPLATE_TimerModal"].instanceData[instanceId].portraitIndex
	return math.floor(90 * EEex_Sprite_GetModalTimerPercentage(EEex_Sprite_GetInPortrait(portraitIndex)) + 0.5)
end

function B3Timer_Menu_TEMPLATE_TimerContingency_Enabled()
	return B3Timer_TemplateInstances[B3Timer_InjectingMenu]["B3Timer_Menu_TEMPLATE_TimerContingency"].instanceData[instanceId].enabled
end

function B3Timer_Menu_TEMPLATE_TimerContingency_Frame()
	local portraitIndex = B3Timer_TemplateInstances[B3Timer_InjectingMenu]["B3Timer_Menu_TEMPLATE_TimerContingency"].instanceData[instanceId].portraitIndex
	return math.floor(90 * EEex_Sprite_GetContingencyTimerPercentage(EEex_Sprite_GetInPortrait(portraitIndex)) + 0.5)
end

function B3Timer_Menu_TEMPLATE_TimerCast_Enabled()
	return B3Timer_TemplateInstances[B3Timer_InjectingMenu]["B3Timer_Menu_TEMPLATE_TimerCast"].instanceData[instanceId].enabled
end

function B3Timer_Menu_TEMPLATE_TimerCast_Frame()
	local portraitIndex = B3Timer_TemplateInstances[B3Timer_InjectingMenu]["B3Timer_Menu_TEMPLATE_TimerCast"].instanceData[instanceId].portraitIndex
	return math.floor(90 * EEex_Sprite_GetCastTimerPercentage(EEex_Sprite_GetInPortrait(portraitIndex)) + 0.5)
end
