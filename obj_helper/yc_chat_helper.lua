--- 聊天工具类 v1.0.2
--- created by 莫小仙 on 2022-05-29
--- last modified on 2023-08-05
YcChatHelper = {
  SPEAK_COLOR = '#ceeeeee', -- 说话内容颜色
  SEPARATOR = '-------' -- 分隔符内容
}

--- 对玩家发送聊天框信息
---@param objid integer 迷你号
---@vararg any 拼接信息内容
function YcChatHelper.sendMsg(objid, ...)
  local str = YcStringHelper.concat(...)
  return Chat:sendSystemMsg(str, objid)
end

--- 尝试对玩家发送聊天框消息
---@param objid integer 迷你号
---@param seconds number 间隔秒数，即每隔几秒才能发送一次
---@param t string | nil 类型
---@return nil
function YcChatHelper.trySendMsg(objid, seconds, t, ...)
  seconds = seconds or 1
  t = t or 'trySendMsgTo'
  local content = YcStringHelper.concat(...)
  YcTimeHelper.newCanPerformTask(function()
    YcChatHelper.sendMsg(objid, content)
  end, seconds, objid .. t)
end

--- 对玩家发送多行（段）聊天框信息
---@param objid integer 迷你号
---@vararg string 每个参数表示一行（段）信息
---@return nil
function YcChatHelper.sendLinesMsg(objid, ...)
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

--- 模拟玩家/NPC说
---@param name string 玩家/NPC名称
---@param toobjid integer 目标玩家迷你号
---@vararg any 拼接说话内容信息
function YcChatHelper.speak(name, toobjid, ...)
  return YcChatHelper.sendMsg(toobjid, name, '：', YcChatHelper.SPEAK_COLOR, ...)
end

--- 模拟玩家/NPC思考
---@param name string 玩家/NPC名称
---@param toobjid integer 目标玩家迷你号
---@vararg any 拼接思考内容信息
function YcChatHelper.think(name, toobjid, ...)
  local content = YcStringHelper.concat(...)
  return YcChatHelper.sendMsg(toobjid, name, '：', YcChatHelper.SPEAK_COLOR, '（', content, YcChatHelper.SPEAK_COLOR,
    '）')
end

--- 一定时间后发送聊天框信息
---@param toobjid integer 接收信息的玩家的迷你号
---@param seconds number 延迟秒数。非正数时表示立即发送
---@return nil
function YcChatHelper.waitSendMsg(toobjid, seconds, ...)
  seconds = seconds or 2
  if seconds <= 0 then -- 时间为非正数，则立即执行
    YcChatHelper.sendMsg(toobjid, ...)
  else -- 延迟执行
    local content = YcStringHelper.concat(...)
    YcTimeHelper.newAfterTimeTask(function()
      YcChatHelper.sendMsg(toobjid, content)
    end, seconds)
  end
end

--- 模拟玩家/NPC一定时间后说
---@param name string 玩家/NPC名称
---@param toobjid integer 接收信息的玩家的迷你号
---@param seconds number 延迟秒数。非正数时表示立即发送
---@vararg any 拼接说话内容信息
---@return nil
function YcChatHelper.waitSpeak(name, toobjid, seconds, ...)
  seconds = seconds or 2
  if seconds <= 0 then -- 时间为非正数，则立即执行
    YcChatHelper.speak(name, toobjid, ...)
  else -- 延迟执行
    local content = YcStringHelper.concat(...)
    YcTimeHelper.newAfterTimeTask(function()
      YcChatHelper.speak(name, toobjid, content)
    end, seconds)
  end
end

--- 模拟玩家/NPC一定时间后思考
---@param name string 玩家/NPC名称
---@param toobjid integer 接收信息的玩家的迷你号
---@param seconds number 延迟秒数。非正数时表示立即发送
---@vararg any 拼接思考内容信息
---@return nil
function YcChatHelper.waitThink(name, toobjid, seconds, ...)
  seconds = seconds or 2
  if seconds <= 0 then -- 时间为非正数，则立即执行
    YcChatHelper.think(name, toobjid, ...)
  else -- 延迟执行
    local content = YcStringHelper.concat(...)
    YcTimeHelper.newAfterTimeTask(function()
      YcChatHelper.think(name, toobjid, content)
    end, seconds)
  end
end

--- 显示分隔符
---@param toobjid integer 目标玩家的迷你号
---@param title string 分隔符标题
---@return nil
function YcChatHelper.showSeparator(toobjid, title)
  title = title or ''
  YcChatHelper.sendMsg(toobjid, YcChatHelper.SEPARATOR, title, YcChatHelper.SEPARATOR)
end
