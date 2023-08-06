--- 位置类 v1.0.3
--- created by 莫小仙 on 2022-05-14
--- last modified on 2023-08-06
YcPosition = {
  TYPE = 'YC_POSITION'
}

--- 判断是否是位置对象
---@param pos table
---@return boolean
function YcPosition.isPosition(pos)
  return not not (pos and pos.TYPE and pos.TYPE == YcPosition.TYPE)
end

--- 创建一个位置对象
---@param x number | nil x位置，默认为0
---@param y number | nil y位置，默认为0
---@param z number | nil z位置，默认为0
---@return YcPosition 位置对象
function YcPosition:new(x, y, z)
  x = x or 0 -- 没有输入x时，默认为0
  y = y or 0 -- 没有输入y时，默认为0
  z = z or 0 -- 没有输入z时，默认为0
  local o
  if type(x) == 'table' then
    return YcPosition:new(x.x, x.y, x.z)
  else
    o = {
      x = x,
      y = y,
      z = z
    }
  end
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 加法
---@param pos number | YcPosition 数字或位置对象
---@return YcPosition | nil 位置对象，nil表示参数错误
function YcPosition:__add(pos)
  if type(pos) == 'number' then -- 如果是加数字
    return YcPosition:new(self.x + pos, self.y + pos, self.z + pos)
  elseif YcPosition.isPosition(pos) then -- 如果是加位置
    return YcPosition:new(self.x + pos.x, self.y + pos.y, self.z + pos.z)
  else
    error('运算对象是' .. type(pos) .. ', 不是数字或位置')
  end
end

--- 减法
---@param pos number | YcPosition 数字或位置对象
---@return YcPosition | nil 位置对象，nil表示参数错误
function YcPosition:__sub(pos)
  if type(pos) == 'number' then -- 如果是减数字
    return YcPosition:new(self.x - pos, self.y - pos, self.z - pos)
  elseif YcPosition.isPosition(pos) then -- 如果是减位置
    return YcPosition:new(self.x - pos.x, self.y - pos.y, self.z - pos.z)
  else
    error('运算对象是' .. type(pos) .. ', 不是数字或位置')
  end
end

--- 乘法
---@param pos number | YcPosition 数字或位置对象
---@return YcPosition | nil 位置对象，nil表示参数错误
function YcPosition:__mul(pos)
  if type(pos) == 'number' then -- 如果是乘数字
    return YcPosition:new(self.x * pos, self.y * pos, self.z * pos)
  elseif YcPosition.isPosition(pos) then -- 如果是乘位置
    return YcPosition:new(self.x * pos.x, self.y * pos.y, self.z * pos.z)
  else
    error('运算对象是' .. type(pos) .. ', 不是数字或位置')
  end
end

-- 除法
---@param pos number | YcPosition 数字或位置对象
---@return YcPosition | nil 位置对象，nil表示参数错误
function YcPosition:__div(pos)
  if type(pos) == 'number' then -- 如果是除以数字
    return YcPosition:new(self.x / pos, self.y / pos, self.z / pos)
  elseif YcPosition.isPosition(pos) then -- 如果是除以位置
    return YcPosition:new(self.x / pos.x, self.y / pos.y, self.z / pos.z)
  else
    error('运算对象是' .. type(pos) .. ', 不是数字或位置')
  end
end

-- 等于，这里判断两个位置是否在同一个格子里
---@param pos any 位置对象或其他
---@return boolean 是否在同一个格子里
function YcPosition:__eq(pos)
  if YcPosition.isPosition(pos) then -- 如果是位置对象
    return self:floor():equals(pos:floor())
  else
    return false
  end
end

--- 自定义表的输出内容
---@return string
function YcPosition:__tostring()
  return self:toString()
end

--- 各个分量向下取整
---@return YcPosition
function YcPosition:floor()
  return YcPosition:new(math.floor(self.x), math.floor(self.y), math.floor(self.z))
end

--- 各个分量向上取整
---@return YcPosition
function YcPosition:ceil()
  return YcPosition:new(math.ceil(self.x), math.ceil(self.y), math.ceil(self.z))
end

--- 获取x、y、z
---@return number x位置
---@return number y位置
---@return number z位置
function YcPosition:get()
  return self.x, self.y, self.z
end

--- 设置x、y、z
---@param x number x位置
---@param y number y位置
---@param z number z位置
---@return nil
function YcPosition:set(x, y, z)
  if type(x) == 'number' then
    self.x = x
  end
  if type(y) == 'number' then
    self.y = y
  end
  if type(z) == 'number' then
    self.z = z
  end
  if type(x) == 'table' then
    self:set(x.x, x.y, x.z)
  end
end

--- 判断是否相等。包括类型与各个分量的值
---@param pos any
function YcPosition:equals(pos)
  if YcPosition.isPosition(pos) then -- 如果是位置对象
    return pos.x == self.x and pos.y == self.y and pos.z == self.z
  else
    return false
  end
end

--- 转换为字符串
---@return string
function YcPosition:toString()
  return '{x=' .. self.x .. ',y=' .. self.y .. ',z=' .. self.z .. '}'
end

--- 是否与方块位置相同
---@param pos table{ x: number, y: number, z: number }
---@return boolean 是否相同
function YcPosition:equalBlockPos(pos)
  if type(pos) ~= 'table' then
    return false
  end
  local x1, y1, z1 = self:floor():get()
  local x2, y2, z2 = math.floor(pos.x), math.floor(pos.y), math.floor(pos.z)
  return x1 == x2 and y1 == y2 and z1 == z2
end

--- 因为目前坐标分量最大只有四位，所以规定从右起每五位代表一个坐标值，与10000相加
---@return number
function YcPosition:toNumber()
  local x = self.x * math.pow(10, 10) + math.pow(10, 14)
  local y = self.y * math.pow(10, 5) + math.pow(10, 9)
  local z = self.z + math.pow(10, 4)
  return x + y + z
end

--- 转换为各分量简单拼接后的字符串
---@return string
function YcPosition:toSimpleString()
  return StringHelper.concat(self.x, ',', self.y, ',', self.z)
end
