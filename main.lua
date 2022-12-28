local Gui = require 'src'
local styles = require "styles"
local gui

local font = require "src.utils".font

love.graphics.setBackgroundColor(1/8, 1/8, 1/8)

local res = {
    text = {
        warnings = {"This doesn't work.", "Please tell me those aren't real.", "Do you just give people your data?", "Don't do this.", "You know it says \"fake\", right?"},
    }
}

love.load = function()
    gui = Gui()
    love.keyboard.setKeyRepeat(true)

    local panel = gui:add("panel", 32, 32, 250, 160, styles.panel)

    panel:add("text", 0, 3, "Fake sign-up form", styles.title)

    local margin = 30
    local offset = 5
    panel:add("text", 0, margin * 1, "E-mail:", styles("right", "100w"))
    panel:add("text", 0, margin * 2, "Username:", styles("right", "100w"))
    panel:add("text", 0, margin * 3, "Password:", styles("right", "100w"))
    local warning = panel:add("text", 6, 140, "", styles.warning)
    local button = panel:add("button", 173, 130, "Sign up", styles.rounded3px)
    panel:add("textLine", 106, margin * 1 - offset, 120, button, "nick", styles.rounded2px)
    panel:add("textLine", 106, margin * 2 - offset, 120, button, "pass", styles.rounded2px)
    panel:add("textLine", 106, margin * 3 - offset, 120, button, "mail", styles.rounded2px)
    button.callback = function(children)
        if not (#children.nick.text > 0 and #children.pass.text > 0 and #children.mail.text > 0) then return end
        children.nick:clear()
        children.pass:clear()
        children.mail:clear()
        local n
        repeat
            n = love.math.random(#res.text.warnings)
        until
            res.text.warnings[n] ~= warning.text
        warning.text = res.text.warnings[n]
    end
end

love.update = function(dt)
    gui:update(dt)
end

love.draw = function()
    love.graphics.setColor(1,1,1,1)
    gui:draw()
end

love.mousepressed = function(x, y, b)
    gui:mousepressed(x, y, b)
end

love.mousereleased = function(x, y, b)
    gui:mousereleased(x, y, b)
end

love.wheelmoved = function(dx, dy)
    gui:wheelmoved(dx, dy)
end

love.textinput = function(text)
    gui:textinput(text)
end

love.keypressed = function(key, keycode, isRepeat)
    gui:keypressed(key, keycode, isRepeat)
end

love.keyreleased = function(key, keycode, isRepeat)
    gui:keyreleased(key, keycode, isRepeat)
end