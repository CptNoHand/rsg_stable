
local SelectedHorseId = {}
local Horses

CreateThread(function()
	if GetCurrentResourceName() ~= "rsg_stable" then
		print("^1=====================================")
		print("^1SCRIPT NAME OTHER THAN ORIGINAL")
		print("^1YOU SHOULD STOP SCRIPT")
		print("^1CHANGE NAME TO: ^2rsg_stable^1")
		print("^1=====================================^0")
	end
end)

RegisterNetEvent("rsg_stable:UpdateHorseComponents", function(components, idhorse, MyHorse_entity)
	local src = source
	local encodedComponents = json.encode(components)
	local Player = exports['qbr-core']:GetPlayer(src)
	local Playercid = Player.PlayerData.citizenid
	local id = idhorse
	MySQL.Async.execute("UPDATE horses SET `components`=@components WHERE `cid`=@cid AND `id`=@id", {components = encodedComponents, cid = Playercid, id = id}, function(done)
		TriggerClientEvent("rsg_stable:client:UpdadeHorseComponents", src, MyHorse_entity, components)
	end)
end)

RegisterNetEvent("rsg_stable:CheckSelectedHorse", function()
	local src = source
	local Player = exports['qbr-core']:GetPlayer(src)
	local Playercid = Player.PlayerData.citizenid

	MySQL.Async.fetchAll('SELECT * FROM horses WHERE `cid`=@cid;', {cid = Playercid}, function(horses)
		if #horses ~= 0 then
			for i = 1, #horses do
				if horses[i].selected == 1 then
					TriggerClientEvent("rsg_stable:SetHorseInfo", src, horses[i].id, horses[i].cid, horses[i].model, horses[i].name, horses[i].components)
				end
			end
		end
	end)
end)

RegisterNetEvent("rsg_stable:AskForMyHorses", function()
	local src = source
	local horseId = nil
	local components = nil
	local Player = exports['qbr-core']:GetPlayer(src)
	local Playercid = Player.PlayerData.citizenid
	MySQL.Async.fetchAll('SELECT * FROM horses WHERE `cid`=@cid;', {cid = Playercid}, function(horses)
		if horses[1]then
			horseId = horses[1].id
		else
			horseId = nil
		end

		MySQL.Async.fetchAll('SELECT * FROM horses WHERE `cid`=@cid;', {cid = Playercid}, function(components)
			if components[1] then
				components = components[1].components
			end
		end)
		TriggerClientEvent("rsg_stable:ReceiveHorsesData", src, horses)
	end)
end)

RegisterNetEvent("rsg_stable:BuyHorse", function(data, name)
	local src = source
	local Player = exports['qbr-core']:GetPlayer(src)
	local Playercid = Player.PlayerData.citizenid

	MySQL.Async.fetchAll('SELECT * FROM horses WHERE `cid`=@cid;', {cid = Playercid}, function(horses)
		if #horses >= 3 then
			TriggerClientEvent('QBCore:Notify', src, 9, 'you can have a maximum of 3 horses!', 5000, 0, 'mp_lobby_textures', 'cross', 'COLOR_WHITE')
			return
		end
		Wait(200)
		if data.IsGold then
			local currentBank = Player.Functions.GetMoney('bank')
			if data.Gold <= currentBank then
				local bank = Player.Functions.RemoveMoney("bank", data.Gold, "stable-bought-horse")
				TriggerClientEvent('QBCore:Notify', src, 9, 'horse purchased for $'..data.Gold, 5000, 0, 'satchel_textures', 'animal_horse', 'COLOR_WHITE')
				TriggerEvent('qbr-log:server:CreateLog', 'shops', 'Stable', 'green', "**"..GetPlayerName(Player.PlayerData.source) .. " (citizenid: "..Player.PlayerData.citizenid.." | id: "..Player.PlayerData.source..")** bought a horse for $"..data.Gold..".")
			else
				TriggerClientEvent('QBCore:Notify', src, 8, 'not enough money', 5000, 'not enough money in your Bank!', 'satchel_textures', 'animal_horse', 'COLOR_WHITE')
				return
			end
		else
			if Player.Functions.RemoveMoney("cash", data.Dollar, "stable-bought-horse") then
				TriggerClientEvent('QBCore:Notify', src, 9, 'horse purchased for $'..data.Dollar, 5000, 0, 'satchel_textures', 'animal_horse', 'COLOR_WHITE')
				TriggerEvent('qbr-log:server:CreateLog', 'shops', 'Stable', 'green', "**"..GetPlayerName(Player.PlayerData.source) .. " (citizenid: "..Player.PlayerData.citizenid.." | id: "..Player.PlayerData.source..")** bought a horse for $"..data.Dollar..".")
			else
				TriggerClientEvent('QBCore:Notify', src, 8, 'not enough money', 5000, 'not enough money in your Wallet!', 'satchel_textures', 'animal_horse', 'COLOR_WHITE')
				return
			end
		end
	MySQL.Async.execute('INSERT INTO horses (`cid`, `name`, `model`) VALUES (@Playercid, @name, @model);',
		{
			Playercid = Playercid,
			name = tostring(name),
			model = data.ModelH
		}, function(rowsChanged)

		end)
	end)
end)

