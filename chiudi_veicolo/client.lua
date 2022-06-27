local ESX = exports['es_extended']:getSharedObject()

local isRunningWorkaround = false
local Vehicle_Opened_Notify = 'Vehicle Opened'
local Vehicle_Closed_Notify = 'Vehicle Closed'
local KeyMapping_Name = 'Close Vehicle'
local KeyMapping_Control = 'Close Vehicle'

function StartWorkaroundTask()
	if isRunningWorkaround then
		return
	end

	local timer = 0
	local playerPed = PlayerPedId()
	isRunningWorkaround = true

	while timer < 100 do
		Citizen.Wait(0)
		timer = timer + 1

		local vehicle = GetVehiclePedIsTryingToEnter(playerPed)

		if DoesEntityExist(vehicle) then
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 4 then
				ClearPedTasks(playerPed)
			end
		end
	end

	isRunningWorkaround = false
end

local targadue = nil
local veicoli = {}
RegisterNetEvent("veicololock")
AddEventHandler("veicololock", function(targa)
	table.insert(veicoli, {targad = targa})
end)

local ebrei = "anim@mp_player_intmenu@key_fob@"

function chiudi()
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local vehicle

	Citizen.CreateThread(function()
		StartWorkaroundTask()
	end)

	if IsPedInAnyVehicle(playerPed, false) then
		vehicle = GetVehiclePedIsIn(playerPed, false)
	else
		vehicle = GetClosestVehicle(coords, 8.0, 0, 71)
	end

	if not DoesEntityExist(vehicle) then
		return
	end

	ESX.TriggerServerCallback('sv_richiedi:veicoli', function(t)

		for k,v in pairs(veicoli) do
			if GetVehicleNumberPlateText(vehicle) == v.targad then
				targadue = v.targad
			else
				targadue = nil
			end
		end

		if t or GetVehicleNumberPlateText(vehicle) == targadue then
			--
			RequestAnimDict(ebrei)
			while not HasAnimDictLoaded(ebrei) do
				Citizen.Wait(0)
			end
			--
			local lockStatus = GetVehicleDoorLockStatus(vehicle)

			if lockStatus == 1 then 
				SetVehicleDoorsLocked(vehicle, 2)
				PlayVehicleDoorCloseSound(vehicle, 1)

				TaskPlayAnim(PlayerPedId(), ebrei, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)

				ESX.ShowNotification(Vehicle_Closed_Notify)
			elseif lockStatus == 2 then 
				SetVehicleDoorsLocked(vehicle, 1)
				PlayVehicleDoorOpenSound(vehicle, 0)

				TaskPlayAnim(PlayerPedId(), ebrei, "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)

				ESX.ShowNotification(Vehicle_Opened_Notify)
			end
		end

	end, ESX.Math.Trim(GetVehicleNumberPlateText(vehicle)))
end

RegisterKeyMapping('+chiudi_veh', KeyMapping_Name, 'keyboard', KeyMapping_Control)

RegisterCommand('+chiudi_veh', function()
	chiudi()
end)


-------EXAMPLE
--ESX.Game.SpawnVehicle('blista', vector3(120.0, -200.0, 30.0), 100.0, function(vehicle) local plate = GetVehicleNumberPlateText(vehicle) TriggerEvent('veicololock', plate) --trigger to add the vehicle to the table end)
