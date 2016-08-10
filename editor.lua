local editor={}
editor.selectPos=1
editor.frames={}
editor.frameSelect=1
editor.t=0
editor.framePage=0
editor.dt={}
-- set frame delete frame run
local f=function() 
	local file = love.filesystem.newFile("save")
	file:open("w")
	file:write(table.save(editor.data))
	file:close()
end
local saveButton=gui:addButton("save",20,10,100,30,f)

local f=function() 
	if love.filesystem.exists("save") then
		local file = love.filesystem.newFile("save")
		file:open("r")
		editor.data=loadstring(file:read())()
		file:close()
		editor:load()
	end
end
local saveButton=gui:addButton("load",130,10,100,30,f)


local f=function() 
	editor.preview=Role:new("preview",editor:generate())
	editor.preview.root.x=600
	editor.preview.root.y=400
end
local generateButton=gui:addButton("generate",240,10,100,30,f)

local f=function() 
	local self=editor
	self.frames[self.frameSelect+self.framePage]=Role:new("frame",self.model:getData())
	self.dt[self.frameSelect+self.framePage]=100
	self.frameSelect=self.frameSelect+1
	if self.frameSelect==8 then
		self.frameSelect=7
		self.framePage=self.framePage+1
	end	
end
local setFrameButton=gui:addButton("set frame",350,10,100,30,f)

local f=function() 
	local self=editor
	self.frames[self.frameSelect+self.framePage]=nil
end
local deleteFrameButton=gui:addButton("delete frame",460,10,100,30,f)

local frameDtLabel=gui:addLabel("frame delta time 1000 ms",570,50)

local f=function(self)
	frameDtLabel.txt="frame delta time "..tostring(math.ceil(self.value*10).." ms")
	editor.dt[editor.frameSelect+editor.framePage]=self.value
end
local frameDtSlider=gui:addSlider(100,1,100,570,10,150,30,f)

local f=function(self) 
	editor.framePage=editor.framePage-1
	if editor.framePage<0 then editor.framePage=0 end
end

local leftButton=gui:addButton("<<",10,100,30,150,f)
local f=function() 
	if editor.framePage<#editor.frames-1 then
		editor.framePage=editor.framePage+1
	else
		return
	end
	for i=1,7 do
		if not editor.frames[i+editor.framePage] then break end
	end
end
local rightButton=gui:addButton(">>",760,100,30,150,f)

local tips=gui:addLabel([[
	TIPS: 
	click the joint to select; 
	drag it to turn; hold ctrl and drag to add a bone to the joint;
	press d to delete a joint and bones; press "~" to add it to a frame; 
	press "enter" to animate the frames
	press 1~7 to locate a frame, press delete to kill a frame
	drag the bar to modify the dt between frames
	you can find the saved file in C:\Users\Administrator\AppData\Roaming\LOVE\bone for example.
	you can hide me by pressing "h"
	enjoy it ! need help? alexar@foxmail.com
	]],80,100)
gui:addLabel("MODEL",180,550)
gui:addLabel("PREVIEW",580,550)

editor.model=Role:new("man",200,400)
local man=editor.model
local body=man:addChild("body",nil,60,math.rad(180))  
local leftArm1=man:addChild("leftArm1",body,40,-math.rad(130)) 
local leftArm2=man:addChild("leftArm2",leftArm1,40,math.rad(-15)) 
local rightArm1=man:addChild("rightArm1",body,40,math.rad(130)) 
local rightArm2=man:addChild("rightArm2",rightArm1,40,-math.rad(-15)) 
local head=man:addChild("head",body,30,math.rad(0))
local leftLeg1=man:addChild("leftLeg1",nil,50,-math.rad(30)) 
local leftLeg2=man:addChild("leftLeg2",leftLeg1,50,math.rad(15)) 
local rightLeg1=man:addChild("rightLeg1",nil,50,math.rad(30)) 
local rightLeg2=man:addChild("rightLeg2",rightLeg1,50,-math.rad(15)) 
head.style="circle"



function getDist(x1,y1,x2,y2)
	return ((x1-x2)^2+(y1-y2)^2)^0.5
end

