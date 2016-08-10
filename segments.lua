local seg=class("segment")

local function axisRot(x,y,rot)
	return math.cos(rot)*x-math.sin(rot)*y,math.cos(rot)*y+math.sin(rot)*x
end


function seg:initialize(tag,parent,lenth,rot)
	if rot<0 then rot=rot+2*math.pi end
	self.type="segment"
	self.tag=tag
	self.parent=parent
	self.child={}
	self.lenth=lenth
	self.rot=rot
	self.width=3
	self.drawable=nil
	self.style="line" --"circle"
	self.x=0
	self.y=0
	self.real_rot=0
	self.isDynamic=true
	self.frame={
		{time=0,x=self.x,y=self.y,lenth=self.lenth,rot=self.rot}
	}
	self.tween={}
	self.origin_rot=self.rot
	self.nextFrame=false
	self.frameIndex=1
	self.isSelected=false
end

function seg:reset()
	self.frame={}
	self.tween={}
	self.rot=self.origin_rot
	self.nextFrame=false
	self.frameIndex=1	
end


function seg:sync()
	--if self.rot>2*math.pi then self.rot=self.rot-2*math.pi end
	self.real_rot=self.parent.real_rot+self.rot
	self.x,self.y=axisRot(0,self.lenth,self.real_rot)
	self.x=self.x+self.parent.x
	self.y=self.y+self.parent.y	
end

function seg:tweenUpdate(dt)
	if not self.tween[self.frameIndex] then return end
	self.tween[self.frameIndex]:update(dt)
	if self.nextFrame then
		self.nextFrame=false
		self.frameIndex=self.frameIndex+1
		if self.frameIndex>#self.frame-1 then
			self.rot=self.origin_rot
			self.frameIndex=1
		end
		--if self.rot>2*math.pi then self.rot=self.rot-2*math.pi end
		self.tween[self.frameIndex]:sync()
		self.tween[self.frameIndex]:reset()
	end
end


function seg:update(dt)
	self:sync()
	self:tweenUpdate(dt)
	for i,v in ipairs(self.child) do
		v:update(dt)
	end
end


function seg:setKeyFrame(time,rot,callback,...)

	local oRot=self.frame[#self.frame].rot

	if rot-oRot>math.pi then
		rot=rot-2*math.pi
	elseif oRot-rot>math.pi then
		rot=rot+2*math.pi
	end
	table.insert(self.frame,{time=time,rot=rot,lenth=self.lenth})
	local tween=tween.new(time, self, {rot=rot}, "linear")
	table.insert(self.tween,tween)
	local f=function(seg,tween,callback,...) 
		seg.nextFrame=true
		if callback then callback(...) end 
	end
	tween:setCallback(f,self,tween,callback,...)
end



function seg:draw()
	love.graphics.setColor(0, 0, 0)
	love.graphics.setLineWidth(self.width)
	if self.style=="line" then
		love.graphics.line(self.x, self.y, self.parent.x, self.parent.y)
	else
		love.graphics.circle("line",(self.x+self.parent.x)/2, (self.y+self.parent.y)/2,self.lenth/2)
	end
	for i,v in ipairs(self.child) do
		v:draw()
	end
	love.graphics.setColor(255, 0, 0)
	love.graphics.circle("fill", self.x, self.y,5)
	love.graphics.setColor(0, 0, 255)
	love.graphics.setLineWidth(1)
	if self.isSelected==true then
		love.graphics.rectangle("line", self.x-5, self.y-5, 10, 10)
	end
end

return seg