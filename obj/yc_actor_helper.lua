--[[ 行为者工具类 v1.0.0
  create by 莫小仙 on 2023-01-14
]]
YcActorHelper = {}

--[[
  获取距离行为者多远的水平位置，受行为者朝向影响
  @param  {integer} objid 行为者id
  @param  {number} distance 距离。正数表示在前方，负数表示在后方
  @param  {number} angle 偏移角度，默认为0。正数为顺时针方向，负数逆时针方向
  @return {YcPosition} 位置
]]--
function YcActorHelper.getDistancePosition (objid, distance, angle)
  angle = angle or 0 -- 默认为0
  local pos = YcCacheHelper.getYcPosition(objid) -- 行为者位置
  local angle2 = ActorAPI.getFaceYaw(objid) + angle -- 实际角度
  return YcPositionHelper.getDistancePosition(pos, angle2, distance)
end

--[[
  获取距离行为者多远的另一排水平位置，多个时依次为中、左、右、左、右...
  @param  {integer} objid 行为者id
  @param  {number} distance 距离。正数表示在前方，负数表示在后方
  @param  {number} angle 偏移角度，默认为0。正数为顺时针方向，负数逆时针方向
  @param  {integer} total 位置总数量，默认为1
  @param  {number} step 垂直于角度边且距离角的顶点指定距离的直线上的间隔距离，默认为1
  @param  {boolean} isFirstLeft 多个位置时，是否先左后右(从pos位置看)
  @return {table} 位置数组
]]
function YcActorHelper.getDistancePositions (objid, distance, angle, total, step, isFirstLeft)
  angle = angle or 0 -- 默认为0
  local pos = YcCacheHelper.getYcPosition(objid) -- 行为者位置
  local angle2 = ActorAPI.getFaceYaw(objid) + angle -- 实际角度
  return YcPositionHelper.getDistancePositions(pos, angle2, distance, total, step, isFirstLeft)
end

--[[
  获取距离位置多远的另一排水平位置，多个时位置在米字形的一条线上
  @param  {table} objid 行为者id
  @param  {number} distance 距离。正数表示在前方，负数表示在后方
  @param  {number} angle 偏移角度，默认为0。正数为顺时针方向，负数逆时针方向
  @param  {integer} total 位置总数量，默认为1
  @param  {integer} num 相邻格子的间隔格子数，默认为0
  @param  {boolean} isFirstLeft 多个位置时，是否先左后右(从pos位置看)
  @return {table} 位置数组
]]
function YcActorHelper.getGridDistancePositions (objid, distance, angle, total, num, isFirstLeft)
  angle = angle or 0 -- 默认为0
  local pos = YcCacheHelper.getYcPosition(objid) -- 行为者位置
  local angle2 = ActorAPI.getFaceYaw(objid) + angle -- 实际角度
  return YcPositionHelper.getGridDistancePositions(pos, angle2, distance, total, num, isFirstLeft)
end

--[[
  获取距离行为者多远的水平位置，不因生物的朝向变化，默认在南方
  @param  {integer} objid 行为者id
  @param  {number} distance 距离。正数表示在前方，负数表示在后方
  @param  {number} angle 偏移角度，默认为0。正数为顺时针方向，负数逆时针方向
  @return {YcPosition} 位置
]]
function YcActorHelper.getFixedDistancePosition (objid, distance, angle)
  angle = angle or 0 -- 默认为0
  local pos = YcCacheHelper.getYcPosition(objid) -- 行为者位置
  return YcPositionHelper.getDistancePosition(pos, angle, distance)
end

--[[
  获取目标行为者处于行为者的哪个水平角度
  @param  {integer} objid 行为者id
  @param  {integer} toobjid 目标行为者id
  @return {number} 水平角度。正前方为0，左负右正，正后方为180
]]
function YcActorHelper.getRelativePlayerAngle (objid, toobjid)
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

--[[
  获取行为者的队伍
  @param  {integer} objid 行为者id
  @return {integer | nil} 队伍id，nil表示获取队伍信息失败
]]
function YcActorHelper.getTeam (objid)
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

--[[
  判断是否是同队。无队伍不算同队
  @param  {integer | nil} teamid1 队伍1id
  @param  {integer | nil} teamid2 队伍2id
  @return {boolean} 是否同队
]]
function YcActorHelper.isTheSameTeam (teamid1, teamid2)
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

--[[
  判断是否是同队的行为者。无队伍不算同队
  @param  {integer} objid1 行为者1的id
  @param  {integer} objid2 行为者2的id
  @return {boolean} 是否同队
]]
function YcActorHelper.isTheSameTeamActor (objid1, objid2)
  local teamid1 = YcCacheHelper.getTeam(objid1)
  local teamid2 = YcCacheHelper.getTeam(objid2)
  return YcActorHelper.isTheSameTeam(teamid1, teamid2)
end

