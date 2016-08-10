class=require "middleclass"
gui = require "gui"
tween=require "tween"
Role = require "role"
editor= require "editor"




function love.load() 
    love.graphics.setBackgroundColor(200, 200,200) 
end


function love.draw()
    editor:draw()
    gui:draw()
end
function love.update(dt)  
   editor:update(dt)
   gui:update()
end 

function love.keypressed(key,isrepeat) 
   
end

function love.mousereleased(x, y, button)

end

function love.mousepressed(x,y,button) 
    if button=="l" then
        editor:clicked()
    end
end 

function love.keyreleased(key)
    editor:pressed(key)
end

function love.textinput(text)
   
end

--[[ 这些放在游戏场景中

function love.draw()
    
end



function love.mousereleased(x, y, button)
    loveframes.mousereleased(x, y, button)
end

function love.keypressed(key, isrepeat) 
    loveframes.keypressed(key, isrepeat)
end

function love.keyreleased(key)
    loveframes.keyreleased(key) 
end

function love.textinput(text)
    loveframes.textinput(text)
end

]]





--[[
function love.quit() --Callback function triggered when the game is closed.
end 
function love.resize(w,h) --Called when the window is resized.
end 
function love.textinput(text) --Called when text has been entered by the user.
end 
function love.threaderror(thread, err ) --Callback function triggered when a Thread encounters an error.
end 
function love.visible() --Callback function triggered when window is shown or hidden.
end 
function love.mousefocus(f)--Callback function triggered when window receives or loses mouse focus.
end
function love.mousepressed(x,y,button) --Callback function triggered when a mouse button is pressed.
end 
function love.mousereleased(x,y,button)--Callback function triggered when a mouse button is released.
end 
function love.errhand(err) --The error handler, used to display error messages.
end 
function love.focus(f) --Callback function triggered when window receives or loses focus.
end 
function love.keypressed(key,isrepeat) --Callback function triggered when a key is pressed.
end
function love.keyreleased(key) --Callback function triggered when a key is released.
end 
function love.run() --The main function, containing the main loop. A sensible default is used when left out.
end
]]