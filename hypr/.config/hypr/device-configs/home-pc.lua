hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@120",
    position = "0x1080",
    scale    = "auto",
})

hl.monitor({
    output   = "DP-3",
    mode     = "1920x1080@60",
    position = "320x0",
    scale    = "auto",
})

hl.monitor({
    output   = "DP-2",
    mode     = "1920x1080@60",
    position = "2560x1260",
    scale    = "auto",
})


for i = 1, 3 do
    hl.workspace_rule({
        workspace  = i,
        monitor    = "DP-1",
        persistent = true,
    })
end
