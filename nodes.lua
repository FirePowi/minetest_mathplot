mathplot = mathplot or {}

-- support for MT game translation.
local S = mathplot.get_translator

mathplot.ORIGIN_NODE_NAME = "mathplot:00_origin"
mathplot.ORIGIN_DESTROYER_NODE_NAME = "mathplot:00_origin_destroyer"

minetest.register_node(mathplot.ORIGIN_NODE_NAME, {
        description = S("MathPlot Origin Node"),
        groups = {cracky = 1},
        paramtype = "light",
        light_source = 7,
        tiles = { "mathplot_origin_node_128x128.png" },
        inventory_image = "mathplot_origin_node_128x128.png",
        on_construct = function(pos)
            --add to mod storage
            local name = S("Untitled Node")
            mathplot.store_origin_location(name, pos)
        end,
        is_ground_content = false,
        on_blast = function(pos, intensity) end, --prevent explosions from destroying it
        on_dig = function(pos, node, digger)
            local wieldedItemName = digger:get_wielded_item():get_name()
            if wieldedItemName == mathplot.ORIGIN_DESTROYER_NODE_NAME then
                minetest.node_dig(pos, node, digger)
            else
                minetest.chat_send_player(digger:get_player_name(), S("Use the 'MathPlot Origin Destroyer' tool to dig this node."))
            end
        end,
        on_punch = function(pos, node, puncher, pointed_thing)
            local wieldedItemName = puncher:get_wielded_item():get_name()
            if wieldedItemName == mathplot.ORIGIN_DESTROYER_NODE_NAME then
                --Default "on_punch" behavior
                minetest.node_punch(pos, node, puncher, pointed_thing)
            else
                --Show menu
                local playername = puncher:get_player_name()
                if mathplot.util.has_mathplot_priv(playername) then
                    local context = {
                        node_pos = pos
                    }
                    mathplot.gui.invoke_screen("originmainmenu", playername, context)
                else
                    minetest.chat_send_player(playername, S("The 'mathplot' privilege is required."))
                end
            end
        end,
        after_destruct = function(pos, oldnode)
            --remove from mod storage
            mathplot.remove_origin_location(pos)
        end
    })
minetest.register_alias("mathplot:origin", mathplot.ORIGIN_NODE_NAME)


minetest.register_tool(mathplot.ORIGIN_DESTROYER_NODE_NAME, {
        description = S("MathPlot Origin Node Destroyer"),
        groups = {},
        inventory_image = "mathplot_tool_destroyer_128x128.png"
    })
minetest.register_alias("mathplot:destroyer", mathplot.ORIGIN_DESTROYER_NODE_NAME)


--#############################################
--############## Colorful Nodes ###############
--#############################################


--mimic the wool colors.
--Not too bright: want to see a little bit of shadow at night
local colors = {
    black = { "000000", S("Black") },
    blue = { "0000ff", S("Blue") },
    brown = { "492300", S("Brown") },
    cyan = { "00ffff", S("Cyan") },
    dark_green = { "2a7a00", S("Dark Green") },
    dark_grey = { "323232", S("Dark Grey") },
    green = { "00ff00", S("Green") },
    grey = { "8b8b8b", S("Grey") },
    magenta = { "e0048b", S("Magenta") },
    orange = { "ff6600", S("Orange") },
    pink = { "ff6d6d", S("Pink") },
    red = { "ff0000", S("Red") },
    violet = { "8a00ff", S("Violet") },
    white = { "ffffff", S("White") },
    yellow = { "ffff00", S("Yellow") }
}
local alpha = "8f"

for colorKey, colorData in pairs(colors) do
    local colorVal = colorData[1]
    local colorName = colorData[2]

    --Translucent nodes
    minetest.register_node("mathplot:translucent_" .. colorKey, {
            description = S("MathPlot @1 Translucent Glow Block", colorName),
            groups = {cracky = 1},
            paramtype = "light",
            light_source = 11,
            use_texture_alpha = true,
            tiles = { "mathplot_translucent_grid_16x16.png^[colorize:#" .. colorVal .. alpha }
        })

    --Make "glow wool" by tweaking standard wool nodes
    local woolNode = table.copy(minetest.registered_nodes["wool:" .. colorKey])
    woolNode.paramtype = "light"
    woolNode.light_source = 8
    woolNode.description = S("MathPlot Glowing @1", woolNode.description)
    minetest.register_node("mathplot:glow_wool_" .. colorKey, woolNode)

    --Make "glow glass" by tweaking the standard glass node
    --local glassNode = table.copy(minetest.registered_nodes["default:obsidian_glass"])
    local glassNode = table.copy(minetest.registered_nodes["default:glass"])
    glassNode.description = S("MathPlot Glowing @1 Glass", colorName)
    glassNode.paramtype = "light"
    glassNode.light_source = 10
    for i = 1, #glassNode.tiles do
        glassNode.tiles[i] = glassNode.tiles[i] .. "^[colorize:#" .. colorVal
    end
    minetest.register_node("mathplot:glow_glass_" .. colorKey, glassNode)
end
