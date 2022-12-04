--[[ 位置工具类 v1.0.0
  create by 莫小仙 on 2022-08-07
]]
YcPositionHelper = {}

--[[
  距离位置多远的另一个水平位置
  @param  {table} pos 指定位置
  @param  {number} angle 角度，以正南方向开始，顺时针为正，逆时针为负
  @param  {number} distance 角度边上距离顶点的距离
  @return {YcPosition} 位置
]]
function YcPositionHelper.getDistancePosition (pos, angle, distance)
  local x = pos.x - distance * math.sin(math.rad(angle))
  local y = pos.y
  local z = pos.z - distance * math.cos(math.rad(angle))
  return YcPosition:new(x, y, z)
end

--[[
  距离位置多远的另一排位置，多个时依次为中、左、右、左、右...
  @param  {table} pos 指定位置
  @param  {number} angle 角度，以正南方向开始，顺时针为正，逆时针为负
  @param  {number} distance 角度边上距离顶点的距离
  @param  {integer} total 位置总数量，默认为1
  @param  {number} step 垂直于角度边且距离角的顶点指定距离的直线上的间隔距离，默认为1
  @param  {boolean} isFirstLeft 多个位置时，是否先左后右(从pos位置看)
  @return {table} 位置数组
]]
function YcPositionHelper.getDistancePositions (pos, angle, distance, total, step, isFirstLeft)
  total = total or 1 -- 默认为1
  step = step or 1 -- 默认为1
  isFirstLeft = isFirstLeft == nil and true or isFirstLeft -- 默认为true
  local offset = isFirstLeft and 0 or 1 -- 序数偏移
  local p = YcPositionHelper.getDistancePosition(pos, angle, distance) -- 第一个位置，即居中的位置
  local positions = { p }
  if total > 1 then -- 位置超过1个时
    for i = 1, total - 1 do
      local tempDistance = step * math.ceil(i / 2) -- 左右间距相同，共两个
      local tempAngle
      if (i + offset) % 2 == 1 then -- 奇数
        tempAngle = angle - 90
      else -- 偶数
        tempAngle = angle + 90
      end
      table.insert(positions, YcPositionHelper.getDistancePosition(p, tempAngle, tempDistance))
    end
  end
  return positions
end

