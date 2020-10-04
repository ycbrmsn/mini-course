-- 翻转复制区域方块
TurnAreaBlockHelper = {
  -- 可修改变量
  buffer = 100, -- 一帧创建的方块数，可根据手机承受能力适当改大
  -- 快捷键序数 1~8
  chooseShortcut = 1, -- 选择复制来源
  sureShorcut = 2, -- 确定翻转复制
  turnFrontShortcut = 5, -- 向前翻转
  turnBackShortcut = 6, -- 向后翻转
  turnLeftShortcut = 7, -- 向左翻转
  turnRightShortcut = 8, -- 向右翻转
  -- 不可修改变量
  srcAreaBlockData = {}, -- 来源区域方块数据
  dstAreaBlockData = {}, -- 目标区域方块数据
  srcAreaid = nil, -- 来源区域
  dstAreaid = nil, -- 目标区域
  category = nil, -- 翻转类型
  isCreating = false, -- 是否在创建
  createIndex = 1, -- 当前创建方块的序数
}

-- 校验
function TurnAreaBlockHelper:check (f)
  xpcall(f, function (err)
    Chat:sendSystemMsg(err)
  end)
end

-- 记录区域方块数据
function TurnAreaBlockHelper:recordAreaBlockData ()
  local idx = 0
  local result, posBeg, posEnd = Area:getAreaRectRange(self.srcAreaid)
  if (result == ErrorCode.OK) then -- 获取起始位置成功
    self.srcAreaBlockData = {}
    for i = posBeg.x, posEnd.x do
      local dataX = {}
      for j = posBeg.y, posEnd.y do
        local dataY = {}
        for k = posBeg.z, posEnd.z do
          local result2, blockid = Block:getBlockID(i, j, k)
          local data = { x = i, y = j, z = k, blockid = blockid or BLOCKID.AIR }
          if (result2 == ErrorCode.OK and blockid ~= BLOCKID.AIR) then -- 方块不是空气
            idx = idx + 1
            if (idx < 10) then
              print(data.blockid)
            end
            local result3, d = Block:getBlockData(i, j, k)
            data.data = d or 0
          end
          table.insert(dataY, data)
        end
        table.insert(dataX, dataY)
      end
      table.insert(self.srcAreaBlockData, dataX)
    end
    self.dstAreaid = nil -- 清除目标区域
    Chat:sendSystemMsg('选定区域，记录数据完成')
    print(idx)
  end
end

-- 校验并确定翻转类型
function TurnAreaBlockHelper:checkAndSetCategory (objid, areaid, dir)
  if (not(areaid)) then -- 未找到区域
    Chat:sendSystemMsg('当前位置未发现区域，请进入正确的区域位置')
  elseif (areaid == self.srcAreaid) then
    Chat:sendSystemMsg('目标区域与源区域相同，请重新选择区域')
  else
    local category, dirname = TurnAreaBlockHelper:getCategory(objid, dir)
    if (category) then
      self.dstAreaid = areaid
      self.category = category
      if (not(TurnAreaBlockHelper:checkAreaSize(self.srcAreaid, self.dstAreaid))) then
        Chat:sendSystemMsg('注意：两区域可容纳方块数不同')
      end
      Chat:sendSystemMsg('当前选择向' .. dirname .. '方翻转，请选择快捷栏第' .. self.sureShorcut .. '格进行确认')
    else
      Chat:sendSystemMsg('请控制人物正确的朝向，勿朝向上下方向')
    end
  end
end

-- 检测两区域可放置方块数是否相同
function TurnAreaBlockHelper:checkAreaSize (areaid1, areaid2)
  local result1, posBeg1, posEnd1 = Area:getAreaRectRange(areaid1)
  local result2, posBeg2, posEnd2 = Area:getAreaRectRange(areaid2)
  if (result1 ~= ErrorCode.OK or result2 ~= ErrorCode.OK) then
    Chat:sendSystemMsg('获取区域大小失败')
    return false
  else
    return (posEnd1.x - posBeg1.x) * (posEnd1.y - posBeg1.y) * (posEnd1.z - posBeg1.z)
      == (posEnd2.x - posBeg2.x) * (posEnd2.y - posBeg2.y) * (posEnd2.z - posBeg2.z)
  end
