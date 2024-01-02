--- 字符串工具类 v1.1.2
--- created by 莫小仙 on 2022-05-22
--- last modified on 2023-12-20
YcStringHelper = {}

--- 转换为字符串
---@param obj any 任意类型
---@param existTables nil | YcArray<table> 已经存在的表。nil表示还没有表存在
---@return string
function YcStringHelper.toString(obj, existTables)
  existTables = existTables or YcArray:new()
  if type(obj) == 'table' then
    if existTables:includes(obj) then -- 已出现过该表
      return '{递归表}'
    else
      existTables:push(obj) -- 记录该表已出现
      return YcStringHelper.tableToString(obj, existTables)
    end
  else
    return tostring(obj)
  end
end

--- 表转换为字符串。将忽略__index属性
---@param t table 表
---@param existTables nil | YcArray<table> 已经存在的表。nil表示还没有表存在
---@return string 转换结果
function YcStringHelper.tableToString(t, existTables)
  existTables = existTables or YcArray:new()
  local str = '{'
  local index = 1
  for k, v in pairs(t) do
    if index ~= 1 then
      str = str .. ', '
    end
    str = str .. YcStringHelper.toString(k, existTables) .. ' = ' .. YcStringHelper.toString(v, existTables)
    index = index + 1
  end
  str = str .. '}'
  return str
end

--- 拼接所有参数
---@vararg any 任意类型
---@return string 拼接结果
function YcStringHelper.concat(...)
  local num = select("#", ...)
  local str = ''
  for i = 1, num do
    local arg = select(i, ...)
    str = str .. YcStringHelper.toString(arg)
  end
  return str
end

--- 拼接所有参数，其中nil值不拼接
---@vararg any 任意类型
---@return string 拼接结果
function YcStringHelper.concatWithoutNil(...)
  local num = select("#", ...)
  local str = ''
  for i = 1, num do
    local arg = select(i, ...)
    if arg ~= nil then
      str = str .. YcStringHelper.toString(arg)
    end
  end
  return str
end

--- 拼接数组中所有元素
---@param t any[] 任意数组
---@param c string 用于连接数组中各个元素的字符串
---@param k string | nil 如果是对象数组，则k是对象的键
---@return string 拼接结果
function YcStringHelper.join(t, c, k)
  c = c or ','
  local str = ''
  local len = #t
  for i, v in ipairs(t) do
    if k then
      str = YcStringHelper.concat(str, v[k])
    else
      str = YcStringHelper.concat(str, v)
    end
    if i ~= len then
      str = YcStringHelper.concat(str, c)
    end
  end
  return str
end

--- 切分字符串
---@param str string 需要被切分的字符串
---@param s string 用于切分的字符串
---@param limit integer | nil 限制切分后数组的长度，nil表示不限制
---@return string[] 结果字符串数组
function YcStringHelper.split(str, s, limit)
  if s == nil then
    s = ''
  else
    s = tostring(s)
  end
  local len = #s -- 用来分割的字符串的长度
  local length = #str -- 被切分的字符串长度
  local index = 1 -- 开始搜索位置
  local arr = {} -- 结果数组
  local arrIndex = 1 -- 数组序号
  while not limit or #arr < limit do
    local startIndex, finishIndex = string.find(str, s, index)
    if startIndex then -- 找到切分字符
      if finishIndex == startIndex - 1 then -- 表示分隔字符为空字符串
        if startIndex > length then -- 如果越界
          break
        else
          startIndex = startIndex + 1 -- 更新本次截取的边界
        end
      end
      arr[arrIndex] = string.sub(str, index, startIndex - 1) -- 截取到匹配位置的前一个
      arrIndex = arrIndex + 1 -- 数组序号递增
      index = startIndex + len -- 更新开始搜索位置
    else -- 没找到切分字符
      arr[arrIndex] = string.sub(str, index) -- 截取剩下字符串
      break
    end
  end
  return arr
end
