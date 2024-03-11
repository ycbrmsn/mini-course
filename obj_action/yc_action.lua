--- 行动类 v1.0.0
--- created by 莫小仙 on 2023-12-18
---@class YcAction 行动
---@field _actor YcActor 行为者
YcAction = {}

--- 实例化一个行动
---@param o table | nil 参数
---@return YcAction 行动
function YcAction:new(o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 开始行动
function YcAction:start()
  -- 在具体行动中实现
end

--- 暂停行动
function YcAction:pause()
  -- 在具体行动中实现
end

--- 恢复行动
function YcAction:resume()
  -- 在具体行动中实现
end

--- 停止行动
function YcAction:stop()
  -- 在具体行动中实现
end

--- 开始下一个行动
function YcAction:runNext()
  if self == self._actor:getAction() then -- 如果当前行动就是第一个行动
    self._actor:shiftAction() -- 删除第一个行动
    self._actor._currentAction = nil -- 当前行动置空
    YcLogHelper.debug('开始下一个行动')
    self._actor:action() -- 开始下一个行动
  end
end
