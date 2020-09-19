--[[ 
  功能：替换区域内方块为点击方块
  作者：莫小仙  2020-09-19
  使用：连续两次点击区域内同一位置的方块则开始替换
  说明：仅替换一个区域内的方块，区域可以是自己通过区域工具手动创建，也可以是通过触发器/脚本创建（不推荐）。
      若方块处于多个区域内，则替换区域为最后创建的区域（存在风险，不推荐如此操作）。
      撤销功能有需要再实现。
]]--
ReplaceBlockHelper = {
  -- 可修改变量
  buffer = 100, -- 一帧替换的方块数，可根据手机承受能力适当改大
  -- 不可修改变量
  blockInfo = { x = -1, y = -1, z = -1, blockid = -1, data = -1, areaid = -1 },
  replaceArr = {},
  isWorking = false, -- 是否开始工作
  replaceIndex = 1, -- 替换序数
  isReplacing = false -- 是否正在替换
}

-- 校验
function ReplaceBlockHelper:check (f)
  xpcall(f, function (err)
    Chat:sendSystemMsg(err)
  end)
end

function ReplaceBlockHelper:getBlockInfo ()
  return self.blockInfo
end

function ReplaceBlockHelper:setBlockInfo (x, y, z, blockid, data, areaid)
  self.blockInfo = { x = x, y = y, z = z, blockid = blockid, data = data, areaid = areaid }
end

-- 是否相等
function ReplaceBlockHelper:equals (info, x, y, z, blockid, data, areaid)
  if (not(info) or not(info.x) or not(info.y) or not(info.z) or not(info.blockid) or not(info.data)
    or not(info.areaid) or not(x) or not(y) or not(z) or not(blockid) or not(data) or not(areaid)) then
    return false
  else
    return info.x == x and info.y == y and info.z == z and info.blockid == blockid
      and info.data == data and info.areaid == areaid
  end
end

-- 替换
function ReplaceBlockHelper:replace ()
  self.isWorking = true
  local info = ReplaceBlockHelper:getBlockInfo()
  local result, posBeg, posEnd = Area:getAreaRectRange(info.areaid)
  if (result) then -- 获取起始位置成功
    local arr = {}
    for i = posBeg.x, posEnd.x do
      for j = posBeg.y, posEnd.y do
        for k = posBeg.z, posEnd.z do
          local result2, blockid = Block:getBlockID(i, j, k)
          if (result2 and blockid ~= BLOCKID.AIR) then -- 方块不是空气
            local result3, data = Block:getBlockData(i, j, k)
            if (result3 and (blockid ~= info.blockid or data ~= info.data)) then -- 方块不同
              table.insert(arr, { x = i, y = j, z = k, blockid = info.blockid, data = info.data })
            end
          end
        end
      end
    end
    self.replaceArr = arr
    self.replaceIndex = 1
    self.isReplacing = true
    Chat:sendSystemMsg('开始替换，请耐心等待……')
  end
end

-- eventobjid, blockid, x, y, z
local playerClickBlock = function (event)
  ReplaceBlockHelper:check(function ()
    local blockid = event.blockid
    local x, y, z = event.x, event.y, event.z
    local result, areaid = Area:getAreaByPos(event)
    if (result == ErrorCode.OK) then -- 存在区域
      local result2, data = Block:getBlockData(x, y, z)
      if (result2) then -- 查询data成功
        local info = ReplaceBlockHelper:getBlockInfo()
        if (ReplaceBlockHelper:equals(info, x, y, z, blockid, data, areaid) 
          and not(ReplaceBlockHelper.isWorking)) then -- 非第一次点击且没开始
          ReplaceBlockHelper:replace()
        else -- 第一次点击
          ReplaceBlockHelper:setBlockInfo(x, y, z, blockid, data, areaid)
          local result3, name = Item:getItemName(blockid)
          if (result3 ~= ErrorCode.OK) then
            name = '点击的方块'
          end
          Chat:sendSystemMsg('你确定要把区域内的方块都替换为' .. name .. '吗？')
        end
      end
    end
  end)
end

local runGame = function ()
  ReplaceBlockHelper:check(function ()
    if (ReplaceBlockHelper.isReplacing) then
      if (ReplaceBlockHelper.replaceIndex <= #ReplaceBlockHelper.replaceArr) then
        local endIndex
        if (ReplaceBlockHelper.replaceIndex + ReplaceBlockHelper.buffer - 1 <= #ReplaceBlockHelper.replaceArr) then -- 足够
          endIndex = ReplaceBlockHelper.buffer - 1
        else -- 不够
          endIndex = #ReplaceBlockHelper.replaceArr - ReplaceBlockHelper.replaceIndex
        end
        for i = 0, endIndex do
          local info = ReplaceBlockHelper.replaceArr[ReplaceBlockHelper.replaceIndex + i]
          Block:setBlockAll(info.x, info.y, info.z, info.blockid, info.data)
        end
        ReplaceBlockHelper.replaceIndex = ReplaceBlockHelper.replaceIndex + endIndex + 1
      else
        ReplaceBlockHelper.isReplacing = false
        ReplaceBlockHelper.isWorking = false
        Chat:sendSystemMsg('替换完成')
      end
    end
  end)
end

ScriptSupportEvent:registerEvent([=[Game.Run]=], runGame) -- 游戏运行时
ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], playerClickBlock) -- 点击方块
