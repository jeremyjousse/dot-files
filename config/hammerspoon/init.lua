-- Add a chooser hs.chooser listing all actions and allowing to search and execute them

-- Window management helpers
function toggleFullScreen()
    local win = hs.window.focusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()
        f.x = max.x
        f.y = max.y
        f.w = max.w
        f.h = max.h
        win:setFrame(f)
    end
end

function moveToLeftHalf()
    local win = hs.window.focusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()
        f.x = max.x
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h
        win:setFrame(f)
    end
end

function moveToRightHalf()
    local win = hs.window.focusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()
        f.x = max.x + (max.w / 2)
        f.y = max.y
        f.w = max.w / 2
        f.h = max.h
        win:setFrame(f)
    end
end

function moveToTopHalf()
    local win = hs.window.focusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()
        f.x = max.x
        f.y = max.y
        f.w = max.w
        f.h = max.h / 2
        win:setFrame(f)
    end
end

function moveToBottomHalf()
    local win = hs.window.focusedWindow()
    if win then
        local f = win:frame()
        local screen = win:screen()
        local max = screen:frame()
        f.x = max.x
        f.y = max.y + (max.h / 2)
        f.w = max.w
        f.h = max.h / 2
        win:setFrame(f)
    end
end

function showHelp()
    hs.alert.show("Help: Use Shift+Ctrl+Alt+Cmd + [D, H, W] to navigate or ? for this help.", 5)
end


local display = {
    { key = "F", name = "Full screen", action = "toggleFullScreen" },
    { key = "L", name = "Left half", action = "moveToLeftHalf" },
    { key = "R", name = "Right half", action = "moveToRightHalf" },
    { key = "U", name = "Top half", action = "moveToTopHalf" },
    { key = "D", name = "Bottom half", action = "moveToBottomHalf" },
}

local app = {
    { key = "C", name = "Google Chrome", path = "/Applications/Google Chrome.app" },
    { key = "O", name = "Obsidian", path = "/Applications/Obsidian.app" },
    { key = "T", name = "Terminal", path = "/Applications/Ghostty.app" },
}

local browse = {
    { key = "G", name = "Google", link = "https://www.google.com"}
}

local code = {
    { key = "D", name = "discory", path = "~/Development/Personal/discory", github = "jeremyjousse/discory" },
    { key = "F", name = "dot-files", path = "~/Development/Personal/dot-files", github = "jeremyjousse/dot-files" },
    { key = "P", name = "places", path = "~/Development/Personal/place-view" , github = "jeremyjousse/place-view"},
    { key = "B", name = "places (Xcode)", path = "~/Development/Personal/place-view/swift-app", app = "Xcode" },
    { key = "W", name = "website", path = "~/Development/Personal/website" , github = "jeremyjousse/website"},
    { key = "G", name = "Toggle GitHub Mode", action = "toggleGithub" },
}

local folder = {
    { key = "A", name = "Applications", path = "/Applications" },
    { key = "C", name = "Code", path = "~/Development" },
    { key = "D", name = "Documents", path = "~/Documents" },
    { key = "T", name = "Downloads", path = "~/Downloads" },
}

local home = {
    { key = "A", name = "App", child = app},
    { key = "B", name = "Browse", child = browse},
    { key = "C", name = "Code", child = code},
    { key = "F", name = "Folder", child = folder}
}



local workConfigPath = hs.configdir .. "/professional.lua"

if hs.fs.attributes(workConfigPath) then
    dofile(workConfigPath)
end

local root = {
    { key = "D", name = "Display", child = display },
    { key = "H", name = "Home", child = home },
    { key = "?", name = "Help", action = "showHelp" },
}

if work then
    table.insert(root, { key = "W", name = "Work", child = work })
end

local hyperKey = {"ctrl", "alt", "cmd", "shift"}

hs.alert.show("Config Loaded", 1)

-- Load GrM Spoon
hs.loadSpoon("GrM")

-- Configure GrM Spoon
spoon.GrM:start(root, hyperKey)



