require("hs.ipc")

-- Settings

hs.grid.setGrid('2x2')

-- Local Variables

local defaultHotkeys = {"cmd", "alt", "ctrl"}

-- Calculations

function halfScreenRect(originX)
   local screen = screen()
   local x = originX
   local y = screen.y
   local w = screen.w/2
   local h = screen.h
   return hs.geometry.rect(x,y,w,h)
end

-- Helpers

function reloadHammerspoon(files)
   doReload = false
   for _,file in pairs(files) do
      if file:sub(-4) == ".lua" then
	 doReload = true
      end
   end
   if doReload then
      hs.reload()
   end
end

-- System Notifications

function showNotification(title, text)
   hs.notify.new({title=title, informativeText=text}):send()
end

function showAlert(text)
   hs.alert.show(text)
end

-- Window Management

function screen()
   return hs.window.focusedWindow():screen():frame()
end

function moveFocusedWindow(amountX, amountY)
   local window = hs.window.focusedWindow()
   local f = window:frame()
   f.x = f.x + amountX
   f.y = f.y + amountY
   window:setFrame(f)
end

function setFocusedWindowFrame(rect)
   local window = hs.window.focusedWindow()
   local f = window:frame()
   f.x = rect.x
   f.y = rect.y
   f.w = rect.w
   f.h = rect.h
   window:setFrame(f)
end

function windowRight ()
   local screen = screen()           
   local middleX = screen.x + screen.w/2
   setFocusedWindowFrame(halfScreenRect(middleX))
end

function windowLeft ()
   local screen = screen()
   local x = screen.x
   setFocusedWindowFrame(halfScreenRect(x))
end

function windowMax ()
   local screen = screen()
   local newRect = hs.geometry.rect(screen.x, screen.y, screen.w, screen.h)
   setFocusedWindowFrame(newRect)
end

-- Emacs

function toggleEmacs ()
   local window = hs.window.focusedWindow()
   local application = window:application()
   local focused = application:name() == "Emacs"
   
   if not focused then
      hs.execute("open /Applications/Emacs.app")
   else
      application:hide()
   end
end

-- Mouse Drawing

function mouseHighlight()
   local mousePoint = hs.mouse.getAbsolutePosition()
   local mouseCircle = hs.drawing.circle(hs.geometry.rect(mousePoint.x - 40, mousePoint.y - 40, 80, 80))
   mouseCircle:setStrokeColor({["red"]=1, ["blue"]=0, ["green"]=0, ["alpha"]=1})
   mouseCircle:setFill(false)
   mouseCircle:setStrokeWidth(2)
   mouseCircle:show()

   hs.timer.doAfter(2, function() mouseCircle:delete() end)
end

-- Key Bindings

hs.hotkey.bind(
   {"shift", "ctrl"}, "m", function()
      windowMax()
end)

hs.hotkey.bind(
   defaultHotkeys, "Left", function()
      windowLeft()
end)

hs.hotkey.bind(
   defaultHotkeys, "Right", function()
      windowRight()
end)

hs.hotkey.bind(
   defaultHotkeys, "j", function()
      hs.grid.show()
end)

hs.hotkey.bind(
   {}, "f7", function()
      hs.execute("open /Applications/Emacs.app")
end)

-- hs.hotkey.bind(
   -- {"ctrl"}, "`", function()
      -- toggleEmacs()
-- end)

-- atreus specific

hs.hotkey.bind(
   {},"f1", function()
      windowLeft()
end)

hs.hotkey.bind(
   {},"f2", function()
      windowRight()
end)

hs.hotkey.bind(
   {},"f3", function()
      windowMax()
end)

hs.hotkey.bind(
   {}, "f7", function()
      hs.execute("open /Applications/Emacs.app")
end)


-- Pathwatchers

hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadHammerspoon):start()
hs.pathwatcher.new(os.getenv("HOME") .. "/.bash_profile", function() hs.execute("source ~/.bash_profile") end):start()

-- USB Events

function usbDeviceCallback(data)
   print("")
   print("Event type: " .. data["eventType"])
   print("Product name: " .. data["productName"])
   print("Vendor name: " .. data["vendorName"])
   print("Vendor ID: " .. data["vendorID"])
   print("Product ID: " .. data["productID"])
end

function controllerDeviceCallback(data)
   if (data["productName"] == "Wireless Controller" or data["productName"] == "USB,2-axis 8-button gamepad  ") then
      if (data["eventType"] == "added") then
	 hs.application.launchOrFocus("OpenEmu")
      end
   end
end
      

usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
usbWatcher:start()

controllerWatcher = hs.usb.watcher.new(controllerDeviceCallback)
controllerWatcher:start()

-- Location Events

function currentCoordinates()
   local coords = hs.location.get()
   print("\nCurrent Location:")
   print("Lat: " .. coords["latitude"])
   print("Lng: " .. coords["longitude"])
end
--// hs.location.start()

-- Wifi Helpers

function availableNetworks()
   for k,v in pairs(hs.wifi.availableNetworks()) do
      print(k, v)
   end
end

function interfaces()
   for k,v in pairs(hs.wifi.interfaces()) do
      print(k, v)
   end
end

-- url events

hs.urlevent.bind(
   "networks", function(eventname, params)
      availableNetworks()
      local output = hs.console.getConsole()
      hs.execute("echo done >> ~/temp.txt && open ~/temp.txt")
end)

showAlert("Hammerspoon config reloaded")
-- end
