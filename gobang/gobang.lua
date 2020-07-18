-- 五子棋v1.0  createBy 莫小仙
-- 手持特定物品（默认是能量剑），点击地面，会在地面上生成棋盘。请找一个空旷的地方，因为棋盘也许会破坏地形。
gobang = {
  particleIds = { 1267, 1190 }, -- 落子位置、胜利连子
  size = 15,
  --          手持物、棋盘、黑子、白子、关闭、确定、重置、 单黑、单白、双黑、双白、悔棋
  itemids = { 12005, 966, 260, 261, 416, 406, 405, 682, 667, 615, 600, 504 },
  scoreMap = {
    [0] = 0, [-10] = 0, [10] = 0, [-20] = 0, [20] = 0, [-30] = 0, [30] = 0,
    [2] = 5, [-12] = 35, [12] = 40, [-22] = 195, [22] = 200, [-32] = 995, [32] = 1000, 
    [1] = 1, [-11] = 19, [11] = 20, [-21] = 35, [21] = 40, [-31] = 195, [31] = 200
  },
  gameInfos = {} -- { objid -> {} }
}

function gobang:init (pos, objid)
  Block:placeBlock(gobang.itemids[5], pos.x, pos.y, pos.z) -- 关闭项
  local result, dirx, diry, dirz = Actor:getFaceDirection(objid)
  local xt, zt = 1, 1
  if (dirx < 0) then
    xt = -1
  end
  if (dirz < 0) then
    zt = -1
  end
  local surePos = { x = pos.x + (xt * 3), y = pos.y, z = pos.z }
  Block:placeBlock(gobang.itemids[6], surePos.x, surePos.y, surePos.z) -- 确定项
  local resetPos = { x = pos.x + (xt * 2), y = pos.y, z = pos.z }
  Block:placeBlock(gobang.itemids[7], resetPos.x, resetPos.y, resetPos.z) -- 重置项

  local singleBlackPos = { x = pos.x + (xt * 5), y = pos.y, z = pos.z }
  Block:placeBlock(gobang.itemids[8], singleBlackPos.x, singleBlackPos.y, singleBlackPos.z) -- 单黑项
  local singleWhitePos = { x = pos.x + (xt * 6), y = pos.y, z = pos.z }
  Block:placeBlock(gobang.itemids[9], singleWhitePos.x, singleWhitePos.y, singleWhitePos.z) -- 单白项

  local doubleBlackPos = { x = pos.x + (xt * 9), y = pos.y, z = pos.z }
  Block:placeBlock(gobang.itemids[10], doubleBlackPos.x, doubleBlackPos.y, doubleBlackPos.z) -- 双人黑项
  local doubleWhitePos = { x = pos.x + (xt * 10), y = pos.y, z = pos.z }
  Block:placeBlock(gobang.itemids[11], doubleWhitePos.x, doubleWhitePos.y, doubleWhitePos.z) -- 双人白项
  local undoPos = { x = pos.x + (xt * 12), y = pos.y, z = pos.z }
  Block:placeBlock(gobang.itemids[12], undoPos.x, undoPos.y, undoPos.z) -- 悔棋项

  -- 棋盘
  local positions = {} -- { x,z -> { pos, color } }
  for i = 1, gobang.size do
    for j = 1, gobang.size do
      local p = { x = pos.x + (xt * i), y = pos.y, z = pos.z + (zt * j) }
      positions[gobang:getPosInfoKey(p)] = { p, 0 }
      Block:placeBlock(gobang.itemids[2], p.x, p.y, p.z, FACE_DIRECTION.DIR_POS_Y)
    end
  end
  gobang.gameInfos[objid] = { objid = objid, positions = positions, closePos = pos, surePos = surePos, 
    resetPos = resetPos, singleBlackPos = singleBlackPos, singleWhitePos = singleWhitePos,
    doubleBlackPos = doubleBlackPos, doubleWhitePos = doubleWhitePos, undoPos = undoPos, 
    lastPosition = {} }
end

