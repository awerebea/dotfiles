-- Enable the `hs` command-line tool
require("hs.ipc")

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
local home = os.getenv("HOME")

-- Per-machine overrides, keyed by LocalHostName (scutil --get LocalHostName)
local hostName = (hs.execute("scutil --get LocalHostName"):gsub("%s+$", ""))
local workHosts = { ["BULGAKA-ML01"] = true }
local isWorkMac = workHosts[hostName:upper()] == true

-- stylua: ignore
local apps = {
  kitty     = { name = "kitty",           path = "/Applications/kitty.app",                         bundleID = "net.kovidgoyal.kitty" },
  brave     = { name = "Brave Browser",   path = "/Applications/Brave Browser.app",                 bundleID = "com.brave.Browser" },
  chrome    = { name = "Google Chrome",   path = "/Applications/Google Chrome.app",                 bundleID = "com.google.Chrome" },
  firefox   = { name = "Firefox",         path = "/Applications/Firefox.app",                       bundleID = "org.mozilla.firefox" },
  vscode    = { name = "Code",            path = "/Applications/Visual Studio Code.app",            bundleID = "com.microsoft.VSCode" },
  qalculate = { name = "qalculate-qt",    path = "/opt/homebrew/opt/qalculate-qt/qalculate-qt.app", bundleID = "com.yourcompany.qalculate-qt" },
  slack     = { name = "Slack",           path = "/Applications/Slack.app",                         bundleID = "com.tinyspeck.slackmacgap" },
  obsidian  = { name = "Obsidian",        path = "/Applications/Obsidian.app",                      bundleID = "md.obsidian" },
  keepassxc = { name = "KeePassXC",       path = "/Applications/KeePassXC.app",                     bundleID = "org.keepassxc.keepassxc" },
  excel     = { name = "Microsoft Excel", path = "/Applications/Microsoft Excel.app",               bundleID = "com.microsoft.Excel" },
  zoom      = { name = "zoom.us",         path = "/Applications/zoom.us.app",                       bundleID = "us.zoom.xos" },
  claude    = { name = "Claude",          path = "/Applications/Claude.app",                        bundleID = "com.anthropic.claudefordesktop" },
  telegram  = { name = "Telegram",        path = "/Applications/Telegram.app",                      bundleID = "ru.keepcoder.Telegram" },
  chatgpt   = { name = "ChatGPT",         path = "/Applications/ChatGPT.app",                       bundleID = "com.openai.codex" },
  gmail     = { name = "Gmail",           path = home .. "/Applications/Brave Browser Apps.localized/Gmail.app" },
}

-- Per-environment apps sharing the same hotkey
local envApps = {
  personal = {
    primaryBrowser = apps.brave,
    backupBrowser = apps.chrome,
  },
  work = {
    primaryBrowser = apps.brave,
    backupBrowser = apps.chrome,
  },
}
local env = isWorkMac and "work" or "personal"

-- stylua: ignore
local appHotkeys = {
  { mods = { "cmd", "alt" }, key = "x", app = apps.kitty },
  { mods = { "cmd", "alt" }, key = "c", app = envApps[env].primaryBrowser },
  { mods = { "cmd", "alt" }, key = "b", app = envApps[env].backupBrowser },
  { mods = { "cmd", "alt" }, key = "f", app = apps.firefox },
  { mods = { "cmd", "alt" }, key = "v", app = apps.vscode },
  { mods = { "cmd", "alt" }, key = "q", app = apps.qalculate },
  { mods = { "cmd", "alt" }, key = "s", app = apps.slack },
  { mods = { "cmd", "alt" }, key = "o", app = apps.obsidian },
  { mods = { "cmd", "alt" }, key = "k", app = apps.keepassxc },
  { mods = { "cmd", "alt" }, key = "e", app = apps.excel },
  { mods = { "cmd", "alt" }, key = "z", app = apps.zoom },
  { mods = { "cmd", "alt" }, key = "i", app = apps.claude },
  { mods = { "cmd", "alt" }, key = "t", app = apps.telegram },
  { mods = { "cmd", "alt" }, key = "g", app = apps.chatgpt },
  { mods = { "cmd", "alt" }, key = "m", app = apps.gmail },
}

for _, item in ipairs(appHotkeys) do
  local app = item.app
  hs.hotkey.bind(item.mods, item.key, function()
    -- Prefer bundle ID: the localized app name may differ from app.name
    -- (e.g. zoom.us reports itself as "Zoom").
    -- Avoid hs.application.get(name): it falls back to matching window
    -- titles and can return an hs.window (e.g. a browser tab mentioning the app)
    local runningApp = nil
    if app.bundleID then
      runningApp = hs.application.applicationsForBundleID(app.bundleID)[1]
    end
    if not runningApp then
      for _, a in ipairs(hs.application.runningApplications()) do
        if a:name() == app.name then
          runningApp = a
          break
        end
      end
    end

    local function launchApp()
      if app.path and hs.fs.attributes(app.path) then
        hs.task.new("/usr/bin/open", nil, { "-a", app.path }):start()
      elseif app.bundleID then
        hs.application.launchOrFocusByBundleID(app.bundleID)
      else
        hs.application.launchOrFocus(app.name)
      end
    end

    if not runningApp then
      launchApp()
      return
    end

    local windows = runningApp:allWindows()
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
          runningApp:activate()
          runningApp:unhide()
          targetWindow:focus()
        end)
      elseif runningApp:isFrontmost() then
        if minimizeOnRepeat then
          targetWindow:minimize()
        end
        -- else do nothing
      else
        runningApp:activate()
        runningApp:unhide()
        targetWindow:focus()
      end
    else
      -- No standard window (e.g. hidden to tray): send a reopen event,
      -- same as clicking the Dock icon
      launchApp()
    end
  end)
end
