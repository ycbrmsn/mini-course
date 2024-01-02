--- 任务目标类 v1.0.1
--- created by 莫小仙 on 2023-11-12
--- last modified on 2023-12-20
---@class YcObjective : YcTable 任务目标
---@field category "1" | "2" | "3" | "99" 任务目标类型：1击败生物；2交付道具；3达到等级；99自定义目标
--- 击败生物类型对应属性
---@field actorid integer 生物类型id
---@field actorname string 生物名称
---@field total integer 需要击败的生物数量
---@field num integer 已经击败的生物数量
--- 交付道具类型对应属性
---@field itemid integer 道具类型id
---@field total integer 需要交付的道具数量
---@field num integer 背包内已有的道具数量
--- 达到等级类型对应属性
---@field minLevel integer 需要达到的最低等级
---@field maxLevel integer 不得超过的最高等级
---@field level integer 当前等级
--- 自定义类型对应属性
---@field f fun(playerid: integer) 判断是否完成目标的函数
YcObjective = YcTable:new({
  TYPE = 'YC_OBJECTIVE'
})

--- 是否是一个任务目标
---@param o any 判断对象
---@return boolean 是否是任务目标
function YcObjective.isObjective(o)
  return type(o) == 'table' and o.TYPE == YcObjective.TYPE
end

--- 实例化一个空任务目标
---@return YcObjective 任务目标
function YcObjective:new(o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 实例化一个击败生物类型的任务目标
---@param actorid integer 生物类型id
---@param actorname string 生物名称
---@param total integer 需要击败的生物数量
---@return YcObjective 任务目标
function YcObjective:newBeatType(actorid, actorname, total)
  if actorid == nil then
    YcLogHelper.error('未设定需要击败的生物类型')
  end
  if actorname == nil then
    YcLogHelper.error('未设定需要击败的生物名称')
  end
  total = total or 1 -- 默认1个
  return YcObjective:new({
    category = YcObjectiveCategory.BEAT,
    actorid = actorid,
    actorname = actorname,
    total = total
  })
end

--- 实例化一个交付道具类型的任务目标
---@param itemid integer 道具类型id
---@param total integer 需要交付的道具数量
---@return YcObjective 任务目标
function YcObjective:newItemType(itemid, total)
  if itemid == nil then
    YcLogHelper.error('未设定需要交付的道具类型')
  end
  total = total or 1 -- 默认1个
  return YcObjective:new({
    category = YcObjectiveCategory.ITEM,
    itemid = itemid,
    total = total
  })
end

--- 实例化一个达到等级类型的任务目标
---@param minLevel integer | nil 最低等级。nil表示不限制最低等级
---@param maxLevel integer | nil 最高等级。nil表示不限制最高等级
---@return YcObjective 任务目标
function YcObjective:newLevelType(minLevel, maxLevel)
  return YcObjective:new({
    category = YcObjectiveCategory.LEVEL,
    minLevel = minLevel,
    maxLevel = maxLevel
  })
end

--- 实例化一个自定义类型的任务目标
---@param f fun(playerid: integer): boolean
---@return YcObjective 任务目标
function YcObjective:newCustomType(f)
  if type(f) ~= 'function' then
    YcLogHelper.error('自定义任务目标不是一个函数')
  end
  return YcObjective:new({
    category = YcObjectiveCategory.CUSTOM,
    f = f
  })
end

--- 复制任务目标并初始化与玩家相关的数据
---@param playerid integer 玩家id/迷你号
---@return nil
function YcObjective:copyAndInit(playerid)
  if self.category == nil then
    YcLogHelper.error('还未设置具体的任务目标')
  end
  local obj = self:clone()
  if obj.category == YcObjectiveCategory.BEAT then -- 击败生物任务
    obj.num = 0
  elseif obj.category == YcObjectiveCategory.ITEM then -- 交付道具任务
    obj.num = YcBackpackHelper.getItemNumAndGrids(playerid, obj.itemid)
  elseif obj.category == YcObjectiveCategory.LEVEL then -- 达到等级任务
    obj.level = YcPlayerHelper.getLevel(playerid)
  end
  return obj
end

--- 任务目标是否达成
---@param playerid integer 玩家id/迷你号
---@return boolean 是否达成
function YcObjective:isAchieved(playerid)
  if self.category == YcObjectiveCategory.BEAT then -- 击败生物任务
    return self.num >= self.total
  elseif self.category == YcObjectiveCategory.ITEM then -- 交付道具任务
    self.num = YcBackpackHelper.getItemNumAndGrids(playerid, self.itemid) -- 顺便更新道具数量
    return self.num >= self.total
  elseif self.category == YcObjectiveCategory.LEVEL then -- 达到等级任务
    self.level = YcPlayerHelper.getLevel(playerid) -- 顺便更新玩家等级
    return (self.minLevel == nil or self.level >= self.minLevel) and
             (self.maxLevel == nil or self.level <= self.maxLevel)
  elseif self.category == YcObjectiveCategory.CUSTOM then -- 自定义任务
    return self.f(playerid)
  end
end

--- 克隆一个任务目标
---@return YcObjective 新任务目标
function YcObjective:clone()
  local objective = YcObjective:new()
  for k, v in pairs(self) do
    objective[k] = v
  end
  return objective
end

--- 自定义表的输出内容
---@return string 输出内容
function YcObjective:__tostring()
  local category = self.category
  local str = YcStringHelper.concat('{category=', category)
  if category == YcObjectiveCategory.BEAT then
    str = str ..
            YcStringHelper.concat(',actorid=', self.actorid, ',actorname=', self.actorname, ',total=', self.total,
        ',num=', self.num, '}')
  elseif category == YcObjectiveCategory.ITEM then
    str = str .. YcStringHelper.concat(',itemid=', self.itemid, ',total=', self.total, ',num=', self.num, '}')
  elseif category == YcObjectiveCategory.LEVEL then
    str = str ..
            YcStringHelper.concat(',minLevel=', self.minLevel, ',maxLevel=', self.maxLevel, ',level=', self.level, '}')
  elseif category == YcObjectiveCategory.CUSTOM then
    str = str .. YcStringHelper.concat('f=', self.f, '}')
  else
    str = str .. '}'
  end
  return str
end

--- 任务目标类型
YcObjectiveCategory = {
  BEAT = 1, -- 击败生物类型
  ITEM = 2, -- 交付道具类型
  LEVEL = 3, -- 达到等级类型
  CUSTOM = 99 -- 自定义类型
}

-- 缩写
YcObj = YcObjective
YcObj.newBT = YcObj.newBeatType
YcObj.newIT = YcObj.newItemType
YcObj.newLT = YcObj.newLevelType
YcObj.newCT = YcObj.newCustomType
