local role=class("role")
local Root=require "root"
local Segments=require "segments"
function role:initialize(tag,x,y)
	self.segments={}
	self.tag=tag
	self.type="role"
	self.assets={}
	self.index=1	
	if type(x)=="table" then
		self:copyByData(x)
	else
		self.root=Root:new(x,y)
		table.insert(self.assets,self.root)
	end
end

function role:getData()
	self.data={}
	local data=self.data
	for k,v in pairs(self.assets) do
		v.frame[1]={time=0,x=v.x,y=v.y,lenth=v.lenth,rot=v.rot}
		data[k]={}
		data[k].frame={}
		for i,v in ipairs(v.frame) do
			local relativeX = v.frame[i-1] and v.x-v.frame[i-1].x or v.frame[1].x
			local realativeY= v.frame[i-1] and v.x-v.frame[i-1].y or v.frame[1].y
			table.insert(data[k].frame,{time=v.time,x=v.x,y=v.y,rot=v.rot,lenth=v.lenth})
		end
		data[k].child={}
		for i,v in ipairs(v.child) do
			table.insert(data[k].child, v.id)
		end
		data[k].tag=v.tag
		data[k].style=v.style
	end
	return data
end


function role:copyByData(data)
	local k=data[1].frame[1]
	self.root=Root:new(k.x,k.y)
	table.insert(self.assets,self.root)

	for i=2,#data do
		local k=data[i].frame[1]
		local part=self:addChild(data[i].tag,nil,k.lenth,k.rot)
		part.style=data[i].style
	end
	self.root.child={}
	for i=1,#data do
		for k,v in ipairs (data[i].child) do
			self.assets[v].parent=self.assets[i]
			table.insert(self.assets[i].child,self.assets[v])
		end
	end
	if #data[1].frame<2 then return end 
	for i=2,#data do
		for j=2,#data[i].frame do
			self.assets[i]:setKeyFrame(data[i].frame[j].time,data[i].frame[j].rot) --time,rot,
		end
	end

end


function role:update(dt)
	self.root:update(dt)
end

function role:addChild(tag,parent,lenth,rot)
	if not parent then parent=self.root end
	local child=Segments:new(tag,parent,lenth,rot)
	table.insert(parent.child,child)
	table.insert(self.assets,child)
	self.index=self.index+1
	child.id=self.index
	return child
end


function role:draw()
	self.root:draw()
end


return role