-- 飞行效果
fly = {
  players = {}, -- { objid -> true }
  delPlayers = {}, -- id数组
  speed = 0.0785 -- 速度
}

function fly:addPlayer (objid)
  if (not(fly.players[objid])) then
    fly.players[objid] = true
  end
end

function fly:delPlayer (objid)
  table.insert(fly.delPlayers, objid)
end

-- 校验
function fly:check (f)
  xpcall(f, function (err)
    Chat:sendSystemMsg(err)
  end)
end

-- 无参数
local runGame = function ()
  fly:check(function ()
    for k, v in pairs(fly.players) do
      Actor:appendSpeed(k, 0, fly.speed, 0)
    end
    for i = #fly.delPlayers, 1, -1 do
      fly.players[fly.delPlayers[i]] = nil
      table.remove(fly.delPlayers, i)
    end
  end)
end

-- eventobjid, playermotion
local playerMotionStateChange = function (event)
  fly:check(function ()
    if (event.playermotion == PLAYERMOTION.JUMP) then
      fly:addPlayer(event.eventobjid)
    elseif (event.playermotion == PLAYERMOTION.SNEAK) then
      fly:delPlayer(event.eventobjid)
    end
  end)
end

ScriptSupportEvent:registerEvent([=[Game.Run]=], runGame) -- 游戏运行时
ScriptSupportEvent:registerEvent([=[Player.MotionStateChange]=], playerMotionStateChange) -- 运动状态改变