# GrM Spoon

## TODO

### Window management

```lua
hs.grid.setGrid('3x3')
hs.grid.setMargins({0, 0}) -- No space between windows
hs.window.animationDuration = 0 -- Instant move

local hyper = {}

hs.hotkey.bind(hyper, "F", function()
    hs.grid.set(hs.window.focusedWindow(), '0,0 3x3')
end)

hs.hotkey.bind(hyper, "Left", function()
    hs.grid.set(hs.window.focusedWindow(), '0,0 1.5x3')
end)

hs.hotkey.bind(hyper, "Right", function()
    hs.grid.set(hs.window.focusedWindow(), '1.5,0 1.5x3')
end)

hs.hotkey.bind(hyper, "C", function()
    hs.grid.set(hs.window.focusedWindow(), '0.5,0 2x3')
end)

hs.hotkey.bind(hyper, "N", function()
    local win = hs.window.focusedWindow()
    win:moveToUnit(hs.layout.right50) -- Hack to force refresh
    win:moveWindowToScreen(win:screen():next())
end)
```
