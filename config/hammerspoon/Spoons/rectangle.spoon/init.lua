--- === rectangle ===
---
--- Move and resize windows in macOS using keyboard shortcuts.
--- Aims to reproduct Rectangle app functionality.
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/rectangle.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/rectangle.spoon.zip)

local obj = {}
local mt = {
    __index = function(_, k) return rawget(obj, k) end,
    __newindex = function(t, k, v)
        rawset(obj, k, v)
        if t._init_done and t._attribs[k] then
            if t.stop then t:stop() end
            if t.init then t:init() end
            if t.start then t:start() end
        end
    end
}
setmetatable(obj, mt)
obj.__index = obj

-- Metadata
obj.name = "rectangle"
obj.version = "0.1"
obj.author = "Gemini"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.homepage = "https://github.com/Hammerspoon/Spoons"

obj._init_done = false
obj.logger = hs.logger.new(obj.name)

-- Default attributes
obj._attribs = {
    leaderKey = {"cmd", "alt", "ctrl", "shift"},
    -- leaderKey = {"cmd", "alt"},
    gridSize = "6x6",
    animationDuration = 0,
    hotkeys = {
        left = "left",
        right = "right",
        up = "up",
        down = "down",
        maximize = "space",
        topLeft = "u",
        topRight = "i",
        bottomLeft = "n",
        bottomRight = "m",
        center = "c",
        -- nextScreen = "right",
        -- prevScreen = "left"
    }
}
for k, v in pairs(obj._attribs) do obj[k] = v end

obj.bound_hotkeys = {}

local actions = {
    left = function(win) hs.grid.set(win, {x=0, y=0, w=3, h=6}) end,
    right = function(win) hs.grid.set(win, {x=3, y=0, w=3, h=6}) end,
    up = function(win) hs.grid.set(win, {x=0, y=0, w=6, h=3}) end,
    down = function(win) hs.grid.set(win, {x=0, y=3, w=6, h=3}) end,
    maximize = function(win) win:maximize() end,
    topLeft = function(win) hs.grid.set(win, {x=0, y=0, w=3, h=3}) end,
    topRight = function(win) hs.grid.set(win, {x=3, y=0, w=3, h=3}) end,
    bottomLeft = function(win) hs.grid.set(win, {x=0, y=3, w=3, h=3}) end,
    bottomRight = function(win) hs.grid.set(win, {x=3, y=3, w=3, h=3}) end,
    center = function(win) win:centerOnScreen() end,
    nextScreen = function(win) win:moveOneScreenEast() end,
    prevScreen = function(win) win:moveOneScreenWest() end
}

function obj:init()
    hs.grid.setGrid(self.gridSize)
    hs.grid.setMargins({0, 0})
    hs.window.animationDuration = self.animationDuration
    self._init_done = true
    self.logger.i("initialized")
    return self
end

function obj:start()
    self:stop() -- Clear any existing bindings
    for action, key in pairs(self.hotkeys) do
        if actions[action] then
            local hotkey = hs.hotkey.bind(self.leaderKey, key, function()
                local win = hs.window.focusedWindow()
                if win then actions[action](win) end
            end)
            if hotkey then
                table.insert(self.bound_hotkeys, hotkey)
            else
                self.logger.w("Failed to bind hotkey for action: " .. action .. " with key: " .. key)
            end
        end
    end
    self.logger.i("started")
    return self
end

function obj:stop()
    for _, hotkey in ipairs(self.bound_hotkeys) do
        hotkey:delete()
    end
    self.bound_hotkeys = {}
    self.logger.i("stopped")
    return self
end

return obj
