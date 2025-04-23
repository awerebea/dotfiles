-- Config toggle
local minimizeOnRepeat = false -- Set to true to enable minimize-on-repeat

-- Move window to next screen
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "Right", function()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  local nextScreen = win:screen():next()
  win:moveToScreen(nextScreen)
end)

-- Move window to previous screen
hs.hotkey.bind({ "ctrl", "alt", "cmd" }, "Left", function()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  local prevScreen = win:screen():previous()
  win:moveToScreen(prevScreen)
end)

-- App hotkeys
-- stylua: ignore
local appHotkeys = {
  { mods = { "cmd", "alt" }, key = "x", app = "kitty",             path = "/Applications/kitty.app",              bundleID = "net.kovidgoyal.kitty" },
  { mods = { "cmd", "alt" }, key = "c", app = "Google Chrome",     path = "/Applications/Google Chrome.app",      bundleID = "com.google.Chrome" },
  { mods = { "cmd", "alt" }, key = "f", app = "Firefox",           path = "/Applications/Firefox.app",            bundleID = "org.mozilla.firefox" },
  { mods = { "cmd", "alt" }, key = "v", app = "Code",              path = "/Applications/Visual Studio Code.app", bundleID = "com.microsoft.VSCode" },
  { mods = { "cmd", "alt" }, key = "q", app = "Calculator",        path = "/System/Applications/Calculator.app",  bundleID = "com.apple.calculator" },
  { mods = { "cmd", "alt" }, key = "s", app = "Slack",             path = "/Applications/Slack.app",              bundleID = "com.tinyspeck.slackmacgap" },
  { mods = { "cmd", "alt" }, key = "o", app = "Obsidian",          path = "/Applications/Obsidian.app",           bundleID = "md.obsidian" },
  { mods = { "cmd", "alt" }, key = "b", app = "Bitwarden",         path = "/Applications/Bitwarden.app",          bundleID = "com.bitwarden.desktop" },
  { mods = { "cmd", "alt" }, key = "k", app = "KeePassXC",         path = "/Applications/KeePassXC.app",          bundleID = "org.keepassx.keepassxc" },
  { mods = { "cmd", "alt" }, key = "u", app = "Microsoft Outlook", path = "/Applications/Microsoft Outlook.app",  bundleID = "com.microsoft.Outlook" },
  { mods = { "cmd", "alt" }, key = "e", app = "TextEdit",          path = "/System/Applications/TextEdit.app",    bundleID = "com.apple.TextEdit" },
  { mods = { "cmd", "alt" }, key = "z", app = "zoom.us",           path = "/Applications/zoom.us.app" },
}

for _, item in ipairs(appHotkeys) do
  hs.hotkey.bind(item.mods, item.key, function()
    local app = hs.application.get(item.app)

    local function launchApp()
      if item.path and hs.fs.attributes(item.path) then
        hs.task.new("/usr/bin/open", nil, { "-a", item.path }):start()
      elseif item.bundleID then
        hs.application.launchOrFocusByBundleID(item.bundleID)
      else
        hs.application.launchOrFocus(item.app)
      end
    end

    if not app then
      launchApp()
      return
    end

    local windows = app:allWindows()
    local targetWindow = nil

    for _, win in ipairs(windows) do
      if win:isStandard() then
        targetWindow = win
        break
      end
    end

    if targetWindow then
      if targetWindow:isMinimized() then
        targetWindow:unminimize()
        hs.timer.doAfter(0.1, function()
          app:activate()
          app:unhide()
          targetWindow:focus()
        end)
      elseif app:isFrontmost() then
        if minimizeOnRepeat then
          targetWindow:minimize()
        end
        -- else do nothing
      else
        app:activate()
        app:unhide()
        targetWindow:focus()
      end
    else
      app:activate()
      app:unhide()
    end
  end)
end
