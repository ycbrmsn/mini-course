-- 回旋镖效果
boomerang = {
  itemid = 4098, -- 回旋镖投掷物道具id，不同地图需要改变该值
  countdown = 2, -- 倒计时2秒
  missileids = {}, -- 代码创建的投掷物
  timerPool = {} -- 计时器池 { timerid = { isOver, missileInfo } }
}

-- 获得一个计时器id
function boomerang:getTimer ()
  local timerid
  -- 查找一个停止的计时器
  for k, v in pairs(self.timerPool) do
    if (v[1]) then
      v[1] = false -- 设置计时器开始工作标识isOver
      timerid = k
      break
    end
  end
  -- 没找到则创建一个计时器，并加入计时器池中s
  if (not(timerid)) then
    local result
    result, timerid = MiniTimer:createTimer('', nil, true)
    self.timerPool[timerid] = { false, '' }
  end
  return timerid
end

-- eventobjid, toobjid, itemid, x, y, z
local missileCreate = function (arg)
  -- 在玩家创建回旋镖投掷物时，开启倒计时
  if (boomerang.missileids[arg.toobjid]) then -- 如果是代码创建的投掷物，则不启动计时器
    boomerang.missileids[arg.toobjid] = nil
    return
  end
  if (arg.itemid == boomerang.itemid) then -- 是回旋镖投掷物
    local timerid = boomerang:getTimer()
    local timerInfo = boomerang.timerPool[timerid]
    timerInfo[2] = arg -- 将创建投掷物的相关信息保存下来
    MiniTimer:startBackwardTimer(timerid, boomerang.countdown) -- 启动倒计时
  end
end

-- timerid, timername
local minitimerChange = function (arg)
  -- 计时器池中的计时器倒计时为0时，销毁关联的投掷物，并创建返回的投掷物
  local result, second = MiniTimer:getTimerTime(arg.timerid)
  if (second == 0) then -- 倒计时为0
    local timerInfo = boomerang.timerPool[arg.timerid]
    if (timerInfo) then -- 是计时器池里面的计时器
      timerInfo[1] = true -- 设置计时器结束工作标识isOver
      local arg2 = timerInfo[2]
      local result1, x, y, z = Actor:getPosition(arg2.toobjid) -- 获取投掷物位置
      if (result1 and not(timerInfo[2].isHit)) then -- 如果投掷物还存在并且未命中，则销毁重新创建一个飞回来的投掷物
        World:despawnActor(arg2.toobjid) -- 销毁投掷物
        local result2, missileid = World:spawnProjectile(arg2.eventobjid, arg2.itemid, x, y, z, arg2.x, arg2.y, arg2.z)
        boomerang.missileids[missileid] = true -- 记录是代码创建的投掷物
      end
    end
  end
end

--eventobjid, toobjid(opt), blockid(opt), x, y, z
local projectileHit = function (arg)
  -- 设置计时器池中对应的投掷物的命中状态
  for k, v in pairs(boomerang.timerPool) do
    if (not(v[1]) and arg.eventobjid == v[2].toobjid) then -- 未结束工作的计时器中的对应投掷物
      v[2].isHit = true
    end
  end
end

ScriptSupportEvent:registerEvent([=[Missile.Create]=], missileCreate) -- 投掷物被创建事件
ScriptSupportEvent:registerEvent([=[minitimer.change]=], minitimerChange) -- 任意计时器发生变化事件
ScriptSupportEvent:registerEvent([=[Actor.Projectile.Hit]=], projectileHit) -- 投掷物击中事件