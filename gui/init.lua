local gui={
	core     = require("gui.core"),
	Button   = require("gui.button"),
	Slider   = require("gui.slider"),
	Slider2D = require("gui.slider2d"),
	Label    = require("gui.label"),
}


local ui={}

ui.objs={}
ui.index=0
ui.fontSize_Norm=20
ui.groups={}


function ui:reset()
	self.objs={}
	self.index=0
	self.fontSize_Norm=20
	self.groups={}
end
--[[ 颜色格式 需要更新core.color
color = {
	normal = {bg = {128,128,128,200}, fg = {59,59,59,200}},
	hot    = {bg = {145,153,153,200}, fg = {60,61,54,200}},
	active = {bg = {145,153,153,255}, fg = {60,61,54,255}}
}
]]
--[[
	mouse        = mouse,
	generateID   = generateID,
	setHot       = setHot,
	setActive    = setActive,
	isHot        = isHot,
	isActive     = isActive,
	updateState  = updateState,
]]
function ui:setColor(color)
	core.color=color
end

function ui:creatGroup()
	local group={}
	table.insert(self.groups,group)
	return self.groups[#self.groups]
end

function ui:addToGroup(obj,group)
	obj.group=group
	table.insert(group,obj)
end

function ui:groupHide(group)
	for i,v in ipairs(group) do
		v.visible=false
	end
end

function ui:groupShow(group)
	for i,v in ipairs(group) do
		v.visible=true
	end
end	

function ui:groupReset(group)
	for i,v in ipairs(group) do
		v.state=nil
	end
end	
function ui:addButton(title,x,y,w,h,callback)
	local obj={
		ui_type="button",
		title=title,
		x=x,
		y=y,
		w=w,
		h=h,
		img_norm=nil,
		img_act=nil,
		img_hot=nil,
		visible=true,
		callback=callback,
		state=nil
	}
	self.index=self.index+1
	obj.index=self.index
	table.insert(self.objs,obj)
	return self.objs[self.index],self.index
end

function ui:addButtonFromImg(title,img,x,y,callback,w,h)
	local obj={
		ui_type="button",
		title=title,
		x=x,
		y=y,
		w=w or img:getWidth(),
		h=h or img:getHeight(),
		img_norm=img,
		img_act=nil,
		img_hot=nil,
		visible=true,
		callback=callback,
		state=nil
	}
	self.index=self.index+1
	obj.index=self.index
	table.insert(self.objs,obj)
	return self.objs[self.index],self.index
end
function ui:addLabel(txt,x,y) --跟字体大小有关
	local obj={
		ui_type="label",
		txt=txt,
		x=x,
		visible=true,
		y=y,
	}
	self.index=self.index+1
	obj.index=self.index
	table.insert(self.objs,obj)
	return self.objs[self.index],self.index
end

function ui:addSlider(value,min,max,x,y,w,h,callback)
	local obj={
		ui_type="slider",
		value=value,
		min=min,
		max=max,
		x=x,
		y=y,
		w=w,
		h=h,
		visible=true,
		callback=callback
	}
	self.index=self.index+1
	obj.index=self.index
	table.insert(self.objs,obj)
	return self.objs[self.index],self.index
end

function ui:update()
	for i,v in ipairs(self.objs) do
		if v.visible==true then
			if v.ui_type=="label" then
				gui.Label(v.txt,v.x,v.y)
			elseif v.ui_type=="button" then
				local test=gui.Button(v.title,v.x,v.y,v.w,v.h,v.img_norm,v.img_hot,v.img_act,v.state)
				if test then
					if v.state==nil then 
						v.callback(v)
					end
				end
			elseif v.ui_type=="slider" then
				
				local tab={
					value=v.value,
					min=v.min,
					max=v.max
				}
				if gui.Slider(tab,v.x,v.y,v.w,v.h) then
					v.callback(v)
				end
				v.value=tab.value
			end
		end
	end
end

function ui:draw()
	gui.core.draw()
end

function ui:delete(obj)
	table.remove(self.objs, obj.index)
	local id
	for i,v in ipairs(obj.group) do
		if v==obj then id=i end
	end
	table.remove(obj.group,id)
	self.index=self.index-1
end 

function ui:汉化()
	ui.添加按钮=ui.addButton
	ui.添加图片按钮=ui.addButtonFromImg
	ui.添加滑动条=ui.addSlider
	ui.添加标签=ui.addLabel
	ui.删除=ui.delete
	ui.更新=ui.update
	ui.绘制=ui.draw
	ui.设置颜色=ui.setColor
end

return ui