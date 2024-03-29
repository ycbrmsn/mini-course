--[[
  像素画工具v1.1.0
  create by 莫小仙
  可修改变量处可根据情况进行修改
]]--  
CreateColorBlockHelper = {
  -- 可修改变量
  blockid = 600, -- 默认毛料。毛料(600)，硬沙块(667)
  category = 1, -- 创建方向。1竖直（从下到上，从左往右）, 2水平（从近到远，从左往右）
  particleid = 1267, -- 创建位置提示特效
  buffer = 50, -- 一帧创建的方块数，可根据图片大小适当改小
  -- 快捷键序数 1~8
  sureShorcut = 1, -- 确认栏
  cancelShorcut = 2, -- 取消栏

  -- 不可修改变量
  dstPos = nil, -- 目标位置
  direct = nil,
  isCreating = false,
  createIndex = 1,
  dataIndex = 1,
  blockData = nil
}

-- 校验
function CreateColorBlockHelper:check (f)
  xpcall(f, function (err)
    Chat:sendSystemMsg(err)
  end)
end

-- 生成
function CreateColorBlockHelper:generate (objid)
  local result, direct = Actor:getCurPlaceDir(objid)
  self.direct = direct
  self.createIndex = 1
  self.dataIndex = 1
  self.isCreating = true
  self.blockData = colorBlockData[self.dataIndex]
  Chat:sendSystemMsg('开始生成，请耐心等待……')
  CreateColorBlockHelper:stopEffect(self.dstPos)
end

function CreateColorBlockHelper:playEffect (pos)
  if (pos) then
    World:playParticalEffect(pos.x, pos.y, pos.z, self.particleid, 1)
  end
end

function CreateColorBlockHelper:stopEffect (pos)
  if (pos) then
    World:stopEffectOnPosition(pos.x, pos.y, pos.z, self.particleid)
  end
end

function CreateColorBlockHelper:getCategoryName ()
  if (self.category == 1) then
    return '竖直'
  else
    return '水平'
  end
end

-- eventobjid, toobjid, itemid, itemnum
local playerSelectShortcut = function (event)
  CreateColorBlockHelper:check(function ()
    local objid = event.eventobjid
    local result, index = Player:getCurShotcut(objid)
    local result2, x, y, z = Actor:getPosition(objid)
    if (index == CreateColorBlockHelper.sureShorcut - 1) then
      if (CreateColorBlockHelper.dstPos) then
        if (CreateColorBlockHelper.isCreating) then
          Chat:sendSystemMsg('正在生成方块中')
        else
          CreateColorBlockHelper:generate(objid)
        end
      end
    elseif (index == CreateColorBlockHelper.cancelShorcut - 1) then
      if (CreateColorBlockHelper.dstPos) then
        CreateColorBlockHelper:stopEffect(CreateColorBlockHelper.dstPos)
        CreateColorBlockHelper.dstPos = nil
        Chat:sendSystemMsg('已取消')
      end
    end
  end)
end

-- eventobjid, blockid, x, y, z
local playerClickBlock = function (event)
  CreateColorBlockHelper:check(function ()
    if (CreateColorBlockHelper.isCreating) then
      Chat:sendSystemMsg('正在生成方块中')
    else
      local objid, blockid = event.objid, event.blockid
      local x, y, z = event.x, event.y, event.z
      local pos = { x = event.x, y = event.y + 1, z = event.z }
      CreateColorBlockHelper:stopEffect(CreateColorBlockHelper.dstPos)
      CreateColorBlockHelper.dstPos = pos
      CreateColorBlockHelper:playEffect(pos)
      local categoryName = CreateColorBlockHelper:getCategoryName()
      Chat:sendSystemMsg('你确定要从此处开始，' .. categoryName .. '生成方块吗？')
    end
  end)
end

