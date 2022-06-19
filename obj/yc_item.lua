--[[ 道具类 v1.0.0
  create by 莫小仙 on 2022-06-19
]]
YcItem = {}

--[[
  实例化
  @param  {table} o 包含道具的基本属性
  @return {YcItem} 道具对象
]]
function YcItem:new (o)
  o = o or {}
  self.__index = self
  setmetatable(o, self)
  if o.itemid and YcItemHelper then -- 有itemid 且 道具工具类存在
    YcItemHelper.register(o) -- 注册道具
  end
  return o
end

--[[
  拿起道具(手上)
  @param  {integer} objid 迷你号/生物id
  @return {nil}
]]
function YcItem:pickUp (objid)
  -- body
end

--[[
  放下道具(手上)
  @param  {integer} objid 迷你号/生物id
  @return {nil}
]]
function YcItem:putDown (objid)
  -- body
end

--[[
  新增道具
  @param  {integer} objid 迷你号/生物id
  @return {nil}
]]
function YcItem:addItem (objid, itemnum)
  -- body
end

--[[
  使用道具
  @param  {integer} objid 迷你号/生物id
  @return {nil}
]]
function YcItem:useItem (objid, itemnum)
  -- body
end

--[[
  消耗道具
  @param  {integer} objid 迷你号/生物id
  @return {nil}
]]
function YcItem:consumeItem (objid, itemnum)
  -- body
end

--[[
  丢弃道具
  @param  {integer} objid 迷你号/生物id
  @return {nil}
]]
function YcItem:discardItem (objid, itemnum)
  -- body
end

--[[
  选择道具
  @param  {integer} objid 迷你号/生物id
  @return {nil}
]]
function YcItem:selectItem (objid)
  -- body
end

--[[
  使用技能
  @param  {integer} objid 迷你号/生物id
  @param  {integer} index 技能序号，从1开始。当一件道具设置了多个技能时，则需要判断技能序号
  @return {nil}
]]
function YcItem:useSkill (objid, index)
  -- body
end

--[[
  手持道具点击方块
  @param  {integer} objid 迷你号/生物id
  @param  {integer} blockid 方块id
  @param  {number} x 方块位置x
  @param  {number} y 方块位置y
  @param  {number} z 方块位置z
  @return {nil}
]]
function YcItem:clickBlock (objid, blockid, x, y, z)
  -- body
end

--[[
  手持道具攻击命中
  @param  {integer} objid 发动攻击对象id
  @param  {integer} toobjid 被命中对象id
  @return {nil}
]]
function YcItem:attackHit (objid, toobjid)
  -- body
end

--[[
  该道具相关的投掷物命中。如道具枪射出的子弹命中
  @param  {table} projectileid 投掷物id
  @param  {integer} objid 投掷物所属对象id，即表示投掷物是谁的
  @param  {integer} toobjid 被命中对象id
  @param  {integer} blockid 方块id
  @param  {number} x 命中的位置x
  @param  {number} y 命中的位置y
  @param  {number} z 命中的位置z
  @return {nil}
]]
function YcItem:projectileHit (projectileid, objid, toobjid, blockid, x, y, z)
  -- body
end