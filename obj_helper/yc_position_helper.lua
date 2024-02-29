--- 位置工具类 v1.0.1
--- created by 莫小仙 on 2022-08-07
--- last modified on 2023-08-05
YcPositionHelper = {}

--- 距离位置多远的另一个水平位置
---@param pos table{ x: number, y: number, z: number } 指定位置
---@param angle number 角度，以正南方向开始，顺时针为正，逆时针为负
---@param distance number 角度边上距离顶点的距离
---@return YcPosition 位置对象
function YcPositionHelper.getDistancePosition(pos, angle, distance)
  local x = pos.x - distance * math.sin(math.rad(angle))
  local y = pos.y
  local z = pos.z - distance * math.cos(math.rad(angle))
  return YcPosition:new(x, y, z)
end

--- 距离位置多远的另一排位置，多个时依次为中、左、右、左、右...
---@param pos table{ x: number, y: number, z: number } 指定位置
---@param angle number 角度，以正南方向开始，顺时针为正，逆时针为负
---@param distance number 角度边上距离顶点的距离
---@param total integer | nil 位置总数量，默认为1
---@param step number | nil 垂直于角度边且距离角的顶点指定距离的直线上的间隔距离，默认为1
---@param isFirstLeft boolean | nil 多个位置时，是否先左后右(从pos位置看)。默认为是
---@return YcPosition[] 位置数组
function YcPositionHelper.getDistancePositions(pos, angle, distance, total, step, isFirstLeft)
  total = total or 1 -- 默认为1
  step = step or 1 -- 默认为1
  isFirstLeft = isFirstLeft == nil and true or isFirstLeft -- 默认为true
  local offset = isFirstLeft and 0 or 1 -- 序数偏移
  local p = YcPositionHelper.getDistancePosition(pos, angle, distance) -- 第一个位置，即居中的位置
  local positions = {p}
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

--- 距离位置多远的另一排位置，多个时位置在米字形的一条线上
---@param pos table{ x: number, y: number, z: number } 指定位置
---@param angle number 角度，以正南方向开始，顺时针为正，逆时针为负
---@param distance number 角度边上距离顶点的距离
---@param total integer | nil 位置总数量，默认为1
---@param num integer | nil 相邻格子的间隔格子数，默认为0
---@param isFirstLeft boolean | nil 多个位置时，是否先左后右(从pos位置看)。默认为是
---@return YcPosition[] 位置数组
function YcPositionHelper.getGridDistancePositions(pos, angle, distance, total, num, isFirstLeft)
  total = total or 1 -- 默认为1
  num = num or 0 -- 默认为0
  local dist = num + 1 -- 相邻格子的轴向距离
  isFirstLeft = isFirstLeft == nil and true or isFirstLeft -- 默认为true
  local offset = isFirstLeft and 0 or 1 -- 序数偏移
  local p = YcPositionHelper.getDistancePosition(pos, angle, distance) -- 第一个位置，即居中的位置
  local positions = {p}
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

--- 获得两点连线上距离另一个点（第二个点）多远的一组位置
--- 若distance为正，则位置在第一个点到第二个点构成的线段的延长线上
--- 为负，则在相反方向上
---@param pos1 table{ x: number, y: number, z: number } 第一个点位置
---@param pos2 table{ x: number, y: number, z: number } 第二个点位置
---@param distance number 与第二个点的距离，为正则pos1到pos2方向上的距离，为负则是相反方向上的距离
---@param total integer 位置总数量
---@param step number 多个位置时，每个位置之间的间距，默认为1。为正则表示从pos1到pos2方向，为负则是相反方向
---@return YcPosition 位置对象
function YcPositionHelper.getTowardsDistancePositions(pos1, pos2, distance, total, step)
  total = total or 1 -- 默认为1
  step = step or 1 -- 默认为1
  local vector3 = YcVector3:new(pos1, pos2) -- pos1到pos2朝向
  local angle = YcVectorHelper.getActorFaceYaw(vector3) -- 角度
  local p = YcPositionHelper.getDistancePosition(pos2, angle, distance) -- 第一个位置
  local positions = {p}
  if total > 1 then -- 位置超过1个时
    for i = 1, total - 1 do
      local dist = distance + step * i
      table.insert(positions, YcPositionHelper.getDistancePosition(pos2, angle, dist))
    end
  end
  return positions
end

--- 获取两点之间的距离
---@param pos1 table{ x: number, y: number, z: number } 第一个点位置
---@param pos2 table{ x: number, y: number, z: number } 第二个点位置
---@return number 距离
function YcPositionHelper.getDistance(pos1, pos2)
  local vec3 = YcVector3:new(pos1, pos2)
  return vec3:length()
end

--- 获取两点水平方向上的距离
---@param pos1 table{ x: number, y: number, z: number } 第一个点位置
---@param pos2 table{ x: number, y: number, z: number } 第二个点位置
---@return number 距离
function YcPositionHelper.getHorizontalDistance(pos1, pos2)
  local vec2 = YcVector2:new(pos1.x, pos1.z, pos2.x, pos2.z)
  return vec2:length()
end

