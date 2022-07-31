--[[ 位置工具类 v1.0.0
  create by 莫小仙 on 2022-07-31
]]
YcPositionHelper = {}

--[[
  距离位置多远的另一个水平位置
  @param  {table} pos 位置
  @param  {number} angle 角度，以正南方向开始，顺时针为正，逆时针为负
  @return {YcPosition} 位置
]]
function YcPositionHelper.getDistancePosition (pos, angle, distance)
  local x = pos.x - distance * math.sin(math.rad(angle))
  local y = pos.y
  local z = pos.z - distance * math.cos(math.rad(angle))
  return YcPosition:new(x, y, z)
end

--[[
  距离位置多远的另一排位置，多个时为中、左、右、左、右...
  @param  {table} pos 位置
  @param  {number} angle 角度，以正南方向开始，顺时针为正，逆时针为负
  @param  {number} distance1 角度连线方向上的距离
  @param  {number} distance2 角度垂直线上的间隔距离，默认为1
  @param  {integer} num 位置数量，默认为1
  @param  {boolean} isFirstLeft 多个时是否先左后右(从pos位置看)
  @return {table} 位置数组
]]
function YcPositionHelper.getDistancePositions (pos, angle, distance1, distance2, num, isFirstLeft)
  distance2 = distance2 or 1
  num = num or 1
  isFirstLeft = isFirstLeft == nil and true or isFirstLeft -- 默认为true
  local flag = isFirstLeft and 1 or -1
  local p = YcPositionHelper.getDistancePosition(pos, angle, distance1)
  local positions = { p }
  if num > 1 then
    for i = 1, num - 1 do
      local tempDistance = distance2 * math.ceil(i / 2) -- 左右间距相同，共两个
      local tempAngle
      if i % 2 == 1 then -- 奇数
        tempAngle = angle - 90 * flag
      else -- 偶数
        tempAngle = angle + 90 * flag
      end
      table.insert(positions, YcPositionHelper.getDistancePosition(p, tempAngle, tempDistance))
    end
  end
  return positions
end

--[[
  距离位置多远的另一排位置，多个时位置在米字形的一条线上
  @param  {table} pos 位置
  @param  {number} angle 角度，以正南方向开始，顺时针为正，逆时针为负
  @param  {number} distance 角度连线方向上的距离
  @param  {integer} num 位置数量，默认为1
  @return {table} 位置数组
]]
function YcPositionHelper.getRegularDistancePositions (pos, angle, distance, num)
  num = num or 1
  local p = YcPositionHelper.getDistancePosition(pos, angle, distance)
  local positions = { p }
  if num > 1 then
    local tempAngle = angle % 360
    local index = 1
    for i = 22.5, 315, 45 do
      if tempAngle >= i and tempAngle < i + 45 then
        break
      else
        index = index + 1
      end
    end
    if index == 1 then -- 西南
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if i % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x + gap, p.y, p.z - gap))
        else
          table.insert(positions, YcPosition:new(p.x - gap, p.y, p.z + gap))
        end
      end
    elseif index == 2 then -- 西
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if i % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x, p.y, p.z - gap))
        else
          table.insert(positions, YcPosition:new(p.x, p.y, p.z + gap))
        end
      end
    elseif index == 3 then -- 西北
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if i % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x - gap, p.y, p.z - gap))
        else
          table.insert(positions, YcPosition:new(p.x + gap, p.y, p.z + gap))
        end
      end
    elseif index == 4 then -- 北
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if i % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x - gap, p.y, p.z))
        else
          table.insert(positions, YcPosition:new(p.x + gap, p.y, p.z))
        end
      end
    elseif index == 5 then -- 东北
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if i % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x - gap, p.y, p.z + gap))
        else
          table.insert(positions, YcPosition:new(p.x + gap, p.y, p.z - gap))
        end
      end
    elseif index == 6 then -- 东
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if i % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x, p.y, p.z + gap))
        else
          table.insert(positions, YcPosition:new(p.x, p.y, p.z - gap))
        end
      end
    elseif index == 7 then -- 东南
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if i % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x + gap, p.y, p.z + gap))
        else
          table.insert(positions, YcPosition:new(p.x - gap, p.y, p.z - gap))
        end
      end
    elseif index == 8 then -- 南
      for i = 1, num - 1 do
        local gap = math.ceil(i / 2)
        if i % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x + gap, p.y, p.z))
        else
          table.insert(positions, YcPosition:new(p.x - gap, p.y, p.z))
        end
      end
    end
  end
  return positions
end

--[[
  获得两点连线上距离另一个点（第二个点）多远的位置
  若distance为正，则位置在第二个点到第一个点构成的射线上
  为负，则在相反方向上
  @param  {table} pos1 第一个点位置
  @param  {table} pos2 第二个点位置
  @param  {number} distance 距离
  @return {YcPosition} 位置
]]
function YcPositionHelper.getPos2PosOnLineDistancePosition (pos1, pos2, distance)
  local vector3 = YcVector3:new(pos2, pos1)
  local angle = YcVectorHelper.getActorFaceYaw(vector3)
  return YcPositionHelper.getDistancePosition(pos2, angle, distance)
end

--[[
  两点之间的距离
  @param  {table} pos1 第一个点位置
  @param  {table} pos2 第二个点位置
  @return {number} 距离
]]
function YcPositionHelper.getDistance (pos1, pos2)
  local vec3 = YcVector3:new(pos1, pos2)
  return vec3:length()
end

--[[
  两点水平方向上的距离
  @param  {table} pos1 第一个点位置
  @param  {table} pos2 第二个点位置
  @return {number} 距离
]]
function YcPositionHelper.getHorizontalDistance (pos1, pos2)
  local vec2 = YcVector2:new(pos1.x, pos1.z, pos2.x, pos2.z)
  return vec2:length()
end

--[[
  矩形区域范围posBeg, posEnd
  @param  {table} pos 位置
  @param  {table} dim 扩展向量
  @return {YcPosition} 起始点位置
  @return {YcPosition} 结束点位置
]] 
function YcPositionHelper.getRectRange (pos, dim)
  return YcPosition:new(pos.x - dim.x, pos.y - dim.y, pos.z - dim.z), 
    YcPosition:new(pos.x + dim.x, pos.y + dim.y, pos.z + dim.z)
end

-- -- 一个生物处于玩家的哪个角度，正前方为0，左负右正，正后方为180
-- function YcPositionHelper.getRelativePlayerAngle (objid, toobjid)
--   local player = PlayerHelper.getPlayer(objid)
--   local playerPos = player:getMyPosition()
--   local aimPos = YcPosition:new(PlayerHelper.getAimPos(objid))
--   local leftPos = player:getDistancePosition(1, -90) -- 左边点
--   local pos = CacheHelper.getMyPosition(toobjid)
--   local vx, vz = pos.x - playerPos.x, pos.z - playerPos.z
--   local angle1 = YcPositionHelper.getTwoVector2Angle(aimPos.x - playerPos.x, aimPos.z - playerPos.z, vx, vz) -- 与前方向量夹角
--   local angle2 = YcPositionHelper.getTwoVector2Angle(leftPos.x - playerPos.x, leftPos.z - playerPos.z, vx, vz) -- 与左方向量夹角
--   local angle
--   if (angle1 <= 90 and angle2 < 90) then -- 左前
--     angle = -angle1
--   elseif (angle1 <= 90 and angle2 >= 90) then -- 右前
--     angle = angle1
--   elseif (angle1 > 90 and angle2 < 90) then -- 左后
--     angle = -angle1
--   else -- 右后
--     angle = angle1
--   end
--   return math.floor(angle)
-- end

