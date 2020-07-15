-- 五子棋
gobang = {
  size = 15,
  --          棋盘、 黑子、白子、关闭、确定、重置、单黑、 单白、双黑、双白、悔棋、悔棋同意
  itemids = { 1120, 615, 600, 416, 406, 405, 682, 667, 615, 600 }, 
  gameInfos = {} -- { objid -> {} }
}

function gobang:init (pos, objid)
  Block:placeBlock(gobang.itemids[4], pos.x, pos.y, pos.z) -- 关闭项
  local result, dirx, diry, dirz = Actor:getFaceDirection(objid)
  local xt, zt = 1, 1
  if (dirx < 0) then
    xt = -1
  end
  if (dirz < 0) then
    zt = -1
  end
  local surePos = { x = pos.x + (xt * 2), y = pos.y, z = pos.z }
  Block:placeBlock(gobang.itemids[5], surePos.x, surePos.y, surePos.z) -- 确定项
  local resetPos = { x = pos.x + (xt * 3), y = pos.y, z = pos.z }
  Block:placeBlock(gobang.itemids[6], resetPos.x, resetPos.y, resetPos.z) -- 重置项

  local singleBlackPos = { x = pos.x + (xt * 6), y = pos.y, z = pos.z }
  Block:placeBlock(gobang.itemids[7], singleBlackPos.x, singleBlackPos.y, singleBlackPos.z) -- 单黑项
  local singleWhitePos = { x = pos.x + (xt * 5), y = pos.y, z = pos.z }
  Block:placeBlock(gobang.itemids[8], singleWhitePos.x, singleWhitePos.y, singleWhitePos.z) -- 单白项
  local positions = {} -- { x,z -> { pos, color } }
  local minX, maxX, minZ, maxZ
  for i = 1, gobang.size do
    for j = 1, gobang.size do
      local p = { x = pos.x + (xt * i), y = pos.y, z = pos.z + (zt * j) }
      positions[gobang:getPosInfoKey(p)] = { p, 0 }
      Block:placeBlock(gobang.itemids[1], p.x, p.y, p.z)
      if (not(minX) or minX > p.x) then
        minX = p.x
      end
      if (not(maxX) or maxX < p.x) then
        maxX = p.x
      end
      if (not(minZ) or minZ > p.z) then
        minZ = p.z
      end
      if (not(maxZ) or maxZ < p.z) then
        maxZ = p.z
      end
    end
  end
  gobang.gameInfos[objid] = { objid = objid, positions = positions, closePos = pos, surePos = surePos, 
    resetPos = resetPos, singleBlackPos = singleBlackPos, singleWhitePos = singleWhitePos,
    lastPosition = {} }
end

function gobang:clear (objid)
  local info = gobang.gameInfos[objid]
  Block:destroyBlock(info.closePos.x, info.closePos.y, info.closePos.z) -- 删除关闭项
  Block:destroyBlock(info.surePos.x, info.surePos.y, info.surePos.z) -- 删除关闭项
  Block:destroyBlock(info.resetPos.x, info.resetPos.y, info.resetPos.z) -- 删除关闭项
  Block:destroyBlock(info.singleBlackPos.x, info.singleBlackPos.y, info.singleBlackPos.z) -- 删除单黑项
  Block:destroyBlock(info.singleWhitePos.x, info.singleWhitePos.y, info.singleWhitePos.z) -- 删除单白项
  -- Block:destroyBlock(info.doubleBlackPos.x, info.doubleBlackPos.y, info.doubleBlackPos.z) -- 删除双黑项
  -- Block:destroyBlock(info.doubleWhitePos.x, info.doubleWhitePos.y, info.doubleWhitePos.z) -- 删除双白项
  -- 删除棋盘
  for k, v in pairs(info.positions) do
    Block:destroyBlock(v[1].x, v[1].y, v[1].z)
  end
end

function gobang:startGame (info)
  info.isGameStart = true
  Chat:sendSystemMsg('开始游戏', info.objid)
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
  if (info.playerid == -1) then -- 电脑
    gobang:computerPlay(info)
  else -- 玩家
    Chat:sendSystemMsg('到你的回合了', info.playerid)
  end
end

function gobang:finishGame (info)
  info.isGameStart = false
  Chat:sendSystemMsg('游戏结束', info.objid)
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
  posInfo[2] = info.thisTurn
  Block:placeBlock(gobang.itemids[posInfo[2] + 1], posInfo[1].x, posInfo[1].y + 1, posInfo[1].z)
  gobang:nextTurn(info)
end

