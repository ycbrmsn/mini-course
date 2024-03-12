--- 看行为类 v1.0.0
---created by 莫小仙 on 2023-12-18
---@class YcLookAction : YcAction 看行为
---@field _actor YcActor 行为者
---@field _toobjid integer | YcActor | YcPosition 目标玩家id/生物id 或 目标玩家/生物 或 位置
---@field _seconds number 看几秒
---@field _t string | number 类型
YcLookAction = YcAction:new()

--- 实例化一个持续看行为
---@param actor YcActor 行为者
---@param toobjid integer | YcActor | YcPosition 目标玩家id/生物id 或 目标玩家/生物 或 位置
---@param seconds number | nil 持续看的时间（秒）
---@return YcLookAction 持续看行为
function YcLookAction:new(actor, toobjid, seconds)
  seconds = seconds or 10
  local o = {
    _actor = actor,
    _toobjid = toobjid,
    _seconds = seconds
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 开始行动
function YcLookAction:start()
  CreatureAPI.setAIActive(self._actor.objid, false) -- 停止AI
  -- 结束时回调
  local callback = function()
    self:runNext() -- 开始下一个行动
  end
  self._t = YcTimeHelper.newContinueTask(function()
    self._actor:lookAt(self._toobjid)
  end, self._seconds, nil, callback)
end

--- 暂停行动
function YcLookAction:pause()
  if self._t then
    YcTimeHelper.delContinueTask(self._t)
    self._t = nil
  end
end

--- 恢复行动
function YcLookAction:resume()
  self:start()
end

--- 停止行动
function YcLookAction:stop()
  self:pause()
end
