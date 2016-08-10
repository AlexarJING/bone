local core = require 'gui.core'

-- default widget drawing function
local function default_draw(state, title, x,y,w,h)
	local c = core.color[state]
	if state ~= 'normal' then
		love.graphics.setColor(c.fg)
		love.graphics.rectangle('fill', x+3,y+3,w,h)
	end
	love.graphics.setColor(c.bg)
	love.graphics.rectangle('fill', x,y,w,h)
	love.graphics.setColor(c.fg)
	local f = love.graphics.getFont() -- font must be set!
	love.graphics.print(title, x + (w-f:getWidth(title))/2, y + (h-f:getHeight(title))/2)
end

local function pic_draw(state, title, x,y,w,h,pic_norm,pic_hot,pic_active)
	local color = {
	normal = {bg = {128,128,128,200}, fg = {200,200,200,200}},
	hot    = {bg = {145,153,153,200}, fg = {255,255,255,255}},
	active = {bg = {145,153,153,255}, fg = {255,255,255,200}}
	}
	local c = color[state]
	if state ~= 'normal'  then
		love.graphics.setColor(c.bg)
		love.graphics.rectangle('fill', x+3,y+3,w,h)
	end
	love.graphics.setColor(c.fg)
	love.graphics.draw(pic_norm,x,y,0,w/pic_norm:getWidth(),h/pic_norm:getHeight())
	local f = love.graphics.getFont() -- font must be set!
	love.graphics.print(title, x + (w-f:getWidth(title))/2, y + (h-f:getHeight(title))/2)
end



-- the widget
return function(title, x,y, w,h,pic_norm,pic_hot,pic_active,state)
	-- Generate unique identifier for gui state update and querying.
	local id = core.generateID()

	-- The widget state can be:
	--   hot (mouse over widget),
	--   active (mouse pressed on widget) or
	--   normal (mouse not on widget and not pressed on widget).
	--
	-- core.updateState(id, x,y,w,h) updates the state for this widget.

	core.updateState(id, x,y,w,h)

	-- core.registerDraw(id, drawfunction, drawfunction-arguments...)
	-- shows widget when core.draw() is called.
	if pic_norm~=nil then 
		core.registerDraw(id, pic_draw,state ,title,x,y,w,h,pic_norm,pic_hot,pic_active)
	else
	 	core.registerDraw(id, default_draw,state ,title,x,y,w,h)   
	end
	-- The mouse-released event on the widget can be queried by checking the
	-- following:
	if state~=nil then return false end

	return not core.mouse.down and core.isHot(id) and core.isActive(id)
end

