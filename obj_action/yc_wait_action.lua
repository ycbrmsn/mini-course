--- 等待行为类 v1.0.0
---created by 莫小仙 on 2024-03-07
---@class YcWaitAction : YcAction 等待行为
---@field _actor YcActor 行为者
---@field _seconds number 等待几秒
---@field _t number 类型
---@field _isPaused boolean 是否是暂停
---@field _group YcActionGroup | nil 所属行为组
---@field NAME string 行为名称
YcWaitAction = YcAction:new({
  NAME = 'wait'
})

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
    self:turnNext() -- 轮到下一个行动
  end, self._seconds)
end

--- 暂停行动
function YcWaitAction:pause()
  self._isPaused = true -- 标记是暂停
  if self._t then
    YcTimeHelper.delAfterTimeTask(self._t)
    self._t = nil
  end
end

--- 恢复行动
function YcWaitAction:resume()
  self:start()
end

--- 停止行动
---@param isTurnNext boolean | nil 停止行动后是否轮到下一个行动。默认不会
function YcWaitAction:stop(isTurnNext)
  self:pause()
  if isTurnNext then
    self:turnNext()
  end
end
