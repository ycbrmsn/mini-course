--- 数组类 v1.0.1
--- created by 莫小仙 on 2023-12-04
--- last modified on 2023-12-09
---@class YcArray 数组对象
---@field array table 数组内容
---@field TYPE "'YC_ARRAY'" 类型
YcArray = {
  TYPE = 'YC_ARRAY'
}

--- 判断是否是一个数组
---@param o any 需要判断的元素
---@return boolean 是否是数组
function YcArray.isArray(o)
  return type(o) == 'table' and o.TYPE == 'YC_ARRAY'
end

--- 根据对象创建数组
---@param obj string | table 有长度的table或有length属性的table都行
---@param f nil | fun(currentValue: any, index: integer, array: YcArray): any 回调函数
---@return YcArray 新数组
function YcArray.from(obj, f)
  local t = type(obj)
  if t == 'string' then -- 如果是字符串
    local array = {}
    for i = 1, #obj do
      array[i] = string.sub(obj, i, i)
    end
    obj = YcArray:new(array) -- 统一将obj赋值为一个数组
  elseif t == 'table' then -- 如果是表
    if not YcArray.isArray(obj) then -- 如果不是数组
      local array = {}
      if obj.length then -- 如果有length属性
        for i = 1, obj.length do
          array[i] = obj[i] or ''
        end
      else -- 没有length属性
        for i, v in ipairs(obj) do
          array[i] = v
        end
      end
      obj = YcArray:new(array) -- 统一将obj赋值为一个数组
    end
  else -- 其他情况就返回一个空数组
    return YcArray:new()
  end
  if type(f) ~= 'function' then -- 如果f不是函数
    f = function(item)
      return item or ''
    end
  end
  return obj:map(f)
end

--- 实例化
---@param array table 数组
---@return YcArray 数组对象
function YcArray:new(array)
  array = type(array) == 'table' and array or {} -- 如果array不是table，则赋值为空数组
  local obj = {
    array = array
  }
  self.__index = self
  setmetatable(obj, self)
  return obj
end

--- 获取数组中指定索引的元素
---@param index integer 索引
---@return any 数组元素
function YcArray:get(index)
  if self:checkIndex(index) then -- 如果索引正常
    return self.array[index]
  else -- 如果索引不正常
    return nil
  end
end

--- 设置数组中指定索引的值
---@param index integer 索引
---@param value any 值
---@return YcArray 原数组
function YcArray:set(index, value)
  if self:checkIndex(index) then -- 如果索引正常
    self.array[index] = value
  end
  return self
end

--- 获取数组长度
---@return integer 数组长度
function YcArray:length()
  return #self.array
end

--- 向数组尾部添加一个或多个元素
---@vararg any 需要添加的元素
---@return YcArray 原数组
function YcArray:push(...)
  local num = select('#', ...)
  local len = self:length()
  for i = 1, num do
    local arg = select(i, ...)
    self.array[len + i] = arg
  end
  return self
end

--- 删除数组尾部的一个元素
---@return any 删除的元素
function YcArray:pop()
  return table.remove(self.array)
end

--- 向数组头部添加一个或多个元素
---@vararg any 需要添加的元素
---@return YcArray 原数组
function YcArray:unshift(...)
  local num = select('#', ...)
  local len = self:length()
  local array = {}
  -- 将需要插入的元素放入新数组
  for i = 1, num do
    local arg = select(i, ...)
    array[i] = arg
  end
  -- 将原数组的元素依次放入新数组
  for i = 1, len do
    array[num + i] = self.array[i]
  end
  -- 覆盖原数组
  for i, v in ipairs(array) do
    self.array[i] = array[i]
  end
  return self
end

--- 删除数组的第一个元素
---@return any 删除的元素
function YcArray:shift()
  return table.remove(self.array, 1)
end

--- 向数组中插入元素
---@param index integer | any 索引或者插入的元素
---@param value any | nil 插入的元素。nil表示pos处传的插入的元素
---@return YcArray 原数组
function YcArray:insert(...)
  table.insert(self.array, ...)
  return self
end

--- 从数组中删除元素
---@param index integer | nil 删除元素的索引。nil表示删除最后一个元素
---@return any 删除的元素
function YcArray:remove(...)
  return table.remove(self.array, ...)
end

