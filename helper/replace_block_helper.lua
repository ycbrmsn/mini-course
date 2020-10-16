--[[ 
  功能：替换区域内特定方块为选择方块
  版本：v1.1.0
  作者：莫小仙  2020-09-19
  使用：第一次点击方块时确定选择方块以及区域，其他次点击时确定需要替换的方块类型。不选择方块类型则替换区域内所有方块。
      选择确定后开始替换。支持撤销/重做操作。若发现残留特效，点击特效所在方块，再选择重置设置即可清除。
  说明：仅替换一个区域内的方块，区域可以是自己通过区域工具手动创建，也可以是通过触发器/脚本创建（不推荐）。
      若方块处于多个区域内，则替换区域为最后创建的区域（存在风险，不推荐如此操作）。
]]--
ReplaceBlockHelper = {
  -- 可修改变量
  buffer = 100, -- 一帧替换的方块数，可根据手机承受能力适当改大
  particleid = 1267, -- 特效
  -- 快捷键序数 1~8，可根据习惯进行修改
  readmeShorcut = 1, -- 说明
  sureShorcut = 2, -- 确定替换
  undoShorcut = 3, -- 撤销
  redoShorcut = 4, -- 重做
  resetShorcut = 8, -- 重置设置
  -- 不可修改变量
  srcBlockInfo = nil, -- 源方块信息
  dstBlockInfo = nil, -- 目标方块信息
  replaceArr = {}, -- 替换方块信息
  historyArr = {}, -- 历史记录
  historyIndex = 0, -- 历史记录序数
  historyBlockInfoArr = {}, -- 历史方块信息
  isWorking = false, -- 是否开始工作
  replaceIndex = 1, -- 替换序数
  isReplacing = false, -- 是否正在替换
  replaceCategory = 1, -- 替换类型：1替换，2撤销
  lastAction = 1, -- 上次撤销还原操作：1替换，2撤销，3重做
}

-- 校验
function ReplaceBlockHelper:check (f)
  xpcall(f, function (err)
    Chat:sendSystemMsg(err)
  end)
end

function ReplaceBlockHelper:getSrcBlockInfo ()
  return self.srcBlockInfo
end

function ReplaceBlockHelper:getDstBlockInfo ()
  return self.dstBlockInfo
end

function ReplaceBlockHelper:setSrcBlockInfo (x, y, z, blockid, data, areaid)
  self.srcBlockInfo = { x = x, y = y, z = z, blockid = blockid, data = data, areaid = areaid }
  ReplaceBlockHelper:playEffect(self.srcBlockInfo)
end

function ReplaceBlockHelper:setDstBlockInfo (x, y, z, blockid, data)
  self.dstBlockInfo = { x = x, y = y, z = z, blockid = blockid, data = data }
  ReplaceBlockHelper:playEffect(self.dstBlockInfo)
end

function ReplaceBlockHelper:clearSrcBlockInfo ()
  self.srcBlockInfo = nil
end

function ReplaceBlockHelper:clearDstBlockInfo ()
  self.dstBlockInfo = nil
end

