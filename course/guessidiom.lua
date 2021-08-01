--[[
  猜成语
  房主点击特定方块后开启游戏，获得一个成语，其他玩家进行猜测。
  期间房主可对成语进行描述，其他玩家猜对后队伍加一分并且本轮游戏结束。
  房主点击特定方块开启下一轮游戏。
  成语猜完后会有提示，不过没有设置游戏胜利标志。
  create by 莫小仙 on 2021-08-01
]]
GuessIdiomHelper = {
  blockid = 100, -- 草块（此id值可自行修改）
  isGameStart = false, -- 游戏是否开始
  idioms = { '呼风唤雨', '三皇五帝', '指鹿为马' }, -- 所有成语
  idiom = nil, -- 当前成语
}

-- 开启游戏
function GuessIdiomHelper.startGame (objid)
  local gih = GuessIdiomHelper
  if (not gih.isGameStart) then -- 游戏未开始
    if (#gih.idioms > 0) then -- 成语池中还有成语
      gih.isGameStart = true -- 标记游戏开始
      local index = math.random(1, #gih.idioms) -- 随机选择成语序号
      gih.idiom = gih.idioms[index] -- 对应成语
      table.remove(gih.idioms, index) -- 从成语池中移除挑选的成语
      Chat:sendSystemMsg('选择成语：' .. gih.idiom, objid)
      Chat:sendSystemMsg('剩余成语数：' .. #gih.idioms, objid)
    else -- 已无成语
      Chat:sendSystemMsg('已没有成语可供挑选', objid)
    end
  else -- 游戏进行中
    Chat:sendSystemMsg('本轮成语尚未有人猜中', objid)
  end
end

-- 检查答案
function GuessIdiomHelper.checkAnswer (content)
  return string.find(content, GuessIdiomHelper.idiom) -- 玩家的回答中是否包含成语
end

-- 结束一轮游戏
function GuessIdiomHelper.finish (objid)
  GuessIdiomHelper.isGameStart = false -- 标记游戏结束
  local result, teamid = Player:getTeam(objid) -- 获取玩家队伍
  local result, name = Player:getNickname(objid) -- 获取玩家昵称
  Team:addTeamScore(teamid, 1) -- 队伍加分
  Chat:sendSystemMsg('玩家 ' .. name .. ' 回答正确')
  if (#GuessIdiomHelper.idioms > 0) then -- 成语池中还有成语
    Chat:sendSystemMsg('等待房主开启下一轮竞猜')
  else
    Chat:sendSystemMsg('成语池中已无成语')
  end
end

-- 玩家点击方块事件
local function playerClickBlock (event)
  local objid = event.eventobjid
  if (GuessIdiomHelper.blockid == event.blockid) then -- 玩家点击了特定方块
    if (Player:isMainPlayer(objid) == 0) then -- 是房主点击
      GuessIdiomHelper.startGame(objid) -- 开始游戏
    end
  end
end

-- 输入字符串
local function playerNewInputContent (event)
  local objid = event.eventobjid
  local gih = GuessIdiomHelper
  if (gih.isGameStart) then -- 游戏进行中
    if (Player:isMainPlayer(objid) ~= 0) then -- 不是房主输入
      if (gih.checkAnswer(event.content)) then -- 回答正确
        gih.finish(objid) -- 结束本轮
      end
    end
  end
end

ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], playerClickBlock) -- 玩家点击方块
ScriptSupportEvent:registerEvent([=[Player.NewInputContent]=], playerNewInputContent) -- 玩家输入字符串
