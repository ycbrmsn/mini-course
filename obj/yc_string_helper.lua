--[[
  字符串工具类 v1.0.0
  create by 莫小仙 on 2022-05-22
]]
YcStringHelper = {}

-- 转换为字符串
function YcStringHelper.toString (obj)
  if type(obj) == 'table' then
    return YcStringHelper.tableToString (obj)
  else
    return tostring(obj)
  end
end

-- 表转换为字符串
function YcStringHelper.tableToString (t)
  local str = '{ '
  local index = 1
  for k, v in pairs(t) do
    if index ~= 1 then
      str = str .. ', '
    end
    str = str .. k .. ' = ' .. YcStringHelper.toString(v)
    index = index + 1
  end
  str = str .. ' }'
  return str
end

-- 拼接所有参数
function YcStringHelper.concat (...)
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

-- 拼接数组中所有元素
function YcStringHelper.join (t, c, k)
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

-- 切分字符串
function YcStringHelper.split (str, s, limit)
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