--- 获取矩形区域起止点位置
---@param pos table{ x: number, y: number, z: number } 中心点位置
---@param dim table{ x: number, y: number, z: number } 三维扩大尺寸
---@return YcPosition 起始点位置
---@return YcPosition 结束点位置
function YcPositionHelper.getRectRange(pos, dim)
  return YcPosition:new(pos.x - dim.x, pos.y - dim.y, pos.z - dim.z),
    YcPosition:new(pos.x + dim.x, pos.y + dim.y, pos.z + dim.z)
end

--- 获取两点构成的线段经过的所有方块位置。方块位置是指一个方块所在的位置
---@param pos1 table{ x: number, y: number, z: number } 点1位置
---@param pos2 table{ x: number, y: number, z: number } 点2位置
---@return YcArray<YcPosition> 方块位置数组
function YcPositionHelper.getBlockPositionsBetweenTwoPositions(pos1, pos2)
  pos1 = YcPosition:new(pos1)
  pos2 = YcPosition:new(pos2)
  local blockPosList = YcArray:new()
  local blockPos1 = pos1:floor() -- 起点方块位置
  blockPosList:push(blockPos1)
  local vec3 = YcVector3:new(pos1, pos2) -- 方向向量
  local len = vec3:length() -- 两点间距离
  local vecNormal = vec3:normalize() -- 单位向量
  local s = 0 -- 从起点往终点的线段上前进的距离
  local currPos = pos1 -- 当前点
  -- 循环找出所有中间方块
  while true do
    -- 判断当前哪个方向上更快进入下一个方格
    local tx, bx = YcPositionHelper.getReachBoundaryTime(currPos, vecNormal, 'x')
    local ty, by = YcPositionHelper.getReachBoundaryTime(currPos, vecNormal, 'y')
    local tz, bz = YcPositionHelper.getReachBoundaryTime(currPos, vecNormal, 'z')
    -- 将三个分量放入数组
    local arr = YcArray:new()
    arr:push(YcTable:new({
      t = tx,
      b = bx,
      c = 'x'
    }), YcTable:new({
      t = ty,
      b = by,
      c = 'y'
    }), YcTable:new({
      t = tz,
      b = bz,
      c = 'z'
    }))
    -- 按时间升序排列，第一个最小
    arr:sort(function(a, b)
      return a.t < b.t
    end)
    local minInfo = arr[1] -- 第一个值就是最先抵达边界的坐标分量信息
    s = s + minInfo.t -- 因为是单位向量，可以认为速度v是1。于是由s = vt得到s = t
    if s < len then -- 如果还没有到达终点，那么说明线段到达边界后还会继续前进，进入下一个方块
      -- 更新到达边界的点的位置
      currPos = YcPosition:new(pos1.x + vecNormal.x * s, pos1.y + vecNormal.y * s, pos1.z + vecNormal.z * s)
      -- 为了避免到底边界点的误差，重新赋值。至于另外两个方向上的误差，就忽略了
      currPos[minInfo.c] = minInfo.b
      -- 这里需要做一个边界判断。虽然说是一个分量到达边界，但有可能同时还有其他分量也到达边界了
      -- 所以这里对三个边界都判断一下
      local bs = {'x', 'y', 'z'} -- 分量名数组
      local offsetArr = {0, 0, 0} -- 各分类偏移位置
      -- 遍历分量，获得偏移位置。正向不变，逆向减1。因为位置点是各分类向下取整的
      -- 如：分量向上到达1时，下一个极近的点范围在(1,2)，向下取整还是1，与分量相同；
      -- 分量向下达到1时，下一个极近的点范围在(0,1)，向下取整是0，比分量小1
      for i, coor in ipairs(bs) do
        if currPos[coor] == math.floor(currPos[coor]) then -- 该分量到达边界
          if vecNormal[coor] < 0 then -- 如果是减少
            offsetArr[i] = -1
          end
        end
      end
      -- 准备计算得出边界点属于哪一个方块
      local blockPos = currPos:floor() -- 各分量向下取整
      if offsetArr[1] ~= 0 then
        blockPos.x = blockPos.x - 1
      end
      if offsetArr[2] ~= 0 then
        blockPos.y = blockPos.y - 1
      end
      if offsetArr[3] ~= 0 then
        blockPos.z = blockPos.z - 1
      end
      blockPosList:push(blockPos)
    else -- 如果超过了终点
      break
    end
  end
  return blockPosList
end

function YcPositionHelper.getReachBoundaryTime(pos, speed, coordinate)
  local boundary -- 最近边界
  if speed[coordinate] > 0 then -- x方向上在增加
    boundary = math.floor(pos[coordinate] + 1)
    local offsetX = boundary - pos[coordinate] -- 当前坐标分量上与边界的距离
    return offsetX / speed[coordinate], boundary
  elseif speed[coordinate] < 0 then -- x方向上在减少
    boundary = math.ceil(pos[coordinate] - 1)
    local offsetX = boundary - pos[coordinate] -- 当前坐标分量上与边界的距离
    return offsetX / speed[coordinate], boundary
  else -- x方向上不变
    return 9999 -- 这里用9999表示无穷大。因为这里的时间最小值（三个方向速度相等时）不会大于根号三，所以任意大于根号三的值都行
  end
end
