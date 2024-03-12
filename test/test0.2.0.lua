function MyPlayer:onInit()
  YcChatHelper.sendMsg(self.objid, '初始化完成')
end

function MyPlayer:onHour(hour)
  YcChatHelper.sendMsg(self.objid, '到' .. hour .. '点了')
end

function MyPlayer:onCollideCreature(toobjid, actorid)
  YcChatHelper.sendMsg(self.objid, '你碰到了' .. toobjid .. '是' .. actorid)
  YcLogHelper.debug('你碰到了' .. toobjid .. '是' .. actorid)
end

-- 叶小龙
yexiaolong = YcNpc:new({
  actorid = 2,
  ableDetectPlayer = true
})

function yexiaolong:onInit()
  YcLogHelper.debug('叶小龙初始化完成')
end

function yexiaolong:onSeePlayer(player)
  YcLogHelper.debug('叶小龙看到了' .. player.objid)
end

YcNpcManager.addUninitNpc(yexiaolong)

YcNpcManager.autoInitNpcs()

timeline = nil
action = nil
facePitch = 0
-- 点击生物
ScriptSupportEvent:registerEvent([=[Player.ClickActor]=], function(event)
  local objid = event.eventobjid
  local toobjid = event.toobjid
  -- 测试时间线
  -- timeline = YcTimeLine:new():add(function()
  --   yexiaolong:lookAt(objid)
  -- end, 1):add(function()
  --   local player = YcPlayerManager.getPlayer(objid)
  --   player:lookAt(toobjid)
  -- end, 1):onComplete(function()
  --   YcLogHelper.debug('时间线结束')
  -- end):run()

  -- 测试看行为
  -- action = YcLookAction:new(yexiaolong, objid)
  -- yexiaolong:setAction(action):act()

  -- 测试抬头低头
  -- CreatureAPI.setAIActive(toobjid, false) -- 停止AI
  -- facePitch = facePitch + 10
  -- if facePitch > 180 then
  --   facePitch = facePitch - 180
  -- end
  -- ActorAPI.setFacePitch(toobjid, facePitch)
  -- YcLogHelper.debug(ActorAPI.turnFacePitch(toobjid, 10))

  -- 测试暂停做行为
  yexiaolong:pauseToAction(YcLookAction:new(yexiaolong, objid, 3))
end)

-- 点击方块
ScriptSupportEvent:registerEvent([=[Player.ClickBlock]=], function(event)
  local objid = event.eventobjid
  -- 测试时间线
  -- if timeline then
  --   timeline:stop()
  --   timeline = nil
  -- end

  -- 测试看行为
  -- action:stop()

  -- 测试奔跑行为
  -- local pos1 = YcPosition:new(event.x, event.y + 1, event.z)
  -- local pos2 = YcPlayerManager.getPlayer(objid):getYcPosition()
  -- action = YcRunAction:new(yexiaolong, {pos1, pos2}, {
  --   dir = 'alternate',
  --   count = 3,
  --   waitSeconds = 3,
  --   isApproach = true
  -- })
  -- yexiaolong:setAction(action):action()

  -- 测试跟随行为
  -- action = YcFollowAction:new(yexiaolong, objid, {
  --   noFollowAction = YcLookAction:new(yexiaolong, objid, 3)
  -- })
  -- yexiaolong:setAction(action):action()

  -- 测试自由活动行为
  -- action = YcFreeAction:new(yexiaolong)
  -- yexiaolong:setAction(action):action()

  -- 测试区域内自由活动行为
  local pos = yexiaolong:getYcPosition()
  local pos2 = YcPosition:new(pos.x + 5, pos.y, pos.z + 5)
  action = YcFreeAreaAction:new(yexiaolong, {pos, pos2})
  yexiaolong:setAction(action):action()
end)
