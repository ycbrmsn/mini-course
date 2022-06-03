--[[ 位置类 v1.0.2
  create by 莫小仙 on 2022-05-14
  last modified on 2022-06-03
]]
YcPosition = {
  TYPE = 'YC_POSITION'
}

-- 是否是位置对象
function YcPosition.isPosition (pos)
  return not not (pos and pos.TYPE and pos.TYPE == YcPosition.TYPE)
end

-- 创建一个位置对象
function YcPosition:new (x, y, z)
  x = x or 0 -- 没有输入x时，默认为0
  y = y or 0 -- 没有输入y时，默认为0
  z = z or 0 -- 没有输入z时，默认为0
  local o
  if type(x) == 'table' then
    return YcPosition:new(x.x, x.y, x.z)
  else
    o = { x = x, y = y, z = z }
  end
  self.__index = self
  setmetatable(o, self)
  return o
end

-- 加法
function YcPosition:__add (pos)
  if type(pos) == 'number' then -- 如果是加数字
    return YcPosition:new(self.x + pos, self.y + pos, self.z + pos)
  elseif YcPosition.isPosition(pos) then -- 如果是加位置
    return YcPosition:new(self.x + pos.x, self.y + pos.y, self.z + pos.z)
  else
    error('运算对象是' .. type(pos) .. ', 不是数字或位置')
  end
end

-- 减法
function YcPosition:__sub (pos)
  if type(pos) == 'number' then -- 如果是加数字
    return YcPosition:new(self.x - pos, self.y - pos, self.z - pos)
  elseif YcPosition.isPosition(pos) then -- 如果是加位置
    return YcPosition:new(self.x - pos.x, self.y - pos.y, self.z - pos.z)
  else
    error('运算对象是' .. type(pos) .. ', 不是数字或位置')
  end
end

-- 乘法
function YcPosition:__mul (pos)
  if type(pos) == 'number' then -- 如果是加数字
    return YcPosition:new(self.x * pos, self.y * pos, self.z * pos)
  elseif YcPosition.isPosition(pos) then -- 如果是加位置
    return YcPosition:new(self.x * pos.x, self.y * pos.y, self.z * pos.z)
  else
    error('运算对象是' .. type(pos) .. ', 不是数字或位置')
  end
end

-- 除法
function YcPosition:__div (pos)
  if type(pos) == 'number' then -- 如果是加数字
    return YcPosition:new(self.x / pos, self.y / pos, self.z / pos)
  elseif YcPosition.isPosition(pos) then -- 如果是加位置
    return YcPosition:new(self.x / pos.x, self.y / pos.y, self.z / pos.z)
  else
    error('运算对象是' .. type(pos) .. ', 不是数字或位置')
  end
end

-- 等于，这里判断两个位置是否在同一个格子里
function YcPosition:__eq (pos)
  if YcPosition.isPosition(pos) then -- 如果是位置对象
    return self:floor():equals(pos:floor())
  else
    return false
  end
end

-- 自定义表的输出内容
function YcPosition:__tostring ()
  return self:toString()
end

-- 向下取整
function YcPosition:floor ()
  return YcPosition:new(math.floor(self.x), math.floor(self.y), math.floor(self.z))
end

-- 向上取整
function YcPosition:ceil ()
  return YcPosition:new(math.ceil(self.x), math.ceil(self.y), math.ceil(self.z))
end

-- 获取x、y、z
function YcPosition:get ()
  return self.x, self.y, self.z
end

-- 设置x、y、z
function YcPosition:set (x, y, z)
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

-- 是否相等
function YcPosition:equals (pos)
  if YcPosition.isPosition(pos) then -- 如果是位置对象
    return pos.x == self.x and pos.y == self.y and pos.z == self.z
  else
    return false
  end
end

-- 转换为字符串
function YcPosition:toString ()
  return '{x=' .. self.x .. ',y=' .. self.y .. ',z=' .. self.z .. '}'
end

---
function YcPosition:equalBlockPos (pos)
  if type(pos) ~= 'table' then
    return false
  end
  local x1, y1, z1 = self:floor():get()
  local x2, y2, z2 = math.floor(pos.x), math.floor(pos.y), math.floor(pos.z)
  return x1 == x2 and y1 == y2 and z1 == z2
end

-- 从右起每四位代表一个坐标值（负数有问题）
function YcPosition:toNumber ()
  return self.x * 100000000 + self.y * 10000 + self.z
end

function YcPosition:toSimpleString ()
  return StringHelper.concat(self.x, ',', self.y, ',', self.z)
end