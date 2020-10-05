-- 圆工具类
CircleHelper = {
  -- 可修改变量
  buffer = 100, -- 一帧创建的方块数，可根据手机承受能力适当改大
  isReplace = false, -- 是否替换已存在方块，默认不替换
  -- 快捷键序数 1~8
  sureShorcut = 1, -- 确定中心点
  resetShorcut = 2, -- 重置设置
  changeModelShorcut = 6, -- 模式转换
  enlargeRadiusShorcut = 7, -- 放大半径
  reduceRadiusShorcut = 8, -- 缩小半径
  -- 不可修改变量
  isCreating = false, -- 是否在创建
  createIndex = 1, -- 当前创建方块的序数
  blockInfo = nil, -- 圆/球心数据
  defaultRadius = 5, -- 默认半径
  radius = 5, -- 半径
  defaultCategory = 1, -- 默认类型
  category = 1, -- 类型1：水平；2前后；3左右；4球。默认水平
  categoryName = { '水平圆圈', '前后圆圈', '左右圆圈', '球形', '半球形' },
  createArr = {},
  existMap = {},
  factor = 0.9999, -- 系数
}

-- 校验
function CircleHelper:check (f)
  xpcall(f, function (err)
    Chat:sendSystemMsg(err)
  end)
end

-- 重置
function CircleHelper:reset ()
  self.category = self.defaultCategory
  self.radius = self.defaultRadius
  Chat:sendSystemMsg('重置半径为#B' .. self.radius .. '#n，模式为#B' .. self.categoryName[self.category])
end

-- 变更模式
function CircleHelper:changeModel ()
  self.category = self.category + 1
  if (self.category > 5) then
    self.category = 1
  end
  Chat:sendSystemMsg('切换为#B' .. self.categoryName[self.category] .. '#n模式')
end

-- 改变半径
function CircleHelper:changeRadius (change)
  self.radius = self.radius + change
  if (self.radius < 1) then
    self.radius = 1
    Chat:sendSystemMsg('半径#B' .. self.radius .. '#n已经是最小了')
  else
    Chat:sendSystemMsg('当前半径调整为#B' .. self.radius)
  end
end

-- 是否选择完成
function CircleHelper:isChooseFinish ()
  if (not(self.blockInfo)) then
    Chat:sendSystemMsg('未选择中心点')
    return false
  end
  return true
end

-- 计算
function CircleHelper:calculate (objid)
  self.createArr = {}
  self.existMap = {}
  local x, y, z = self.blockInfo.x, self.blockInfo.y, self.blockInfo.z
  if (self.category == 1) then -- 水平
    CircleHelper:insertCenterY(x, y, z, self.radius)
  elseif (self.category == 2) then -- 前后
    local result, direct = Actor:getCurPlaceDir(objid)
    if (direct == FACE_DIRECTION.DIR_NEG_X or direct == FACE_DIRECTION.DIR_POS_X) then -- x
      CircleHelper:insertCenterZ(x, y, z, self.radius)
    else
      CircleHelper:insertCenterX(x, y, z, self.radius)
    end
  elseif (self.category == 3) then -- 左右
    local result, direct = Actor:getCurPlaceDir(objid)
    if (direct == FACE_DIRECTION.DIR_NEG_X or direct == FACE_DIRECTION.DIR_POS_X) then -- x
      CircleHelper:insertCenterX(x, y, z, self.radius)
    else
      CircleHelper:insertCenterZ(x, y, z, self.radius)
    end
  elseif (self.category == 4) then -- 球形
    CircleHelper:insertBall()
  else -- 半球形
    local result, dirx, diry, dirz = Actor:getFaceDirection(objid)
    print(dirx, diry, dirz)
    local dx, dy, dz = math.abs(dirx), math.abs(diry), math.abs(dirz)
    if (dx >= dy and dx >= dz) then -- x
      if (dirx > 0) then -- x+
        CircleHelper:insertXBall(0, 90)
      else -- x-
        CircleHelper:insertXBall(90, 180)
      end
    elseif (dy >= dx and dy >= dz) then -- y
      if (diry > 0) then
        CircleHelper:insertYBall(0, 90)
      else
        CircleHelper:insertYBall(90, 180)
      end
    else -- z
      if (dirz > 0) then
        CircleHelper:insertZBall(0, 90)
      else
        CircleHelper:insertZBall(90, 180)
      end
    end
  end
  return true
end

function CircleHelper:getAngle (radius)
  local angle = 90 / (radius * 2 + 1) -- 90度除以一边长
  if (angle < 0.5) then
    return 0.25
  elseif (angle < 1) then
    return 0.5
  elseif (angle < 2) then
    return 1
  elseif (angle < 3) then
    return 2
  elseif (angle < 6) then
    return 3
  elseif (angle < 9) then
    return 6
  else
    return 9
  end
end

-- x轴正方向起旋转

function CircleHelper:sin (angle)
  return math.sin(math.rad(angle))
end

function CircleHelper:cos (angle)
  return math.cos(math.rad(angle))
end

-- 不存在才插入
function CircleHelper:insert (arr, x, y, z)
  -- print(x, z)
  local nx, ny, nz = math.floor(x), math.floor(y), math.floor(z)
  local key = nx .. ',' .. ny .. ',' .. nz
  if (not(self.existMap[key])) then
    table.insert(arr, { x = nx, y = ny, z = nz })
    self.existMap[key] = true
    -- print(nx, nz, x, z)
  end
end

