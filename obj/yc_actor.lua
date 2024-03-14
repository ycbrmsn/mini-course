--- 行为者类 v1.0.0
--- created by 莫小仙 on 2023-12-18
---@class YcActor 行为者
---@field objid integer 行为者id
---@field nickname string 昵称
---@field defaultSpeed number 默认速度
---@field sightLineDistance number 视线长度
---@field visionKeepSeconds number 看不见目标后，仍能保持知晓目标位置几秒钟
---@field _actionGroup YcActionGroup 行为组
---@field _currentAction YcAction | nil 当前行动
---@field x number x位置
---@field y number y位置
---@field z number z位置
YcActor = YcTable:new({
  TYPE = 'YC_ACTOR',
  defaultSpeed = 300,
  sightLineDistance = 10,
  visionKeepSeconds = 3
})
-- YcActor = {
--   objid = nil, -- 生物id
--   actorid = nil, -- 生物类型id
--   defaultSpeed = 300, -- 默认速度
--   disableMoveTime = 0, -- 无法移动的时间
--   motion = 0, -- 静止
--   freeInAreaId = nil, -- 自由活动区域id
--   wants = nil, -- 想法
--   isInited = false, -- 是否初始化生物完成
--   -- 对话相关
--   talkIndex = 0, -- 对话序数
--   talkInfos = {}, -- 对话信息
--   defaultTalkMsg = nil, -- 默认对话
--   speakDim = {
--     x = 30,
--     y = 30,
--     z = 30
--   }, -- 默认说话声音传播范围
--   offset = 120, -- 会话文字板高度
--   clickNoUsePlayerids = {} -- 点击无效的玩家id，主要用于某时刻某玩家无法点击对话，如对话需要等待一段时间后才可点击
-- }

function YcActor:new(o)
  o = o or {}
  o._actionGroup = YcActionGroup:new()
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 获取位置
---@param notUseCache boolean 是否不使用缓存，默认使用缓存
---@return number | nil 位置x，nil表示找不到该行为者
---@return number | nil 位置y，nil表示找不到该行为者
---@return number | nil 位置z，nil表示找不到该行为者
function YcActor:getPosition(notUseCache)
  return YcCacheHelper.getPosition(self.objid, notUseCache)
end

--- 获取位置
---@param notUseCache boolean 是否不使用缓存，默认使用缓存
---@return YcPosition | nil 位置，nil表示找不到该行为者
function YcActor:getYcPosition(notUseCache)
  return YcCacheHelper.getYcPosition(self.objid, notUseCache)
end

--- 设置位置
---@param x number x位置
---@param y number y位置
---@param z number z位置
---@return boolean 是否成功
---------重载---------
---@overload fun(t: table) : boolean t类型{ x: number, y: number, z: number }
function YcActor:setPosition(x, y, z)
  if type(x) == 'number' then
    return ActorAPI.setPosition(self.objid, x, y, z)
  else -- 这里认为是一个位置对象
    return ActorAPI.setPosition(self.objid, x.x, x.y, x.z)
  end
end

--- 获取水平朝向角度
---@return number | nil 水平朝向角度，nil表示找不到该行为者
function YcActor:getFaceYaw()
  return ActorAPI.getFaceYaw(self.objid)
end

--- 设置水平朝向角度
---@param yaw number 水平朝向角度
---@return boolean 是否成功
function YcActor:setFaceYaw(yaw)
  return ActorAPI.setFaceYaw(self.objid, yaw)
end

--- 设置水平转动角度
---@param offset number 转动角度
---@return boolean 是否成功
function YcActor:turnFaceYaw(offset)
  return ActorAPI.turnFaceYaw(self.objid, offset)
end

--- 获取视线与水平方向的角度
---@return number | nil 视线与水平方向的角度，nil表示找不到该行为者
function YcActor:getFacePitch()
  return ActorAPI.getFacePitch(self.objid)
end

--- 设置视线与水平方向的角度
---@param pitch number 视线与水平方向的角度
---@return boolean 是否成功
function YcActor:setFacePitch(pitch)
  return ActorAPI.setFacePitch(self.objid, pitch)
end

--- 设置视线上下转动的角度
---@param offset number 转动角度
---@return boolean 是否成功
function YcActor:turnFacePitch(offset)
  return ActorAPI.turnFacePitch(self.objid, offset)
end

-- 看向某人/某处
function YcActor:lookAt(toobjid)
  YcActorHelper.lookAt(self.objid, toobjid, YcPlayerManager.needRotateCamera)
end

--- 设置昵称
---@param nickname string 昵称
---@return boolean 是否成功
function YcActor:setNickname(nickname)
  self.nickname = nickname
  return ActorAPI.setnickname(self.objid, nickname)
