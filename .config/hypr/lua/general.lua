local colors = require("colors.colors")

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 6,

        border_size = 2,

        col = {
            active_border = colors.outline,
            inactive_border = colors.outline_variant,
        },

        allow_tearing = true,
        resize_on_border = false,

        layout = "scrolling",
    },

    dwindle = {
        preserve_split = true,
        force_split = 2,
    },

    scrolling = {
        column_width = 0.8,
        follow_focus = 1,
        focus_fit_method = 0
    },
})
