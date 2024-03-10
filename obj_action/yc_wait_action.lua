--- 等待行为类 v1.0.0
---created by 莫小仙 on 2024-03-07
---@class YcWaitAction : YcAction 等待行为
---@field _actor YcActor 行为者
---@field _seconds number 等待几秒
---@field _t number 类型
YcWaitAction = YcAction:new()

--- 实例化一个等待行为
---@param actor YcActor 行为者
---@param seconds number | nil 等待几秒。默认3秒
---@return YcWaitAction 等待行为
function YcWaitAction:new(actor, seconds)
  seconds = seconds or 3
  local o = {
    _actor = actor,
    _seconds = seconds
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 开始行动
function YcWaitAction:start()
  CreatureAPI.setAIActive(self._actor.objid, false) -- 停止AI
  self._t = YcTimeHelper.newAfterTimeTask(function()
    self:runNext() -- 开始下一个行动
  end, self._seconds)
end

--- 暂停行动
function YcWaitAction:pause()
  YcTimeHelper.delAfterTimeTask(self._t)
end

--- 恢复行动
function YcWaitAction:resume()
  self:start()
end

--- 停止行动
function YcWaitAction:stop()
  self:pause()
end
