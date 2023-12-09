--- 奖励类 v1.0.0
--- created by 莫小仙 on 2023-10-17
---@class YcReward : YcRewardParam
YcReward = {
  TYPE = 'YC_REWARD'
}

--- 用于实例化任务奖励的参数
---@class YcRewardParam
---@field category "1" | "2" | "3" 奖励类型：1道具；2经验；3其他
---@field itemid integer 奖励道具id
---@field num integer 奖励道具数量/经验值
---@field desc string 奖励描述
---@field f fun(playerid: number): void 获得奖励后的调用函数（也可用于自定义实现其他奖励）
YcRewardParam = {}

--- 是否是一个任务奖励
---@param o any 判断对象
---@return boolean 是否是任务奖励
function YcReward.isReward(o)
  return type(o) == 'table' and o.TYPE == YcReward.TYPE
end

--- 实例化
---@param o YcRewardParam 任务奖励参数
---@return YcReward 任务奖励对象
function YcReward:new(o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 实例化一个道具类型的奖励
---@param itemid integer 道具类型id
---@param num integer 奖励道具数量
---@param desc string | nil 奖励描述
---@return YcReward 任务奖励对象
function YcReward:newItemType(itemid, num, desc)
  return YcReward:new({
    category = 1,
    itemid = itemid,
    num = num,
    desc = desc
  })
end

--- 实例化一个经验类型的奖励
---@param num integer 经验值
---@param desc string | nil 奖励描述
---@return YcReward 任务奖励对象
function YcReward:newExpType(num, desc)
  return YcReward:new({
    category = 2,
    num = num,
    desc = desc
  })
end

--- 实例化一个自定义类型的奖励
---@param f fun(playerid: integer) : void 调用函数
---@param desc string | nil 奖励描述
---@return YcReward 任务奖励对象
function YcReward:newFunType(f, desc)
  return YcReward:new({
    category = 3,
    f = f,
    desc = desc
  })
end

--- 设置获得奖励后的调用内容，比如推动剧情、获得其他自定义奖励等
---@param f fun(playerid: number): void 获得奖励后的调用函数
---@return YcReward 任务奖励对象
function YcReward:after(f)
  self.f = f
  return self
end