end

--- 在行动数组尾部添加一个或多个行动/行动组
---@vararg YcAction | YcActionGroup 需要添加的行动/行动组
---@return YcActor 行为者
function YcActor:pushActions(...)
  self._actionGroup:push(...)
  return self
end

--- 在行动数组尾部添加一个或多个行动/行动组
---@vararg YcAction | YcActionGroup 需要添加的行动/行动组
---@return YcActor 行为者
function YcActor:pushTempActions(...)
  self._actionGroup:unshift(...)
  return self
end

--- 清空行动
---@return YcActor 行为者
function YcActor:clearActions()
  self._actionGroup:stop() -- 停止行动
  self._actionGroup = YcActionGroup:new() -- 重新实例化一个行为组
  return self
end

--- 获取第几个行动
---@param index integer | nil 序号。默认第一个
---@return YcAction 行动
function YcActor:getAction(index)
  return self._actionGroup:get(index)
end

--- 设置第几个行动
---@param action YcAction 行动
---@param index integer | nil 序号。默认第一个
---@return YcActor 行为者
function YcActor:setAction(action, index)
  self._actionGroup:set(action, index)
  return self
end

--- 重新设置行动
---@vararg YcAction | YcActionGroup 需要添加的行为/行为组
---@return YcActor 行为者
function YcActor:resetActions(...)
  self:clearActions()
  self._actionGroup:push(...)
  return self
end

--- 开始行动
---@return YcActor 行为者
function YcActor:startAction()
  self._actionGroup:start()
  return self
end

--- 添加临时行动。如果当前在执行主行动，则暂停，优先执行临时行动
---@vararg YcAction | YcActionGroup 需要添加的行动/行动组
---@return YcActor 行为者
function YcActor:addTempAction(...)
  self:pushTempActions(...)
  self._actionGroup:tryStartTemp()
  return self
end

--- 尝试停止行动，然后执行后面的行动
---@param actionName string 需要停止的行动
function YcActor:tryStopAction(actionName)
  local action = YcActionHelper.getCurrentAction(self._actionGroup) -- 获取当前具体行为
  if action and action.NAME == actionName then -- 如果行为名称相同
    action:stop(true) -- 停止当前行为，并执行下一个行为
  end
end

--- 探测玩家
--- 根据生物的朝向、眼睛位置、抬头高度、视线长度、是否有不透明方块遮挡来判断它是否可以发现玩家
--- 可能会比较耗性能
---@return YcArray<MyPlayer> 玩家数组
function YcActor:detectPlayers()
  local x, y, z = YcCacheHelper.getPosition(self.objid) -- 行为者位置
  local fx, fy, fz = ActorAPI.getFaceDirection(self.objid) -- 行为者朝向
  local pos = YcActorHelper.getEyeHeightPosition(self.objid) -- 行为者眼睛位置
  local players = YcArray:new() -- 玩家数组
  -- 遍历所有玩家
  YcPlayerManager.playerPairs(function(player, toobjid)
    if toobjid == self.objid then -- 如果就是玩家自己
      return
    end
    if YcActor._canFindActor(pos, x, y, z, fx, fy, fz, toobjid, self.sightLineDistance) then -- 如果能看到
      players:push(player)
    end
  end)
  return players
end

--- 探测NPC
--- 根据生物的朝向、眼睛位置、抬头高度、视线长度、是否有不透明方块遮挡来判断它是否可以发现NPC
--- 可能会比较耗性能
---@return YcArray<YcNpc> NPC数组
function YcActor:detectNpcs()
  local x, y, z = YcCacheHelper.getPosition(self.objid) -- 行为者位置
  local fx, fy, fz = ActorAPI.getFaceDirection(self.objid) -- 行为者朝向
  local pos = YcActorHelper.getEyeHeightPosition(self.objid) -- 行为者眼睛位置
  local npcs = YcArray:new() -- NPC数组
  -- 遍历所有NPC
  YcNpcManager.npcPairs(function(npc, toobjid)
    if toobjid == self.objid then -- 如果就是NPC自己
      return
    end
    if YcActor._canFindActor(pos, x, y, z, fx, fy, fz, toobjid, self.sightLineDistance) then -- 如果能看到
      npcs:push(npc)
    end
  end)
  return npcs
end