local runGame = function ()
  CreateColorBlockHelper:check(function ()
    if (CreateColorBlockHelper.isCreating) then
      if (CreateColorBlockHelper.createIndex <= #CreateColorBlockHelper.blockData) then
        local endIndex
        if (CreateColorBlockHelper.createIndex + CreateColorBlockHelper.buffer - 1 <= #CreateColorBlockHelper.blockData) then -- 足够
          endIndex = CreateColorBlockHelper.buffer - 1
        else -- 不够
          endIndex = #CreateColorBlockHelper.blockData - CreateColorBlockHelper.createIndex
        end
        local x, y, z
        for i = 0, endIndex do
          local data = CreateColorBlockHelper.blockData[CreateColorBlockHelper.createIndex + i]
          local category = CreateColorBlockHelper.category
          local direct = CreateColorBlockHelper.direct
          if (direct == FACE_DIRECTION.DIR_NEG_X) then -- 东
            if (category == 1) then -- 竖直
              x = CreateColorBlockHelper.dstPos.x
              y = CreateColorBlockHelper.dstPos.y + data[4]
              z = CreateColorBlockHelper.dstPos.z - data[3]
            else -- 水平
              x = CreateColorBlockHelper.dstPos.x + data[4]
              y = CreateColorBlockHelper.dstPos.y
              z = CreateColorBlockHelper.dstPos.z - data[3]
            end
          elseif (direct == FACE_DIRECTION.DIR_POS_X) then -- 西
            if (category == 1) then
              x = CreateColorBlockHelper.dstPos.x
              y = CreateColorBlockHelper.dstPos.y + data[4]
              z = CreateColorBlockHelper.dstPos.z + data[3]
            else
              x = CreateColorBlockHelper.dstPos.x - data[4]
              y = CreateColorBlockHelper.dstPos.y
              z = CreateColorBlockHelper.dstPos.z + data[3]
            end
          elseif (direct == FACE_DIRECTION.DIR_POS_Z) then -- 南
            if (category == 1) then
              x = CreateColorBlockHelper.dstPos.x - data[3]
              y = CreateColorBlockHelper.dstPos.y + data[4]
              z = CreateColorBlockHelper.dstPos.z
            else
              x = CreateColorBlockHelper.dstPos.x - data[3]
              y = CreateColorBlockHelper.dstPos.y
              z = CreateColorBlockHelper.dstPos.z - data[4]
            end
          else -- 北
            if (category == 1) then
              x = CreateColorBlockHelper.dstPos.x + data[3]
              y = CreateColorBlockHelper.dstPos.y + data[4]
              z = CreateColorBlockHelper.dstPos.z
            else
              x = CreateColorBlockHelper.dstPos.x + data[3]
              y = CreateColorBlockHelper.dstPos.y
              z = CreateColorBlockHelper.dstPos.z + data[4]
            end
          end
          Block:setBlockAll(x, y, z, CreateColorBlockHelper.blockid + data[1], data[2])
        end
        CreateColorBlockHelper.createIndex = CreateColorBlockHelper.createIndex + endIndex + 1
      else -- 处理完一个blockData
        if (CreateColorBlockHelper.dataIndex < #colorBlockData) then -- 还有数据，则处理下一个
          CreateColorBlockHelper.createIndex = 1
          CreateColorBlockHelper.dataIndex = CreateColorBlockHelper.dataIndex + 1
          CreateColorBlockHelper.blockData = colorBlockData[CreateColorBlockHelper.dataIndex]
        else
          CreateColorBlockHelper.isCreating = false
          CreateColorBlockHelper.dstPos = nil
          Chat:sendSystemMsg('生成完成')
        end
      end
    end
  end)
end

ScriptSupportEvent:registerEvent([=[Player.SelectShortcut]=], playerSelectShortcut) -- 选择快捷栏
ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], playerClickBlock) -- 点击方块
ScriptSupportEvent:registerEvent([=[Game.Run]=], runGame) -- 游戏运行时