end

-- 返回翻转类型 dir：1前2后3左4右
function TurnAreaBlockHelper:getCategory (objid, dir)
  dir = dir or 1
  local result, direct = Actor:getCurPlaceDir(objid)
  if (direct == FACE_DIRECTION.DIR_NEG_X) then -- x+
    if (dir == 1) then
      return 'x+', '前'
    elseif (dir == 2) then
      return 'x-', '后'
    elseif (dir == 3) then
      return 'z+', '左'
    else
      return 'z-', '右'
    end
  elseif (direct == FACE_DIRECTION.DIR_POS_X) then -- x-
    if (dir == 1) then
      return 'x-', '前'
    elseif (dir == 2) then
      return 'x+', '后'
    elseif (dir == 3) then
      return 'z-', '左'
    else
      return 'z+', '右'
    end
  elseif (direct == FACE_DIRECTION.DIR_NEG_Z) then -- z+
    if (dir == 1) then
      return 'z+', '前'
    elseif (dir == 2) then
      return 'z-', '后'
    elseif (dir == 3) then
      return 'x-', '左'
    else
      return 'x+', '右'
    end
  elseif (direct == FACE_DIRECTION.DIR_POS_Z) then -- z-
    if (dir == 1) then
      return 'z-', '前'
    elseif (dir == 2) then
      return 'z+', '后'
    elseif (dir == 3) then
      return 'x+', '左'
    else
      return 'x-', '右'
    end
  else -- 其他方向
    return nil
  end
end

-- 创建目标区域数据
function TurnAreaBlockHelper:createTargetData ()
  local result1, posBeg1, posEnd1 = Area:getAreaRectRange(self.srcAreaid)
  local result2, posBeg2, posEnd2 = Area:getAreaRectRange(self.dstAreaid)
  if (result1 ~= ErrorCode.OK or result2 ~= ErrorCode.OK) then -- 获取起始点失败
    return false
  end
  self.dstAreaBlockData = {}
  if (self.category == 'x+') then
    -- 目标底面x+、z+、y+ 对应 源最右面y+、z+、x-
    local x = #self.srcAreaBlockData
    for j = posBeg2.y, posEnd2.y do
      local z = 1
      for k = posBeg2.z, posEnd2.z do
        local y = 1
        for i = posBeg2.x, posEnd2.x do
          TurnAreaBlockHelper:addDstData(i, j, k, x, y, z)
          y = y + 1
        end
        z = z + 1
      end
      x = x - 1
    end
    print('x+')
  elseif (self.category == 'x-') then
    -- 目标底面x+、z+、y+ 对应 源最左面y-、z+、x+
    local x = 1
    for j = posBeg2.y, posEnd2.y do
      local z = 1
      for k = posBeg2.z, posEnd2.z do
        local y = #self.srcAreaBlockData[1]
        for i = posBeg2.x, posEnd2.x do
          TurnAreaBlockHelper:addDstData(i, j, k, x, y, z)
          y = y - 1
        end
        z = z + 1
      end
      x = x + 1
    end
    print('x-')
  elseif (self.category == 'z+') then
    -- 目标底面x+、z+、y+ 对应 源最远面x+、y+、z-
    local z = #self.srcAreaBlockData[1][1]
    for j = posBeg2.y, posEnd2.y do
      local y = 1
      for k = posBeg2.z, posEnd2.z do
        local x = 1
        for i = posBeg2.x, posEnd2.x do
          TurnAreaBlockHelper:addDstData(i, j, k, x, y, z)
          x = x + 1
        end
        y = y + 1
      end
      z = z - 1
    end
    print('z+')
  else
    -- 目标底面x+、z+、y+ 对应 源最近面x+、y-、z+
    local z = 1
    for j = posBeg2.y, posEnd2.y do
      local y = #self.srcAreaBlockData[1]
      for k = posBeg2.z, posEnd2.z do
        local x = 1
        for i = posBeg2.x, posEnd2.x do
          TurnAreaBlockHelper:addDstData(i, j, k, x, y, z)
          x = x + 1
        end
        y = y - 1
      end
      z = z + 1
    end
    print('z-')
  end
  return true
