--- 动作行为类 v1.0.0
---created by 莫小仙 on 2024-03-07
---@class YcActAction : YcAction 动作行为
---@field _actor YcActor 行为者
---@field _actid integer 动作id
---@field _seconds number 做几秒会结束
---@field _isPaused boolean 是否是暂停
---@field _group YcActionGroup | nil 所属行为组
---@field NAME string 行为名称
YcActAction = YcAction:new({
  NAME = 'act'
})

--- 实例化一个动作行为
---@param actor YcActor 行为者
---@param actid integer 动作id
---@param seconds number 做几秒会结束。默认2秒
---@return YcActAction 动作行为
function YcActAction:new(actor, actid, seconds)
  seconds = seconds or 2
  local o = {
    _actor = actor,
    _actid = actid,
    _seconds = seconds,
    _isPaused = false
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 开始行动
function YcActAction:start()
  CreatureAPI.setAIActive(self._actor.objid, false) -- 停止AI
  self._isPaused = false
  ActorAPI.playAct(self._actor.objid, self._actid)
  self._t = YcTimeHelper.newAfterTimeTask(function()
    self:turnNext() -- 轮到下一个行动
  end, self._seconds)
end

--- 暂停行动
function YcActAction:pause()
  self._isPaused = true -- 标记是暂停
  if self._t then
    YcTimeHelper.delAfterTimeTask(self._t)
    self._t = nil
  end
end

--- 恢复行动
function YcActAction:resume()
  self:start()
end

--- 停止行动
---@param isTurnNext boolean | nil 停止行动后是否轮到下一个行动。默认不会
function YcActAction:stop(isTurnNext)
  self:pause()
  if isTurnNext then
    self:turnNext()
  end
end
