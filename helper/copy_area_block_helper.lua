-- 复制区域方块
CopyAreaBlockHelper = {
  -- 可修改变量
  buffer = 100, -- 一帧创建的方块数，可根据手机承受能力适当改大
  -- 快捷键序数 1~8
  chooseShortcut = 1, -- 选择复制来源
  sureShorcut = 2, -- 确定复制
  mirrorShortcut = 4, -- 镜像(前后、左右、上下)
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
  mirrorDir = 0, -- 镜像方向(1前后2左右3上下)
}

-- 校验
function CopyAreaBlockHelper:check (f)
  xpcall(f, function (err)
    Chat:sendSystemMsg(err)
  end)
end

-- 记录区域方块数据
function CopyAreaBlockHelper:recordAreaBlockData ()
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

function CopyAreaBlockHelper:checkArea (areaid)
  if (not(areaid)) then -- 未找到区域
    Chat:sendSystemMsg('当前位置未发现区域，请进入正确的区域位置')
    return false
  elseif (areaid == self.srcAreaid) then
    Chat:sendSystemMsg('目标区域与源区域相同，请重新选择区域')
    return false
  else
    return true
  end
end

-- dir(朝向) category(水平/竖直)
function CopyAreaBlockHelper:checkAndSetMirror (objid, areaid)
  if (CopyAreaBlockHelper:checkArea(areaid)) then
    local category, dirname = CopyAreaBlockHelper:getMirrorCategory(objid)
    self.dstAreaid = areaid
    self.category = category
    if (not(CopyAreaBlockHelper:checkAreaSize(self.srcAreaid, self.dstAreaid))) then
      Chat:sendSystemMsg('注意：两区域可容纳方块数不同')
    end
    Chat:sendSystemMsg('当前选择#G' .. dirname .. '镜像#n，请选择快捷栏第' .. self.sureShorcut .. '格进行确认')
  end
end

-- 校验并确定翻转类型
function CopyAreaBlockHelper:checkAndSetCategory (objid, areaid, dir)
  if (CopyAreaBlockHelper:checkArea(areaid)) then
    local category, dirname = CopyAreaBlockHelper:getCategory(objid, dir)
    if (category) then
      self.dstAreaid = areaid
      self.category = category
      if (not(CopyAreaBlockHelper:checkAreaSize(self.srcAreaid, self.dstAreaid))) then
        Chat:sendSystemMsg('注意：两区域可容纳方块数不同')
      end
      Chat:sendSystemMsg('当前选择#G向' .. dirname .. '方翻转#n，请选择快捷栏第' .. self.sureShorcut .. '格进行确认')
    else
      Chat:sendSystemMsg('请控制人物正确的朝向，勿朝向上下方向')
    end
  end
end

-- 检测两区域可放置方块数是否相同
function CopyAreaBlockHelper:checkAreaSize (areaid1, areaid2)
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

-- 返回镜像类型 dir(1前后2左右3竖直)
function CopyAreaBlockHelper:getMirrorCategory (objid)
  self.mirrorDir = self.mirrorDir + 1
  if (self.mirrorDir > 3) then
    self.mirrorDir = 1
  end
  if (self.mirrorDir == 1) then
    local result, direct = Actor:getCurPlaceDir(objid)
    if (direct == FACE_DIRECTION.DIR_NEG_X or direct == FACE_DIRECTION.DIR_POS_X) then
      return 'x', '前后'
    elseif (direct == FACE_DIRECTION.DIR_NEG_Z or direct == FACE_DIRECTION.DIR_POS_Z) then
      return 'z', '前后'
    end
  elseif (self.mirrorDir == 2) then
    local result, direct = Actor:getCurPlaceDir(objid)
    if (direct == FACE_DIRECTION.DIR_NEG_X or direct == FACE_DIRECTION.DIR_POS_X) then
      return 'z', '左右'
    elseif (direct == FACE_DIRECTION.DIR_NEG_Z or direct == FACE_DIRECTION.DIR_POS_Z) then
      return 'x', '左右'
    end
  end
  return 'y', '竖直'
end

