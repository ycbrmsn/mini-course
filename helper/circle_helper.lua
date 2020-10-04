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
  Chat:sendSystemMsg('重置半径为' .. self.radius .. '，模式为' .. self.categoryName[self.category])
end

-- 变更模式
function CircleHelper:changeModel ()
  self.category = self.category + 1
  if (self.category > 5) then
    self.category = 1
  end
  Chat:sendSystemMsg('当前选择' .. self.categoryName[self.category] .. '模式')
end

-- 改变半径
function CircleHelper:changeRadius (change)
  self.radius = self.radius + change
  if (self.radius < 1) then
    self.radius = 1
    Chat:sendSystemMsg('半径' .. self.radius .. '已经是最小了')
  else
    Chat:sendSystemMsg('当前半径调整为' .. self.radius)
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
    CircleHelper:insertTopHalfBall()
  else -- 半球形

  end
  Chat:sendSystemMsg('计算完成')
  return true
end

-- 获取另一边长
function CircleHelper:getSideArr (radius)
  local arr = {}
  for i = 0, radius do
    local len = math.sqrt(math.pow(radius, 2) - math.pow(i, 2))
    table.insert(arr, len)
    print(len)
  end
  return arr
end

function CircleHelper:getAngle (radius)
  return 90 / (radius * 2 + 1)
end

function CircleHelper:insertCenterX (x, y, z, radius)
  local angle = CircleHelper:getAngle(radius)
  for i = 0, 360, angle do
    table.insert(self.createArr, { x = x, y = y - radius * CircleHelper:sin(i), z = z + radius * CircleHelper:cos(i) })
  end
end

-- x轴正方向起旋转

function CircleHelper:insertCenterY (x, y, z, radius)
  local angle = CircleHelper:getAngle(radius)
  for i = 0, 360, angle do
    table.insert(self.createArr, { x = x + radius * CircleHelper:cos(i), y = y, z = z - radius * CircleHelper:sin(i) })
    print(self.createArr[#self.createArr].x, self.createArr[#self.createArr].z)
  end
end

function CircleHelper:sin (angle)
  return math.sin(math.rad(angle))
end

function CircleHelper:cos (angle)
  return math.cos(math.rad(angle))
end

function CircleHelper:insertCenterZ (x, y, z, radius)
  local angle = CircleHelper:getAngle(radius)
  for i = 0, 360, angle do
    table.insert(self.createArr, { x = x + radius * CircleHelper:cos(i), y = y - radius * CircleHelper:sin(i), z = z })
  end
end

function CircleHelper:insertTopHalfBall ()
 for i = 0, self.radius do
  local radius = self.radius - i
  if (radius > 0) then
    print('半径：', radius)
    Chat:sendSystemMsg('半径：' .. radius)
    local x, y, z = self.blockInfo.x, self.blockInfo.y + i, self.blockInfo.z
    CircleHelper:insertCenterY(x, y, z, radius)
  end
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
    Chat:sendSystemMsg('选择成功，是否以' .. CircleHelper.categoryName[CircleHelper.category]
      .. '模式创建方块？')
    Chat:sendSystemMsg('（选择快捷栏第' .. CircleHelper.sureShorcut .. '格确定，第'
      .. CircleHelper.changeModelShorcut .. '格切换模式）')
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