function getRot(x1,y1,x2,y2,toggle)
	if x1==x2 and y1==y2 then return 0 end 
	local angle=math.atan((x1-x2)/(y1-y2))
	if y1-y2<0 then angle=angle-math.pi end
	if toggle==true then angle=angle+math.pi end
	if angle>0 then angle=angle-2*math.pi end
	if angle==0 then return 0 end
	return -angle
end

function table.copy(st,copyto,ifcopyfunction)
    copyto=copyto or {}
    for k, v in pairs(st or {}) do
        if type(v) == "table" then
            copyto[k] = table.copy(v,copyto[k])          
        elseif type(v) == "function" then 
        	if ifcopyfunction then
        		copyto[k] = v
        	end
        else 
            copyto[k] = v
        end
    end
    return copyto
end


function table.save(tab,name)
    name=name or "test"
    local output="local "..name.."=\n"
    local function ergodic(target,time)
        time=time+1
        output=output.."{\n"
        for k,v in pairs(target) do
            output=output .. string.rep("\t",time)
            if type(v)=="table" then
                if type(k)=="number" then
                    output=output.."["..k.."]".."="
                elseif type(k)=="string" then
                    output=output.."[\""..k.."\"]="
                end 
                ergodic(v,time)
                output=output .. string.rep("\t",time)
                output=output.."},\n"
            elseif type(v)=="string" then
                if type(k)=="number" then
                    output=output.."["..k.."]".."=\""..v.."\",\n"
                elseif type(k)=="string" then
                    output=output.."[\""..k.."\"]=\""..v.."\",\n"
                end 
            elseif type(v)=="number" then
                if type(k)=="number" then
                    output=output.."["..k.."]".."="..v..",\n"
                elseif type(k)=="string" then
                    output=output.."[\""..k.."\"]="..v..",\n"
                end 
            end
        end
    end
    ergodic(tab,0)
    output=output.."}\n return "..name
    return output 
end


function editor:create()
	if not self.selectTab or not self.selectTab[self.selectPos] then return end

	if not love.keyboard.isDown("lctrl") then 
		self.creating=false
		return 
	end

	if love.mouse.isDown("l") then
		self.creating=true
		self.createX,self.createY= love.mouse.getPosition()
	elseif self.creating==true then
		self.creating=false
		local seg=self.model.assets[self.selectTab[self.selectPos]]
		local dist=getDist(seg.x,seg.y,self.createX,self.createY)
		local rad =getRot(self.createX,self.createY,seg.x,seg.y)-seg.real_rot
		self.model:addChild("new",seg,50,rad)
	end		

end



function editor:update(dt)
	self.t=self.t+math.pi*dt
	self.model:update()
	self:drag()
	self:create()
	for k,v in pairs(self.frames) do
		v:update()
	end
	if self.preview then
		self.preview:update(dt)
	end
end

function editor:select()
	local s --为index
	if #self.selectTab>0 then
		s=self.selectTab[self.selectPos]
	end
	for i,v in pairs(self.model.assets) do
		if i==s then
			v.isSelectd=true
		else
			v.isSelectd=false
		end
	end
end


function editor:drag()
	if love.keyboard.isDown("lctrl") or  not self.selectTab then return end
	if  love.mouse.isDown("l") and self.selectTab[self.selectPos] then
		local seg=self.model.assets[self.selectTab[self.selectPos]]
		if seg.type=="root" then
			local x, y = love.mouse.getPosition()
			seg.x=x;seg.y=y
		else
			local x, y = love.mouse.getPosition()
			seg.rot=getRot(x,y,seg.parent.x,seg.parent.y)-seg.parent.real_rot
			if seg.rot<0 then seg.rot=seg.rot+2*math.pi end
		end
	end
end



function editor:clicked()
	if love.keyboard.isDown("lctrl") then return end 
	self.selectMax=0
	self.selectTab={}
	local x, y = love.mouse.getPosition()
	for i,v in pairs(self.model.assets) do
		if getDist(v.x,v.y,x,y)<8 then 
			table.insert(self.selectTab,i)
		end
	end
	if #self.selectTab>0 then
		s=self.selectTab[self.selectPos]
	end
	for i,v in pairs(self.model.assets) do
		if i==s then
			v.isSelected=true
		else
			v.isSelected=false
		end
	end
	if y>100 and y<250 then
		local k=math.ceil((x-50)/100)
			if k>0 and k<8 then
			self.frameSelect=k
			frameDtSlider.value=self.dt[self.frameSelect+self.framePage] or 100
			frameDtLabel.txt="frame delta time "..tostring(math.ceil(frameDtSlider.value*10 or 1000).." ms")
		end
	end
