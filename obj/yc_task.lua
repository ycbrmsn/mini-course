--- 任务类 v1.0.0
--- created by 莫小仙 on 2023-11-12
---@class YcTask : YcTaskParam
---@field objectives YcArray<YcObjective> 任务目标集合
YcTask = {
  TYPE = 'YC_TASK'
}

--- 用于实例化任务的参数
---@class YcTaskParam
---@field name string 任务名称
---@field desc string 任务描述
---@field itemid integer 任务书，用于不重置地图时记录玩家任务。即如果有任务书，则表示玩家接受了任务
---@field isSingleton boolean 任务是否是唯一。用于标志任务是否可以重复接
---@field objectives YcObjective[] 任务目标集合
---@field rewardMsg string 任务奖励描述。如果不为空，则奖励显示这个
---@field rewards YcReward[] 任务奖励
YcTaskParam = {}

--- 是否是一个任务对象
---@param o any 判断对象
---@return boolean 是否是任务对象
function YcTask.isTask(o)
  return type(o) == 'table' and o.TYPE == YcTask.TYPE
end

--- 实例化任务
---@param o YcTaskParam 任务参数
---@return YcTask 任务对象
function YcTask:new(o)
  o = o or {}
  if YcTask._check(o) then
    YcTask._switchToArray(o)
  end
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 自定义表的输出内容
---@return string 输出内容
function YcTask:__tostring()
  return YcStringHelper.concat('{id=', self.id, ',name=', self.name, ',TYPE=', self.TYPE, '}')
end

--- 检查数组函数
---@param o table 被检查表
function YcTask._check(o)
  if o.objectives and type(o.objectives) ~= 'table' then -- 如果任务目标存在，且不是一个表
    YcLogHelper:error('任务目标必须是一个数组')
    return false
  end
  if o.rewards and type(o.rewards) ~= 'table' then -- 如果任务奖励存在，且不是一个表
    YcLogHelper:error('任务奖励必须是一个数组')
    return false
  end
  return true
end

--- 将表中的普通数组转成自定义数组
---@param o table
function YcTask._switchToArray(o)
  if o.objectives and not YcArray.isArray(o.objectives) then -- 如果任务目标存在 且 不是数组
    o.objectives = YcArray:new(o.objectives)
  end
  if o.rewards and not YcArray.isArray(o.rewards) then -- 如果任务奖励存在 且 不是数组
    o.rewards = YcArray:new(o.rewards)
  end
end