-- 记录历史
function ReplaceBlockHelper:recordHistory (arr)
  if (self.historyIndex < #self.historyArr) then -- 不是最后一条记录
    repeat
      table.remove(self.historyArr)
    until(self.historyIndex == #self.historyArr)
  end
  if (self.lastAction == 1 or self.lastAction == 3) then -- 上一步是替换或重做时则增加一步
    self.historyIndex = self.historyIndex + 1
  end
  self.historyArr[self.historyIndex] = arr
  self.historyBlockInfoArr[self.historyIndex] = {
    src = ReplaceBlockHelper:copyBlockInfo(self.srcBlockInfo), 
    dst = ReplaceBlockHelper:copyBlockInfo(self.dstBlockInfo)
  }
end

function ReplaceBlockHelper:copyBlockInfo (info)
  if (info) then
    return { x = info.x, y = info.y, z = info.z, blockid = info.blockid, data = info.data, areaid = info.areaid }
  else
    return info
  end
end

-- 恢复方块数据及特效
function ReplaceBlockHelper:recoverBlockInfo ()
  if (self.lastAction == 2 or self.lastAction == 3) then -- 撤销/重做
    ReplaceBlockHelper:stopEffect(self.srcBlockInfo)
    ReplaceBlockHelper:stopEffect(self.dstBlockInfo)
    self.srcBlockInfo = ReplaceBlockHelper:copyBlockInfo(self.historyBlockInfoArr[self.historyIndex].src)
    self.dstBlockInfo = ReplaceBlockHelper:copyBlockInfo(self.historyBlockInfoArr[self.historyIndex].dst)
    ReplaceBlockHelper:playEffect(self.srcBlockInfo)
    ReplaceBlockHelper:playEffect(self.dstBlockInfo)
  end
  if (self.lastAction == 1 or self.lastAction == 3) then -- 替换/重做
    if (self.dstBlockInfo) then
      self.dstBlockInfo.blockid = self.historyBlockInfoArr[self.historyIndex].src.blockid
      self.dstBlockInfo.data = self.historyBlockInfoArr[self.historyIndex].src.data
    end
  end
end

-- 说明
function ReplaceBlockHelper:readme ()
  Chat:sendSystemMsg('------')
  Chat:sendSystemMsg('快捷栏' .. self.readmeShorcut .. '：帮助')
  Chat:sendSystemMsg('快捷栏' .. self.sureShorcut .. '：确定替换')
  Chat:sendSystemMsg('快捷栏' .. self.undoShorcut .. '：撤销')
  Chat:sendSystemMsg('快捷栏' .. self.redoShorcut .. '：重做')
  Chat:sendSystemMsg('快捷栏' .. self.resetShorcut .. '：重置设置')
  Chat:sendSystemMsg('------')
end

-- 替换
function ReplaceBlockHelper:replace ()
  self.isWorking = true
  local info = ReplaceBlockHelper:getSrcBlockInfo()
  local dstInfo = ReplaceBlockHelper:getDstBlockInfo()
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
              if (not(dstInfo) or (blockid == dstInfo.blockid and data == dstInfo.data)) then
                table.insert(arr, { x = i, y = j, z = k, blockid = info.blockid, data = info.data,
                prevBlockid = blockid, prevData = data })
              end
            end
          end
        end
      end
    end
    self.replaceArr = arr
    ReplaceBlockHelper:recordHistory(arr)
    self.replaceCategory = 1
    self.lastAction = 1
    self.replaceIndex = 1
    self.isReplacing = true
    Chat:sendSystemMsg('开始替换，请耐心等待……')
  end
end

-- 重置设置
function ReplaceBlockHelper:reset ()
  ReplaceBlockHelper:stopEffect(self.srcBlockInfo)
  ReplaceBlockHelper:stopEffect(self.dstBlockInfo)
  ReplaceBlockHelper:clearSrcBlockInfo()
  ReplaceBlockHelper:clearDstBlockInfo()
  self.replaceCategory = 1
  Chat:sendSystemMsg('所有选项已重置')
end

-- 撤销
function ReplaceBlockHelper:undo ()
  if (self.historyIndex > 0) then
    if (self.lastAction == 1 or self.lastAction == 3) then -- 上次是替换或重做
      ReplaceBlockHelper:startUnReDo(2)
    else -- 上次是撤销
      if (self.historyIndex == 1) then -- 只有一步操作
        Chat:sendSystemMsg('没有上一步了')
      else -- 有多步操作
        self.historyIndex = self.historyIndex - 1
        ReplaceBlockHelper:startUnReDo(2)
      end
    end
  else
    Chat:sendSystemMsg('没有上一步了')
  end
end

-- 重做
function ReplaceBlockHelper:redo ()
  if (self.historyIndex < #self.historyArr) then -- 不是最后一步
    if (self.lastAction == 2) then -- 上次是撤销
      ReplaceBlockHelper:startUnReDo(3)
    else -- 上次是重做
      if (self.historyIndex == #self.historyArr) then -- 最后一步操作
        Chat:sendSystemMsg('没有下一步了')
      else -- 不是最后一步操作
        self.historyIndex = self.historyIndex + 1
        ReplaceBlockHelper:startUnReDo(3)
      end
    end
  else -- 最后一步（包括没有的情况）
    if (self.lastAction == 2) then
      ReplaceBlockHelper:startUnReDo(3)
    else
      Chat:sendSystemMsg('没有下一步了')
    end
  end
end

function ReplaceBlockHelper:startUnReDo (category)
  self.isWorking = true
  self.replaceArr = self.historyArr[self.historyIndex]
  self.replaceCategory = category
  self.lastAction = category
  self.replaceIndex = 1
  self.isReplacing = true
  ReplaceBlockHelper:recoverBlockInfo()
  local actionName = '？？？'
  if (category == 1) then
    actionName = '替换'
  elseif (category == 2) then
    actionName = '撤销'
  elseif (category == 3) then
    actionName = '重做'
  end
  Chat:sendSystemMsg('开始' .. actionName .. '，请耐心等待……')
end

function ReplaceBlockHelper:playEffect (info)
  if (info) then
    World:playParticalEffect(info.x, info.y, info.z, self.particleid, 1)
  end
end

function ReplaceBlockHelper:stopEffect (info)
  if (info) then
    World:stopEffectOnPosition(info.x, info.y, info.z, self.particleid)
  end
end

function ReplaceBlockHelper:isSameTypeBlock (info, blockid, data)
  return info.blockid == blockid and info.data == data
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
        local info = ReplaceBlockHelper:getSrcBlockInfo()
        if (not(info)) then -- 未选定源方块
          ReplaceBlockHelper:setSrcBlockInfo(x, y, z, blockid, data, areaid)
          Chat:sendSystemMsg('选定源方块')
        else -- 其他次选择
          if (ReplaceBlockHelper:isSameTypeBlock(info, blockid, data)) then -- 选择相同类型方块
            Chat:sendSystemMsg('相同类型方块无需替换')
          else -- 不同方块
            local dstInfo = ReplaceBlockHelper:getDstBlockInfo()
            if (dstInfo) then -- 已选择过
              ReplaceBlockHelper:stopEffect(dstInfo)
              if (dstInfo.x == x and dstInfo.y == y and dstInfo.z == z) then -- 同一位置则取消
                ReplaceBlockHelper:clearDstBlockInfo()
                Chat:sendSystemMsg('取消目标方块')
              else
                ReplaceBlockHelper:setDstBlockInfo(x, y, z, blockid, data)
                Chat:sendSystemMsg('选定目标方块')
              end
            else -- 未选择过
              ReplaceBlockHelper:setDstBlockInfo(x, y, z, blockid, data)
              Chat:sendSystemMsg('选定目标方块')
            end
          end
        end
      end
    end
  end)
end

-- eventobjid, toobjid, itemid, itemnum
local playerSelectShortcut = function (event)
  ReplaceBlockHelper:check(function ()
    local objid = event.eventobjid
    local result, index = Player:getCurShotcut(objid)
    if (index == ReplaceBlockHelper.readmeShorcut - 1) then -- 说明
      ReplaceBlockHelper:readme()
    elseif (index == ReplaceBlockHelper.sureShorcut - 1) then -- 确定开始替换
      if (not(ReplaceBlockHelper.srcBlockInfo)) then
        Chat:sendSystemMsg('未选定源方块')
        return
      end
      local info = ReplaceBlockHelper.dstBlockInfo
      if (info and ReplaceBlockHelper:isSameTypeBlock(ReplaceBlockHelper.srcBlockInfo,
        info.blockid, info.data)) then
        Chat:sendSystemMsg('相同类型方块无需替换')
        return
      end
      if (not(ReplaceBlockHelper.isWorking)) then
        ReplaceBlockHelper:replace()
      else
        Chat:sendSystemMsg('正在替换中，无法确定')
      end
    elseif (index == ReplaceBlockHelper.undoShorcut - 1) then -- 撤销
      if (not(ReplaceBlockHelper.isWorking)) then
        ReplaceBlockHelper:undo()
      else
        Chat:sendSystemMsg('正在替换中，无法撤销')
      end
    elseif (index == ReplaceBlockHelper.redoShorcut - 1) then -- 重做
      if (not(ReplaceBlockHelper.isWorking)) then
        ReplaceBlockHelper:redo()
      else
        Chat:sendSystemMsg('正在替换中，无法重做')
      end
    elseif (index == ReplaceBlockHelper.resetShorcut - 1) then -- 重置设置
      ReplaceBlockHelper:reset()
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
          if (ReplaceBlockHelper.replaceCategory == 1 or ReplaceBlockHelper.replaceCategory == 3) then -- 替换/重做
            Block:setBlockAll(info.x, info.y, info.z, info.blockid, info.data)
          elseif (ReplaceBlockHelper.replaceCategory == 2) then -- 还原
            Block:setBlockAll(info.x, info.y, info.z, info.prevBlockid, info.prevData)
          end
        end
        ReplaceBlockHelper.replaceIndex = ReplaceBlockHelper.replaceIndex + endIndex + 1
      else
        ReplaceBlockHelper.isReplacing = false
        ReplaceBlockHelper.isWorking = false
        -- ReplaceBlockHelper:stopEffect(ReplaceBlockHelper.srcBlockInfo)
        -- ReplaceBlockHelper:stopEffect(ReplaceBlockHelper.dstBlockInfo)
        if (ReplaceBlockHelper.replaceCategory == 1) then
          ReplaceBlockHelper:recoverBlockInfo()
          Chat:sendSystemMsg('替换完成')
        elseif (ReplaceBlockHelper.replaceCategory == 2) then
          Chat:sendSystemMsg('撤销完成')
        elseif (ReplaceBlockHelper.replaceCategory == 3) then
          Chat:sendSystemMsg('重做完成')
        end
      end
    end
  end)
end

ScriptSupportEvent:registerEvent([=[Game.Run]=], runGame) -- 游戏运行时
ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], playerClickBlock) -- 点击方块
ScriptSupportEvent:registerEvent([=[Player.SelectShortcut]=], playerSelectShortcut) -- 选择快捷栏
