--- 行为者管理类 v1.0.0
--- created by 莫小仙 on 2024-01-07
---@class YcActorManager 行为者管理类
YcActorManager = {}

-- 生物碰撞生物/玩家 生物-生物 生物-玩家
ScriptSupportEvent:registerEvent([=[Actor.Collide]=], function(event)
  local objid = event.eventobjid
  local npc = YcNpcManager.getNpc(objid) -- 获取主动NPC
  local actorid = event.actorid
  local monster = YcMonsterManager.getMonster(actorid) -- 获取主动怪物
  local toobjid = event.toobjid
  local toPlayer = YcPlayerManager.getPlayer(toobjid) -- 获取被动玩家
  local toNpc = YcNpcManager.getNpc(toobjid) -- 获取被动NPC
  local toactorid = event.targetactorid
  local toMonster = YcMonsterManager.getMonster(toactorid) -- 获取被动怪物
  if npc then -- 如果找到主动NPC
    YcActorManager._creatureCollide(npc, toPlayer, toNpc, toMonster, objid, actorid, toobjid, toactorid, 'Npc')
  elseif monster then -- 如果找到主动怪物
    YcActorManager._creatureCollide(monster, toPlayer, toNpc, toMonster, objid, actorid, toobjid, toactorid, 'Monster')
  else -- 反之，则是主动普通生物
    YcActorManager._creatureCollide(nil, toPlayer, toNpc, toMonster, objid, actorid, toobjid, toactorid)
  end
  -- if not ActorAPI.isPlayer(toobjid) then
  --   YcLogHelper.debug('生物碰撞', objid, '-', event.toobjid, '-', YcTimeHelper.getFrame(), '-', event.targetactorid)
  -- end
end)

--- 生物碰撞其他
function YcActorManager._creatureCollide(actor, toPlayer, toNpc, toMonster, objid, actorid, toobjid, toactorid, category)
  local toActor
  if toPlayer then -- 如果找到被动玩家
    if actor then
      actor:onCollidePlayer(toPlayer)
    end
    toActor = toPlayer
  elseif toNpc then -- 如果找到被动NPC
    if actor then
      actor:onCollideNpc(toNpc)
    end
    toActor = toNpc
  elseif toMonster then -- 如果找到被动怪物
    if actor then
      actor:onCollideMonster(toMonster, toobjid)
    end
    toActor = toMonster
  else -- 反之，则是普通生物
    if actor then
      actor:onCollideCreature(toobjid, toactorid)
    end
    return
  end
  if category then
    toActor['onCollideBy' .. category](toActor, actor)
  else
    toActor:onCollidedByCreature(objid, actorid)
  end
end

-- 玩家碰撞生物/玩家 玩家-生物 玩家-玩家
ScriptSupportEvent:registerEvent([=[Player.Collide]=], function(event)
  local objid = event.eventobjid
  local player = YcPlayerManager.getPlayer(objid) -- 主动玩家
  local toobjid = event.toobjid
  local toPlayer = YcPlayerManager.getPlayer(toobjid) -- 被动玩家
  -- YcLogHelper.debug('玩家碰生物:', toobjid)
  if toPlayer then -- 如果找到被动玩家
    player:onCollidePlayer(toPlayer)
    toPlayer:onCollidedByPlayer(player)
    -- YcLogHelper.debug(player.nickname, '碰了', toPlayer.nickname)
  else -- 反之，则是生物
    local toNpc = YcNpcManager.getNpc(toobjid)
    local actorid = CreatureAPI.getActorID(toobjid)
    local toMonster = YcMonsterManager.getMonster(actorid)
    if toNpc then -- 如果找到被动NPC
      player:onCollideNpc(toNpc)
      toNpc:onCollidedByPlayer(player)
    elseif toMonster then -- 如果找到被动怪物
      player:onCollideMonster(toMonster)
      toMonster:onCollidedByPlayer(player)
    else -- 反之，则是普通生物
      player:onCollideCreature(toobjid, actorid)
    end
  end
end)