end

function TurnAreaBlockHelper:addDstData (i, j, k, x, y, z)
  local data
  if (x >= 1 and x <= #self.srcAreaBlockData and y >= 1 and y <=#self.srcAreaBlockData[1]
    and z >= 1 and z <= #self.srcAreaBlockData[1][1]) then
    data = self.srcAreaBlockData[x][y][z]
  else
    data = { blockid = BLOCKID.AIR, data = 0 }
  end
  local dstData = { x = i, y = j, z = k, blockid = data.blockid, data = data.data }
  table.insert(self.dstAreaBlockData, dstData)
end

function TurnAreaBlockHelper:generate ()
  self.createIndex = 1
  self.isCreating = true
  Chat:sendSystemMsg('开始生成，请耐心等待……')
end

-- eventobjid, toobjid, itemid, itemnum
local playerSelectShortcut = function (event)
  TurnAreaBlockHelper:check(function ()
    local objid = event.eventobjid
    local result, index = Player:getCurShotcut(objid)
    local result2, x, y, z = Actor:getPosition(objid)
    local result3, areaid = Area:getAreaByPos({ x = x, y = y, z = z })
    if (index == TurnAreaBlockHelper.chooseShortcut - 1) then -- 选择区域
      if (result3 == ErrorCode.OK) then -- 找到区域
        TurnAreaBlockHelper.srcAreaid = areaid
        TurnAreaBlockHelper:recordAreaBlockData()
      else
        Chat:sendSystemMsg('当前位置未发现区域，请进入正确的区域位置')
      end
    elseif (index == TurnAreaBlockHelper.sureShorcut - 1) then -- 确定翻转复制
      if (TurnAreaBlockHelper.dstAreaid) then
        if (TurnAreaBlockHelper:createTargetData()) then
          TurnAreaBlockHelper:generate()
        end
      end
    elseif (index == TurnAreaBlockHelper.turnFrontShortcut - 1) then -- 向前翻转
      TurnAreaBlockHelper:checkAndSetCategory(objid, areaid, 1)
    elseif (index == TurnAreaBlockHelper.turnBackShortcut - 1) then -- 向后翻转
      TurnAreaBlockHelper:checkAndSetCategory(objid, areaid, 2)
    elseif (index == TurnAreaBlockHelper.turnLeftShortcut - 1) then -- 向左翻转
      TurnAreaBlockHelper:checkAndSetCategory(objid, areaid, 3)
    elseif (index == TurnAreaBlockHelper.turnRightShortcut - 1) then -- 向右翻转
      TurnAreaBlockHelper:checkAndSetCategory(objid, areaid, 4)
    end
  end)
end

local runGame = function ()
  TurnAreaBlockHelper:check(function ()
    if (TurnAreaBlockHelper.isCreating) then
      if (TurnAreaBlockHelper.createIndex <= #TurnAreaBlockHelper.dstAreaBlockData) then
        local endIndex
        if (TurnAreaBlockHelper.createIndex + TurnAreaBlockHelper.buffer - 1 <= #TurnAreaBlockHelper.dstAreaBlockData) then -- 足够
          endIndex = TurnAreaBlockHelper.buffer - 1
        else -- 不够
          endIndex = #TurnAreaBlockHelper.dstAreaBlockData - TurnAreaBlockHelper.createIndex
        end
        for i = 0, endIndex do
          local data = TurnAreaBlockHelper.dstAreaBlockData[TurnAreaBlockHelper.createIndex + i]
          Block:setBlockAll(data.x, data.y, data.z, data.blockid, data.data)
        end
        TurnAreaBlockHelper.createIndex = TurnAreaBlockHelper.createIndex + endIndex + 1
      else
        TurnAreaBlockHelper.isCreating = false
        Chat:sendSystemMsg('翻转复制完成')
      end
    end
  end)
end

ScriptSupportEvent:registerEvent([=[Player.SelectShortcut]=], playerSelectShortcut) -- 选择快捷栏
ScriptSupportEvent:registerEvent([=[Game.Run]=], runGame) -- 游戏运行时