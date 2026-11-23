local colors = require("colors.colors")

hl.config({
    decoration = {
        rounding = 8,
        rounding_power = 2,

        active_opacity = 0.95,
        inactive_opacity = 0.90,
        fullscreen_opacity = 1,
        dim_special = 0.7,

        shadow = {
            enabled = true,

            range = 4,
            render_power = 4,
            offset = {0, 0},
            color = colors.shadow,
        },

        blur = {
            enabled = true,

            size = 6,
            passes = 2,
            noise = 0.02,

            new_optimizations = true,
            ignore_opacity = true,
            popups = true,
            popups_ignorealpha = 0.5,
            input_methods = true,
			input_methods_ignorealpha = 0.5,
            special = true,
        }
    }
})
