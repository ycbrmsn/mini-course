--- NPC管理类 v1.0.0
--- created by 莫小仙 on 2024-01-03
---@class YcNpcManager NPC管理类
---@field _npcMap YcTable<objid, YcNpc> 所有初始化完成的NPC
---@field _npcSeePlayers YcWeakTable<YcNpc, YcWeakTable<MyPlayer, true>> NPC看到的所有玩家
---@field _npcSeeNpcs YcWeakTable<YcNpc, YcWeakTable<YcNpc, true>> NPC看到的所有NPC
---@field _npcSeeCreatures YcWeakTable<YcNpc, YcTable<integer, integer>> NPC看到的所有生物<objid, actorid>
---@field _uninitNpcs YcArray<YcNpc> 所有需要初始化的NPC
---@field initDim table{ x: number, y: number, z: number } 初始化NPC的距离，即玩家附近该范围内的NPC能够被初始化
YcNpcManager = {
  _npcMap = YcTable:new(),
  _npcSeePlayers = YcWeakTable:new(),
  _npcSeeNpcs = YcWeakTable:new(),
  _npcSeeCreatures = YcWeakTable:new(),
  _uninitNpcs = YcArray:new(),
  initDim = { x = 40, y = 40, z = 20 }
}

--- 添加一个NPC对象
---@param npc YcNpc 需要加入的NPC
function YcNpcManager.addNpc(npc)
  YcNpcManager._npcMap[npc.objid] = npc
end

--- 移除一个NPC对象
---@param objid integer NPCid
function YcNpcManager.removeNpc(objid)
  YcNpcManager._npcMap[objid] = nil
end

--- 获取NPC对象
---@param objid integer NPCid
---@return YcNpc NPC对象
function YcNpcManager.getNpc(objid)
  return YcNpcManager._npcMap[objid]
end

--- 加入所有需要初始化的NPC
---@vararg YcNpc NPC对象
function YcNpcManager.addUninitNpc(...)
  YcNpcManager._uninitNpcs:push(...)
end

--- 自动初始化所有需要初始化的NPC
function YcNpcManager.autoInitNpcs()
  -- 每秒检测一次，直到全部初始化完成
  YcTimeHelper.newAfterTimeTask(function ()
    if YcNpcManager._uninitNpcs:length() > 0 then -- 如果有需要初始化的NPC
      -- 遍历所有玩家，找到玩家附近的所有生物
      YcPlayerManager.playerPairs(function (player)
        local pos = player:getYcPosition() -- 玩家位置
        local objids = YcActorHelper.getAllCreaturesArroundPos(pos, YcNpcManager.initDim) -- 附近所有生物
        local findNpcIndexes = YcArray:new() -- 新发现可以初始化的NPC的序号
        -- 遍历需要初始化的NPC
        ---@param npc YcNpc
        YcNpcManager._uninitNpcs:forEach(function (npc, index)
          -- 遍历附近的所有生物
          for i, objid in ipairs(objids) do
            local actorid = YcCacheHelper.getAcotrId(objid) -- 生物类型id
            if actorid == npc.actorid then -- 发现NPC
              findNpcIndexes:unshift(index) -- 记录序号
              npc:setObjid(objid)
              npc:onInit()
              YcNpcManager.addNpc(npc)
              -- 所有NPC唯一，找到就找下一个
              break
            end
          end
        end)
        if findNpcIndexes:length() > 0 then -- 如果有初始化完成的NPC
          -- 将他们从需要初始化的数组中移除
          findNpcIndexes:forEach(function (index)
            YcNpcManager._uninitNpcs:splice(index, 1)
          end)
        end
      end)
      YcNpcManager.autoInitNpcs()
    else
      YcLogHelper.debug('自动初始化结束')
    end
  end, 1)
end

--- 遍历NPC对象
---@param f fun(npc: YcNpc, objid: integer): void 回调函数
function YcNpcManager.npcPairs(f)
  YcNpcManager._npcMap:pairs(f)
end

--- 尝试新增NPC看见玩家
---@param npc YcNpc NPC对象
---@param toPlayer MyPlayer 玩家对象
function YcNpcManager._tryAddSeePlayer(npc, toPlayer)
  local t = npc.objid .. 'seePlayer' .. toPlayer.objid
  local playerMap = YcNpcManager._npcSeePlayers[npc]
  if not playerMap then -- 如果还不存在
    playerMap = YcWeakTable:new()
    YcNpcManager._npcSeePlayers[npc] = playerMap
  end
  if playerMap[toPlayer] then -- 如果刚刚已经看到过该玩家了
    YcTimeHelper.delAfterTimeTask(t) -- 删除之前的倒计时，准备重新开始计时
  else -- 如果刚刚没有看到过该玩家
    playerMap[toPlayer] = true
    npc:onSeePlayer(toPlayer)
  end
  -- 开始倒计时删除
  YcTimeHelper.newAfterTimeTask(function()
    playerMap[toPlayer] = nil -- 删除信息
  end, npc.visionKeepSeconds, t)
