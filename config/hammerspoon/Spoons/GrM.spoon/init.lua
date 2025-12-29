local obj = {}
local activeMode = nil

function obj.scheduleAutoExit(mode, modeName)
    if mode.autoExitTimer then
        mode.autoExitTimer:stop()
    end
    mode.autoExitTimer = hs.timer.doAfter(3, function()
        if activeMode == modeName then
            mode:exit()
            hs.alert.show("Leaving " .. modeName, 2)
        end
    end)
end

function obj:createSelectionMode(title, items, callback)
    local mode = hs.hotkey.modal.new()

    mode.entered = function()
        activeMode = title
        local msg = title .. ":\n"
        if items then
            for _, item in ipairs(items) do
                msg = msg .. (item.key or "?") .. " -> " .. (item.name or "?") .. "\n"
            end
        else
            msg = msg .. "No items defined"
        end
        
        
        hs.alert.show(msg, 3)
        
        
        obj.scheduleAutoExit(mode, title)
    end

    function mode:exited()
        activeMode = nil
    end

    mode:bind({}, "escape", function() mode:exit() end)

    for _, item in ipairs(items) do
        mode:bind({}, item.key, function()
            mode:exit()
            callback(item)
        end)
    end

    return mode
end

return obj