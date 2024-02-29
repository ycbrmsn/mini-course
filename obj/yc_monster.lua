--- 怪物类 v1.0.0
--- created by 莫小仙 on 2024-01-07
---@class YcMonster 怪物，指一类怪物，非单个
---@field actorid integer 生物类型id
YcMonster = YcTable:new()

---------事件---------

--- 碰撞了玩家
---@param player MyPlayer 玩家对象
function YcMonster:onCollidePlayer(player)
  -- 在具体怪物类中实现
end

--- 被玩家碰撞了
---@param player MyPlayer 玩家对象
function YcMonster:onCollidedByPlayer(player)
  -- 在具体怪物类中实现
end

--- 碰撞了NPC
---@param npc YcNpc NPC对象
function YcMonster:onCollideNpc(npc)
  -- 在具体怪物类中实现
end

--- 被NPC碰撞了
---@param npc YcNpc NPC对象
function YcMonster:onCollidedByNpc(npc)
  -- 在具体怪物类中实现
end

--- 碰撞了怪物
---@param monster YcMonster 怪物实现类
---@param objid integer 怪物id
function YcMonster:onCollideMonster(monster, objid)
  -- 在具体怪物类中实现
end

--- 被怪物碰撞了
---@param monster YcMonster 怪物实现类
---@param objid integer 怪物id
function YcMonster:onCollidedByMonster(monster, objid)
  -- 在具体怪物类中实现
end

--- 碰撞了普通生物
---@param objid integer 生物id
---@param actorid integer 生物类型
function YcMonster:onCollideCreature(objid, actorid)
  -- 在具体怪物类中实现
end

--- 被普通生物碰撞了
---@param objid integer 生物id
---@param actorid integer 生物类型
function YcMonster:onCollidedByCreature(objid, actorid)
  -- 在具体怪物类中实现
end
