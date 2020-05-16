mathplot.gui.screens = mathplot.gui.screens or {}

local S = mathplot.get_translator

mathplot.gui.screens["examples"] = {
    initialize = function(playername, identifier, context)
    end,
    get_formspec = function(playername, identifier, context)
        local formspec = "size[12.25,9.75]"
        .. string.format("label[0,0;%s]", S("Examples"))
        .. "container[0,1]"
        .. string.format("label[0,0;%s]",S("Implicit Plot"))
        .. string.format("button_exit[0,0.5;3,1;btn_hemisphere;%s]", S("Hemisphere"))
        .. string.format("button_exit[3,0.5;3,1;btn_solid_hemisphere;%s]", S("Solid Hemisphere"))
        .. string.format("button_exit[6,0.5;3,1;btn_cylinder_with_tunnel;%s]", S("Cylinder w/ Tunnel"))
        .. string.format("button_exit[9,0.5;3,1;btn_implicit_cone;%s]", S("Cone"))
        .. "container_end[]"
        .. "container[0,3]"
        .. string.format("label[0,0;%s]",S("Parametric Curve"))
        .. string.format("button_exit[0,0.5;3,1;btn_onevar_ftn_graph;%s]", S("Graph of Function"))
        .. string.format("button_exit[3,0.5;3,1;btn_helix;%s]", S("Helix"))
        .. string.format("button_exit[6,0.5;3,1;btn_coil;%s]", S("Coil"))
        .. string.format("button_exit[9,0.5;3,1;btn_trefoil_knot;%s]", S("Trefoil Knot"))
        .. "container_end[]"
        .. "container[0,5]"
        .. string.format("label[0,0;%s]",S("Parametric Surface"))
        .. string.format("button_exit[0,0.5;3,1;btn_twovar_ftn_graph;%s]", S("Graph of Function"))
        .. string.format("button_exit[3,0.5;3,1;btn_parametric_torus;%s]", S("Torus"))
        .. string.format("button_exit[6,0.5;3,1;btn_surface_of_revolution;%s]", S("Surface of Revolution"))
        .. string.format("tooltip[btn_surface_of_revolution;%s]", S("The surface generated by revolving the graph of y = 5x/6 - x^3/200 about the x-axis, then translated vertically in the z-direction"))
        .. string.format("button_exit[9,0.5;3,1;btn_klein_bottle;%s]", S("Klein Bottle"))
        .. "container_end[]"
        .. "container[0,7]"
        .. string.format("label[0,0;%s]",S("Parametric Solid"))
        .. string.format("button_exit[0,0.5;3,1;btn_thick_twovar_ftn_graph;%s]", minetest.formspec_escape(S("'Thick' Graph")))
        .. string.format("tooltip[btn_thick_twovar_ftn_graph;%s]", S("The graph of a two-variable function, extruded in the z-direction"))
        .. string.format("button_exit[3,0.5;3,1;btn_solid_of_revolution;%s]", S("Solid of Revolution"))
        .. string.format("tooltip[btn_solid_of_revolution;%s]", S("The solid generated by revolving the region between the graphs of x = 3z/10 and x = 5+(z/10)^2 about the z-axis"))
        .. "container_end[]"
        .. string.format("button_exit[0,9;2,1;btn_exit;%s]", S("Exit"))
        return formspec
    end,
    on_receive_fields = function(playername, identifier, fields, context)
        for name, _ in pairs(fields) do
            if string.match(name, "^btn_") then
                local exampleName = string.gsub(name, "^btn_", "")
                local exampleExists = mathplot.examples[exampleName] ~= nil
                if exampleExists then
                    mathplot.examples[exampleName](playername, context.node_pos)
                    break
                end
            end
        end
    end
}

