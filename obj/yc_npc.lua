--- NPC类 v1.0.0
--- created by 莫小仙 on 2023-12-18
---@class YcNpc : YcActor NPC
---@field ableClicked boolean 是否能够被（同组）玩家点击
---@field ableDetectPlayer boolean 是否能够探测玩家
---@field ableDetectNpc boolean 是否能够探测NPC
---@field ableDetectCreature boolean 是否能够探测生物（包括怪物）
---@field ableDetectDropItem boolean 是否能够探测掉落物
---@field visiblePlayers YcTable<objid, MyPlayer> 可见玩家集合
---@field visibleNpcs YcTable<objid, YcNpc> 可见NPC集合
---@field freeInAreaId integer | nil 自由活动区域id
---@field isInited boolean 是否初始化完成
YcNpc = YcActor:new({
  ableClicked = true,
  ableDetectPlayer = false,
  ableDetectNpc = false,
  ableDetectCreature = false,
  ableDetectDropItem = false
})

--- 实例化一个NPC
---@param o table NPC信息
---@return YcNpc NPC
function YcNpc:new(o)
  o = o or {}
  o.visiblePlayers = YcTable:new() -- 可见玩家集合
  o.visibleNpcs = YcTable:new() -- 可见NPC集合
  o.moveable = true -- 默认可以移动
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 记录NPC的objid和名称
---@param objid integer 生物id
function YcNpc:setObjid(objid)
  self.objid = objid
  self.nickname = CreatureAPI.getActorName(objid) -- 记录NPC名称
end

---------事件---------

--- （同组）NPC被玩家点击
---@param player MyPlayer 玩家对象
function YcNpc:onClick(player)
  -- 在具体NPC或玩家类中实现
end

--- 看见了玩家
---@param player MyPlayer 玩家对象
function YcNpc:onSeePlayer(player)
  -- 在具体生物或玩家类中实现
end

--- 看见了NPC
---@param npc YcNpc NPC对象
function YcNpc:onSeeNpc(npc)
  -- 在具体生物或玩家类中实现
end

--- 看见了生物（包括怪物）
---@param objid integer 生物id
---@param actorid integer 生物类型id
function YcNpc:onSeeCreature(objid, actorid)
  -- 在具体生物或玩家类中实现
end

-- 下面onSee事件暂未实现

--- 看见了掉落物
---@param itemid integer 道具类型id
---@param itemnum integer 道具数量
function YcNpc:onSeeDropItems(itemid, itemnum)
  -- 在具体生物或玩家类中实现
end
