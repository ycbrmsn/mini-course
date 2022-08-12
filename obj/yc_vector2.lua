--[[ 二维向量类 v1.0.0
  create by 莫小仙 on 2022-07-31
]]
YcVector2 = {
  TYPE = 'YC_VECTOR2'
}

--[[
  是否是二维向量
  @param  {any} obj 任意类型
  @return {boolean} 是否是二维向量
]]
function YcVector2.isVector2 (obj)
  return not not (obj and obj.TYPE and obj.TYPE == YcVector2.TYPE)
end

--[[
  构造子类 参数：四个number/两个number/两个table/一个table
  @param  {number | table} x1 数值或表
  @param  {number | table | nil} y1 数值或表
  @param  {number | nil} x2 数值或nil
  @param  {number | nil} y2 数值或nil
  @return {YcVector2} 二维向量
]]
function YcVector2:new (x1, y1, x2, y2)
  local o
  if type(x2) == 'number' and type(y2) == 'number'
    and type(x1) == 'number' and type(y1) == 'number' then -- 4个数值
    o = { x = x2 - x1, y = y2 - y1 }
  elseif type(x1) == 'number' and type(y1) == 'number' then -- 2个数值
    o = { x = x1, y = y1 }
  elseif type(y1) == 'table' and type(x1) == 'table' then -- 2个表
    return YcVector2:new(x1.x, x1.y, y1.x, y1.y)
  elseif type(x1) == 'table' then -- 1个表
    return YcVector2:new(x1.x, x1.y)
  else -- 其他不合规定的参数
    o = { x = 0, y = 0 }
  end
  self.__index = self
  setmetatable(o, self)
  return o
end

YcVector2.zero = YcVector2:new(0, 0)
YcVector2.one = YcVector2:new(1, 1)
YcVector2.left = YcVector2:new(-1, 0) -- 对应西方向
YcVector2.right = YcVector2:new(1, 0) -- 对应东方向
YcVector2.up = YcVector2:new(0, 1) -- 对应上方向
YcVector2.down = YcVector2:new(0, -1) -- 对应下方向

--[[
  加法
  @param  {number | YcVector2} vec 数值或二维向量
  @return {YcVector2 | nil} 向量，nil表示加数类型错误
]]
function YcVector2:__add (vec)
  if type(vec) == 'number' then -- 如果是加数字
    return YcVector2:new(self.x + vec, self.y + vec)
  elseif YcVector2.isVector2(vec) then -- 如果是加向量
    return YcVector2:new(self.x + vec.x, self.y + vec.y)
  else
    error('运算对象是' .. type(vec) .. ', 不是数字或二维向量')
  end
end

--[[
  减法
  @param  {number | YcVector2} vec 数值或二维向量
  @return {YcVector2 | nil} 向量，nil表示减数类型错误
]]
function YcVector2:__sub (vec)
  if type(vec) == 'number' then -- 如果是减数字
    return YcVector2:new(self.x - vec, self.y - vec)
  elseif YcVector2.isVector2(vec) then -- 如果是减向量
    return YcVector2:new(self.x - vec.x, self.y - vec.y)
  else
    error('运算对象是' .. type(vec) .. ', 不是数字或二维向量')
  end
end

--[[
  乘法
  @param  {number | YcVector2} vec 数值或二维向量
  @return {YcVector2 | nil} 向量，nil表示乘数类型错误
]]
function YcVector2:__mul (vec)
  if type(vec) == 'number' then -- 如果是乘数字
    return YcVector2:new(self.x * vec, self.y * vec)
  elseif YcVector2.isVector2(vec) then -- 如果是乘向量
    return YcVector2:new(self.x * vec.x, self.y * vec.y)
  else
    error('运算对象是' .. type(vec) .. ', 不是数字或二维向量')
  end
end

--[[
  除法
  @param  {number | YcVector2} vec 数值或二维向量
  @return {YcVector2 | nil} 向量，nil表示除数类型错误
]]
function YcVector2:__div (vec)
  if type(vec) == 'number' then -- 如果是除以数字
    return YcVector2:new(self.x / vec, self.y / vec)
  elseif YcVector2.isVector2(vec) then -- 如果是除以向量
    return YcVector2:new(self.x / vec.x, self.y / vec.y)
  else
    error('运算对象是' .. type(vec) .. ', 不是数字或二维向量')
  end
end

--[[
  等于
  @param  {any} vec 任意类型
  @return {boolean} 是否相等
]]
function YcVector2:__eq (vec)
  if YcVector2.isVector2(vec) then -- 如果是向量对象
    return vec.x == self.x and vec.y == self.y
  else
    return false
  end
end

--[[
  自定义表的输出内容
  @return {string} 输出内容
]]
function YcVector2:__tostring ()
  return self:toString()
end

--[[
  点乘
  @param  {YcVector2} vec 二维向量
  @return {number | nil} 数值，nil表示参数不是二维向量 
]]
function YcVector2:dot (vec)
  if YcVector2.isVector2(vec) then
    return self.x * vec.x + self.y * vec.y
  else
    error('点乘对象是' .. type(vec) .. ', 不是二维向量')
  end
end

--[[
  叉乘
  @param  {YcVector2} vec 二维向量
  @return {number | nil} 二维向量，nil表示参数不是二维向量
]]
function YcVector2:cross (vec)
  if YcVector2.isVector2(vec) then
    return self.x * vec.y - self.y * vec.x
  else
    error('叉乘对象是' .. type(vec) .. ', 不是二维向量')
  end
end

--[[
  获取向量长度
  @return {number} 长度
]]
function YcVector2:length ()
  return math.sqrt(math.pow(self.x, 2) + math.pow(self.y, 2))
end

--[[
  获取归一化向量
  @return {YcVector2} 单位向量
]]
function YcVector2:normalize ()
  local length = self:length()
  if length == 0 then -- 长度为0
    return YcVector2:new()
  else
    return YcVector2:new(self.x / length, self.y / length)
  end
end

--[[
  是否是零向量
  @return {boolean} 是否零向量
]]
function YcVector2:isZero ()
  return self.x == 0 and self.y == 0
end

--[[
  获取x、y
  @return {number} x值
  @return {number} y值
]]
function YcVector2:get ()
  return self.x, self.y
end

--[[
  设置x、y
  @param  {number | table} x 数值或table
  @param  {number | nil} y 数值或nil
  @return {nil}
]]
function YcVector2:set (x, y)
  if type(x) == 'table' then
    self:set(x.x, x.y)
  else
    if type(x) == 'number' then
      self.x = x
    end
    if type(y) == 'number' then
      self.y = y
    end
  end
end

--[[
  转换为字符串
  @return {string} 字符串
]]
function YcVector2:toString ()
  return '{x=' .. self.x .. ',y=' .. self.y .. '}'
end