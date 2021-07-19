--[[
  点点消
  create by 莫小仙 on 2021-06-16
]]
PointPointClearHelper = {
  areaSize = { x = 4, y = 0, z = 4 }, -- 方块区域大小
  blockid1 = 667, -- 白色硬砂块
  blockid2 = 682, -- 黑色硬砂块
  blockNum = 6, -- 每种方块数量
  playerData = {} -- 保存玩家点击方块信息 objid -> { blockid, x, y, z }
}

-- 创建方块的方法
function PointPointClearHelper.createBlock (areaid, blockid, num) 
  local total = 0 -- 定义一个计数器
  repeat
    local result, pos = Area:getRandomPos(areaid) -- 获取区域内的随机位置
    local result, bid = Block:getBlockID(pos.x, pos.y, pos.z) -- 获取方块类型
    if (bid == BLOCKID.AIR) then -- 是空气方块
      Block:placeBlock(blockid, pos.x, pos.y, pos.z) -- 放置方块
      total = total + 1 -- 计数器加1
    end
  until (total == num) -- 数量满足后结束
end

-- 玩家进入游戏事件
local function playerEnterGame (event)
  local ppch = PointPointClearHelper
  local result, x, y, z = Player:getPosition(event.eventobjid)
  local result, areaid = Area:createAreaRect({ x = x, y = y, z = z }, ppch.areaSize) -- 创建区域
  ppch.createBlock(areaid, ppch.blockid1, ppch.blockNum) -- 创建白色硬砂块
  ppch.createBlock(areaid, ppch.blockid2, ppch.blockNum) -- 创建黑色硬砂块
end

-- 玩家点击方块事件
local function playerClickBlock (event)
  local objid = event.eventobjid
  local playerData = PointPointClearHelper.playerData
  if (playerData[objid] == nil) then -- 表示该玩家之前未点击过方块或消除了方块
    playerData[objid] = event
  else -- 点击过则判断两次点击方块是否相同
    local info = playerData[objid]
    if (info.blockid == event.blockid) then -- 方块相同则判断是不是同一个方块
      if (info.x == event.x and info.y == event.y and info.z == event.z) then -- 同一个方块
        -- do nothing
      else -- 不同方块
        Block:destroyBlock(info.x, info.y, info.z) -- 销毁之前点击的方块
        Block:destroyBlock(event.x, event.y, event.z) -- 销毁当前点击的方块
        playerData[objid] = nil -- 删除方块数据
      end
    else -- 不相同则重置方块信息
      playerData[objid] = event -- 记录方块数据
    end
  end
end

ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=], playerEnterGame) -- 玩家进入游戏
ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], playerClickBlock) -- 玩家点击方块
