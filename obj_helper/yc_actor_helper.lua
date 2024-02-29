--- 行为者工具类 v1.1.0
--- created by 莫小仙 on 2023-01-14
--- last modified on 2023-12-18
YcActorHelper = {}

--- 获得生物眼睛高度的位置
---@param objid integer 行为者id
---@param notUseCache boolean 是否不使用缓存，默认使用缓存
---@return YcPosition | nil 眼睛位置，nil表示找不到该生物
function YcActorHelper.getEyeHeightPosition(objid, notUseCache)
  local pos = YcCacheHelper.getYcPosition(objid, notUseCache)
  if pos then -- 生物存在
    local height = ActorAPI.getEyeHeight(objid) -- 眼睛高度
    if height then
      pos.y = pos.y + height
    end
  end
  return pos
end

--- 获取生物视线方向多远的位置
---@param objid integer 行为者id
---@param distance number 距离
---@param notUseCache boolean 是否不使用缓存，默认使用缓存
---@return YcPosition | nil 目标位置，nil表示找不到该生物
function YcActorHelper.getFaceDistancePosition(objid, distance, notUseCache)
  local pos = YcActorHelper.getEyeHeightPosition(objid, notUseCache) -- 眼睛位置
  if pos then
    local x, y, z = ActorAPI.getFaceDirection(objid) -- 朝向
    local vec3 = YcVector3:new(x, y, z):normalize() -- 朝向的单位向量
    local distVec3 = vec3 * distance -- 距离向量
    return pos + distVec3
  end
end

--- 获取距离行为者多远的水平位置，受行为者朝向影响
---@param objid integer 行为者id
---@param distance number 距离。正数表示在前方，负数表示在后方
---@param angle number 偏移角度，默认为0。正数为顺时针方向，负数逆时针方向
---@return YcPosition 位置
function YcActorHelper.getDistancePosition(objid, distance, angle)
  angle = angle or 0 -- 默认为0
  local pos = YcCacheHelper.getYcPosition(objid) -- 行为者位置
  local angle2 = ActorAPI.getFaceYaw(objid) + angle -- 实际角度
  return YcPositionHelper.getDistancePosition(pos, angle2, distance)
end

--- 获取距离行为者多远的另一排水平位置，多个时依次为中、左、右、左、右...
---@param objid integer 行为者id
---@param distance number 距离。正数表示在前方，负数表示在后方
---@param angle number 偏移角度，默认为0。正数为顺时针方向，负数逆时针方向
---@param total integer 位置总数量，默认为1
---@param step number 垂直于角度边且距离角的顶点指定距离的直线上的间隔距离，默认为1
---@param isFirstLeft boolean 多个位置时，是否先左后右(从pos位置看)
---@return YcPosition[] 位置数组
function YcActorHelper.getDistancePositions(objid, distance, angle, total, step, isFirstLeft)
  angle = angle or 0 -- 默认为0
  local pos = YcCacheHelper.getYcPosition(objid) -- 行为者位置
  local angle2 = ActorAPI.getFaceYaw(objid) + angle -- 实际角度
  return YcPositionHelper.getDistancePositions(pos, angle2, distance, total, step, isFirstLeft)
end

--- 获取距离位置多远的另一排水平位置，多个时位置在米字形的一条线上
---@param objid integer 行为者id
---@param distance number 距离。正数表示在前方，负数表示在后方
---@param angle number 偏移角度，默认为0。正数为顺时针方向，负数逆时针方向
---@param total integer 位置总数量，默认为1
---@param num integer 相邻格子的间隔格子数，默认为0
---@param isFirstLeft boolean 多个位置时，是否先左后右(从pos位置看)
---@return YcPosition[] 位置数组
function YcActorHelper.getGridDistancePositions(objid, distance, angle, total, num, isFirstLeft)
  angle = angle or 0 -- 默认为0
  local pos = YcCacheHelper.getYcPosition(objid) -- 行为者位置
  local angle2 = ActorAPI.getFaceYaw(objid) + angle -- 实际角度
  return YcPositionHelper.getGridDistancePositions(pos, angle2, distance, total, num, isFirstLeft)
end

--- 获取距离行为者多远的水平位置，不因生物的朝向变化，默认在南方
---@param objid integer 行为者id
---@param distance number 距离。正数表示在前方，负数表示在后方
---@param angle number 偏移角度，默认为0。正数为顺时针方向，负数逆时针方向
---@return YcPosition 位置
function YcActorHelper.getFixedDistancePosition(objid, distance, angle)
  angle = angle or 0 -- 默认为0
  local pos = YcCacheHelper.getYcPosition(objid) -- 行为者位置
  return YcPositionHelper.getDistancePosition(pos, angle, distance)
