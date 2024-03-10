--- 跟随行为类 v1.0.0
---created by 莫小仙 on 2024-03-11
---@class YcFollowAction 跟随行为
---@field _actor YcActor 行为者
---@field _toobjid integer 目标玩家id/生物id
---@field _distance number 最大活动范围。超过该范围将进入跟随状态。默认为6米
---@field _action YcAction | nil 非跟随状态下的行为。默认什么都不做
YcFollowAction = YcAction:new()

---@class YcFollowActionOption 跟随行为的其他配置信息
---@field distance number 最大活动范围。超过该范围将进入跟随状态。默认为6米
---@field action YcAction | nil 非跟随状态下的行为。默认什么都不做
YcFollowActionOption = {}

--- 实例化一个跟随行为
---@param actor YcActor 行为者
---@param toobjid integer 目标玩家id/生物id
---@param option YcFollowActionOption 跟随行为的其他配置信息
---@return YcLookAction 持续看行为
function YcFollowAction:new(actor, toobjid, option)
  option = option or {}
  local distance = option.distance or 6
  local action = option.action
  local o = {
    _actor = actor,
    _toobjid = toobjid,
    _distance = distance,
    _action = action
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 开始行动
function YcFollowAction:start()
  
end

--- 暂停行动
function YcFollowAction:pause()
  
end

--- 恢复行动
function YcFollowAction:resume()
  
end

--- 停止行动
function YcFollowAction:stop()
  
end