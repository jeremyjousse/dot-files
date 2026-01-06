local obj = {}
obj.__index = obj

-- Metadata
obj.name = "GrM"
obj.version = "1.0"
obj.author = "Jeremy Jousse"
obj.license = "MIT"

local activeMode = nil

function obj.scheduleAutoExit(mode, modeName)
    if mode.autoExitTimer then
        mode.autoExitTimer:stop()
    end
    mode.autoExitTimer = hs.timer.doAfter(5, function()
        if activeMode == modeName then
            mode:exit()
            hs.alert.show("Leaving " .. modeName, 1)
        end
    end)
end

function obj:runAction(item, modeState)
    if item.action == "toggleGithub" then
        modeState = modeState or {}
        modeState.githubMode = not modeState.githubMode
        hs.alert.show("GitHub Mode: " .. (modeState.githubMode and "ON" or "OFF"))
        return false -- do not exit
    end

    local actionExecuted = false

    if item.action and _G[item.action] then
        _G[item.action]()
        actionExecuted = true
    elseif item.github and modeState and modeState.githubMode then
        hs.urlevent.openURL("https://github.com/" .. item.github)
        actionExecuted = true
    elseif item.app then
        hs.application.launchOrFocus(item.app)
        actionExecuted = true
    elseif item.path then
        hs.execute("open " .. item.path)
        actionExecuted = true
    elseif item.link then
        hs.urlevent.openURL(item.link)
        actionExecuted = true
    elseif item.url then
        hs.urlevent.openURL(item.url)
        actionExecuted = true
    end
    
    return actionExecuted
end

function obj:createSelectionMode(title, items)
    local mode = hs.hotkey.modal.new()
    mode.githubMode = false

    mode.entered = function()
        activeMode = title
        local msg = title .. " Mode:\n"
        for _, item in ipairs(items) do
            msg = msg .. (item.key or "?") .. " -> " .. (item.name or "?") .. "\n"
        end
        hs.alert.show(msg, 3)
        obj.scheduleAutoExit(mode, title)
    end

    function mode:exited()
        activeMode = nil
        mode.githubMode = false
    end

    mode:bind({}, "escape", function() mode:exit() end)

    for _, item in ipairs(items) do
        if item.child then
            local subMode = obj:createSelectionMode(item.name, item.child)
            mode:bind({}, item.key, function()
                mode:exit()
                subMode:enter()
            end)
        else
            mode:bind({}, item.key, function()
                local shouldExit = obj:runAction(item, mode)
                if shouldExit then
                    mode:exit()
                else
                    obj.scheduleAutoExit(mode, title)
                end
            end)
        end
    end
    return mode
end

function obj:start(config, hyper)
    hs.hotkey.bind(hyper, "R", function()
      hs.reload()
    end)

    for _, item in ipairs(config) do
        if item.child then
            local mode = self:createSelectionMode(item.name, item.child)
            if item.key == "?" then
                hs.hotkey.bind(hyper, "/", function() mode:enter() end)
            else
                hs.hotkey.bind(hyper, item.key, function() mode:enter() end)
            end
        else
             if item.key == "?" then
                hs.hotkey.bind(hyper, "/", function() self:runAction(item, {}) end)
            else
                hs.hotkey.bind(hyper, item.key, function() self:runAction(item, {}) end)
            end
        end
    end
end

return obj
