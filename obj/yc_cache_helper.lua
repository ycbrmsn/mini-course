--[[ 缓存工具类 v1.0.2
  create by 莫小仙 on 2022-06-16
  last modified on 2022-08-27
]]
YcCacheHelper = {
  position = { -- 位置信息
    frame = 0, -- 对应YcTimeHelper中的frame
    map = {} -- { [objid] = { x = x, y = y, z = z } | -1 } -1表示没有找到该生物
  },
  team = { -- 队伍信息
    map = {}, -- { [objid] = teamid }
    time = 180, -- 最多缓存180秒后清除
    t = 'cacheTeamid'
  }
}

--[[
  获取对象的位置信息。如果有缓存，则从缓存中取
  无论是否使用缓存，都会缓存本次结果
  @param  {integer} objid 对象id
  @param  {boolean} notUseCache 是否不使用缓存，默认使用缓存
  @return {number | nil} 位置的x，nil表示找不到该对象
  @return {number | nil} 位置的y，nil表示找不到该对象
  @return {number | nil} 位置的z，nil表示找不到该对象
]]
function YcCacheHelper.getPosition (objid, notUseCache)
  local positionInfo = YcCacheHelper.position -- 位置信息
  local frame = YcTimeHelper.getFrame() -- 当前帧
  if positionInfo.frame ~= frame then -- 位置缓存中已不是当前帧的数据了
    positionInfo.frame = frame -- 更新帧数
    positionInfo.map = {} -- 重置映射
  end
  if notUseCache then -- 不使用缓存
    local x, y, z = ActorAPI.getPosition(objid) -- 调用游戏API获取位置
    if x then -- x存在，表示获取位置成功
      local pos = positionInfo.map[objid] -- 查询缓存位置信息
      if type(pos) == 'table' then -- 如果是表，则更新数值
        pos.x, pos.y, pos.z = x, y, z -- 更新缓存位置
      else -- 如果不是表，则重新赋值
        positionInfo.map[objid] = { x = x, y = y, z = z }
      end
      return x, y, z
    else -- 获取失败，则缓存-1
      positionInfo.map[objid] = -1
      return nil
    end
  else -- 使用缓存
    local pos = positionInfo.map[objid] -- 查询缓存位置信息
    if pos == nil then -- 不存在，表示未缓存
      local x, y, z = ActorAPI.getPosition(objid) -- 调用游戏API获取位置
      if x then -- x存在，表示获取成功
        positionInfo.map[objid] = { x = x, y = y, z = z } -- 更新缓存
        return x, y, z
      else -- 获取失败，则缓存-1
        positionInfo.map[objid] = -1
        return nil
      end
    elseif pos == -1 then -- 表示有缓存，但位置信息不存在
      return nil
    else
      return pos.x, pos.y, pos.z
    end
  end
end

--[[
  获取对象的位置信息。如果有缓存，则从缓存中取
  无论是否使用缓存，都会缓存本次结果
  @param  {integer} objid 对象id
  @param  {boolean} notUseCache 是否不使用缓存，默认使用缓存
  @return {YcPosition | nil} 位置对象，nil表示找不到该对象
]]
function YcCacheHelper.getYcPosition (objid, notUseCache)
  local x, y, z = YcCacheHelper.getPosition(objid, notUseCache) -- 获取缓存位置信息
  if x then -- 位置信息存在
    return YcPosition:new(x, y, z)
  end
end

--[[
  获取对象的队伍信息。如果使用缓存，则优先从缓存中取
  无论是否使用缓存，都会缓存本次结果
  @param  {integer} objid 对象id
  @param  {boolean} notUseCache 是否不使用缓存，默认使用缓存
  @return {integer | nil} 队伍id，nil表示找不到队伍信息
]]
function YcCacheHelper.getTeam (objid, notUseCache)
  local teamInfo = YcCacheHelper.team -- 队伍信息
  if notUseCache then -- 不使用缓存
    local teamid = YcActorHelper.getTeam(objid)
    if teamid then -- teamid存在，表示获取队伍成功
      YcCacheHelper.recordInfoSomeTime(teamInfo.map, objid, teamid, teamInfo.time, teamInfo.t) -- 缓存一段时间
      return teamid
    else -- 获取失败
      return nil
    end
  else -- 使用缓存
    local teamid = teamInfo.map[objid] -- 查询缓存队伍信息
    if teamid == nil then -- 不存在，表示未缓存
      local teamid = YcActorHelper.getTeam(objid)
      if teamid then -- teamid存在，表示获取成功
        YcCacheHelper.recordInfoSomeTime(teamInfo.map, objid, teamid, teamInfo.time, teamInfo.t) -- 缓存一段时间
        return teamid
      else -- 获取失败
        return nil
      end
    else
      return teamid
    end
  end
end

--[[
  记录信息一段时间
  @param  {table} info 信息
  @param  {any} key 键
  @param  {any} value 值
  @param  {number} time 时长
  @param  {string} 时间类型
  @return {nil}
]]
function YcCacheHelper.recordInfoSomeTime (info, key, value, time, t)
  t = key .. t
  if info[key] then -- 已存在
    YcTimeHelper.delAfterTimeTask(t) -- 清除删除信息的任务
  end
  info[key] = value
  -- 保留的记录n秒后删除
  YcTimeHelper.newAfterTimeTask(function ()
    info[key] = nil -- 清除缓存信息
  end, time, t)
end

--[[
  移除对象，并清除缓存。
  如果该对象缓存了位置，则手动移除时需要使用此方法。用以防止对象已消失，但缓存位置数据还在。
  @param  {integer} objid 对象id
  @return {boolean} 是否成功
]]
function YcCacheHelper.despawnActor (objid)
  local result = WorldAPI.despawnActor(objid) -- 移除对象
  if result then -- 移除成功
    -- 清除缓存
    local frame = YcTimeHelper.getFrame() -- 获取当前帧数
    -- 循环清除当前帧的一些信息
    local arr = { 'position' }
    for i, key in ipairs(arr) do
      YcCacheHelper.clearInfo(objid, key, frame)
    end
    -- 清除队伍信息
    local teamInfo = YcCacheHelper.team
    if teamInfo.map[objid] then
      teamInfo.map[objid] = nil
      YcTimeHelper.delAfterTimeTask(objid .. teamInfo.t) -- 清除延时任务
    end
  end
  return result
end

--[[
  清除指定帧信息
  @param  {integer} objid 对象id
  @param  {string} key 缓存属性名
  @param  {integer} frame 帧数
  @return {nil}
]]
function YcCacheHelper.clearInfo (objid, key, frame)
  local info = YcCacheHelper[key]
  if info and info.frame == frame then -- 是同一帧，表示当前帧缓存了信息
    if info.map[objid] then -- 如果存在该对象的信息
      info.map[objid] = nil -- 清除
    end
  end
end