end

function editor:pressed(key)
	if key=="q" then
		self.selectPos=self.selectPos+1
		if self.selectPos>#self.selectTab then
			self.selectPos=1
		end
		editor:select()
	end

	if key=="t" and self.selectTab[self.selectPos] and self.selectTab[self.selectPos]~=1 then
		local seg=self.model.assets[self.selectTab[self.selectPos]]
		if seg.style=="line" then
			seg.style="circle"
		else
			seg.style="line"
		end
	end

	if key=="d" and self.selectTab[self.selectPos] and self.selectTab[self.selectPos]~=1 then
		local seg=self.model.assets[self.selectTab[self.selectPos]]
		for i,v in ipairs(seg.parent.child) do
			if v==seg then
				table.remove(seg.parent.child,i)
				self.model.assets[seg.id]=nil
			end
		end
	end

	if key=="h" then
		if tips.visible==false then
			tips.visible=true
		else
			tips.visible=false
		end
	end

	if tonumber(key) and tonumber(key)<8 and tonumber(key)>0 then
		local key=tonumber(key)
		self.frameSelect=key
		frameDtSlider.value=self.dt[self.frameSelect+self.framePage] or 100
		frameDtLabel.txt="frame delta time "..tostring(math.ceil(frameDtSlider.value*10 or 1000).." ms")
	end

	if key=="`" then
		self.frames[self.frameSelect+self.framePage]=Role:new("frame",self.model:getData())
		self.dt[self.frameSelect+self.framePage]=100
		self.frameSelect=self.frameSelect+1
		if self.frameSelect==8 then
			self.frameSelect=7
			self.framePage=self.framePage+1
		end	
	end

	if key=="return" then
		self.preview=Role:new("preview",self:generate())
		self.preview.root.x=600
		self.preview.root.y=400
	end

	if key=="delete" then
		self.frames[self.frameSelect+self.framePage]=nil
	end
end

function editor:generate()
	local data={}
	for i,v in ipairs(self.frames) do
		data[i]=v:getData()
	end

	for i=2,#data do
		for k,v in pairs(data[i]) do
			local frame=v.frame[1]
			table.insert(data[1][k].frame, {time=self.dt[i]/100,x=frame.x,y=frame.y,rot=frame.rot,lenth=frame.lenth})
		end
	end
	self.data=data[1]
	return self.data
end

function editor:load()
	if not self.data then return end
	print("loaded")
	local frameCount=#self.data[1].frame

	for i=1,frameCount do
		local data=table.copy(self.data)
		for k,v in pairs(data) do
			v.frame[1]=table.copy(v.frame[i])
		end
		for k,v in pairs(data) do
			for j=2,frameCount do
				v.frame[j]=nil
			end
		end
		if i==1 then 
			self.model=Role:new("model",data)
			self.model.root.x=200
			self.model.root.y=400
		end
		self.frames[i]=Role:new("model",data)
	end
end

function editor:draw()
	self.model:draw()
	if self.creating==true then
		local seg=self.model.assets[self.selectTab[self.selectPos]]
		love.graphics.setLineWidth(3)
		love.graphics.setColor(20,200, 20)
		love.graphics.line(self.createX,self.createY,seg.x,seg.y)
		love.graphics.circle("fill", self.createX,self.createY, 3)
	end

	for i=1,7 do
		if self.frames[i+self.framePage] then
			self.frames[i+self.framePage]:draw()
			self.frames[i+self.framePage].root.x=i*100
			self.frames[i+self.framePage].root.y=200
			love.graphics.setColor(0, 0, 0)
			love.graphics.circle("line", i*100, 280, 10)
			love.graphics.print(tostring(i+self.framePage), i*100-5, 280-5)
		end
	end
	if self.preview then
		self.preview:draw()
	end
	
	love.graphics.setColor(0,200, 100, math.cos(self.t)*255)
	love.graphics.circle("fill", self.frameSelect*100, 280, 10)
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(tostring(self.frameSelect+self.framePage), self.frameSelect*100-5, 280-5)
end

return editor