--- 行动类 v1.0.0
--- created by 莫小仙 on 2023-12-18
---@class YcAction 行动
---@field _actor YcActor 行为者
---@field _isPaused boolean 是否是暂停
---@field _group YcActionGroup | nil 所属行为组
---@field NAME string 行为名称
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
---@param isTurnNext boolean | nil 停止行动后是否轮到下一个行动。默认不会
function YcAction:stop(isTurnNext)
  -- 在具体行动中实现
end

--- 开始下一个行动
function YcAction:_turnNext()
  if self._group then -- 如果有所属行为组
    self._group:_turnNext() -- 开始行为组里的下一个
  else
    YcLogHelper.warn('缺失行为组')
  end
end

--- 设置所属行为组
function YcAction:setGroup(group)
  self._group = group
  return self
end