-- 重置棋盘数据
function gobang:resetData (info)
  for k, v in pairs(info.positions) do
    if (v[2] ~= 0) then
      v[2] = 0
    end
  end
  info.lastPosition = {}
  info.isUndo = false
end

function gobang:clear (objid)
  local info = gobang.gameInfos[objid]
  Block:destroyBlock(info.closePos.x, info.closePos.y, info.closePos.z) -- 删除关闭项
  Block:destroyBlock(info.surePos.x, info.surePos.y, info.surePos.z) -- 删除确定项
  Block:destroyBlock(info.resetPos.x, info.resetPos.y, info.resetPos.z) -- 删除重置项
  Block:destroyBlock(info.singleBlackPos.x, info.singleBlackPos.y, info.singleBlackPos.z) -- 删除单黑项
  Block:destroyBlock(info.singleWhitePos.x, info.singleWhitePos.y, info.singleWhitePos.z) -- 删除单白项
  Block:destroyBlock(info.doubleBlackPos.x, info.doubleBlackPos.y, info.doubleBlackPos.z) -- 删除双黑项
  Block:destroyBlock(info.doubleWhitePos.x, info.doubleWhitePos.y, info.doubleWhitePos.z) -- 删除双白项
  Block:destroyBlock(info.undoPos.x, info.undoPos.y, info.undoPos.z) -- 删除悔棋项
  gobang:clearPieces(info)
  -- 删除棋盘
  for k, v in pairs(info.positions) do
    Block:destroyBlock(v[1].x, v[1].y, v[1].z)
  end
  if (info.isGameStart) then
    gobang:finishGame(info)
  end
end

