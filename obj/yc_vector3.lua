--[[ 三维向量类 v1.1.0
  create by 莫小仙 on 2022-05-15
  last modified on 2022-07-31
]]
YcVector3 = {
  TYPE = 'YC_VECTOR3'
}

--[[
  是否是三维向量
  @param  {any} obj 任意类型
  @return {boolean} 是否是三维向量
]]
function YcVector3.isVector3 (obj)
  return not not (obj and obj.TYPE and obj.TYPE == YcVector3.TYPE)
end

--[[
  构造子类 参数：六个number/三个number/两个table/一个table
  @param  {number | table} x1 数值或表
  @param  {number | table | nil} y1 数值或表
  @param  {number | nil} z1 数值或nil
  @param  {number | nil} x2 数值或nil
  @param  {number | nil} y2 数值或nil
  @param  {number | nil} z2 数值或nil
  @return {YcVector3} 三维向量
]]
function YcVector3:new (x1, y1, z1, x2, y2, z2)
  local o
  if type(x2) == 'number' and type(y2) == 'number' and type(z2) == 'number'
    and type(x1) == 'number' and type(y1) == 'number' and type(z1) == 'number' then -- 6个数值
    o = { x = x2 - x1, y = y2 - y1, z = z2 - z1 }
  elseif type(x1) == 'number' and type(y1) == 'number' and type(z1) == 'number' then -- 3个数值
    o = { x = x1, y = y1, z = z1 }
  elseif type(y1) == 'table' and type(x1) == 'table' then -- 2个表
    return YcVector3:new(x1.x, x1.y, x1.z, y1.x, y1.y, y1.z)
  elseif type(x1) == 'table' then -- 1个表
    return YcVector3:new(x1.x, x1.y, x1.z)
  else -- 其他不合规定的参数
    o = { x = 0, y = 0, z = 0 }
  end
  self.__index = self
  setmetatable(o, self)
  return o
end

YcVector3.zero = YcVector3:new(0, 0, 0)
YcVector3.one = YcVector3:new(1, 1, 1)
YcVector3.left = YcVector3:new(-1, 0, 0) -- 对应西方向
YcVector3.right = YcVector3:new(1, 0, 0) -- 对应东方向
YcVector3.up = YcVector3:new(0, 1, 0) -- 对应上方向
YcVector3.down = YcVector3:new(0, -1, 0) -- 对象下方向
YcVector3.forward = YcVector3:new(0, 0, 1) -- 对应北方向
YcVector3.back = YcVector3:new(0, 0, -1) -- 对应南方向

--[[
  加法
  @param  {number | YcVector3} vec 数值或三维向量
  @return {YcVector3 | nil} 向量，nil表示加数类型错误
]]
function YcVector3:__add (vec)
  if type(vec) == 'number' then -- 如果是加数字
    return YcVector3:new(self.x + vec, self.y + vec, self.z + vec)
  elseif YcVector3.isVector3(vec) then -- 如果是加向量
    return YcVector3:new(self.x + vec.x, self.y + vec.y, self.z + vec.z)
  else
    error('运算对象是' .. type(vec) .. ', 不是数字或三维向量')
  end
end

--[[
  减法
  @param  {number | YcVector3} vec 数值或三维向量
  @return {YcVector3 | nil} 向量，nil表示减数类型错误
]]
function YcVector3:__sub (vec)
  if type(vec) == 'number' then -- 如果是减数字
    return YcVector3:new(self.x - vec, self.y - vec, self.z - vec)
  elseif YcVector3.isVector3(vec) then -- 如果是减向量
    return YcVector3:new(self.x - vec.x, self.y - vec.y, self.z - vec.z)
  else
    error('运算对象是' .. type(vec) .. ', 不是数字或三维向量')
  end
end

