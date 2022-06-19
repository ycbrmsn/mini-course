--[[ 缓存工具类 v1.0.1
  create by 莫小仙 on 2022-06-16
  last modified on 2022-06-19
]]
YcCacheHelper = {
  position = {
    frame = 0, -- 对应YcTimeHelper中的frame
    map = {} -- { [objid] = YcPosition }
  }
}

--[[
  获取对象的位置信息。如果有缓存，则从缓存中取
  @param  {integer} objid 对象id
  @return {YcPosition | nil} 位置对象，nil表示找不到该对象
]]
function YcCacheHelper.getYcPosition (objid)
  local positionInfo = YcCacheHelper.position -- 位置信息
  local frame = YcTimeHelper.getFrame() -- 当前帧
  if positionInfo.frame ~= frame then -- 位置缓存中已不是当前帧的数据了
    positionInfo.frame = frame -- 更新帧数
    positionInfo.map = {} -- 重置映射
  end
  local pos = positionInfo.map[objid] -- 查询位置信息
  if pos == nil then -- 不存在，表示未缓存
    local x, y, z = ActorAPI.getPosition(objid) -- 调用游戏API获取位置
    if x then -- x存在，表示获取成功
      pos = YcPosition:new(x, y, z)
    end
    if pos then -- 位置信息存在
      positionInfo.map[objid] = pos -- 缓存位置
    else -- 不存在时缓存-1
      positionInfo.map[objid] = -1
    end
  elseif pos == -1 then -- 表示有缓存，但位置信息不存在
    return nil
  end
  return pos
end

--[[
  获取对象的位置信息。如果有缓存，则从缓存中取
  @param  {integer} objid 对象id
  @return {number | nil} 位置的x，nil表示找不到该对象
  @return {number | nil} 位置的y，nil表示找不到该对象
  @return {number | nil} 位置的z，nil表示找不到该对象
]]
function YcCacheHelper.getPosition (objid)
  local pos = YcCacheHelper.getYcPosition(objid) -- 获取缓存位置信息
  if pos then -- 位置信息存在
    return pos.x, pos.y, pos.z
  end
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
    local positionInfo = YcCacheHelper.position
    local frame = YcTimeHelper.getFrame() -- 获取当前帧数
    if positionInfo.frame == frame then -- 是同一帧，表示当前帧缓存了位置信息
      if positionInfo.map[objid] then -- 如果存在该对象的位置信息
        positionInfo.map[objid] = nil -- 清除
      end
    end
  end
  return result
end