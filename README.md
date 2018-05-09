# 6raphical User Interface
A GUI module for LÖVE 11.x. Starts with a 6 because, hopefully, it'll be usable by the 6th anniversary of me coding my first GUI library which I've been using until yesterday, when I finally caved in and started a new one from scratch. Damn, I was NOT good at coding then. Then again, I'm not now either.

## Usage
Because the lib is still in development, usage isn't yet completely defined. This snippet is what I'd like it to look like though:
```lua
local Gui = require "src" -- you can move/rename the folder, making it require "lib.gui" for example
local gui = Gui()

local b = gui:add("button", 100, 100, "Click me!")
b:setCallback(function() error("Happy now?") end)

love.update = function(dt)
  gui:update(dt)
end

love.draw = function()
  gui:draw()
end

love.mousepressed = function(x, y, b)
  gui:mousepressed(x, y, b)
end

love.mousereleased = function(x, y, b)
  gui:mousereleased(x, y, b)
end
--and so on
```
