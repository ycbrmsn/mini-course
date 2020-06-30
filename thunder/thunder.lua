-- 落雷术效果
thunder = {
  itemid = 4097, -- 使用道具id，不同地图需要修改
  isSuper = false, -- 是否是大落雷术
  waitSeconds = 2, -- 从技能发动到天雷落下之间的等待时间
  continueSeconds = 2, -- 天雷存在的有效时间
  skillRange = 8, -- 技能有效区域大小
  thunderRange = 2, -- 落雷区域大小
  particleids = { 1293, 1301, 1297 }, -- 技能特效id
  areaids = {}, -- 落雷区域 { objid = areaids }
  timerPool = {} -- 计时器池 { timerid = { isOver, timername, missileInfo } }
}

-- 计算两点间的距离，因为之前调用接口一直有问题，所以还是自己写一个
function thunder:getDistance (x1, y1, z1, x2, y2, z2)
  local x, y, z = x1 - x2, y1 - y2, z1 - z2
  return math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
end

-- 获得一个计时器id
function thunder:getTimer (timername)
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
function thunder:check (f)
  xpcall(f, function (err)
    Chat:sendSystemMsg(err)
  end)
end

-- eventobjid, toobjid, itemid, itemnum
local playerUseItem = function (event)
  thunder:check(function ()
    if (event.itemid == thunder.itemid) then -- 使用发动落雷术道具
      local result, teamid = Player:getTeam(event.eventobjid) -- 玩家队伍
      local result, x, y, z = Actor:getPosition(event.eventobjid) -- 玩家位置
      local result, areaid = Area:createAreaRect({ x = x, y = y, z = z }, 
        { x = thunder.skillRange, y = thunder.skillRange, z = thunder.skillRange }) -- 创建有效区域
      local result, posBeg, posEnd = Area:getAreaRectRange(areaid) -- 区域范围
      local result, objids1 = Area:getAllPlayersInAreaRange(posBeg, posEnd) -- 所有玩家
      local result, objids2 = Area:getAllCreaturesInAreaRange(posBeg, posEnd) -- 所有生物
      Area:destroyArea(areaid) -- 销毁区域
      local targetObjids = {} -- 目标数组
      -- 循环找出敌对生物加入目标数组
      for i, v in ipairs(objids1) do
        local result, tid = Player:getTeam(v) -- 目标队伍
        if (teamid ~= tid) then -- 敌对玩家
          table.insert(targetObjids, v)
        end
      end
      for i, v in ipairs(objids2) do
        local result, tid = Creature:getTeam(v) -- 目标队伍
        if (teamid ~= tid) then -- 敌对生物
          table.insert(targetObjids, v)
        end
      end
      if (#targetObjids > 0) then -- 如果有目标
        -- 记录下目标位置
        local positions = {}
        if (thunder.isSuper) then -- 是大落雷术
          for i, v in ipairs(targetObjids) do
            local result, x2, y2, z2 = Actor:getPosition(v) -- 生物位置
            table.insert(positions, { x2, y2, z2 })
          end
        else -- 不是大落雷术，则取最近目标
          local targetPosition, minDistance = {}
           -- 循环找出最近的生物
          for i, v in ipairs(targetObjids) do
            local result, x2, y2, z2 = Actor:getPosition(v) -- 生物位置
            local distance = thunder:getDistance(x, y, z, x2, y2, z2)
            if (not(minDistance) or minDistance > distance) then -- 发现更近生物
              minDistance = distance
              targetPosition = { x2, y2, z2 }
            end
          end
          positions = { targetPosition }
        end
        -- 启动倒计时
        local timerid = thunder:getTimer('skill')
        local timerInfo = thunder.timerPool[timerid]
        timerInfo[3] = { objid = event.eventobjid, positions = positions, 
          position = { x, y, z } } -- 将目标相关信息保存下来
        MiniTimer:startBackwardTimer(timerid, thunder.waitSeconds) -- 启动倒计时
        thunder.areaids[event.eventobjid] = {} -- 重置落雷区域
        -- 显示特效
        World:playParticalEffect(x, y, z, thunder.particleids[1], 1)
        for i, v in ipairs(positions) do
          World:playParticalEffect(v[1], v[2], v[3], thunder.particleids[2], 1)
        end
      else
        Chat:sendSystemMsg('技能范围内未发现目标', event.eventobjid)
      end
    end
  end)
end

-- timerid, timername
local minitimerChange = function (event)
  thunder:check(function ()
    -- 计时器池中的计时器倒计时为0时，销毁关联的投掷物，并创建返回的投掷物
    local result, second = MiniTimer:getTimerTime(event.timerid)
    if (second == 0) then -- 倒计时为0
      local timerInfo = thunder.timerPool[event.timerid]
      if (timerInfo) then -- 是计时器池里面的计时器
        timerInfo[1] = true -- 设置计时器结束工作标识isOver
        if (timerInfo[2] == 'skill') then -- 发动法术
          local arg = timerInfo[3]
          local objid = arg.objid
          local positions = arg.positions
          local position = arg.position
          for i, v in ipairs(positions) do
            local result, areaid = Area:createAreaRect({ x = v[1], y = v[2], z = v[3] }, 
              { x = thunder.thunderRange, y = thunder.thunderRange, 
              z = thunder.thunderRange }) -- 创建落雷区域
            table.insert(thunder.areaids[objid], areaid)
            -- 特效效果
            World:stopEffectOnPosition(position[1], position[2], position[3], 
              thunder.particleids[1])
            World:stopEffectOnPosition(v[1], v[2], v[3], thunder.particleids[2])
            World:playParticalEffect(v[1], v[2], v[3], thunder.particleids[3], thunder.thunderRange)
          end
          -- 启动倒计时销毁这些区域
          local timerid = thunder:getTimer('clear')
          local timerInfo = thunder.timerPool[timerid]
          timerInfo[3] = { objid = objid, positions = positions }
          MiniTimer:startBackwardTimer(timerid, thunder.continueSeconds) -- 启动倒计时
          World:playParticalEffect(tx, ty, tz, thunder.particleids[2], 1)
        elseif (timerInfo[2] == 'clear') then -- 清除区域
          thunder.areaids[timerInfo[3].objid] = {} -- 重置落雷区域
          -- 关闭特效
          for i, v in ipairs(timerInfo[3].positions) do
            World:stopEffectOnPosition(v[1], v[2], v[3], thunder.particleids[3])
          end
        end
      end
    end
  end)
end

-- eventobjid, areaid
local playerAreaIn = function (event)
  thunder:check(function ()
    for k, v in pairs(thunder.areaids) do
      for ii, vv in ipairs(v) do
        if (event.areaid == vv) then -- 进入落雷区域
          local result, teamid = Player:getTeam(k) -- 施法者队伍
          local result, tid = Player:getTeam(event.eventobjid) -- 玩家队伍
          if (teamid ~= tid) then -- 敌对生物
            Actor:killSelf(event.eventobjid) -- 杀死自己
            return
          end
        end
      end
    end
  end)
end

-- eventobjid, areaid
local actorAreaIn = function (event)
  thunder:check(function ()
    for k, v in pairs(thunder.areaids) do
      for ii, vv in ipairs(v) do
        if (event.areaid == vv) then -- 进入落雷区域
          local result, teamid = Player:getTeam(k) -- 施法者队伍
          local result, tid = Creature:getTeam(event.eventobjid) -- 生物队伍
          if (teamid ~= tid) then -- 敌对生物
            Actor:killSelf(event.eventobjid) -- 杀死自己
            return
          end
        end
      end
    end
  end)
end

ScriptSupportEvent:registerEvent([=[Player.UseItem]=], playerUseItem) -- 玩家使用道具事件
ScriptSupportEvent:registerEvent([=[minitimer.change]=], minitimerChange) -- 任意计时器发生变化事件
ScriptSupportEvent:registerEvent([=[Player.AreaIn]=], playerAreaIn) -- 玩家进入区域事件
ScriptSupportEvent:registerEvent([=[Actor.AreaIn]=], actorAreaIn) -- 生物进入区域事件