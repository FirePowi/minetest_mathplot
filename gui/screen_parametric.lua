mathplot.gui.screens = mathplot.gui.screens or {}

local S = mathplot.get_translator

local function validate_parametric(playername, identifier, fields, context)
    local e = {}  --list of error messages
    local p = table.copy(fields)

    if not mathplot.util.has_mathplot_priv(playername) then
        e[#e+1] = S("The 'mathplot' privilege is required.")
    end

    if minetest.string_to_pos(p.e1) == nil then
        e[#e+1] = S("Invalid +x Direction.")
    end
    if minetest.string_to_pos(p.e2) == nil then
        e[#e+1] = S("Invalid +y Direction.")
    end
    if minetest.string_to_pos(p.e3) == nil then
        e[#e+1] = S("Invalid +z Direction.")
    end

    local varnamesStr = mathplot.parametric_argstr_display(p.varnames)

    --Load ftn code string to check for syntax error
    local syntaxerror = mathplot.check_function_syntax(p.umin, {}, {})
    if syntaxerror ~= nil then
        e[#e+1] = S("Syntax error in u Min: @1", syntaxerror)
    end
    syntaxerror = mathplot.check_function_syntax(p.umax, {}, {})
    if syntaxerror ~= nil then
        e[#e+1] = S("Syntax error in u Max: @1", syntaxerror)
    end
    syntaxerror = mathplot.check_function_syntax(p.ustep, {}, {})
    if syntaxerror ~= nil then
        e[#e+1] = S("Syntax error in u Step: @1", syntaxerror)
    end

    syntaxerror = mathplot.check_function_syntax(p.vmin, {p.varnames[1]}, {0})
    if syntaxerror ~= nil then
        e[#e+1] = S("Syntax error in v Min: @1", syntaxerror)
    end
    syntaxerror = mathplot.check_function_syntax(p.vmax, {p.varnames[1]}, {0})
    if syntaxerror ~= nil then
        e[#e+1] = S("Syntax error in v Max: @1", syntaxerror)
    end
    syntaxerror = mathplot.check_function_syntax(p.vstep, {p.varnames[1]}, {0})
    if syntaxerror ~= nil then
        e[#e+1] = S("Syntax error in v Step: @1", syntaxerror)
    end

    syntaxerror = mathplot.check_function_syntax(p.wmin, {p.varnames[1], p.varnames[2]}, {0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = S("Syntax error in w Min: @1", syntaxerror)
    end
    syntaxerror = mathplot.check_function_syntax(p.wmax, {p.varnames[1], p.varnames[2]}, {0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = S("Syntax error in w Max: @1", syntaxerror)
    end
    syntaxerror = mathplot.check_function_syntax(p.wstep, {p.varnames[1], p.varnames[2]}, {0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = S("Syntax error in w Step: @1", syntaxerror)
    end

    syntaxerror = mathplot.check_function_syntax(p.ftn_x, p.varnames, {0, 0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = S("Syntax error in @1(@2): @3", "x", varnamesStr, syntaxerror)
    end
    syntaxerror = mathplot.check_function_syntax(p.ftn_y, p.varnames, {0, 0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = S("Syntax error in @1(@2): @3", "y", varnamesStr, syntaxerror)
    end
    syntaxerror = mathplot.check_function_syntax(p.ftn_z, p.varnames, {0, 0, 0})
    if syntaxerror ~= nil then
        e[#e+1] = S("Syntax error in @1(@2): @3", "z", varnamesStr, syntaxerror)
    end

    if not mathplot.util.is_drawable_node(fields.nodename) then
        e[#e+1] = S("'@1' is not a drawable node.", tostring(fields.nodename))
    end

    if #e == 0 then
        return p, e
    end
    --If errors, return original values
    return fields, e
end

local function title_container(title)
    return {
        height = 1,
        formspec = string.format("label[0,0;%s]", title)
    }
end
local function direction_container(e1, e2, e3)
    return {
        height = 1,
        formspec = string.format("label[0,0;%s]field[2,0;2,1;e1;;%s]", S("+x Direction:"), e1)
        .. string.format("label[4,0;%s]field[6,0;2,1;e2;;%s]", S("+y Direction:"), e2)
        .. string.format("label[8,0;%s]field[10,0;2,1;e3;;%s]", S("+z Direction:"), e3)
    }
end
local function min_max_step_container(varname, min, max, step, minCaption, maxCaption, stepCaption)
    return {
        height = 1,
        formspec = string.format("label[0,0;%s]field[2,0;2,1;%smin;;%s]", minCaption, varname, min)
        .. string.format("label[4,0;%s]field[6,0;2,1;%smax;;%s]", maxCaption, varname, max)
        .. string.format("label[8,0;%s]field[10,0;2,1;%sstep;;%s]", stepCaption, varname, step)
    }
end
local function min_max_step_container_u(min, max, step)
    return min_max_step_container("u", min, max, step, S("u Min:"), S("u Max:"), S("u Step:"))
end
local function min_max_step_container_v(min, max, step)
    return min_max_step_container("v", min, max, step, S("v Min:"), S("v Max:"), S("v Step:"))
end
local function min_max_step_container_w(min, max, step)
    return min_max_step_container("w", min, max, step, S("w Min:"), S("w Max:"), S("w Step:"))
end
local function ftn_container(varnames, ftn_x, ftn_y, ftn_z)
    local varstr = table.concat(varnames, ",")
    return {
        height = 3,
        formspec = string.format("label[0,0;x(%s) = ]field[2,0;10,1;ftn_x;;%s]", varstr, ftn_x)
        .. string.format("label[0,1;y(%s) = ]field[2,1;10,1;ftn_y;;%s]", varstr, ftn_y)
        .. string.format("label[0,2;z(%s) = ]field[2,2;10,1;ftn_z;;%s]", varstr, ftn_z)
    }
end
local function inventory_container(playername, identifier, connect)
    local btn_to_name1 = nil
    local btn_to_label1 = nil
    local btn_to_name2 = nil
    local btn_to_label2 = nil
    if identifier == "parametric_curve" then
        btn_to_name1, btn_to_label1 = "btn_to_surface", S("To Surface")
        btn_to_name2, btn_to_label2 = "btn_to_solid", S("To Solid")
    elseif identifier == "parametric_surface" then
        btn_to_name1, btn_to_label1 = "btn_to_curve", S("To Curve")
        btn_to_name2, btn_to_label2 = "btn_to_solid", S("To Solid")
    elseif identifier == "parametric_solid" then
        btn_to_name1, btn_to_label1 = "btn_to_curve", S("To Curve")
        btn_to_name2, btn_to_label2 = "btn_to_surface", S("To Surface")
    end

    --For parametric curves, show a checkbox indicating whether the generated points should be
    --connected by line segments.
    local connectCheckbox = ""
    if identifier == "parametric_curve" then
        local connectCheckboxTooltipText = S("Connect the curve points with line segments.")
        connectCheckbox = string.format("checkbox[8.25,2;chk_connect;%s;%s]", S("Connected"), tostring(connect))
        .. string.format("tooltip[chk_connect;%s]", minetest.formspec_escape(connectCheckboxTooltipText))
    end

    return {
        height = 4,
        formspec = "list[current_player;main;0,0;8,4;]"
        .. string.format("label[8.25,0.25;%s]", S("Plot node:"))
        .. "list[detached:mathplot:inv_brush_" .. playername .. ";brush;9.75,0;1,1;]"
        .. "image[10.81,0.1;0.8,0.8;creative_trash_icon.png]"
        .. "list[detached:mathplot:inv_trash;main;10.75,0;1,1;]"
        .. connectCheckbox
        .. string.format("button_exit[8.25,3;2,1;%s;%s]", btn_to_name1, btn_to_label1)
        .. string.format("button_exit[10.1,3;2,1;%s;%s]", btn_to_name2, btn_to_label2)
    }
end
local function plot_cancel_container(allowErase)
    return {
        height = 1,
        formspec = string.format("button_exit[0,0;2,1;btn_plot;%s]", S("Plot"))
        .. string.format("button_exit[2,0;2,1;btn_cancel;%s]", S("Cancel"))
        .. (allowErase and string.format("button_exit[9.1,0;3,1;btn_erase;%s]", S("Erase Previous")) or "")
    }
end


local function concat_containers(...)
    local y = 0
    local formspec = ""
    for _, c in ipairs({...}) do
        formspec = formspec
        .. string.format("container[0,%f]", y)
        .. c.formspec
        .. "container_end[]\n"
        y = y + c.height
    end
    return y, formspec
end


local function default_params(identifier)
    if identifier == "parametric_curve" then
        return mathplot.plotdefaults.plot_parametric_curve_params()
    elseif identifier == "parametric_surface" then
        return mathplot.plotdefaults.plot_parametric_surface_params()
    elseif identifier == "parametric_solid" then
        return mathplot.plotdefaults.plot_parametric_solid_params()
    end
    return nil
end


local function load_saved_params(context, identifier)
    local defaults = default_params(identifier)
    local meta = minetest.get_meta(context.node_pos)
    local s = meta:get_string(identifier .. "_params")
    local deserializedParams = minetest.deserialize(s) or {}
    return mathplot.util.merge_tables(
        defaults,
        deserializedParams
    )
end
local function have_saved_params(context, identifier)
    local meta = minetest.get_meta(context.node_pos)
    local s = meta:get_string(identifier .. "_params")
    return s ~= nil and string.trim(s) ~= ""
end

local parametric_screen = {
    initialize = function(playername, identifier, context)
        --If context.screen_params is already in context, then show those values.
        --(Likely coming back from a validation error.)
        if not context.screen_params then
            context.screen_params = load_saved_params(context, identifier)
        end
        return context
    end,
    get_formspec = function(playername, identifier, context)
        local p = context.screen_params
        local nodepos = context.node_pos

        mathplot.gui.set_brushes(playername, {brush = p.nodename})

        local formspec = ""
        local totalHeight = 0
        local allowErase = have_saved_params(context, identifier)
        if identifier == "parametric_curve" then
            totalHeight, formspec = concat_containers(
                title_container(S("Parametric Curve")),
                direction_container(p.e1, p.e2, p.e3),
                min_max_step_container_u(p.umin, p.umax, p.ustep),
                ftn_container({"u"}, p.ftn_x, p.ftn_y, p.ftn_z),
                inventory_container(playername, identifier, p.connect),
                plot_cancel_container(allowErase)
            )
        elseif identifier == "parametric_surface" then
            totalHeight, formspec = concat_containers(
                title_container(S("Parametric Surface")),
                direction_container(p.e1, p.e2, p.e3),
                min_max_step_container_u(p.umin, p.umax, p.ustep),
                min_max_step_container_v(p.vmin, p.vmax, p.vstep),
                ftn_container({"u", "v"}, p.ftn_x, p.ftn_y, p.ftn_z),
                inventory_container(playername, identifier),
                plot_cancel_container(allowErase)
            )
        elseif identifier == "parametric_solid" then
            totalHeight, formspec = concat_containers(
                title_container(S("Parametric Solid")),
                direction_container(p.e1, p.e2, p.e3),
                min_max_step_container_u(p.umin, p.umax, p.ustep),
                min_max_step_container_v(p.vmin, p.vmax, p.vstep),
                min_max_step_container_w(p.wmin, p.wmax, p.wstep),
                ftn_container({"u", "v", "w"}, p.ftn_x, p.ftn_y, p.ftn_z),
                inventory_container(playername, identifier),
                plot_cancel_container(allowErase)
            )
        end

        formspec = string.format("size[12,%f]", totalHeight-0.5) .. formspec
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
        if fields.chk_connect ~= nil then
            --Checkbox field chk_connect is not sent on button press, so store it on the context
            context.screen_params.connect = minetest.is_yes(fields.chk_connect)
        end

        if fields.btn_plot or fields.key_enter or fields.btn_erase then
            local nodename = ""
            local newfields = nil
            if fields.btn_erase then
                newfields = load_saved_params(context, identifier)
                newfields.nodename = "air"
                context.is_erase = true
            else
                nodename = mathplot.gui.get_brushes(playername, { "brush" })["brush"]
                newfields = mathplot.util.merge_tables(
                    default_params(identifier),
                    fields,
                    { origin_pos = context.node_pos, nodename = nodename, connect = context.screen_params.connect }
                )
            end

            mathplot.gui.validate_screen_form(playername, identifier, newfields, context, {
                    validator_function = validate_parametric,
                    success_callback = function(playername, identifier, validated_params, context)
                        if not context.is_erase then
                            local nodemeta = minetest.get_meta(validated_params.origin_pos)
                            nodemeta:set_string(identifier .. "_params", minetest.serialize(validated_params))
                        end

                        return mathplot.plot_parametric(validated_params, playername)
                    end
                })
        elseif fields.btn_to_curve or fields.btn_to_surface or fields.btn_to_solid then
            local screenIdentifier = fields.btn_to_curve and "parametric_curve" or fields.btn_to_surface and "parametric_surface" or fields.btn_to_solid and "parametric_solid" or nil
            local nodename = mathplot.gui.get_brushes(playername, { "brush" })["brush"]
            local newfields = mathplot.util.merge_tables(
                default_params(screenIdentifier),
                fields,
                { origin_pos = context.node_pos, nodename = nodename }
            )
            context.screen_params = newfields
            mathplot.gui.invoke_screen(screenIdentifier, playername, context)
        end
    end
}


mathplot.gui.screens["parametric_curve"] = parametric_screen;
mathplot.gui.screens["parametric_surface"] = parametric_screen;
mathplot.gui.screens["parametric_solid"] = parametric_screen;