end

--- 尝试新增NPC看见NPC
---@param npc YcNpc NPC对象
---@param toNpc YcNpc 目标NPC对象
function YcNpcManager._tryAddSeeNpc(npc, toNpc)
  local t = npc.objid .. 'seeNpc' .. toNpc.objid
  local npcMap = YcNpcManager._npcSeeNpcs[npc]
  if not npcMap then -- 如果还不存在
    npcMap = YcWeakTable:new()
    YcNpcManager._npcSeeNpcs[npc] = npcMap
  end
  if npcMap[toNpc] then -- 如果刚刚已经看到过该NPC了
    YcTimeHelper.delAfterTimeTask(t) -- 删除之前的倒计时，准备重新开始计时
  else -- 如果刚刚没有看到过该NPC
    npcMap[toNpc] = true
    npc:onSeeNpc(toNpc)
  end
  -- 开始倒计时删除
  YcTimeHelper.newAfterTimeTask(function()
    npcMap[toNpc] = nil -- 删除信息
  end, npc.visionKeepSeconds, t)
end

--- 尝试新增NPC看见生物
---@param npc YcNpc NPC对象
---@param objid integer 生物id
---@param actorid integer 生物类型id
function YcNpcManager._tryAddSeeCreature(npc, toobjid, toactorid)
  local t = npc.objid .. 'seeCreature' .. toobjid
  local monsterMap = YcNpcManager._npcSeeCreatures[npc]
  if not monsterMap then -- 如果还不存在
    monsterMap = YcWeakTable:new()
    YcNpcManager._npcSeeCreatures[npc] = monsterMap
  end
  if monsterMap[toobjid] then -- 如果刚刚已经看到过该生物了
    YcTimeHelper.delAfterTimeTask(t) -- 删除之前的倒计时，准备重新开始计时
  else -- 如果刚刚没有看到过该生物
    monsterMap[toobjid] = true
    npc:onSeeCreature(toobjid, toactorid)
  end
  -- 开始倒计时删除
  YcTimeHelper.newAfterTimeTask(function()
    monsterMap[toobjid] = nil -- 删除信息
  end, npc.visionKeepSeconds, t)
end

-- 玩家点击生物（用于NPC被点击事件）
ScriptSupportEvent:registerEvent([=[Player.ClickActor]=], function(event)
  local toobjid = event.toobjid
  local npc = YcNpcManager.getNpc(toobjid) -- 获取NPC
  if npc and npc.ableClicked then -- 找到NPC，表示该NPC已初始化完成（因为只有初始化完成的NPC才能找到） 且 NPC能被点击
    local playerid = event.eventobjid
    local teamid1 = PlayerAPI.getTeam(playerid)
    local teamid2 = CreatureAPI.getTeam(toobjid)
    if YcActorHelper.isTheSameTeam(teamid1, teamid2) then -- 如果是同队
      local player = YcPlayerManager.getPlayer(playerid)
      npc:onClick(player) -- 触发NPC的被玩家点击事件
    end
  end
end)

-- 世界时间到[n]秒（用于NPC探测玩家/NPC/怪物/生物事件）
-- ScriptSupportEvent:registerEvent([=[Game.RunTime]=], function()
YcEventHelper.registerEvent([=[Game.RealSecond]=], function()
  ---@param npc YcNpc
  YcNpcManager.npcPairs(function(npc)
    if npc.ableDetectPlayer then -- 如果NPC可探测玩家
      local players = npc:detectPlayers()
      if players:length() > 0 then -- 如果发现了玩家
        players:forEach(function(player)
          YcNpcManager._tryAddSeePlayer(npc, player)
        end)
      end
    end
    if npc.ableDetectNpc then -- 如果NPC可探测NPC
      local npcs = npc:detectNpcs()
      if npcs:length() > 0 then -- 如果发现了NPC
        npcs:forEach(function(toNpc)
          YcNpcManager._tryAddSeeNpc(npc, toNpc)
        end)
      end
    end
    if npc.ableDetectCreature then -- 如果NPC可探测生物
      local creatures = npc:detectMonstersAndCreatures()
      if creatures:length() > 0 then -- 如果发现了生物
        creatures:forEach(function(toCreatureInfo)
          YcNpcManager._tryAddSeeCreature(npc, toNpc)
        end)
      end
    end
  end)
end)

---@class YcCreatureInfo 生物信息
---@field objid integer 生物id
---@field actorid integer 生物类型id
YcCreatureInfo = {}