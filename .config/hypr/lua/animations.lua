hl.curve("fastSpatial", {
    type = "bezier",
    points = { {0.27, 1.04}, {0.18, 1.00} }
})

hl.curve("fastEffect", {
    type = "bezier",
    points = { {0.31, 0.94}, {0.34, 1.00} }
})

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 3.5,
    bezier = "fastSpatial",
    style = "slide"
})

hl.animation({
    leaf = "border",
    enabled = true,
    speed = 1.5,
    bezier = "fastEffect"
})

hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 1.5,
    bezier = "fastEffect"
})

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 4,
    bezier = "fastSpatial",
    style = "slidevert"
})

hl.animation({
    leaf = "monitorAdded",
    enabled = true,
    speed = 1.5,
    bezier = "fastEffect"
})

hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 1.5,
    bezier = "fastEffect",
    style = "fade"
})