RegisterNetEvent("rsg_stable:SelectHorseWithId", function(id)
	local src = source
	local Player = exports['qbr-core']:GetPlayer(src)
	local Playercid = Player.PlayerData.citizenid
	MySQL.Async.fetchAll('SELECT * FROM horses WHERE `cid`=@cid;', {cid = Playercid}, function(horse)
		for i = 1, #horse do
			local horseID = horse[i].id
			MySQL.Async.execute("UPDATE horses SET `selected`='0' WHERE `cid`=@cid AND `id`=@id", {cid = Playercid,  id = horseID}, function(done)
			end)

			Wait(300)

			if horse[i].id == id then
				MySQL.Async.execute("UPDATE horses SET `selected`='1' WHERE `cid`=@cid AND `id`=@id", {cid = Playercid, id = id}, function(done)
					TriggerClientEvent("rsg_stable:SetHorseInfo", src, horse[i].model, horse[i].name, horse[i].components)
				end)
			end
		end
	end)
end)

RegisterNetEvent("rsg_stable:SellHorseWithId", function(id)
	local modelHorse = nil
	local src = source
	local Player = exports['qbr-core']:GetPlayer(src)
	local Playercid = Player.PlayerData.citizenid
	MySQL.Async.fetchAll('SELECT * FROM horses WHERE `cid`=@cid;', {cid = Playercid}, function(horses)

		for i = 1, #horses do
		   if tonumber(horses[i].id) == tonumber(id) then
				modelHorse = horses[i].model
				MySQL.Async.fetchAll('DELETE FROM horses WHERE `cid`=@cid AND`id`=@id;', {cid = Playercid,  id = id}, function(result)
				end)
			end
		end

		for k,v in pairs(Config.Horses) do
			for models,values in pairs(v) do
				if models ~= "name" then
					if models == modelHorse then
						local price = tonumber(values[3]/2)
						Player.Functions.AddMoney("cash", price, "stable-sell-horse")
						TriggerEvent('qbr-log:server:CreateLog', 'shops', 'Stable', 'red', "**"..GetPlayerName(Player.PlayerData.source) .. " (citizenid: "..Player.PlayerData.citizenid.." | id: "..Player.PlayerData.source..")** sold a horse for $"..price..".")
					end
				end
			end
		end
	end)
end)

-- feed horse
exports['qbr-core']:CreateUseableItem("carrot", function(source, item)
    local Player = exports['qbr-core']:GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("rsg_stable:client:feedhorse", source, item.name, 25)
    end
end)

exports['qbr-core']:CreateUseableItem("sugar", function(source, item)
    local Player = exports['qbr-core']:GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("rsg_stable:client:feedhorse", source, item.name, 50)
    end
end)

-- brush horse
exports['qbr-core']:CreateUseableItem("horsebrush", function(source, item)
    local Player = exports['qbr-core']:GetPlayer(source)
	TriggerClientEvent("rsg_stable:client:brushhorse", source, item.name)
end)