--[[
  获取过滤掉不满足队伍信息的行为者数组
  @param  {table} objids 行为者id数组
  @param  {integer | nil} teamid 队伍id或空
  @param  {boolean | nil} isTheSameTeam 是否同队，默认不是同队
  @return {table} 行为者id数组
]]
function YcActorHelper.filterTeam (objids, teamid, isTheSameTeam)
  if objids and teamid then -- 有队伍信息
    local arr, tid = {}
    for i, objid in ipairs(objids) do -- 遍历数组
      tid = YcCacheHelper.getTeam(objid) -- 行为者队伍
      if isTheSameTeam and YcActorHelper.isTheSameTeam(teamid, tid) or -- 同队
        not isTheSameTeam and not YcActorHelper.isTheSameTeam(teamid, tid) then -- 不同队
        table.insert(arr, v) -- 加入结果数组
      end
    end
    return arr
  else -- 无队伍信息，则全部返回
    return objids
  end
end

--[[
  获取位置附近的所有玩家
  @param  {table} pos 位置
  @param  {table} dim 区域尺寸大小
  @param  {integer | nil} 队伍id
  @param  {boolean | nil} 是否同队，默认不同队
  @return {table} 玩家迷你号数组
]]
function YcActorHelper.getAllPlayersArroundPos (pos, dim, teamid, isTheSameTeam)
  local posBeg, posEnd = YcPositionHelper.getRectRange(pos, dim) -- 根据区域中点与尺寸查询区域的起止位置
  local objids = AreaAPI.getAllObjsInAreaRange(posBeg, posEnd, OBJ_TYPE.OBJTYPE_PLAYER) -- 查询区域内所有玩家
  return YcActorHelper.filterTeam(objids, teamid, isTheSameTeam) -- 过滤队伍
end

--[[
  获取位置附近的所有生物
  @param  {table} pos 位置
  @param  {table} dim 区域尺寸大小
  @param  {integer | nil} 队伍id
  @param  {boolean | nil} 是否同队，默认不同队
  @return {table} 生物id数组
]]
function YcActorHelper.getAllCreaturesArroundPos (pos, dim, teamid, isTheSameTeam)
  local posBeg, posEnd = YcPositionHelper.getRectRange(pos, dim) -- 根据区域中点与尺寸查询区域的起止位置
  local objids = AreaAPI.getAllObjsInAreaRange(posBeg, posEnd, OBJ_TYPE.OBJTYPE_CREATURE) -- 查询区域内所有生物
  return YcActorHelper.filterTeam(objids, teamid, isTheSameTeam) -- 过滤队伍
end

--[[
  获取附近的所有投掷物
  @param  {table} pos 位置
  @param  {table} dim 区域尺寸大小
  @param  {integer | nil} 队伍id
  @param  {boolean | nil} 是否同队，默认不同队
  @return {table} 投掷物id数组
]]
function YcActorHelper.getAllMissilesArroundPos (pos, dim, teamid, isTheSameTeam)
  local posBeg, posEnd = YcPositionHelper.getRectRange(pos, dim) -- 根据区域中点与尺寸查询区域的起止位置
  local objids = AreaAPI.getAllObjsInAreaRange(posBeg, posEnd, OBJ_TYPE.OBJTYPE_MISSILE) -- 查询区域内所有投掷物
  return YcActorHelper.filterTeam(objids, teamid, isTheSameTeam) -- 过滤队伍
end

--[[
  获取附近的所有玩家和生物
  @param  {table} pos 位置
  @param  {table} dim 区域尺寸大小
  @param  {integer | nil} 队伍id
  @param  {boolean | nil} 是否同队，默认不同队
  @return {table} 玩家迷你号/生物id数组
]]
function YcActorHelper.getAllPlayersAndCreaturesArroundPos (pos, dim, teamid, isTheSameTeam)
  local posBeg, posEnd = YcPositionHelper.getRectRange(pos, dim) -- 根据区域中点与尺寸查询区域的起止位置
  local objids = AreaAPI.getAllObjsInAreaRangeByObjTypes(posBeg, posEnd,
    { OBJ_TYPE.OBJTYPE_PLAYER, OBJ_TYPE.OBJTYPE_CREATURE }) -- 查询区域内所有玩家和生物
  return YcActorHelper.filterTeam(objids, teamid, isTheSameTeam) -- 过滤队伍
end

--[[
  获取数组中活着的行为者
  @param  {table} objids 玩家/生物id数组
  @return {table} 活着的玩家/生物id数组
]]
function YcActorHelper.getAliveActors (objids)
  local aliveObjids = {}
  for i, objid in ipairs(objids) do
    local hp
    if ActorHelper.isPlayer(objid) then -- 如果是玩家
      hp = PlayerHelper.getHp(objid) -- 获取生命值
    else -- 如果是生物
      hp = CreatureHelper.getHp(objid) -- 获取生命值
    end
    if hp and hp > 0 then -- 如果还有生命值
      table.insert(aliveObjids, objid) -- 加入数组
    end
  end
  return aliveObjids
end

--[[
  获取距离pos最近的行为者id isTwo是否是二维平面
  @param  {table} objids 行为者id数组
  @param  {table} pos 位置
  @param  {boolean} isTwo 是否是只看水平的二维平面上
  @return {integer | nil} 行为者id，nil表示没有行为者
  @return {number | nil} 最短距离，nil表示没有行为者
]]
function YcActorHelper.getNearestActor (objids, pos, isTwo)
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