-- 删除棋子及特效
function gobang:clearPieces (info)
  if (#info.lastPosition > 0) then -- 之前下过棋，则清空
    local pInfo = info.lastPosition[#info.lastPosition]
    World:stopEffectOnPosition(pInfo[1].x, pInfo[1].y + 1, pInfo[1].z, gobang.particleIds[1])
    for i, v in ipairs(info.winPositions) do
      World:stopEffectOnPosition(v.x, v.y + 2, v.z, gobang.particleIds[2])
    end
    for k, v in pairs(info.positions) do
      if (v[2] ~= 0) then
        Block:destroyBlock(v[1].x, v[1].y + 1, v[1].z)
      end
    end
  end
end

function gobang:startGame (info)
  info.isGameStart = true
  gobang:clearPieces(info)
  gobang:resetData(info)
  for i, v in ipairs(info.players) do
    gobang:showMessage('游戏开始', v)
  end
  gobang:nextTurn(info, true)
end

function gobang:nextTurn (info, isFirstTurn)
  if (isFirstTurn) then
    info.turn = 0
  else
    info.turn = info.turn + 1
  end
  info.thisTurn = info.turn % 2 + 1
  info.playerid = info.players[info.thisTurn]
  if (info.playerid == -1) then -- 该电脑落子
    gobang:computerPlay(info)
  else -- 该玩家落子
    for i, v in ipairs(info.players) do
      if (v == -1) then -- 电脑
      elseif (v == info.playerid) then
        Chat:sendSystemMsg('到你的回合了', v)
      else
        Chat:sendSystemMsg('正在等待对手落子', v)
      end
    end
  end
end

-- 结束游戏
function gobang:finishGame (info, playerid)
  info.isGameStart = false
  if (not(playerid)) then
    for i, v in ipairs(info.players) do
      gobang:showMessage('游戏中止', v)
    end
  elseif (playerid == -66) then -- 平局
    for i, v in ipairs(info.players) do
      if (v == playerid) then
        gobang:showMessage('平局结束', v)
      else
        gobang:showMessage('平局结束', v)
      end
    end
  else -- 一方胜利
    for i, v in ipairs(info.winPositions) do
      World:playParticalEffect(v.x, v.y + 2, v.z, gobang.particleIds[2], 1)
    end
    for i, v in ipairs(info.players) do
      if (v == playerid) then
        gobang:showMessage('你赢了', v)
      else
        gobang:showMessage('你输了', v)
      end
    end
  end
end

-- 显示消息
function gobang:showMessage (msg, objid)
  if (objid > -1) then
    Chat:sendSystemMsg(msg, objid)
  end
end

function gobang:equals (pos1, pos2)
  if (pos1.x == pos2.x and pos1.y == pos2.y and pos1.z == pos2.z) then
    return true
  else
    return false
  end
end

function gobang:getPosInfoKey (pos)
  return pos.x .. ',' .. pos.z
end

-- 校验
function gobang:check (f)
  xpcall(f, function (err)
    Chat:sendSystemMsg(err)
  end)
end

function gobang:computerPlay (info)
  local posInfo = gobang:getGreatPosition(info)
  gobang:placePiece(info, posInfo)
  if (not(gobang:isWin(info, posInfo[1])) and not(gobang:isTie(info))) then
    gobang:nextTurn(info)
  end
end

-- 获得一个最好的位置
function gobang:getGreatPosition (info)
  local maxScore = -1
  local greatScorePositions
  for k, v in pairs(info.positions) do
    if (v[2] == 0) then -- 无子
      local score = gobang:calcScore(info, v[1])
      if (score > maxScore) then
        greatScorePositions = { v }
        maxScore = score
      elseif (score == maxScore) then
        table.insert(greatScorePositions, v)
      end
    end
  end
  return greatScorePositions[math.random(1, #greatScorePositions)]
end

-- 获得此位置的博弈分
function gobang:calcScore (info, pos)
  local color = info.thisTurn
  -- 东西方
  local num11 = gobang:getNum(info, pos, color, { x = -1, z = 0 }, true)
  local num12 = gobang:getNum(info, pos, color, { x = 1, z = 0 }, true)
  local num1 = gobang:calcScoreOneLine(num11, num12)
  -- 南北方
  local num21 = gobang:getNum(info, pos, color, { x = 0, z = -1 }, true)
  local num22 = gobang:getNum(info, pos, color, { x = 0, z = 1 }, true)
  local num2 = gobang:calcScoreOneLine(num21, num22)
  -- 东南西北
  local num31 = gobang:getNum(info, pos, color, { x = 1, z = -1 }, true)
  local num32 = gobang:getNum(info, pos, color, { x = -1, z = 1 }, true)
  local num3 = gobang:calcScoreOneLine(num31, num32)
  -- 东北西南
  local num41 = gobang:getNum(info, pos, color, { x = 1, z = 1 }, true)
  local num42 = gobang:getNum(info, pos, color, { x = -1, z = -1 }, true)
  local num4 = gobang:calcScoreOneLine(num41, num42)
  return num1 + num2 + num3 + num4
end

-- 为正，表示己方连续整数位个；为负，表示对方连续整数位个；有小数表示有空位
function gobang:getNum (info, pos, lastColor, vec2, isFirst)
  local p = { x = pos.x + vec2.x, y = pos.y, z = pos.z + vec2.z }
  local posInfo = info.positions[gobang:getPosInfoKey(p)]
  if (not(posInfo)) then -- 已是边界
    return 0
  elseif (posInfo[2] == 0) then -- 空
    return 1
  elseif (posInfo[2] == lastColor) then -- 颜色相同
    return gobang:getNum(info, p, posInfo[2], vec2) + 10
  else -- 颜色不同
    if (isFirst) then
      return (gobang:getNum(info, p, posInfo[2], vec2) + 10) * -1
    else
      return 0
    end
  end
end

-- 获取一行的分数
function gobang:calcScoreOneLine (num1, num2)
  local num
  if (num1 == 0 and num2 == 0) then -- 两边都是边界（不存在情况）
    num = 0
  elseif (num1 == 0) then -- 一边是边界
    local na2 = math.abs(num2)
    if (na2 == math.floor(na2)) then -- 被堵住了
      if (na2 < 40) then -- 小于4时无法连成5子，简单定为0分
        num = 0
      else
        num = num2
      end
    else -- 没有堵住，简单定为长度
      num = num2
    end
  elseif (num2 == 0) then -- 一边是边界
    local na1 = math.abs(num1)
    if (na1 == math.floor(na1)) then -- 被堵住了
      if (na1 < 40) then -- 小于4时无法连成5子，简单定为0分
        num = 0
      else
        num = num1
      end
    else -- 没有堵住，简单定为长度
      num = num1
    end
  elseif (num1 * num2 > 0) then -- 双通
    num = num1 + num2
  elseif (num1 == 1) then -- 双通
    if (num2 > 0) then
      num = num1 + num2
    else
      num = -num1 + num2
    end
  elseif (num2 == 1) then -- 双通
    if (num1 > 0) then
      num = num1 + num2
    else
      num = num1 - num2
    end
  else -- 异号
    local na1, na2 = math.abs(num1), math.abs(num2)
    if (na1 == math.floor(na1)) then -- 被堵住了
      if (na1 < 40) then -- 小于4时无法连成5子，简单定为0分
        num = 0
      else
        num = 100
      end
    else -- 没有堵住，简单定为长度
      num = na1
    end
    local temp
    if (na2 == math.floor(na2)) then -- 被堵住了
      if (na2 < 40) then -- 小于4时无法连成5子，简单定为0分
        temp = 0
      else
        temp = 100
      end
    else -- 没有堵住，简单定为长度
      temp = na2
    end
    if (num < temp) then
      num = num2
    elseif (num > temp) then
      num = num1
    else
      if (num1 > num2) then
        num = num1
      else
        num = num2
      end
    end
  end
  if (not(num)) then
    print(num1, num2)
  end
  return gobang:getScore(num)
end

function gobang:getScore (num)
  local score = 0
  if (num <= -40) then
    score = 4995
  elseif (num >= 40) then
    score = 5000
  else
    score = gobang.scoreMap[num]
  end
  if (not(score)) then
    print('nil:', num, type(num), num == -12, math.abs(num) == 12)
    print(gobang.scoreMap[12], gobang.scoreMap[-12], gobang.scoreMap[math.abs(num)])
    print(gobang.scoreMap[num])
  end
  return score
end

function gobang:placePiece (info, posInfo)
  posInfo[2] = info.thisTurn
  Block:placeBlock(gobang.itemids[posInfo[2] + 2], posInfo[1].x, posInfo[1].y + 1, 
    posInfo[1].z, FACE_DIRECTION.DIR_POS_Y)
  World:playParticalEffect(posInfo[1].x, posInfo[1].y + 1, posInfo[1].z, gobang.particleIds[1], 1)
  if (#info.lastPosition > 0) then
    local pInfo = info.lastPosition[#info.lastPosition]
    World:stopEffectOnPosition(pInfo[1].x, pInfo[1].y + 1, pInfo[1].z, gobang.particleIds[1])
  end
  table.insert(info.lastPosition, posInfo)
  if (#info.lastPosition > 3) then -- 最多保留三位，即仅能悔棋一步
    table.remove(info.lastPosition, 0)
  end
end

function gobang:isWin (info, pos)
  -- 东西方
  info.winPositions = { pos }
  local num1 = gobang:countHalfLine(info, pos, { x = -1, z = 0 })
  local num2 = gobang:countHalfLine(info, pos, { x = 1, z = 0 })
  local num = num1 + num2
  if (num >= 4) then
    gobang:finishGame(info, info.playerid)
    return true
  end
  -- 南北方
  info.winPositions = { pos }
  num1 = gobang:countHalfLine(info, pos, { x = 0, z = -1 })
  num2 = gobang:countHalfLine(info, pos, { x = 0, z = 1 })
  num = num1 + num2
  if (num >= 4) then
    gobang:finishGame(info, info.playerid)
    return true
  end
  -- 东南西北
  info.winPositions = { pos }
  num1 = gobang:countHalfLine(info, pos, { x = 1, z = -1 })
  num2 = gobang:countHalfLine(info, pos, { x = -1, z = 1 })
  num = num1 + num2
  if (num >= 4) then
    gobang:finishGame(info, info.playerid)
    return true
  end
  -- 东北西南
  info.winPositions = { pos }
  num1 = gobang:countHalfLine(info, pos, { x = 1, z = 1 })
  num2 = gobang:countHalfLine(info, pos, { x = -1, z = -1 })
  num = num1 + num2
  if (num >= 4) then
    gobang:finishGame(info, info.playerid)
    return true
  end
  return false
end

function gobang:countHalfLine (info, pos, vec2)
  local p = { x = pos.x + vec2.x, y = pos.y, z = pos.z + vec2.z }
  local posInfo = info.positions[gobang:getPosInfoKey(p)]
  if (not(posInfo)) then -- 已是边界
    return 0
  elseif (posInfo[2] == 0) then -- 空
    return 0
  elseif (posInfo[2] == info.thisTurn) then -- 颜色相同
    table.insert(info.winPositions, p)
    return gobang:countHalfLine(info, p, vec2) + 1
  else -- 颜色不同
    return 0
  end
end

-- 是否平局
function gobang:isTie (info)
  local hasEmptyPosition = false
  for k, v in pairs(info.positions) do
    if (v[2] == 0) then
      hasEmptyPosition = true
      break
    end
  end
  if (not(hasEmptyPosition)) then -- 没有空位了
    gobang:finishGame(info, -66)
    return true
  else
    return false
  end
end

-- 点击相关位置
function gobang:click (info, objid, pos)
  if (gobang:equals(pos, info.closePos)) then -- 关闭
    if (objid == info.objid) then
      gobang:clear(objid)
      gobang.gameInfos[objid] = nil
      Chat:sendSystemMsg('你收回了棋盘', objid)
    else
      Chat:sendSystemMsg('这不是你放置的棋盘，无法收回', objid)
    end
  elseif (gobang:equals(pos, info.surePos)) then -- 确定
    if (info.isGameStart) then
      Chat:sendSystemMsg('游戏尚未结束，无法确定', objid)
      return
    end
    if (info.isSingle) then -- 单人模式
      if (info.singleBlack) then -- 黑子
        info.players = { objid, -1 }
      else
        info.players = { -1, objid }
      end
      gobang:startGame(info)
    elseif (info.isDouble) then -- 双人模式
      if (not(info.doubleBlack)) then
        Chat:sendSystemMsg('双人黑子（先手）无人选择', objid)
      elseif (not(info.doubleWhite)) then
        Chat:sendSystemMsg('双人白子（后手）无人选择', objid)
      else
        info.players = { info.doubleBlack, info.doubleWhite }
        gobang:startGame(info)
      end
    else -- 未选择
      Chat:sendSystemMsg('请先选择黑白子后再进行确定', objid)
    end
  elseif (gobang:equals(pos, info.resetPos)) then -- 重置
    if (info.isGameStart) then
      Chat:sendSystemMsg('游戏尚未结束，重置无效', objid)
      return
    end
    info.isSingle = false
    info.isDouble = false
    info.doubleBlack = nil
    info.doubleWhite = nil
    Chat:sendSystemMsg('重置', objid)
  elseif (gobang:equals(pos, info.singleBlackPos)) then -- 单黑
    if (info.isGameStart) then
      Chat:sendSystemMsg('游戏尚未结束，选择无效', objid)
      return
    end
    info.isSingle = true
    info.isDouble = false
    info.singleBlack = true
    Chat:sendSystemMsg('你选择了单人黑子（先手）', objid)
  elseif (gobang:equals(pos, info.singleWhitePos)) then -- 单白
    if (info.isGameStart) then
      Chat:sendSystemMsg('游戏尚未结束，选择无效', objid)
      return
    end
    info.isSingle = true
    info.isDouble = false
    info.singleBlack = false
    Chat:sendSystemMsg('你选择了单人白子（后手）', objid)
  elseif (gobang:equals(pos, info.doubleBlackPos)) then -- 双黑
    if (info.isGameStart) then
      Chat:sendSystemMsg('游戏尚未结束，选择无效', objid)
      return
    end
    info.isSingle = false
    info.isDouble = true
    info.doubleBlack = objid
    if (info.doubleWhite == objid) then
      info.doubleWhite = nil
    end
    Chat:sendSystemMsg('你选择了双人黑子（先手）', objid)
  elseif (gobang:equals(pos, info.doubleWhitePos)) then -- 双白
    if (info.isGameStart) then
      Chat:sendSystemMsg('游戏尚未结束，选择无效', objid)
      return
    end
    info.isSingle = false
    info.isDouble = true
    info.doubleWhite = objid
    if (info.doubleBlack == objid) then
      info.doubleBlack = nil
    end
    Chat:sendSystemMsg('你选择了双人白子（后手）', objid)
  elseif (gobang:equals(pos, info.undoPos)) then -- 悔棋
    if (not(info.isGameStart)) then
      Chat:sendSystemMsg('游戏尚未开始，无法悔棋', objid)
      return
    elseif (objid ~= info.playerid) then
      Chat:sendSystemMsg('当前不是你的回合，无法悔棋', objid)
      return
    end
    if (info.isSingle) then -- 单人模式
      if (#info.lastPosition < 3) then
        if (info.isUndo) then
          Chat:sendSystemMsg('无法连续悔棋', objid)
        else
          Chat:sendSystemMsg('当前无法悔棋', objid)
        end
      else
        info.isUndo = true
        local pInfo = info.lastPosition[#info.lastPosition]
        pInfo[2] = 0
        World:stopEffectOnPosition(pInfo[1].x, pInfo[1].y + 1, pInfo[1].z, gobang.particleIds[1])
        Block:destroyBlock(pInfo[1].x, pInfo[1].y + 1, pInfo[1].z) -- 删除一个棋子
        table.remove(info.lastPosition)
        pInfo = info.lastPosition[#info.lastPosition]
        pInfo[2] = 0
        Block:destroyBlock(pInfo[1].x, pInfo[1].y + 1, pInfo[1].z) -- 删除一个棋子
        table.remove(info.lastPosition)
        pInfo = info.lastPosition[#info.lastPosition]
        World:playParticalEffect(pInfo[1].x, pInfo[1].y + 1, pInfo[1].z, gobang.particleIds[1], 1)
      end
    else -- 双人模式
      Chat:sendSystemMsg('双人模式下无法悔棋', objid)
    end
  else
    local posInfo = info.positions[gobang:getPosInfoKey(pos)]
    if (posInfo) then -- 棋盘
      if (not(info.isGameStart)) then -- 游戏未开始
        Chat:sendSystemMsg('游戏尚未开始', objid)
      elseif (info.playerid == objid) then -- 玩家的回合
        if (posInfo[2] == 0) then -- 可下
          gobang:placePiece(info, posInfo)
          if (not(gobang:isWin(info, posInfo[1])) and not(gobang:isTie(info))) then
            gobang:nextTurn(info)
          end
        else -- 不可下
          Chat:sendSystemMsg('此处已有棋子', objid)
        end
      else
        Chat:sendSystemMsg('当前不是你的回合', objid)
      end
    else
      return false
    end
  end
  return true
end

-- eventobjid, blockid, x, y, z
local playerClickBlock = function (event)
  gobang:check (function ()
    local x, y, z = math.floor(event.x) + 0.5, math.floor(event.y) + 0.5, math.floor(event.z) + 0.5
    local objid = event.eventobjid
    local pos = { x = x, y = y, z = z }
    -- 创建棋盘
    local result, itemid = Player:getCurToolID(objid)
    if (itemid == gobang.itemids[1]) then
      local info = gobang.gameInfos[objid]
      if (not(info)) then
        gobang:init({ x = x, y = y + 1, z = z }, objid)
        return
      end
    end
    for k, v in pairs(gobang.gameInfos) do
      if (gobang:click(v, objid, pos)) then
        break
      end
    end
  end)
end

ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], playerClickBlock)