function CircleHelper:insertCenterX (x, y, z, radius)
  radius = radius * self.factor
  local angle = CircleHelper:getAngle(radius)
  for i = 0, 360, angle do
    CircleHelper:insert(self.createArr, x, y - radius * CircleHelper:sin(i), z + radius * CircleHelper:cos(i))
  end
end

function CircleHelper:insertCenterY (x, y, z, radius)
  radius = radius * self.factor
  local angle = CircleHelper:getAngle(radius)
  for i = 0, 360, angle do
    CircleHelper:insert(self.createArr, x + radius * CircleHelper:cos(i), y, z - radius * CircleHelper:sin(i))
  end
end

function CircleHelper:insertCenterZ (x, y, z, radius)
  radius = radius * self.factor
  local angle = CircleHelper:getAngle(radius)
  for i = 0, 360, angle do
    CircleHelper:insert(self.createArr, x + radius * CircleHelper:cos(i), y - radius * CircleHelper:sin(i), z)
  end
end

function CircleHelper:insertBall ()
  CircleHelper:insertYBall(0, 180)
end

function CircleHelper:insertXBall (angle1, angle2)
  local y, z = self.blockInfo.y, self.blockInfo.z
  local angle = CircleHelper:getAngle(self.radius)
  for i = angle1, angle2, angle do
    local x = self.blockInfo.x + self.radius * self.factor * CircleHelper:cos(i)
    local radius = self.radius * CircleHelper:sin(i)
    CircleHelper:insertCenterX(x, y, z, radius)
  end
end

function CircleHelper:insertYBall (angle1, angle2)
  local x, z = self.blockInfo.x, self.blockInfo.z
  local angle = CircleHelper:getAngle(self.radius)
  for i = angle1, angle2, angle do
    local y = self.blockInfo.y + self.radius * self.factor * CircleHelper:cos(i)
    local radius = self.radius * CircleHelper:sin(i)
    CircleHelper:insertCenterY(x, y, z, radius)
  end
end

function CircleHelper:insertZBall (angle1, angle2)
  local x, y = self.blockInfo.x, self.blockInfo.y
  local angle = CircleHelper:getAngle(self.radius)
  for i = angle1, angle2, angle do
    local z = self.blockInfo.z + self.radius * self.factor * CircleHelper:cos(i)
    local radius = self.radius * CircleHelper:sin(i)
    CircleHelper:insertCenterZ(x, y, z, radius)
  end
end

-- 生成
function CircleHelper:generate ()
  self.createIndex = 1
  self.isCreating = true
  Chat:sendSystemMsg('开始创建，请稍后')
end

local runGame = function ()
  CircleHelper:check(function ()
    if (CircleHelper.isCreating) then
      if (CircleHelper.createIndex <= #CircleHelper.createArr) then
        local endIndex
        if (CircleHelper.createIndex + CircleHelper.buffer - 1 <= #CircleHelper.createArr) then -- 足够
          endIndex = CircleHelper.buffer - 1
        else -- 不够
          endIndex = #CircleHelper.createArr - CircleHelper.createIndex
        end
        for i = 0, endIndex do
          local data = CircleHelper.createArr[CircleHelper.createIndex + i]
          Block:setBlockAll(data.x, data.y, data.z, CircleHelper.blockInfo.blockid, CircleHelper.blockInfo.data)
        end
        CircleHelper.createIndex = CircleHelper.createIndex + endIndex + 1
      else
        CircleHelper.isCreating = false
        Chat:sendSystemMsg('创建完成')
      end
    end
  end)
end

-- eventobjid, blockid, x, y, z
local playerClickBlock = function (event)
  CircleHelper:check(function ()
    local objid, blockid = event.objid, event.blockid
    local x, y, z = event.x, event.y, event.z
    local result, data = Block:getBlockData(x, y, z)
    if (result ~= ErrorCode.OK) then
      Chat:sendSystemMsg('获取方块数据失败，请重新选择方块')
      return
    end
    CircleHelper.blockInfo = { x = x, y = y, z = z, blockid = blockid, data = data }
    Chat:sendSystemMsg('选择中心方块成功，是否以#B' .. CircleHelper.categoryName[CircleHelper.category]
      .. '#n模式创建方块？')
    Chat:sendSystemMsg('（选择快捷栏第#B' .. CircleHelper.sureShorcut .. '#n格确定，第#B'
      .. CircleHelper.changeModelShorcut .. '#n格切换模式）')
  end)
end

-- eventobjid, toobjid, itemid, itemnum
local playerSelectShortcut = function (event)
  CircleHelper:check(function ()
    local objid = event.eventobjid
    local result, index = Player:getCurShotcut(objid)
    if (index == CircleHelper.sureShorcut - 1) then -- 确定中心点
      if (CircleHelper:isChooseFinish()) then
        CircleHelper:calculate(objid)
        CircleHelper:generate()
      end
    elseif (index == CircleHelper.resetShorcut - 1) then -- 重置设置
      CircleHelper:reset()
    elseif (index == CircleHelper.changeModelShorcut - 1) then -- 转换模式
      CircleHelper:changeModel()
    elseif (index == CircleHelper.enlargeRadiusShorcut - 1) then -- 放大半径
      CircleHelper:changeRadius(1)
    elseif (index == CircleHelper.reduceRadiusShorcut - 1) then -- 缩小半径
      CircleHelper:changeRadius(-1)
    end
  end)
end

ScriptSupportEvent:registerEvent([=[Game.Run]=], runGame) -- 游戏运行时
ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], playerClickBlock) -- 点击方块
ScriptSupportEvent:registerEvent([=[Player.SelectShortcut]=], playerSelectShortcut) -- 选择快捷栏
