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

--- 结束行动
function YcAction:stop()
  -- 在具体行动中实现
end

--- 开始下一个行动
function YcAction:runNext()
  self._actor:performAction() -- 开始下一个行动
end
