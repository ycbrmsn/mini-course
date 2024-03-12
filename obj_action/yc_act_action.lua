--- 动作行为类 v1.0.0
---created by 莫小仙 on 2024-03-07
---@class YcActAction : YcAction 动作行为
---@field _actor YcActor 行为者
---@field _actid integer 动作id
---@field _seconds number 做几秒会结束
YcActAction = YcAction:new()

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
    _seconds = seconds
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 开始行动
function YcActAction:start()
  CreatureAPI.setAIActive(self._actor.objid, false) -- 停止AI
  ActorAPI.playAct(self._actor.objid, self._actid)
  self._t = YcTimeHelper.newAfterTimeTask(function()
    self:runNext() -- 开始下一个行动
  end, self._seconds)
end

--- 暂停行动
function YcActAction:pause()
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
function YcActAction:stop()
  self:pause()
end
