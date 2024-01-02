--- 道具类 v1.0.2
--- created by 莫小仙 on 2022-06-19
--- last modified on 2024-01-02
---@class YcItem : YcTable 道具
YcItem = YcTable:new({
  TYPE = 'YC_ITEM'
})

--- 实例化
---@param o table 包含道具的基本属性
---@return YcItem 道具对象
function YcItem:new(o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  if o.itemid and YcItemHelper then -- 有itemid 且 道具工具类存在
    YcItemHelper.register(o) -- 注册道具
  end
  return o
end

--- 拿起道具(手上)
--- 接口，具体实现在继承的类中
---@param objid integer 迷你号/生物id
---@return nil
function YcItem:pickUp(objid)
  -- body
end

--- 放下道具(手上)
--- 接口，具体实现在继承的类中
---@param objid integer 迷你号/生物id
---@return nil
function YcItem:putDown(objid)
  -- body
end

--- 新增道具
--- 接口，具体实现在继承的类中
---@param objid integer 迷你号/生物id
---@param itemnum integer 道具数量
---@return nil
function YcItem:addItem(objid, itemnum)
  -- body
end

--- 使用道具
--- 接口，具体实现在继承的类中
---@param objid integer 迷你号/生物id
---@param itemnum integer 道具数量
---@return nil
function YcItem:useItem(objid, itemnum)
  -- body
end

--- 消耗道具
--- 接口，具体实现在继承的类中
---@param objid integer 迷你号/生物id
---@param itemnum integer 道具数量
---@return nil
function YcItem:consumeItem(objid, itemnum)
  -- body
end

--- 丢弃道具
--- 接口，具体实现在继承的类中
---@param objid integer 迷你号/生物id
---@param itemnum integer 道具数量
---@return nil
function YcItem:discardItem(objid, itemnum)
  -- body
end

--- 选择道具
--- 接口，具体实现在继承的类中
---@param objid integer 迷你号/生物id
---@param itemnum integer 道具数量
---@return nil
function YcItem:selectItem(objid)
  -- body
end

--- 使用技能
--- 接口，具体实现在继承的类中
---@param objid integer 迷你号/生物id
---@param index integer 技能序号，从1开始。当一件道具设置了多个技能时，则需要判断技能序号
---@return nil
function YcItem:useSkill(objid, index)
  -- body
end

--- 手持道具点击方块
--- 接口，具体实现在继承的类中
---@param objid integer 迷你号/生物id
---@param blockid integer 方块id
---@param x number 方块位置x
---@param y number 方块位置y
---@param z number 方块位置z
---@return nil
function YcItem:clickBlock(objid, blockid, x, y, z)
  -- body
end

--- 手持道具攻击命中
--- 接口，具体实现在继承的类中
---@param objid integer 发动攻击对象id
---@param toobjid integer 被命中对象id
---@return nil
function YcItem:attackHit(objid, toobjid)
  -- body
end

--- 该道具相关的投掷物命中。如道具枪射出的子弹命中
--- 接口，具体实现在继承的类中
---@param projectileid integer 投掷物id
---@param objid integer 投掷物所属对象id，即表示投掷物是谁的
---@param toobjid integer 被命中对象id
---@param blockid integer 方块id
---@param x number 命中的位置x
---@param y number 命中的位置y
---@param z number 命中的位置z
---@return nil
function YcItem:projectileHit(projectileid, objid, toobjid, blockid, x, y, z)
  -- body
end