end

--- 获取目标行为者处于行为者的哪个水平角度
---@param objid integer 行为者id
---@param toobjid integer 目标行为者id
---@return number 水平角度。正前方为0，左负右正，正后方为180
function YcActorHelper.getRelativePlayerAngle(objid, toobjid)
  local x, y, z = ActorAPI.getPosition(objid) -- 行为者位置
  local tx, ty, tz = ActorAPI.getPosition(toobjid) -- 目标行为者位置
  local dx, dz = tx - x, tz - z -- 行为者到目标行为者的水平方向
  local fx, fy, fz = ActorAPI.getFaceDirection(objid) -- 行为者朝向
  local angle1 = YcVectorHelper.getTwoVector2Angle(fx, fz, dx, dz) -- 看向目标方向与行为者前方向量夹角
  local pos = YcActorHelper.getDistancePosition(objid, 1, -90) -- 行为者左侧1米的位置
  local lx, lz = pos.x - x, pos.z - z -- 行为者到左方的水平方向
  local angle2 = YcVectorHelper.getTwoVector2Angle(lx, lz, dx, dz) -- 看向目标方向与行为者左方向量夹角
  local angle
  if angle1 <= 90 and angle2 < 90 then -- 左前
    angle = -angle1
  elseif angle1 <= 90 and angle2 >= 90 then -- 右前
    angle = angle1
  elseif angle1 > 90 and angle2 < 90 then -- 左后
    angle = -angle1
  else -- 右后
    angle = angle1
  end
  return math.floor(angle)
end

--- 获取行为者的队伍
---@param objid integer 行为者id
---@return integer | nil 队伍id，nil表示获取队伍信息失败
function YcActorHelper.getTeam(objid)
  local objType = ActorAPI.getObjType(objid) -- 获取行为者类型
  if objType == OBJ_TYPE.OBJTYPE_PLAYER then -- 是玩家
    return PlayerAPI.getTeam(objid)
  elseif objType == OBJ_TYPE.OBJTYPE_CREATURE then -- 是生物
    return CreatureAPI.getTeam(objid)
  elseif objType == OBJ_TYPE.OBJTYPE_DROPITEM then -- 掉落物
    return 0 -- 这里认为是无主之物
  elseif objType == OBJ_TYPE.OBJTYPE_MISSILE then -- 投掷物
    return YcItemHelper.getMissileTeamid(projectileid) -- 尝试从投掷物信息中获取
  else -- 错误参数
    return nil
  end
end

--- 判断是否是同队。无队伍不算同队
---@param teamid1 integer | nil 队伍1id
---@param teamid2 integer | nil 队伍2id
---@return boolean 是否同队
function YcActorHelper.isTheSameTeam(teamid1, teamid2)
  if teamid1 == teamid2 then -- id相同
    if teamid1 == nil or teamid1 == 0 then -- id为空 或 无队伍
      return false
    else
      return true
    end
  else -- 不相同
    return false
  end
end

--- 判断是否是同队的行为者。无队伍不算同队
---@param objid1 integer 行为者1的id
---@param objid2 integer 行为者2的id
---@return boolean 是否同队
function YcActorHelper.isTheSameTeamActor(objid1, objid2)
  local teamid1 = YcCacheHelper.getTeam(objid1)
  local teamid2 = YcCacheHelper.getTeam(objid2)
  return YcActorHelper.isTheSameTeam(teamid1, teamid2)
end

--- 获取过滤掉不满足队伍信息的行为者数组
---@param objids integer[] 行为者id数组
---@param teamid integer | nil 队伍id或空
---@param isTheSameTeam boolean | nil 是否同队，默认不是同队
---@return integer[] 行为者id数组
function YcActorHelper.filterTeam(objids, teamid, isTheSameTeam)
  if objids and teamid then -- 有队伍信息
    local arr, tid = {}
    for i, objid in ipairs(objids) do -- 遍历数组
      tid = YcCacheHelper.getTeam(objid) -- 行为者队伍
      if isTheSameTeam and YcActorHelper.isTheSameTeam(teamid, tid) or -- 同队
      not isTheSameTeam and not YcActorHelper.isTheSameTeam(teamid, tid) then -- 不同队
        table.insert(arr, objid) -- 加入结果数组
      end
    end
    return arr
  else -- 无队伍信息，则全部返回
    return objids
  end
