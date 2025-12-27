-- Code Mode
local codeMode = hs.hotkey.modal.new()
local codeTimer = nil

local function exitCodeMode()
    codeMode:exit()
    if codeTimer then codeTimer:stop() end
end

local projects = {
    { key = "D", name = "discory", path = "/Users/jerry/Development/Personal/discory" },
    { key = "F", name = "dot-files", path = "/Users/jerry/Development/Personal/dot-files" },
    { key = "P", name = "places", path = "/Users/jerry/Development/Personal/place-view" },
    { key = "B", name = "places (Xcode)", path = "/Users/jerry/Development/Personal/place-view/swift-app", app = "Xcode" },
    { key = "W", name = "website", path = "/Users/jerry/Development/Personal/website" },
}

local function openProject(project)
    exitCodeMode()
    local app = project.app or "Visual Studio Code"
    hs.task.new("/usr/bin/open", nil, {"-a", app, project.path}):start()
    hs.alert.show("Opening " .. project.name)
end

for _, project in ipairs(projects) do
    codeMode:bind({"cmd", "alt"}, project.key, function()
        openProject(project)
    end)
end

hs.hotkey.bind({"cmd", "alt"}, "C", function()
    codeMode:enter()
    local msg = "Code Mode\n\r"
    for _, project in ipairs(projects) do
        msg = msg .. "\n" .. project.key .. ": " .. project.name
    end
    hs.alert.show(msg, 2)
    codeTimer = hs.timer.doAfter(2, exitCodeMode)
end)

codeMode:bind({}, "escape", function()
    exitCodeMode()
    hs.alert.show("Code Mode cancelled")
end)

hs.hotkey.bind({"cmd", "alt"}, "R", function()
	hs.reload()
end)
hs.alert.show("Config loaded")