--- 探测生物（包括怪物）
--- 根据生物的朝向、眼睛位置、抬头高度、视线长度、是否有不透明方块遮挡来判断它是否可以发现生物
--- 可能会比较耗性能
---@return YcArray<YcCreatureInfo> 生物信息数组
function YcActor:detectCreatures()
  local x, y, z = YcCacheHelper.getPosition(self.objid) -- 行为者位置
  local fx, fy, fz = ActorAPI.getFaceDirection(self.objid) -- 行为者朝向
  local pos = YcActorHelper.getEyeHeightPosition(self.objid) -- 行为者眼睛位置
  local creatures = YcArray:new() -- 生物数组
  -- 获得区域内所有生物
  local toobjids = AreaAPI.getAllCreaturesInAreaRange({
    x = x - self.sightLineDistance,
    y = y - self.sightLineDistance,
    z = z - self.sightLineDistance
  }, {
    x = x + self.sightLineDistance,
    y = y + self.sightLineDistance,
    z = z + self.sightLineDistance
  })
  for i, toobjid in ipairs(toobjids) do
    local toNpc = YcNpcManager.getNpc(toobjid)
    if not toNpc then -- 如果不是NPC
      if YcActor._canFindActor(pos, x, y, z, fx, fy, fz, toobjid, self.sightLineDistance) then -- 如果能看到
        local actorid = CreatureAPI.getActorID(toobjid)
        creatures:push({
          objid = toobjid,
          actorid = actorid
        })
      end
    end
  end
  return creatures
end

function YcActor._canFindActor(pos, x, y, z, fx, fy, fz, toobjid, sightLineDistance)
  local x2, y2, z2 = YcCacheHelper.getPosition(toobjid) -- 目标位置
  if not x2 then -- 如果没找到该目标位置
    return false
  end
  local vec3 = YcVector3:new(x, y, z, x2, y2, z2)
  local distance = vec3:length()
  if distance > sightLineDistance then -- 如果是在视线范围外
    return false
  end
  vec3 = YcVector3:new(pos.x, pos.y, pos.z, x2, y2, z2) -- 眼睛位置与目标玩家位置的向量
  local angle = YcVectorHelper.getTwoVector3Angle(fx, fy, fz, vec3.x, vec3.y, vec3.z) -- 视线夹角
  if angle > 60 then -- 如果视线角度大于60
    return false
  end
  local blockPosList = YcPositionHelper.getBlockPositionsBetweenTwoPositions(YcPosition:new(x, y, z),
    YcPosition:new(x2, y2, z2))
  -- 是否所有方块都是透明方块
  return blockPosList:every(function(blockPos)
    return YcBlockManager.isTransparentBlock(blockPos:get())
  end)
end

---------事件---------

--- 初始化信息
function YcActor:onInit()
  -- 在具体生物或玩家类中实现
end

--- 在几点做什么
---@param hour integer 小时。0~23
function YcActor:onHour(hour)
  -- 在具体生物或玩家类中实现
end

--- 立刻做事
function YcActor:doItNow()
  -- 在具体生物或玩家类中实现
  -- 可以先获取小时WorldAPI.getHours
  -- 然后根据YcActor:onHour来实现
  -- 如:
  -- local hour = WorldAPI.getHours()
  -- if hour < 12 then
  --   self:onHour(0)
  -- else
  --   self:onHour(12)
  -- end
end

--- 碰撞了玩家
---@param player MyPlayer 玩家对象
function YcActor:onCollidePlayer(player)
  -- 在具体生物或玩家类中实现
end

--- 被玩家碰撞了
---@param player MyPlayer 玩家对象
function YcActor:onCollidedByPlayer(player)
  -- 在具体生物或玩家类中实现
end

--- 碰撞了生物（这里的生物是在YcNpcManager中的生物）
---@param creature YcNpc 生物对象
function YcActor:onCollideNpc(creature)
  -- 在具体生物或玩家类中实现
end

--- 被生物碰撞了（这里的生物是在YcNpcManager中的生物）
---@param creature YcNpc 生物对象
function YcActor:onCollidedByNpc(creature)
  -- 在具体生物或玩家类中实现
end

--- 碰撞了怪物
---@param monster YcMonster 怪物实现类
---@param objid integer 怪物id
function YcActor:onCollideMonster(monster, objid)
  -- 在具体生物或玩家类中实现
end

--- 被怪物碰撞了
---@param monster YcMonster 怪物实现类
---@param objid integer 怪物id
function YcActor:onCollidedByMonster(monster, objid)
  -- 在具体生物或玩家类中实现
end

--- 碰撞了普通生物
---@param objid integer 生物id
---@param actorid integer 生物类型
function YcActor:onCollideCreature(objid, actorid)
  -- 在具体生物或玩家类中实现
end

--- 被普通生物碰撞了
---@param objid integer 生物id
---@param actorid integer 生物类型
function YcActor:onCollidedByCreature(objid, actorid)
  -- 在具体生物或玩家类中实现
end
