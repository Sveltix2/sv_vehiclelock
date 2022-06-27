# sv_vehiclelock

Simple vehicle lock system with the possibility of closing unowned vehicles [like secondary job vehicles and job vehicle] very easily


ESX.Game.SpawnVehicle('blista', vector3(120.0, -200.0, 30.0), 100.0, function(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    TriggerEvent('veicololock', plate) --trigger to add the vehicle to the table
end)

