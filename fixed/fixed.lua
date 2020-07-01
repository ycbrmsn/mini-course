-- 定身弓效果
fixed = {
  itemid = 12051, -- 石箭的道具id，若是其他投掷物则需要修改
  seconds = 3, -- 定身时长
  isTimeReset = true, -- 命中生物后是否重置定身时间
  actors = {}, -- 被定身的对象 { objid = timerid }
  missiles = {}, -- 投掷物队伍数组 { { missileid, teamid } }
  timerPool = {} -- 计时器池 { timerid = { isOver, timername, missileInfo } }
}

-- 获得一个计时器id
function fixed:getTimer (timername)
  timername = timername or 'default'
  local timerid
  -- 查找一个停止的计时器
  for k, v in pairs(self.timerPool) do
    if (v[1] and v[2] == timername) then
      v[1] = false -- 设置计时器开始工作标识isOver
      timerid = k
      break
    end
  end
  -- 没找到则创建一个计时器，并加入计时器池中
  if (not(timerid)) then
    local result
    result, timerid = MiniTimer:createTimer(timername, nil, true)
    self.timerPool[timerid] = { false, timername, '' }
  end
  return timerid
end

-- 校验
function fixed:check (f)
  xpcall(f, function (err)
    Chat:sendSystemMsg(err)
  end)
end

-- 记录投掷物所属队伍
function fixed:recordMissile (missileid, teamid)
  table.insert(self.missiles, { missileid, teamid })
  if (#self.missiles > 100) then -- 超过100条记录，则删除最早的记录
    table.remove(self.missiles, 1)
  end
end

function fixed:getMissileTeam (missileid)
  for i, v in ipairs(self.missiles) do
    if (v[1] == missileid) then
      return v[2]
    end
  end
  return nil
end

-- eventobjid, toobjid, itemid, x, y, z
local missileCreate = function (event)
  fixed:check(function ()
    if (event.itemid == fixed.itemid) then -- 是对应投掷物
      if (event.eventobjid > -1) then -- 生物创建
        local result, teamid -- 投掷物所属队伍
        if (Actor:isPlayer(event.eventobjid) == ErrorCode.OK) then -- 玩家创建
          result, teamid = Player:getTeam(event.eventobjid) -- 玩家队伍
        else -- 生物创建
          result, teamid = Creature:getTeam(event.eventobjid) -- 生物队伍
        end
        fixed:recordMissile(event.toobjid, teamid)
      else -- 其他创建
        fixed:recordMissile(event.toobjid, 0)
      end
    end
  end)
end

--eventobjid, toobjid(opt), blockid(opt), x, y, z
local projectileHit = function (event)
  fixed:check(function ()
    local teamid = fixed:getMissileTeam(event.eventobjid)
    if (event.toobjid > -1 and teamid) then -- 如果命中生物并且是对应投掷物
      local tid -- 命中生物队伍
      local objType -- 目标类型
      if (Actor:isPlayer(event.toobjid) == ErrorCode.OK) then -- 击中玩家
        local result, tid = Player:getTeam(event.toobjid)
        if (teamid ~= tid) then -- 敌对玩家
          objType = OBJ_TYPE.OBJTYPE_PLAYER
          Player:setActionAttrState(event.toobjid, PLAYERATTR.ENABLE_MOVE, false) -- 设置玩家不可移动
        end
      else -- 击中生物
        local result, tid = Creature:getTeam(event.toobjid)
        if (teamid ~= tid) then -- 敌对生物
          objType = OBJ_TYPE.OBJTYPE_CREATURE
          Actor:setActionAttrState(event.toobjid, CREATUREATTR.ENABLE_MOVE, false) -- 设置生物不可移动
        end
      end
      if (objType) then -- 击中敌对生物
        local timerid = fixed.actors[event.toobjid]
        if (timerid) then -- 生物处于定身中
          if (fixed.isTimeReset) then -- 重置计时
            MiniTimer:pauseTimer(timerid) -- 暂停
            MiniTimer:changeTimerTime(timerid, fixed.seconds) -- 重置时间
            MiniTimer:resumeTimer(timerid) -- 恢复
          end
        else -- 生物未定身中
          timerid = fixed:getTimer()
          local timerInfo = fixed.timerPool[timerid]
          timerInfo[3] = { objid = event.toobjid }
          MiniTimer:startBackwardTimer(timerid, fixed.seconds) -- 启动倒计时
          fixed.actors[event.toobjid] = timerid
        end
      end
    end
  end)
end

-- timerid, timername
local minitimerChange = function (event)
  fixed:check(function ()
    -- 计时器池中的计时器倒计时为0时，恢复生物移动
    local result, second = MiniTimer:getTimerTime(event.timerid)
    if (second == 0) then -- 倒计时为0
      local timerInfo = fixed.timerPool[event.timerid]
      if (timerInfo) then -- 是计时器池里面的计时器
        timerInfo[1] = true -- 设置计时器结束工作标识isOver
        local arg = timerInfo[3]
        local objid = arg.objid
        fixed.actors[objid] = nil
        if (Actor:isPlayer(objid) == ErrorCode.OK) then -- 玩家
          Player:setActionAttrState(objid, PLAYERATTR.ENABLE_MOVE, true) -- 设置玩家可移动
        else -- 生物
          Actor:setActionAttrState(objid, CREATUREATTR.ENABLE_MOVE, true) -- 设置生物可移动
        end
      end
    end
  end)
end

ScriptSupportEvent:registerEvent([=[Missile.Create]=], missileCreate) -- 投掷物被创建事件
ScriptSupportEvent:registerEvent([=[Actor.Projectile.Hit]=], projectileHit) -- 投掷物击中事件
ScriptSupportEvent:registerEvent([=[minitimer.change]=], minitimerChange) -- 任意计时器发生变化事件