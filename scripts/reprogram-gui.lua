local match_to_item = {
    ["equipment-bot-chip-trees"] = true,
    ["equipment-bot-chip-items"] = true,
    ["equipment-bot-chip-launcher"] = true,
    ["ammo-nano-constructors"] = true,
    ["ammo-nano-termites"] = true,
}

local function remove_gui(player, frame_name)
    return player.gui.left[frame_name] and player.gui.left[frame_name].destroy()
end

local bot_radius = MOD.config.BOT_RADIUS

local function draw_gui(player) -- return gui
    --remove_gui(player, "nano_frame_main")

    if not player.gui.left["nano_frame_main"] then

        local gui = player.gui.left.add{type = "frame", name = "nano_frame_main", direction = "horizontal", style="nano_frame_style"}
        gui.add{type="label", name="nano_label", caption={"frame.label-caption"}, tooltip={"tooltip.label"}, style="nano_label_style"}
        gui.add{type="textfield", name = "nano_text_box", text=0, tooltip={"tooltip.text-field"}, style="nano_text_style"}
        local table = gui.add{type="table", name = "nano_table", colspan=1, style="nano_table_style"}
        table.add{type="button", name="nano_btn_up", style="nano_btn_up"}
        table.add{type="button", name="nano_btn_dn", style="nano_btn_dn"}
        return gui
    else
        return player.gui.left["nano_frame_main"]
    end
end

local function get_max_radius(player)
    if player.cursor_stack.type == "ammo" then
        return bot_radius[player.force.get_ammo_damage_modifier(player.cursor_stack.prototype.ammo_type.category)]
    else
        return player.logistic_cell and player.logistic_cell.mobile and player.logistic_cell.construction_radius or 10
    end
end

local function increase_decrease_reprogrammer(event, change)
    local player, pdata = game.players[event.player_index], global.players[event.player_index]

    if player.cursor_stack.valid_for_read then
        local stack = player.cursor_stack
        if match_to_item[stack.name] then
            local radius
            local text_field = draw_gui(player)["nano_text_box"]
            local max_radius = get_max_radius(player)
            if event.element and event.element.name == "nano_text_box" and not type(event.element.text) == "number" then
                return
            elseif event.element and event.element.name == "nano_text_box" then
                radius = tonumber(text_field.text)
            else

                radius = math.max(1, (pdata.ranges[stack.name] or max_radius) + change)

                --pdata.ranges[stack.name] = radius

                text_field.text = radius

            end
            pdata.ranges[stack.name] = ((radius > 0 and radius < max_radius) and radius) or nil
            game.print(stack.name .." max = "..max_radius.." stored = ".. (pdata.ranges[stack.name] or "not saved"))
        end
    else
        remove_gui(player, "nano_frame_main")
    end
end

local function reprogrammer_text_changed(event)
    local player = game.players[event.player_index]
    game.print(event.element.text)
end

Event.gui_hotkeys = Event.gui_hotkeys or {}
Event.gui_hotkeys["nano-increase-radius"] = function (event) increase_decrease_reprogrammer(event, 1) end
Event.gui_hotkeys["nano-decrease-radius"] = function (event) increase_decrease_reprogrammer(event, -1) end
for event_name in pairs(Event.gui_hotkeys) do
    script.on_event(event_name, Event.gui_hotkeys[event_name])
end
Event.register(defines.events.on_player_cursor_stack_changed, function (event) increase_decrease_reprogrammer(event, 0) end)
Gui.on_text_changed("nano_text_box", function (event) increase_decrease_reprogrammer(event, 0) end)
Gui.on_click("nano_btn_up", function (event) increase_decrease_reprogrammer(event, 1) end)
Gui.on_click("nano_btn_dn", function (event) increase_decrease_reprogrammer(event, -1) end)