end

--- 获取位置附近的所有玩家
---@param pos table{ x: number, y: number, z: number } 位置
---@param dim table{ x: number, y: number, z: number } 区域尺寸大小
---@param teamid integer | nil 队伍id
---@param isTheSameTeam boolean | nil 是否同队，默认不同队
---@return integer[] 玩家迷你号数组
function YcActorHelper.getAllPlayersArroundPos(pos, dim, teamid, isTheSameTeam)
  local posBeg, posEnd = YcPositionHelper.getRectRange(pos, dim) -- 根据区域中点与尺寸查询区域的起止位置
  local objids = AreaAPI.getAllObjsInAreaRange(posBeg, posEnd, OBJ_TYPE.OBJTYPE_PLAYER) -- 查询区域内所有玩家
  return YcActorHelper.filterTeam(objids, teamid, isTheSameTeam) -- 过滤队伍
end

--- 获取位置附近的所有生物
---@param pos table{ x: number, y: number, z: number } 位置
---@param dim table{ x: number, y: number, z: number } 区域尺寸大小
---@param teamid integer | nil 队伍id
---@param isTheSameTeam boolean | nil 是否同队，默认不同队
---@return integer[] 生物id数组
function YcActorHelper.getAllCreaturesArroundPos(pos, dim, teamid, isTheSameTeam)
  local posBeg, posEnd = YcPositionHelper.getRectRange(pos, dim) -- 根据区域中点与尺寸查询区域的起止位置
  local objids = AreaAPI.getAllObjsInAreaRange(posBeg, posEnd, OBJ_TYPE.OBJTYPE_CREATURE) -- 查询区域内所有生物
  return YcActorHelper.filterTeam(objids, teamid, isTheSameTeam) -- 过滤队伍
end

--- 获取附近的所有投掷物
---@param pos table{ x: number, y: number, z: number } 位置
---@param dim table{ x: number, y: number, z: number } 区域尺寸大小
---@param teamid integer | nil 队伍id
---@param isTheSameTeam boolean | nil 是否同队，默认不同队
---@return integer[] 投掷物id数组
function YcActorHelper.getAllMissilesArroundPos(pos, dim, teamid, isTheSameTeam)
  local posBeg, posEnd = YcPositionHelper.getRectRange(pos, dim) -- 根据区域中点与尺寸查询区域的起止位置
  local objids = AreaAPI.getAllObjsInAreaRange(posBeg, posEnd, OBJ_TYPE.OBJTYPE_MISSILE) -- 查询区域内所有投掷物
  return YcActorHelper.filterTeam(objids, teamid, isTheSameTeam) -- 过滤队伍
end

--- 获取附近的所有玩家和生物
---@param pos table{ x: number, y: number, z: number } 位置
---@param dim table{ x: number, y: number, z: number } 区域尺寸大小
---@param teamid integer | nil 队伍id
---@param isTheSameTeam boolean | nil 是否同队，默认不同队
---@return integer[] 玩家迷你号/生物id数组
function YcActorHelper.getAllPlayersAndCreaturesArroundPos(pos, dim, teamid, isTheSameTeam)
  local posBeg, posEnd = YcPositionHelper.getRectRange(pos, dim) -- 根据区域中点与尺寸查询区域的起止位置
  local objids = AreaAPI.getAllObjsInAreaRangeByObjTypes(posBeg, posEnd,
    {OBJ_TYPE.OBJTYPE_PLAYER, OBJ_TYPE.OBJTYPE_CREATURE}) -- 查询区域内所有玩家和生物
  return YcActorHelper.filterTeam(objids, teamid, isTheSameTeam) -- 过滤队伍
end

--- 获取数组中活着的行为者
---@param objids integer[] 玩家/生物id数组
---@return integer[] 活着的玩家/生物id数组
function YcActorHelper.getAliveActors(objids)
  local aliveObjids = {}
  for i, objid in ipairs(objids) do
    local hp
    if ActorAPI.isPlayer(objid) then -- 如果是玩家
      hp = PlayerAPI.getAttr(objid, PLAYERATTR.CUR_HP) -- 获取生命值
    else -- 如果是生物
      hp = CreatureAPI.getAttr(objid, CREATUREATTR.CUR_HP) -- 获取生命值
    end
    if hp and hp > 0 then -- 如果还有生命值
      table.insert(aliveObjids, objid) -- 加入数组
    end
  end
  return aliveObjids
end