-- 返回翻转类型 dir：1前2后3左4右
function CopyAreaBlockHelper:getCategory (objid, dir)
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
function CopyAreaBlockHelper:createTargetData ()
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
          CopyAreaBlockHelper:addDstData(i, j, k, x, y, z)
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
          CopyAreaBlockHelper:addDstData(i, j, k, x, y, z)
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
          CopyAreaBlockHelper:addDstData(i, j, k, x, y, z)
          x = x + 1
        end
        y = y + 1
      end
      z = z - 1
    end
    print('z+')
  elseif (self.category == 'z-') then
    -- 目标底面x+、z+、y+ 对应 源最近面x+、y-、z+
    local z = 1
    for j = posBeg2.y, posEnd2.y do
      local y = #self.srcAreaBlockData[1]
      for k = posBeg2.z, posEnd2.z do
        local x = 1
        for i = posBeg2.x, posEnd2.x do
          CopyAreaBlockHelper:addDstData(i, j, k, x, y, z)
          x = x + 1
        end
        y = y - 1
      end
      z = z + 1
    end
    print('z-')
  elseif (self.category == 'x') then
    -- 目标底面x+、z+、y+ 对应 源目标底面x-、z+、y+
    local y = 1
    for j = posBeg2.y, posEnd2.y do
      local z = 1
      for k = posBeg2.z, posEnd2.z do
        local x = #self.srcAreaBlockData
        for i = posBeg2.x, posEnd2.x do
          CopyAreaBlockHelper:addDstData(i, j, k, x, y, z)
          x = x - 1
        end
        z = z + 1
      end
      y = y + 1
    end
  elseif (self.category == 'y') then
    -- 目标底面x+、z+、y+ 对应 源目标底面x+、z+、y-
    local y = #self.srcAreaBlockData[1]
    for j = posBeg2.y, posEnd2.y do
      local z = 1
      for k = posBeg2.z, posEnd2.z do
        local x = 1
        for i = posBeg2.x, posEnd2.x do
          CopyAreaBlockHelper:addDstData(i, j, k, x, y, z)
          x = x + 1
        end
        z = z + 1
      end
      y = y - 1
    end
  elseif (self.category == 'z') then
    -- 目标底面x+、z+、y+ 对应 源目标底面x+、z-、y+
    local y = 1
    for j = posBeg2.y, posEnd2.y do
      local z = #self.srcAreaBlockData[1][1]
      for k = posBeg2.z, posEnd2.z do
        local x = 1
        for i = posBeg2.x, posEnd2.x do
          CopyAreaBlockHelper:addDstData(i, j, k, x, y, z)
          x = x + 1
        end
        z = z - 1
      end
      y = y + 1
    end
  end
  return true
end

function CopyAreaBlockHelper:addDstData (i, j, k, x, y, z)
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

function CopyAreaBlockHelper:generate ()
  self.createIndex = 1
  self.isCreating = true
  Chat:sendSystemMsg('开始生成，请耐心等待……')
end

-- eventobjid, toobjid, itemid, itemnum
local playerSelectShortcut = function (event)
  CopyAreaBlockHelper:check(function ()
    local objid = event.eventobjid
    local result, index = Player:getCurShotcut(objid)
    local result2, x, y, z = Actor:getPosition(objid)
    local result3, areaid = Area:getAreaByPos({ x = x, y = y, z = z })
    if (index == CopyAreaBlockHelper.chooseShortcut - 1) then -- 选择区域
      if (result3 == ErrorCode.OK) then -- 找到区域
        CopyAreaBlockHelper.srcAreaid = areaid
        CopyAreaBlockHelper:recordAreaBlockData()
      else
        Chat:sendSystemMsg('当前位置未发现区域，请进入正确的区域位置')
      end
    elseif (index == CopyAreaBlockHelper.sureShorcut - 1) then -- 确定翻转复制
      if (CopyAreaBlockHelper.dstAreaid) then
        if (CopyAreaBlockHelper:createTargetData()) then
          CopyAreaBlockHelper:generate()
        end
      end
    elseif (index == CopyAreaBlockHelper.mirrorShortcut - 1) then -- 水平镜像
      CopyAreaBlockHelper:checkAndSetMirror(objid, areaid)
    elseif (index == CopyAreaBlockHelper.turnFrontShortcut - 1) then -- 向前翻转
      CopyAreaBlockHelper:checkAndSetCategory(objid, areaid, 1)
    elseif (index == CopyAreaBlockHelper.turnBackShortcut - 1) then -- 向后翻转
      CopyAreaBlockHelper:checkAndSetCategory(objid, areaid, 2)
    elseif (index == CopyAreaBlockHelper.turnLeftShortcut - 1) then -- 向左翻转
      CopyAreaBlockHelper:checkAndSetCategory(objid, areaid, 3)
    elseif (index == CopyAreaBlockHelper.turnRightShortcut - 1) then -- 向右翻转
      CopyAreaBlockHelper:checkAndSetCategory(objid, areaid, 4)
    end
  end)
end

local runGame = function ()
  CopyAreaBlockHelper:check(function ()
    if (CopyAreaBlockHelper.isCreating) then
      if (CopyAreaBlockHelper.createIndex <= #CopyAreaBlockHelper.dstAreaBlockData) then
        local endIndex
        if (CopyAreaBlockHelper.createIndex + CopyAreaBlockHelper.buffer - 1 <= #CopyAreaBlockHelper.dstAreaBlockData) then -- 足够
          endIndex = CopyAreaBlockHelper.buffer - 1
        else -- 不够
          endIndex = #CopyAreaBlockHelper.dstAreaBlockData - CopyAreaBlockHelper.createIndex
        end
        for i = 0, endIndex do
          local data = CopyAreaBlockHelper.dstAreaBlockData[CopyAreaBlockHelper.createIndex + i]
          Block:setBlockAll(data.x, data.y, data.z, data.blockid, data.data)
        end
        CopyAreaBlockHelper.createIndex = CopyAreaBlockHelper.createIndex + endIndex + 1
      else
        CopyAreaBlockHelper.isCreating = false
        Chat:sendSystemMsg('复制完成')
      end
    end
  end)
end

ScriptSupportEvent:registerEvent([=[Player.SelectShortcut]=], playerSelectShortcut) -- 选择快捷栏
ScriptSupportEvent:registerEvent([=[Game.Run]=], runGame) -- 游戏运行时