-- 获得一个最好的位置
function gobang:getGreatPosition (info)
  local posInfo = { -1, -1 }
  for k, v in pairs(info.positions) do
    if (v[2] == 0) then -- 无子
      local score = gobang:calcScore(info, v[1])
      if (score > posInfo[1]) then
        print(score, v[1].x, v[1].z)
        posInfo[1] = score
        posInfo[2] = v
      end
    end
  end
  return posInfo[2]
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
    return 0.1
  elseif (posInfo[2] == lastColor) then -- 颜色相同
    return gobang:getNum(info, p, posInfo[2], vec2) + 1
  else -- 颜色不同
    if (isFirst) then
      return (gobang:getNum(info, p, posInfo[2], vec2) + 1) * -1
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
      if (na2 < 4) then -- 小于4时无法连成5子，简单定为0分
        num = 0
      else
        num = na2
      end
    else -- 没有堵住，简单定为长度
      num = na2
    end
  elseif (num2 == 0) then -- 一边是边界
    local na1 = math.abs(num1)
    if (na1 == math.floor(na1)) then -- 被堵住了
      if (na1 < 4) then -- 小于4时无法连成5子，简单定为0分
        num = 0
      else
        num = na1
      end
    else -- 没有堵住，简单定为长度
      num = na1
    end
  elseif (num1 * num2 > 0) then -- 双通
    num = num1 + num2
  elseif (math.abs(num1) == 0.1 or math.abs(num2) == 0.1) then -- 双通
    num = math.abs(num1) + math.abs(num2)
  else -- 异号
    local na1, na2 = math.abs(num1), math.abs(num2)
    if (na1 == math.floor(na1)) then -- 被堵住了
      if (na1 < 4) then -- 小于4时无法连成5子，简单定为0分
        num = 0
      else
        num = 100
      end
    else -- 没有堵住，简单定为长度
      num = na1
    end
    local temp
    if (na2 == math.floor(na2)) then -- 被堵住了
      if (na2 < 4) then -- 小于4时无法连成5子，简单定为0分
        temp = 0
      else
        temp = 100
      end
    else -- 没有堵住，简单定为长度
      temp = na2
    end
    if (num < temp) then
      num = temp
    end
  end
  return gobang:getScore(num)
end

function gobang:getScore (num)
  num = math.abs(num)
  local score = 0
  if (num == 0.2) then -- 双通
    score = 10
  elseif (num == 1.2) then
    score = 20
  elseif (num == 2.2) then
    score = 50
  elseif (num == 3.2) then
    score = 200
  elseif (num >= 4) then
    score = 500
  elseif (num == 0 or num == 1 or num == 2 or num == 3) then -- 两边都堵上
    score = 0
  elseif (num == 0.1) then -- 一边堵上
    score = 1
  elseif (num == 1.1) then
    score = 10
  elseif (num == 2.1) then
    score = 20
  elseif (num == 3.1) then
    score = 50
  end
  return score
end

-- eventobjid, blockid, x, y, z
local playerClickBlock = function (event)
  gobang:check (function ()
    local x, y, z = math.floor(event.x) + 0.5, math.floor(event.y) + 0.5, math.floor(event.z) + 0.5
    local objid = event.eventobjid
    local pos = { x = x, y = y, z = z }
    local info = gobang.gameInfos[objid]
    if (info) then
      if (gobang:equals(pos, info.closePos)) then -- 关闭
        gobang:clear(objid)
        gobang.gameInfos[objid] = nil
        Chat:sendSystemMsg('你收回了棋局', objid)
      elseif (gobang:equals(pos, info.surePos)) then -- 确定
        if (info.singleBlack) then -- 单黑
          info.type = 1
          info.players = { objid, -1 }
          gobang:startGame(info)
        elseif (info.singleWhite) then -- 单白
          info.type = 1
          info.players = { -1, objid }
          gobang:startGame(info)
        else
          Chat:sendSystemMsg('请先选择黑白子后再进行确定', objid)
        end
      elseif (gobang:equals(pos, info.resetPos)) then -- 重置
        Chat:sendSystemMsg('重置', objid)
      elseif (gobang:equals(pos, info.singleBlackPos)) then -- 单黑
        info.singleBlack = true
        info.singleWhite = false
        Chat:sendSystemMsg('你选择了单人黑子（先手）', objid)
      elseif (gobang:equals(pos, info.singleWhitePos)) then -- 单白
        info.singleWhite = true
        info.singleBlack = false
        Chat:sendSystemMsg('你选择了单人白棋（后手）', objid)
      else
        local posInfo = info.positions[gobang:getPosInfoKey(pos)]
        if (posInfo) then -- 棋盘
          if (not(info.isGameStart)) then -- 游戏未开始
            Chat:sendSystemMsg('游戏尚未开始', objid)
          elseif (info.playerid == objid) then -- 玩家的回合
            if (posInfo[2] == 0) then -- 可下
              posInfo[2] = info.thisTurn
              Block:placeBlock(gobang.itemids[posInfo[2] + 1], posInfo[1].x, posInfo[1].y + 1, posInfo[1].z)
              gobang:nextTurn(info)
            else -- 不可下
              Chat:sendSystemMsg('此处已有棋子', objid)
            end
          else
            Chat:sendSystemMsg('当前不是你的回合', objid)
          end
        end
      end
    else
      gobang:init({ x = x, y = y + 1, z = z }, objid)
    end
  end)
end

ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], playerClickBlock)