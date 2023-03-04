--[[ API工具类 v1.0.0
  create by 莫小仙 on 2022-06-03
]]
YcApiHelper = {
  levels = { 'debug', 'info', 'warn' } -- 显示API调用失败的日志级别
}

-- lua5.1版本为unpack，lua5.3为table.unpack
if not table.unpack then
  table.unpack = unpack
end

-- 是否是满足条件的日志级别
function YcApiHelper.isSatisfiedLevel ()
  local lv = string.lower(YcLogHelper.level)
  for i, level in ipairs(YcApiHelper.levels) do
    if lv == level then
      return true
    end
  end
  return false
end

-- 显示API调用失败警告信息 methodDesc:接口描述 ... 参数名=参数值
function YcApiHelper.warn (methodDesc, ...)
  if methodDesc and YcApiHelper.isSatisfiedLevel() then
    local msg = YcStringHelper.concat(...)
    if #msg > 0 then
      msg = '，参数：' .. msg
    end
    YcLogHelper.warn(methodDesc, '失败', msg)
  end
end

-- f:函数 methodDesc:接口描述 ... 参数名=参数值
function YcApiHelper.callIsSuccessMethod (f, methodDesc, ...)
  local result = f()
  if result == ErrorCode.OK then
    return true
  end
  YcApiHelper.warn(methodDesc, ...)
  return false
end

-- f:函数 methodDesc:接口描述 ... 参数名=参数值
function YcApiHelper.callResultMethod (f, methodDesc, ...)
  local arr = { f() }
  if arr[1] == ErrorCode.OK then
    return table.unpack(arr, 2)
  end
  YcApiHelper.warn(methodDesc, ...)
  return nil
end