--[[
  乘法
  @param  {number | YcVector3} vec 数值或三维向量
  @return {YcVector3 | nil} 向量，nil表示乘数类型错误
]]
function YcVector3:__mul (vec)
  if type(vec) == 'number' then -- 如果是乘数字
    return YcVector3:new(self.x * vec, self.y * vec, self.z * vec)
  elseif YcVector3.isVector3(vec) then -- 如果是乘向量
    return YcVector3:new(self.x * vec.x, self.y * vec.y, self.z * vec.z)
  else
    error('运算对象是' .. type(vec) .. ', 不是数字或三维向量')
  end
end

--[[
  除法
  @param  {number | YcVector3} vec 数值或三维向量
  @return {YcVector3 | nil} 向量，nil表示除数类型错误
]]
function YcVector3:__div (vec)
  if type(vec) == 'number' then -- 如果是除以数字
    return YcVector3:new(self.x / vec, self.y / vec, self.z / vec)
  elseif YcVector3.isVector3(vec) then -- 如果是除以向量
    return YcVector3:new(self.x / vec.x, self.y / vec.y, self.z / vec.z)
  else
    error('运算对象是' .. type(vec) .. ', 不是数字或三维向量')
  end
end

--[[
  等于
  @param  {any} vec 任意类型
  @return {boolean} 是否相等
]]
function YcVector3:__eq (vec)
  if YcVector3.isVector3(vec) then -- 如果是向量对象
    return vec.x == self.x and vec.y == self.y and vec.z == self.z
  else
    return false
  end
end

--[[
  自定义表的输出内容
  @return {string} 输出内容
]]
function YcVector3:__tostring ()
  return self:toString()
end

--[[
  点乘
  @param  {YcVector3} vec 三维向量
  @return {number | nil} 数值，nil表示参数不是三维向量 
]]
function YcVector3:dot (vec)
  if YcVector3.isVector3(vec) then
    return self.x * vec.x + self.y * vec.y + self.z * vec.z
  else
    error('点乘对象是' .. type(vec) .. ', 不是三维向量')
  end
end

--[[
  叉乘
  @param  {YcVector3} vec 三维向量
  @return {YcVector3} 三维向量，nil表示参数不是三维向量
]]
function YcVector3:cross (vec)
  if YcVector3.isVector3(vec) then
    return YcVector3:new(self.y * vec.z - self.z * vec.y,
      self.z * vec.x - self.x * vec.z, self.x * vec.y - self.y * vec.x)
  else
    error('叉乘对象是' .. type(vec) .. ', 不是三维向量')
  end
end

--[[
  获取向量长度
  @return {number} 长度
]]
function YcVector3:length ()
  return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2) + math.pow(self.z, 2))
end

--[[
  获取归一化向量
  @return {YcVector3} 单位向量
]]
function YcVector3:normalize ()
  local length = self:length()
  if length == 0 then -- 长度为0
    return YcVector3:new()
  else
    return YcVector3:new(self.x / length, self.y / length, self.z / length)
  end
end

--[[
  是否是零向量
  @return {boolean} 是否零向量
]]
function YcVector3:isZero ()
  return self.x == 0 and self.y == 0 and self.z == 0
end

--[[
  获取x、y、z
  @return {number} x值
  @return {number} y值
  @return {number} z值
]]
function YcVector3:get ()
  return self.x, self.y, self.z
end

--[[
  设置x、y、z
  @param  {number | table} x 数值或table
  @param  {number | nil} y 数值或nil
  @param  {number | nil} z 数值或nil
  @return {nil}
]]
function YcVector3:set (x, y, z)
  if type(x) == 'table' then
    self:set(x.x, x.y, x.z)
  else
    if type(x) == 'number' then
      self.x = x
    end
    if type(y) == 'number' then
      self.y = y
    end
    if type(z) == 'number' then
      self.z = z
    end
  end
end

--[[
  转换为字符串
  @return {string} 字符串
]]
function YcVector3:toString ()
  return '{x=' .. self.x .. ',y=' .. self.y .. ',z=' .. self.z .. '}'
end
