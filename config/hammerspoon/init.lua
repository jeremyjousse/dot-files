-- Maybe consider to create a Spoon?
local workConfigPath = hs.configdir .. "/professional.lua"

if hs.fs.attributes(workConfigPath) then
    local status, err = pcall(function() require("professional") end)
    
    if status then
        hs.alert.show("Professional config enabled.")
    else
        hs.alert.show("error loading professional.lua : " .. err)
    end
end

-- Code Mode
local codeMode = hs.hotkey.modal.new()
local codeTimer = nil
local githubMode = false

local function exitCodeMode()
    codeMode:exit()
    if codeTimer then codeTimer:stop() end
    githubMode = false
end

local projects = {
    { key = "D", name = "discory", path = "~/Development/Personal/discory", github = "jeremyjousse/discory" },
    { key = "F", name = "dot-files", path = "~/Development/Personal/dot-files", github = "jeremyjousse/dot-files" },
    { key = "P", name = "places", path = "~/Development/Personal/place-view" , github = "jeremyjousse/place-view"},
    { key = "B", name = "places (Xcode)", path = "~/Development/Personal/place-view/swift-app", app = "Xcode" },
    { key = "W", name = "website", path = "~/Development/Personal/website" , github = "jeremyjousse/website"},
}

local apps = {
    { key = "C", name = "Google Chrome", path = "/Applications/Google Chrome.app" },
    { key = "O", name = "Obsidian", path = "/Applications/Obsidian.app" },
    { key = "T", name = "Terminal", path = "/Applications/Ghostty.app" },
}

local folders = {
    { key = "A", name = "Applications", path = "/Applications" },
    { key = "C", name = "Code", path = "~/Development" },
    { key = "D", name = "Documents", path = "~/Documents" },
    { key = "T", name = "Downloads", path = "~/Downloads" },
}
    
local function openProject(project)
    exitCodeMode()
    local app = project.app or "Visual Studio Code"
    local path = project.path:gsub("^~", os.getenv("HOME"))
    hs.task.new("/usr/bin/open", nil, {"-a", app, path}):start()
    hs.alert.show("Opening " .. project.name)
end

local function openGithub(project)
    exitCodeMode()
    if project.github then
        hs.task.new("/usr/bin/open", nil, {"https://github.com/" .. project.github}):start()
        hs.alert.show("Opening " .. project.name .. " on GitHub")
    else
        hs.alert.show("No GitHub repo for " .. project.name)
    end
end

for _, project in ipairs(projects) do
    codeMode:bind({"ctrl", "alt", "cmd", "shift"}, project.key, function()
        if githubMode then
            openGithub(project)
        else
            openProject(project)
        end
    end)
end

codeMode:bind({"ctrl", "alt", "cmd", "shift"}, "G", function()
    githubMode = not githubMode
    if codeTimer then codeTimer:stop() end
    codeTimer = hs.timer.doAfter(2, exitCodeMode)
    if githubMode then
        hs.alert.show("GitHub Mode Enabled", 2)
    else
        hs.alert.show("GitHub Mode Disabled", 2)
    end
end)

hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "C", function()
    codeMode:enter()
    local msg = "Code Mode\n\r"
    msg = msg .. ("G: GitHub Mode\n\r" or "")
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

hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "R", function()
	hs.reload()
end)


-- Load GrM Spoon

hs.loadSpoon("GrM")

-- Configure GrM Spoon

local appMode = spoon.GrM:createSelectionMode("Apps Mode", apps, function(item)
    hs.task.new("/usr/bin/open", nil, {item.path}):start()
end)

hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "T", function()
    appMode:enter()
end)

local folderMode = spoon.GrM:createSelectionMode("Folders Mode", folders, function(item)
    local path = item.path:gsub("^~", os.getenv("HOME"))
    hs.task.new("/usr/bin/open", nil, {path}):start()
end)

hs.hotkey.bind({"ctrl", "alt", "cmd", "shift"}, "F", function()
    folderMode:enter()
end)