--- 获取距离pos最近的行为者id isTwo是否是二维平面
---@param objids integer[] 行为者id数组
---@param pos table{ x: number, y: number, z: number } 位置
---@param isTwo boolean 是否是只看水平的二维平面上
---@return integer | nil 行为者id，nil表示没有行为者
---@return number | nil 最短距离，nil表示没有行为者
function YcActorHelper.getNearestActor(objids, pos, isTwo)
  local objid, minDistance
  for i, v in ipairs(objids) do
    local p = YcCacheHelper.getYcPosition(v) -- 查询行为者位置
    if p then -- 如果找到位置
      local distance
      if isTwo then -- 如果只比较水平的二维平面
        distance = YcPositionHelper.getHorizontalDistance(p, pos)
      else -- 如果是比较三维平面
        distance = YcPositionHelper.getDistance(p, pos)
      end
      if not minDistance or minDistance > distance then -- 如果找到了更短距离
        minDistance = distancee
        objid = v
      end
    end
  end
  return objid, minDistance
end

--  执行者、目标、是否需要旋转镜头（三维视角需要旋转），toobjid可以是objid、位置、玩家、生物
--- 行为者看向
---@param objid integer | YcArray<integer> 玩家id/生物id 或 玩家id数组/生物id数组
---@param toobjid integer | YcActor | YcPosition 目标玩家id/生物id 或 目标玩家/生物 或 位置
---@param needRotateCamera boolean 是否需要旋转镜头（三维视角需要旋转）
function YcActorHelper.lookAt(objid, toobjid, needRotateCamera)
  -- LogHelper.debug('lookat')
  if type(objid) == 'number' then -- 单个执行者
    local x, y, z
    if type(toobjid) == 'table' then
      -- 判断是不是玩家或者生物
      if toobjid.TYPE == YcActor.TYPE then -- 玩家或生物
        toobjid = toobjid.objid
      else -- 是个位置
        x, y, z = toobjid.x, toobjid.y, toobjid.z
      end
    end
    if not x then -- 不是位置
      x, y, z = YcCacheHelper.getPosition(toobjid)
      if not x then -- 取不到目标位置数据
        return
      end
      y = y + ActorAPI.getEyeHeight(toobjid)
    end
    local x0, y0, z0 = YcCacheHelper.getPosition(objid)
    if not x0 then -- 取不到执行者位置数据
      return
    end
    y0 = y0 + ActorAPI.getEyeHeight(objid)
    local myVector3 = YcVector3:new(x0, y0, z0, x, y, z) -- 视线方向
    if ActorAPI.isPlayer(objid) and needRotateCamera then -- 如果执行者是三维视角玩家
      local faceYaw, facePitch
      if y == y0 then
        facePitch = 0
      else
        facePitch = YcVectorHelper.getActorFacePitch(myVector3)
      end
      if x ~= x0 or z ~= z0 then -- 不在同一竖直位置上
        -- faceYaw = MathHelper.getPlayerFaceYaw(myVector3)
        local player = YcPlayerManager.getPlayer(objid)
        faceYaw = YcVectorHelper.getActorFaceYaw(myVector3) - player.yawDiff
      else -- 在同一竖直位置上
        faceYaw = ActorAPI.getFaceYaw(objid)
        -- if y0 < y then -- 向上
        --   facePitch = -90
        -- elseif y0 > y then -- 向下
        --   facePitch = 90
        -- else -- 水平
        --   facePitch = 0
        -- end
      end
      PlayerAPI.rotateCamera(objid, faceYaw, facePitch)
    else -- 执行者是生物或二维视角玩家
      local facePitch
      if y == y0 then
        facePitch = 0
      else
        facePitch = YcVectorHelper.getActorFacePitch(myVector3)
      end
      if x ~= x0 or z ~= z0 then -- 不在同一竖直位置上
        local faceYaw = YcVectorHelper.getActorFaceYaw(myVector3)
        ActorAPI.setFaceYaw(objid, faceYaw)
      else -- 在同一竖直位置上
        -- if y0 < y then -- 向上
        --   facePitch = -90
        -- elseif y0 > y then -- 向下
        --   facePitch = 90
        -- else -- 水平
        --   facePitch = 0
        -- end
      end
      local result = ActorAPI.setFacePitch(objid, facePitch)
      if not result then
        YcLogHelper.debug(myVector3)
      end
    end
  else -- 如果执行者是多个（数组）
    for i, id in ipairs(objid) do
      YcActorHelper.lookAt(id, toobjid, needRotateCamera)
    end
  end
end