--[[
  距离位置多远的另一排位置，多个时位置在米字形的一条线上
  @param  {table} pos 指定位置
  @param  {number} angle 角度，以正南方向开始，顺时针为正，逆时针为负
  @param  {number} distance 角度边上距离顶点的距离
  @param  {integer} total 位置总数量，默认为1
  @param  {integer} num 相邻格子的间隔格子数，默认为0
  @param  {boolean} isFirstLeft 多个位置时，是否先左后右(从pos位置看)
  @return {table} 位置数组
]]
function YcPositionHelper.getGridDistancePositions (pos, angle, distance, total, num, isFirstLeft)
  total = total or 1 -- 默认为1
  num = num or 0 -- 默认为0
  local dist = num + 1 -- 相邻格子的轴向距离
  isFirstLeft = isFirstLeft == nil and true or isFirstLeft -- 默认为true
  local offset = isFirstLeft and 0 or 1 -- 序数偏移
  local p = YcPositionHelper.getDistancePosition(pos, angle, distance) -- 第一个位置，即居中的位置
  local positions = { p }
  if total > 1 then -- 位置超过1个时
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
      for i = 1, total - 1 do
        local gap = dist * math.ceil(i / 2)
        if (i + offset) % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x + gap, p.y, p.z - gap)) -- 东南
        else
          table.insert(positions, YcPosition:new(p.x - gap, p.y, p.z + gap)) -- 西北
        end
      end
    elseif index == 2 then -- 西
      for i = 1, total - 1 do
        local gap = dist * math.ceil(i / 2)
        if (i + offset) % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x, p.y, p.z - gap)) -- 南
        else
          table.insert(positions, YcPosition:new(p.x, p.y, p.z + gap)) -- 北
        end
      end
    elseif index == 3 then -- 西北
      for i = 1, total - 1 do
        local gap = dist * math.ceil(i / 2)
        if (i + offset) % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x - gap, p.y, p.z - gap)) -- 西南
        else
          table.insert(positions, YcPosition:new(p.x + gap, p.y, p.z + gap)) -- 东北
        end
      end
    elseif index == 4 then -- 北
      for i = 1, total - 1 do
        local gap = dist * math.ceil(i / 2)
        if (i + offset) % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x - gap, p.y, p.z)) -- 西
        else
          table.insert(positions, YcPosition:new(p.x + gap, p.y, p.z)) -- 东
        end
      end
    elseif index == 5 then -- 东北
      for i = 1, total - 1 do
        local gap = dist * math.ceil(i / 2)
        if (i + offset) % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x - gap, p.y, p.z + gap)) -- 西北
        else
          table.insert(positions, YcPosition:new(p.x + gap, p.y, p.z - gap)) -- 东南
        end
      end
    elseif index == 6 then -- 东
      for i = 1, total - 1 do
        local gap = dist * math.ceil(i / 2)
        if (i + offset) % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x, p.y, p.z + gap)) -- 北
        else
          table.insert(positions, YcPosition:new(p.x, p.y, p.z - gap)) -- 南
        end
      end
    elseif index == 7 then -- 东南
      for i = 1, total - 1 do
        local gap = dist * math.ceil(i / 2)
        if (i + offset) % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x + gap, p.y, p.z + gap)) -- 东北
        else
          table.insert(positions, YcPosition:new(p.x - gap, p.y, p.z - gap)) -- 西南
        end
      end
    elseif index == 8 then -- 南
      for i = 1, total - 1 do
        local gap = dist * math.ceil(i / 2)
        if (i + offset) % 2 == 1 then -- 奇数
          table.insert(positions, YcPosition:new(p.x + gap, p.y, p.z)) -- 东
        else
          table.insert(positions, YcPosition:new(p.x - gap, p.y, p.z)) -- 西
        end
      end
    end
  end
  return positions
end

--[[
  获得两点连线上距离另一个点（第二个点）多远的一组位置
  若distance为正，则位置在第一个点到第二个点构成的线段的延长线上
  为负，则在相反方向上
  @param  {table} pos1 第一个点位置
  @param  {table} pos2 第二个点位置
  @param  {number} distance 与第二个点的距离，为正则pos1到pos2方向上的距离，为负则是相反方向上的距离
  @param  {integer} total 位置总数量
  @param  {number} step 多个位置时，每个位置之间的间距，默认为1。为正则表示从pos1到pos2方向，为负则是相反方向
  @return {YcPosition} 位置
]]
function YcPositionHelper.getTowardsDistancePositions (pos1, pos2, distance, total, step)
  total = total or 1 -- 默认为1
  step = step or 1 -- 默认为1
  local vector3 = YcVector3:new(pos1, pos2) -- pos1到pos2朝向
  local angle = YcVectorHelper.getActorFaceYaw(vector3) -- 角度
  local p = YcPositionHelper.getDistancePosition(pos2, angle, distance) -- 第一个位置
  local positions = { p }
  if total > 1 then -- 位置超过1个时
    for i = 1, total - 1 do
      local dist = distance + step * i
      table.insert(positions, YcPositionHelper.getDistancePosition(pos2, angle, dist))
    end
  end
  return positions
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
  矩形区域起止点位置
  @param  {table} pos 中心点位置
  @param  {table} dim 三维扩大尺寸
  @return {YcPosition} 起始点位置
  @return {YcPosition} 结束点位置
]] 
function YcPositionHelper.getRectRange (pos, dim)
  return YcPosition:new(pos.x - dim.x, pos.y - dim.y, pos.z - dim.z), 
    YcPosition:new(pos.x + dim.x, pos.y + dim.y, pos.z + dim.z)
end