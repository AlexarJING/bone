local root=class("root")

function root:initialize(x,y)
	self.type="root"
	self.tag="main"
	self.x=x or 400
	self.y=y or 300
	self.rot=0
	self.child={}
	self.tween=nil
	self.drawable=nil
	self.real_rot=0
	self.isSelected=false
	self.id=1
	self.frame={
		{time=0,x=self.x,y=self.y,lenth=self.lenth,rot=self.rot}
	}
end

function root:sync()
	self.real_rot=self.rot
end

function root:setKeyFrame(time,x,y,callback,...)
	table.insert(self.frame,{time=time,x=x,y=y})
	local tween=tween.new(time, self, {x=x+self.x,y=y+self.y}, "linear")
	table.insert(self.tween,tween)
	local f=function(seg,tween,callback,...) 
		seg.nextFrame=true
		if callback then callback(...) end 
	end
	tween:setCallback(f,self,tween,callback,...)
end



function root:update(dt)
	self:sync()
	for i,v in ipairs(self.child) do
		v:update(dt)
	end	
end

function root:draw()
	for i,v in ipairs(self.child) do
		v:draw()
	end
	love.graphics.setColor(255, 200, 0)
	love.graphics.circle("fill", self.x, self.y,5)
	love.graphics.setColor(0, 0, 255)
	love.graphics.setLineWidth(1)
	if self.isSelected==true then
		love.graphics.rectangle("line", self.x-5, self.y-5, 10, 10)
	end
end


return root