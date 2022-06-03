--[[ 聊天工具类 v1.0.1
  create by 莫小仙 on 2022-05-29
  last modified on 2022-06-03
]]
YcChatHelper = {
  SPEAK_COLOR = '#ceeeeee', -- 说话内容颜色
  SEPARATOR = '-------' -- 分隔符内容
}

-- 对玩家发送聊天框信息
function YcChatHelper.sendMsg (objid, ...)
  local str = YcStringHelper.concat(...)
  return Chat:sendSystemMsg(str, objid)
end

-- 尝试对玩家发送聊天框消息
function YcChatHelper.trySendMsg (objid, seconds, t, ...)
  seconds = seconds or 1
  t = t or 'trySendMsg'
  local content = YcStringHelper.concat(...)
  YcTimeHelper.newCanPerformTask(function ()
    YcChatHelper.sendMsg(objid, content)
  end, seconds, objid .. t)
end

-- 对玩家发送多行聊天框信息
function YcChatHelper.sendLinesMsg (objid, ...)
  local num = select("#", ...)
  local str
  for i = 1, num do
    local arg = select(i, ...)
    if arg ~= nil then
      str = YcStringHelper.toString(arg)
      YcChatHelper.sendMsg(objid, str)
    end
  end
end

-- 模拟玩家/NPC说
function YcChatHelper.speak (name, toobjid, ...)
  return YcChatHelper.sendMsg(toobjid, name, '：', YcChatHelper.SPEAK_COLOR, ...)
end

-- 模拟玩家/NPC思考
function YcChatHelper.think (name, toobjid, ...)
  local content = YcStringHelper.concat(...)
  return YcChatHelper.sendMsg(toobjid, name, '：', YcChatHelper.SPEAK_COLOR, '（', content, YcChatHelper.SPEAK_COLOR, '）')
end

-- 一定时间后发送聊天框信息
function YcChatHelper.waitSendMsg (objid, seconds, ...)
  seconds = seconds or 2
  if (seconds <= 0) then -- 时间为非正数，则立即执行
    YcChatHelper.sendMsg(objid, ...)
  else -- 延迟执行
    local content = YcStringHelper.concat(...)
    YcTimeHelper.newAfterTimeTask(function ()
      YcChatHelper.sendMsg(objid, content)
    end, seconds)
  end
end

-- 模拟玩家/NPC一定时间后说
function YcChatHelper.waitSpeak (name, toobjid, seconds, ...)
  seconds = seconds or 2
  if (seconds <= 0) then -- 时间为非正数，则立即执行
    YcChatHelper.speak(name, toobjid, ...)
  else -- 延迟执行
    local content = YcStringHelper.concat(...)
    YcTimeHelper.newAfterTimeTask(function ()
      YcChatHelper.speak(name, toobjid, content)
    end, seconds)
  end
end

-- 模拟玩家/NPC一定时间后思考
function YcChatHelper.waitThink (name, toobjid, seconds, ...)
  seconds = seconds or 2
  if (seconds <= 0) then -- 时间为非正数，则立即执行
    YcChatHelper.think(name, toobjid, ...)
  else -- 延迟执行
    local content = YcStringHelper.concat(...)
    YcTimeHelper.newAfterTimeTask(function ()
      YcChatHelper.think(name, toobjid, content)
    end, seconds)
  end
end

-- 显示分隔符
function YcChatHelper.showSeparator (objid, title)
  title = title or ''
  YcChatHelper.sendMsg(objid, YcChatHelper.SEPARATOR, title, YcChatHelper.SEPARATOR)
end