--- 连接两个或多个数组。不会改变原数组
---@vararg YcArray 需要拼接的数组
---@return YcArray 连接后的新数组
function YcArray:concat(...)
  local index = 1
  -- 包含当前数组所有元素的一个数组
  local array = self:reduce(function(total, item)
    total[index] = item
    index = index + 1
    return total
  end, {})
  -- 需要拼接的其他数组
  local num = select('#', ...)
  for i = 1, num do
    local arr = select(i, ...)
    arr:forEach(function(item)
      array[index] = item
      index = index + 1
    end)
  end
  return YcArray:new(array)
end

--- 遍历数组
---@param f fun(currentValue: any, index: integer, array: YcArray): void 回调函数
---@return YcArray 原数组
function YcArray:forEach(f)
  for i, v in ipairs(self.array) do
    f(v, i, self)
  end
  return self
end

--- 循环生成一个新数组
---@generic T
---@param f fun(currentValue: any, index: integer, array: YcArray): T 回调函数
---@return YcArray<T> 新数组
function YcArray:map(f)
  local array = YcArray:new()
  for i, v in ipairs(self.array) do
    array:push(f(v, i, self))
  end
  return array
end

--- 检测数组中是否有元素满足指定条件
---@param f fun(currentValue: any, index: integer, array: YcArray): boolean 回调函数
---@return boolean 是否有元素满足
function YcArray:some(f)
  for i, v in ipairs(self.array) do
    if f(v, i, self) then
      return true
    end
  end
  return false
end

--- 检测数组中是否所有元素都满足指定条件
---@param f fun(currentValue: any, index: integer, array: YcArray): boolean 回调函数
---@return boolean 是否所有元素都满足
function YcArray:every(f)
  for i, v in ipairs(self.array) do
    if not f(v, i, self) then
      return false
    end
  end
  return true
end

--- 根据条件过滤，生成新数组
---@param f fun(currentValue: any, index: integer, array: YcArray): boolean 回调函数
---@return YcArray 新数组
function YcArray:filter(f)
  local array = YcArray:new()
  for i, v in ipairs(self.array) do
    if f(v, i, self) then
      array:push(v)
    end
  end
  return array
end

--- 累加器
---@param f fun(total: any, currentValue: any, index: integer, array: YcArray): any 回调函数
---@param initialValue any 初始值
---@return any 累加值
function YcArray:reduce(f, initialValue)
  local total -- 计算返回值
  if initialValue == nil then -- 如果没有初始值
    if self:length() > 0 then -- 如果数组内有元素
      total = self.array[1] -- 计算返回值为数组内第一个
      for i = 2, self:length(), 1 do -- 从数组中第二个开始循环
        total = f(total, self.array[i], i, self)
      end
    end
  else -- 如果有初始值
    total = initialValue
    for i, v in ipairs(self.array) do
      total = f(total, v, i, self)
    end
  end
  return total
end

--- 找到数组中第一个满足条件的值。如果没有一个满足条件，则返回nil
---@param f fun(currentValue: any, index: integer, array: YcArray): any 回调函数
---@return any 满足条件的值。
function YcArray:find(f)
  for i, v in ipairs(self.array) do
    if f(v, i, self) then
      return v
    end
  end
  return nil
end

--- 找到数组中第一个满足条件的值的索引。如果没有一个满足条件，则返回-1
---@param f fun(currentValue: any, index: integer, array: YcArray): any 回调函数
---@return integer 满足条件的值的索引。
function YcArray:findIndex(f)
  for i, v in ipairs(self.array) do
    if f(v, i, self) then
      return i
    end
  end
  return -1
end

--- 检测数组中是否包含某个元素
---@param value any 检测元素
---@return boolean 是否包含
function YcArray:includes(value)
  return self:some(function(item)
    return item == value
  end)
end

--- 找到数组中指定值的索引。如果没有找到，则返回-1
---@param value any 指定值
---@param startIndex integer | nil 开始位置。默认为1。负数表示倒数第几个
---@return integer 指定值的索引
function YcArray:indexOf(value, startIndex)
  local num = self:length()
  startIndex = startIndex or 1
  if startIndex < 0 then -- 负值则反向计数
    startIndex = num + startIndex + 1
  end
  local array = self.array
  for i = startIndex, num do
    local v = array[i]
    if v == value then
      return i
    end
  end
  return -1
end

--- 找到数组中指定值的索引。如果没有找到，则返回-1
---@param value any 指定值
---@param startIndex integer | nil 开始位置。默认为最后一个。负数表示倒数第几个
---@return integer 指定值的索引
function YcArray:lastIndexOf(value, startIndex)
  local num = self:length() -- 数组长度
  startIndex = startIndex or num
  if startIndex < 0 then -- 负值则反向计数
    startIndex = num + startIndex + 1
  end
  local array = self.array
  for i = startIndex, 1, -1 do
    local v = array[i]
    if v == value then
      return i
    end
  end
  return -1
