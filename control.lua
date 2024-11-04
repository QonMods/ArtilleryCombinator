local SHORTCUT_NAME = 'artillerycombinator-shame-and-regret'

script.on_init(function()
    storage.EntityActivity = {}
    storage.EntityListID = {}
    storage.EntityListUN = {}
    storage.entity_id_counter = 0
end)

--function to add entity to list
function EntityCreate(event)
    local entity = event.created_entity or event.entity
    if entity.name == "artillery-combinator" then
        storage.entity_id_counter = storage.entity_id_counter + 1
        storage.EntityListID[storage.entity_id_counter] = {un = entity.unit_number, entity = entity}
        storage.EntityListUN[entity.unit_number] = {id = storage.entity_id_counter, entity = entity}
    end
end

--function to remove entity from list
function EntityRemove(event)
    local entity = event.created_entity or event.entity
    if entity.name == "artillery-combinator" then
        local id = storage.EntityListUN[entity.unit_number].id
        storage.EntityListID[id] = nil
        storage.EntityActivity[entity.unit_number] = nil
        storage.EntityListUN[entity.unit_number] = nil
    end
end

--function that pings map for each "artillery-combinator" entity
function runthrough()
    for k,entity in pairs(storage.EntityListID) do
        entity = entity.entity
        --check validity of entity and remove it if it isn't valid
        if entity.valid == false then
            local un = storage.EntityListID[k].un
            storage.EntityListID[k] = nil
            storage.EntityActivity[un] = nil
            storage.EntityListUN[un] = nil
            goto skip
        end

        --set up info for entity
        entity.get_or_create_control_behavior()
        --local netA = entity.get_circuit_network(defines.wire_type.green)
	local netA = entity.get_circuit_network(defines.wire_connector_id.circuit_green)
        --local netB = entity.get_circuit_network(defines.wire_type.red)
	local netB = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
        --store correct values from the circuit network. Commented out values are 1.1.
        if netA == nil then
            NetAX = 0
            NetAY = 0
            NetAOK = 0
            NetAabs = 0
        else
            NetAX = netA.get_signal({["type"] = "virtual", ["name"] = "signal-X"})
            NetAY = netA.get_signal({["type"] = "virtual", ["name"] = "signal-Y"})
            NetAabs = netA.get_signal({["type"] = "virtual", ["name"] = "signal-A"})
            NetAOK = netA.get_signal({["type"] = "item", ["name"] = "artillery-targeting-remote"})
        end
        if netB == nil then
            NetBX = 0
            NetBY = 0
            NetBOK = 0
            NetBabs = 0
        else
            NetBX = netB.get_signal({["type"] = "virtual", ["name"] = "signal-X"})
            NetBY = netB.get_signal({["type"] = "virtual", ["name"] = "signal-Y"})
            NetBabs = netB.get_signal({["type"] = "virtual", ["name"] = "signal-A"})
            NetBOK = netB.get_signal({["type"] = "item", ["name"] = "artillery-targeting-remote"})
        end
        --set up a few more variables
        local x = NetAX + NetBX
        local y = NetAY + NetBY
        if NetAabs + NetBabs <= 0 then
            x = x + entity.position.x
            y = y + entity.position.y
        end
        if (NetAOK ~= 0 or NetBOK ~= 0) --[[or game.tick % 60 == 0--]] then -- storage.EntityActivity[entity.unit_number] == nil and (NetAOK ~= 0 or NetBOK ~= 0) then
            -- entity.force.print("[gps="..x..","..y.."]")
            entity.surface.create_entity({
                    name = "artillery-flare",
                    position = {x, y},
                    force = entity.force,
                    movement = {0, 0},
                    height = 0,
                    vertical_speed = 0,
                    frame_speed = 0,
            })
            -- storage.EntityActivity[entity.unit_number] = 0
        end
        --reset entity
        -- if NetAOK == 0 and NetBOK == 0 then
        --  storage.EntityActivity[entity.unit_number] = nil
        -- end
        ::skip::
    end
end

script.on_event(defines.events.on_built_entity, EntityCreate)
script.on_event(defines.events.on_robot_built_entity, EntityCreate)
script.on_event(defines.events.script_raised_revive, EntityCreate)

script.on_event(defines.events.on_pre_player_mined_item, EntityRemove)
script.on_event(defines.events.on_robot_pre_mined, EntityRemove)
script.on_event(defines.events.on_entity_died, EntityRemove)
script.on_event(defines.events.script_raised_destroy, EntityRemove)

script.on_event(defines.events.on_tick, runthrough)

script.on_event('artillerycombinator-shame-and-regret', function(event)
    if event.input_name ~= SHORTCUT_NAME and event.prototype_name ~=  SHORTCUT_NAME then return end
    local player = game.players[event.player_index]
    for m, surface in pairs(game.surfaces) do
        for k, flare in pairs(surface.find_entities_filtered{name = 'artillery-flare', force = player.force}) do
            flare.destroy()
        end
    end
    for m, surface in pairs(game.surfaces) do
        for k, ac in pairs(surface.find_entities_filtered{name = 'artillery-combinator', force = player.force}) do
            player.print('Artillery Combinator at: '..game.table_to_json(ac.position))
        end
    end
    player.print('You are at: '..game.table_to_json(player.position))
    game.print('Shame on you '..player.name.. ', you messed up!')
end)