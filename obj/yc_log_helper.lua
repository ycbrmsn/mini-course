--[[ 日志工具类 v1.0.0
  create by 莫小仙 on 2022-05-31
]]
YcLogHelper = {
  LIST_ERROR_RECORDS_TYPE = 'listErrorRecordsType', -- 显示错误信息类型字符串
  LEVEL_COLORS = { '#c3adf00', '#cf2f2f2', '#cffbf00', '#cfe2e2e' }, -- 各日志级别信息对应文字颜色
  level = 'debug', -- 日志级别：debug info warn error off
  errorRecords = {}, -- 错误记录
  errorTimes = {} -- 不同错误出现次数
}

-- 显示调试信息
function YcLogHelper.debug (...)
  local level = string.lower(YcLogHelper.level)
  if level == 'debug' then
    local message = YcStringHelper.concat(...)
    YcChatHelper.sendMsg(nil, YcLogHelper.LEVEL_COLORS[1], 'DEBUG: ', message) -- 显示聊天框信息
    print('DEBUG: ', message) -- 打印调试信息
  end
end

-- 显示普通信息
function YcLogHelper.info (...)
  local level = string.lower(YcLogHelper.level)
  if level == 'debug' or level == 'info' then
    local message = YcStringHelper.concat(...)
    YcChatHelper.sendMsg(nil, YcLogHelper.LEVEL_COLORS[2], 'INFO: ', message) -- 显示聊天框信息
    print('INFO: ', message) -- 打印调试信息
  end
end

-- 显示警告信息
function YcLogHelper.warn (...)
  local level = string.lower(YcLogHelper.level)
  if level == 'debug' or level == 'info' or level == 'warn' then
    local message = YcStringHelper.concat(...)
    YcChatHelper.sendMsg(nil, YcLogHelper.LEVEL_COLORS[3], 'WARN: ', message) -- 显示聊天框信息
    print('WARN: ', message) -- 打印调试信息
  end
end

-- 显示错误信息
function YcLogHelper.error (...)
  local level = string.lower(YcLogHelper.level)
  if level ~= 'off' then
    local message = YcStringHelper.concat(...)
    YcChatHelper.sendMsg(nil, YcLogHelper.LEVEL_COLORS[4], 'ERROR: ', message) -- 显示聊天框信息
    print('ERROR: ', message) -- 打印调试信息
  end
end

-- 捕获错误并记录
function YcLogHelper.try (f)
  xpcall(f, function (err)
    YcLogHelper.error(err)
    local num = YcLogHelper.errorTimes[err] -- 错误出现次数
    if not num then -- 没出现过
      table.insert(YcLogHelper.errorRecords, err) -- 添加错误记录
      YcLogHelper.errorTimes[err] = 1
    else -- 出现过
      YcLogHelper.errorTimes[err] = YcLogHelper.errorTimes[err] + 1
    end
  end)
end

-- 显示错误信息
function YcLogHelper.startShowErrorRecords (objid)
  if #YcLogHelper.errorRecords == 0 then -- 错误记录数为0
    YcChatHelper.sendMsg(objid, '太棒了，当前没有错误')
  else -- 错误数不为0
    YcChatHelper.sendMsg(objid, '警告，当前有', #YcLogHelper.errorRecords, '条错误信息，下面开始显示：')
    local t = objid .. YcLogHelper.LIST_ERROR_RECORDS_TYPE
    YcTimeHelper.delAfterTimeTask(t) -- 停止错误信息显示，避免重复显示
    -- 1秒后开始显示错误信息
    YcTimeHelper.newAfterTimeTask(function ()
      YcLogHelper.listErrorRecords(objid)
    end, 1, t)
  end
end

-- 列出错误信息
function YcLogHelper.listErrorRecords (objid, index)
  index = index or 1
  if index <= #YcLogHelper.errorRecords then -- 还有错误信息
    YcChatHelper.sendMsg(objid, YcLogHelper.errorRecords[index]) -- 显示信息
    index = index + 1
    -- 1秒后显示下一条错误信息
    YcTimeHelper.newAfterTimeTask(function ()
      YcLogHelper.listErrorRecords(objid, index)
    end, 1, objid .. YcLogHelper.LIST_ERROR_RECORDS_TYPE)
  end
end

-- 停止显示错误信息
function YcLogHelper.stopShowErrorRecords (objid)
  YcTimeHelper.delAfterTimeTask(objid .. YcLogHelper.LIST_ERROR_RECORDS_TYPE)
  YcChatHelper.sendMsg(objid, '错误信息已停止显示')
end

local playerNewInputContent = function (event)
  local objid, content = event.eventobjid, event.content
  if content == 'l=1' then -- level = 1
    YcLogHelper.level = 'debug'
    YcChatHelper.sendMsg(objid, '日志等级切换为debug')
  elseif content == 'l=2' then -- level = 2
    YcLogHelper.level = 'info'
    YcChatHelper.sendMsg(objid, '日志等级切换为info')
  elseif content == 'l=3' then -- level = 3
    YcLogHelper.level = 'warn'
    YcChatHelper.sendMsg(objid, '日志等级切换为warn')
  elseif content == 'l=4' then -- level = 4
    YcLogHelper.level = 'error'
    YcChatHelper.sendMsg(objid, '日志等级切换为error')
  elseif content == 'l=5' then -- level = 5
    YcLogHelper.level = 'off'
    YcChatHelper.sendMsg(objid, '日志已关闭')
  elseif content == 'OER' then -- openErrorRecords
    YcLogHelper.startShowErrorRecords(objid)
  elseif content == 'CER' then -- closeErrorRecords
    YcLogHelper.stopShowErrorRecords(objid)
  end
end

ScriptSupportEvent:registerEvent([=[Player.NewInputContent]=], playerNewInputContent) -- 输入字符串