end

--- 用指定值填充数组中的指定元素
---@param value any 指定值
---@param startIndex integer | nil 开始位置。默认为1。负数表示倒数第几个
---@param endIndex integer | nil 结束位置。默认为最后一个位置。负数表示倒数第几个
---@return YcArray 原数组
function YcArray:fill(value, startIndex, endIndex)
  local num = self:length()
  startIndex = startIndex or 1
  if startIndex < 0 then -- 负值则反向计数
    startIndex = num + startIndex + 1
  end
  endIndex = endIndex or num
  if endIndex < 0 then -- 负值则反向计数
    endIndex = num + endIndex + 1
  end
  self:forEach(function(item, index)
    if index >= startIndex and index <= endIndex then
      self.array[index] = value
    end
  end)
  return self
end

--- 将数组中所有元素连接成一个字符串
---@param separator string 各个元素间的连接符
---@return string 连接后的字符串
function YcArray:join(separator)
  separator = separator or ','
  local str = ''
  for i, v in ipairs(self.array) do
    if i == self:length() then -- 如果是最后一个
      str = YcStringHelper.concat(str, v)
    else -- 如果不是最后一个
      str = YcStringHelper.concat(str, v, separator)
    end
  end
  return str
end

--- 反转数组中的元素。将会改变原数组
---@return YcArray 原数组
function YcArray:reverse()
  local array = {}
  local num = self:length()
  for i = 1, num do
    array[i] = self.array[num - i + 1]
  end
  -- 循环覆盖原值
  for i, v in ipairs(array) do
    self.array[i] = v
  end
  return self
end

--- 从数组中截取一部分，返回一个新数组。不会改变原数组
---@param startIndex integer 开始位置。默认为1。负数表示倒数第几个
---@param endIndex integer 结束位置。默认为最后一个位置。负数表示倒数第几个
---@return YcArray 新数组
function YcArray:slice(startIndex, endIndex)
  local num = self:length()
  startIndex = startIndex or 1
  if startIndex < 0 then -- 负值则反向计数
    startIndex = num + startIndex + 1
  end
  endIndex = endIndex or num
  if endIndex < 0 then -- 负值则反向计数
    endIndex = num + endIndex + 1
  end
  local array = {}
  local index = 1
  for i = startIndex, endIndex do
    array[index] = self.array[i]
    index = index + 1
  end
  return YcArray:new(array)
end

--- 从数组中删除元素，向数组中插入元素
---@param index integer 位置
---@param howmany integer 删除元素的数量
---@vararg any 需要插入的元素
---@return YcArray 删除的元素构成的数组
function YcArray:splice(index, howmany, ...)
  local array = {}
  local idx = 1
  local len = self:length()
  -- 将index之前的元素放入新数组
  for i = 1, index - 1 do
    array[idx] = self.array[i]
    idx = idx + 1
  end
  -- 将需要插入的元素放入新数组
  local num = select('#', ...)
  for i = 1, num do
    array[idx] = select(i, ...)
    idx = idx + 1
  end
  -- 将删除后剩余数组元素放入新数组
  for i = index + howmany, len do
    array[idx] = self.array[i]
    idx = idx + 1
  end
  -- 将需要删除的元素加入新数组
  local array2 = {}
  local idx2 = 1
  for i = 1, howmany do
    array2[i] = self.array[index + i - 1]
  end
  -- 准备覆盖数组
  if len > #array then -- 如果原数组比新数组长，则需要删除超长的部分
    for i = len, #array + 1, -1 do
      table.remove(self.array, i)
    end
  end
  -- 覆盖原数组
  for i, v in ipairs(array) do
    self.array[i] = array[i]
  end
  return YcArray:new(array2)
end

--- 排序。默认升序
---@param f nil | fun(a: any, b: any): boolean
---@return YcArray 原数组
function YcArray:sort(f)
  table.sort(self.array, f)
  return self
end

--- 自定义表的输出内容
---@return string 输出内容
function YcArray:__tostring()
  return YcStringHelper.concat('{', self:join(), '}')
end

--- 检查索引是否正常
---@param index integer 索引
---@return boolean 是否正常
function YcArray:checkIndex(index)
  if type(index) ~= 'number' then
    YcLogHelper.error('数组索引错误：', index)
    return false
  end
  if index < 1 or index > self:length() then
    YcLogHelper.error('数组索引越界：', index)
    return false
  end
  return true
end
