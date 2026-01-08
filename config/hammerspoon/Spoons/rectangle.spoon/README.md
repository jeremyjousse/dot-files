# rectangle Spoon

A Hammerspoon Spoon to move and resize windows in macOS using keyboard shortcuts. This Spoon aims to reproduce some of the functionality of the popular [Rectangle app](https://rectangleapp.com/).

## Installation

1.  Download the latest version of the Spoon.
2.  Unzip the downloaded file. This will give you `rectangle.spoon`.
3.  Move `rectangle.spoon` to `~/.hammerspoon/Spoons/`.
4.  Load the Spoon in your `init.lua`:

```lua
hs.loadSpoon("rectangle")
```

## Usage

Once loaded, the Spoon provides a set of keyboard shortcuts to manipulate the focused window. The default leader key combination is `Cmd+Alt+Ctrl`.

### Default Shortcuts

*   **Leader + h**: Left half
*   **Leader + l**: Right half
*   **Leader + k**: Top half
*   **Leader + j**: Bottom half
*   **Leader + f**: Maximize
*   **Leader + u**: Top-left corner
*   **Leader + i**: Top-right corner
*   **Leader + n**: Bottom-left corner
*   **Leader + m**: Bottom-right corner
*   **Leader + c**: Center window
*   **Leader + →**: Move to next screen
*   **Leader + ←**: Move to previous screen

## Configuration

You can customize the Spoon's behavior by setting properties on the Spoon object in your `init.lua`.

```lua
local rectangle = hs.loadSpoon("rectangle")

-- Example: Change the leader key
rectangle.leaderKey = {"cmd", "alt"}

-- Example: Change a specific hotkey
rectangle.hotkeys.left = "left"
rectangle.hotkeys.right = "right"

-- After changing configuration, you need to start the spoon
rectangle:init()
rectangle:start()
```

### Configurable Properties

*   `leaderKey`: A table of modifier keys for the hotkeys. Default: `{"cmd", "alt", "ctrl"}`.
*   `gridSize`: The grid size for `hs.grid`. Default: `"6x6"`.
*   `animationDuration`: Window animation duration. Default: `0`.
*   `hotkeys`: A table mapping actions to key strings.
