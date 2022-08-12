--[[ 简化版御仙剑 v1.0.0
  create by 莫小仙 on 2022-08-12
]]
Yuxianjian = YcItem:new({
  STATE = {
    NONE = 0, -- 未飞行
    STATIC = 1, -- 滞空状态
    FORWARD = 2 -- 前行状态
  },
  TYPE = {
    STATIC = 'yuxianjianStaticFly', -- 滞空状态类型
    FORWARD = 'yuxianjianForwardFly', -- 飞行前进类型
    UP = 'yuxianjianUpFly' -- 向上飞行
  },
  SPEED = {
    FLY_UP = 0.06, -- 玩家飞行上升速度
    FLY_FORWARD = 0.1, -- 飞行前进速度
    FLY_DOWN = -0.02, -- 抑制泡泡上升的速度
    FLY_JUMP = 0.5, -- 玩家进入飞行状态时起跳的速度
    FLY_STATIC = 0.0785, -- 滞空速度
  },
  PARTICLE_ID = 1237, -- 泡泡包裹特效
  data = {}, -- { objid = { state = state, flySwordId = flySwordId } }
  -- 地图相关属性
  itemid = 4097, -- 御仙剑道具类型id。不同地图取值可能不同
  projectileItemid = 4098, -- 跟随的御仙剑道具类型id。不同地图取值可能不同
  buffid = 50000001 -- 飞行状态id。不同地图取值可能不同
})

--[[
  使用御仙剑技能
  @param  {integer} objid 玩家迷你号
  @param  {integer} itemnum 使用的道具数量，此时此参数没有意义
  @return {nil}
]]
function Yuxianjian:useItem (objid, itemnum)
  local state = Yuxianjian.getState(objid) -- 飞行状态
  if state == Yuxianjian.STATE.NONE then -- 未飞行
    Yuxianjian.changeFlyState(objid, Yuxianjian.STATE.STATIC) -- 进入滞空状态
  elseif state == Yuxianjian.STATE.STATIC then -- 滞空状态
    Yuxianjian.changeFlyState(objid, Yuxianjian.STATE.FORWARD) -- 进入前行状态
  elseif state == Yuxianjian.STATE.FORWARD then -- 前行状态
    Yuxianjian.changeFlyState(objid, Yuxianjian.STATE.STATIC) -- 进入滞空状态
  end
end

--[[
  改变飞行状态
  @param  {integer} objid 玩家迷你号
  @param  {integer} nextState 下一个飞行状态
  @return {boolean} 飞行状态是否发生改变
]]
function Yuxianjian.changeFlyState (objid, nextState)
  local isChaged = true -- 状态是否发生改变
  local state = Yuxianjian.getState(objid) -- 当前飞行状态
  if nextState == Yuxianjian.STATE.NONE then -- 取消飞行
    if state == Yuxianjian.STATE.NONE then -- 未飞行
      isChaged = false -- 状态未改变
    elseif state == Yuxianjian.STATE.STATIC then -- 滞空状态
      Yuxianjian.stopStaticFly(objid) -- 取消滞空状态
    elseif state == Yuxianjian.STATE.FORWARD then -- 前行状态
      Yuxianjian.stopStaticFly(objid) -- 取消滞空状态
      Yuxianjian.stopForwardFly(objid) -- 取消向前飞行状态
    end
  elseif nextState == Yuxianjian.STATE.STATIC then -- 滞空状态
    if state == Yuxianjian.STATE.NONE then -- 未飞行
      Yuxianjian.startStaticFly(objid) -- 开始进入滞空状态
    elseif state == Yuxianjian.STATE.STATIC then -- 滞空状态
      isChaged = false -- 状态未改变
    elseif state == Yuxianjian.STATE.FORWARD then -- 前行状态
      Yuxianjian.stopForwardFly(objid) -- 取消向前飞行状态
    end
  elseif nextState == Yuxianjian.STATE.FORWARD then -- 前行状态
    if state == Yuxianjian.STATE.NONE then -- 未飞行
      Yuxianjian.startStaticFly(objid) -- 开始进入滞空状态
      Yuxianjian.startForwardFly(objid) -- 开始进入向前飞行状态
    elseif state == Yuxianjian.STATE.STATIC then -- 滞空状态
      Yuxianjian.startForwardFly(objid) -- 开始进入向前飞行状态
    elseif state == Yuxianjian.STATE.FORWARD then -- 前行状态
      isChaged = false -- 状态未改变
    end
  end
  Yuxianjian.data[objid].state = nextState -- 更新飞行状态
  return isChaged
end

--[[
  开始进入滞空飞行
  @param  {integer} objid 玩家迷你号
  @return {nil}
]]
function Yuxianjian.startStaticFly (objid)
  ActorAPI.appendSpeed(objid, 0, Yuxianjian.SPEED.FLY_JUMP, 0) -- 给一个上升速度模拟跳跃
  ActorAPI.addBuff(objid, Yuxianjian.buffid, 1, 0) -- 添加飞行状态
  ActorAPI.stopBodyEffectById(objid, Yuxianjian.PARTICLE_ID) -- 去掉泡泡包裹特效
  Yuxianjian.createFlySword(objid) -- 创建御仙剑并跟随玩家
end

--[[
  创建御仙剑并跟随玩家
  @param  {integer} objid 玩家迷你号
  @return {nil}
]]
function Yuxianjian.createFlySword (objid)
  local p = YcCacheHelper.getYcPosition(objid) -- 行为者位置
  -- 在玩家的位置创建一把脚踩的仙剑
  local flySwordId = WorldAPI.spawnProjectileByDir(objid, Yuxianjian.projectileItemid, p.x, p.y, p.z, 0, 0, 0, 0)
  local flyInfo = Yuxianjian.getFlyInfo(objid) -- 飞行信息
  flyInfo.flySwordId = flySwordId -- 记录下脚下仙剑的id
  local t = Yuxianjian.TYPE.STATIC + objid -- 类型，时间函数需要用到
  -- 持续抑制泡泡上升
  YcTimeHelper.newContinueTask(function ()
    ActorAPI.appendSpeed(objid, 0, Yuxianjian.SPEED.FLY_DOWN, 0) -- 抑制泡泡上升速度
    local swordPos = YcCacheHelper.getYcPosition(flySwordId) -- 御仙剑位置
    if swordPos then -- 御仙剑存在
      local p = YcCacheHelper.getYcPosition(objid) -- 行为者位置
      local faceYaw = ActorAPI.getFaceYaw(objid) -- 行为者水平朝向
      -- 下面三行代码的设置值会根据模型道具的位置、朝向等不同而有所不同
      ActorAPI.setPosition(flySwordId, p.x, p.y - 0.1, p.z) -- 设置御仙剑位置
      ActorAPI.setFaceYaw(flySwordId, faceYaw) -- 设置御仙剑水平朝向
      ActorAPI.setFacePitch(flySwordId, 90) -- 设置御仙剑垂直朝向
    end
  end, -1, t)
end

--[[
  停止滞空飞行
  @param  {integer} objid 玩家迷你号
  @return {nil}
]]
function Yuxianjian.stopStaticFly (objid)
  ActorAPI.removeBuff(objid, Yuxianjian.buffid) -- 移除飞行状态
  local t = Yuxianjian.TYPE.STATIC + objid -- 类型，时间函数需要用到
  YcTimeHelper.delContinueTask(t) -- 删除持续向下的效果
  local flyInfo = Yuxianjian.getFlyInfo(objid) -- 飞行信息
  YcCacheHelper.despawnActor(flyInfo.flySwordId) -- 删除御仙剑
  flyInfo.flySwordId = nil -- 清除仙剑id
end

--[[
  开始向前飞行
  @param  {integer} objid 玩家迷你号
  @return {nil}
]]
function Yuxianjian.startForwardFly (objid)
  local t = Yuxianjian.TYPE.FORWARD + objid -- 类型，时间函数需要用到
  -- 持续向前
  YcTimeHelper.newContinueTask(function ()
    local dx, dy, dz = ActorAPI.getFaceDirection(objid) -- 玩家朝向
    local vec3 = YcVector3:new(dx, dy, dz) -- 构造三维向量
    local speedVec3 = vec3 * Yuxianjian.SPEED.FLY_FORWARD -- 速度向量
    ActorAPI.appendSpeed(objid, speedVec3.x, speedVec3.y, speedVec3.z) -- 给一个向前的速度
  end, -1, t)
end

--[[
  停止向前飞行
  @param  {integer} objid 玩家迷你号
  @return {nil}
]]
function Yuxianjian.stopForwardFly (objid)
  local t = Yuxianjian.TYPE.FORWARD + objid -- 类型，时间函数需要用到
  YcTimeHelper.delContinueTask(t) -- 删除持续向前飞行效果
end

--[[
  开始向上飞行
  @param  {integer} objid 玩家迷你号
  @return {nil}
]]
function Yuxianjian.startUpFly (objid)
  local t = Yuxianjian.TYPE.UP + objid -- 类型，时间函数需要用到
  -- 持续向上
  YcTimeHelper.newContinueTask(function ()
    ActorAPI.appendSpeed(objid, 0, Yuxianjian.SPEED.FLY_UP, 0) -- 给一个向上的速度
  end, -1, t)
end

--[[
  停止向上飞行
  @param  {integer} objid 玩家迷你号
  @return {nil}
]]
function Yuxianjian.stopUpFly (objid)
  local t = Yuxianjian.TYPE.UP + objid -- 类型，时间函数需要用到
  YcTimeHelper.delContinueTask(t) -- 删除持续向上飞行效果
end

--[[
  获取玩家飞行信息
  @param  {integer} objid 玩家迷你号
  @return {table} 飞行信息
]]
function Yuxianjian.getFlyInfo (objid)
  local info = Yuxianjian.data[objid] -- 飞行信息
  if not info then -- 不存在，即玩家没有飞行过
    info = { state = Yuxianjian.STATE.NONE } -- 初始化一个飞行信息
    Yuxianjian.data[objid] = info -- 记录下来
  end
  return info
end

--[[
  获取玩家飞行状态
  @param  {integer} objid 玩家迷你号
  @return {integer} 飞行状态
]]
function Yuxianjian.getState (objid)
  local info = Yuxianjian.getFlyInfo(objid) -- 飞行信息
  return info.state
end

--[[
  判断玩家是否在飞行
  @param  {integer} objid 玩家迷你号
  @return {boolean} 是否飞行中
]]
function Yuxianjian.isFlying (objid)
  local state = Yuxianjian.getState(objid) -- 飞行状态
  return state ~= Yuxianjian.STATE.NONE
end

-- 定义一个按键被按下事件
YcEventHelper.registerEvent('Player.InputKeyDown', function (event)
  if event.vkey == 'SPACE' then -- 按下空格键/跳跃键
    local objid = event.eventobjid -- 玩家迷你号
    if Yuxianjian.isFlying(objid) then -- 在飞行中
      Yuxianjian.startUpFly(objid) -- 开始向上飞行
    end
  end
end)

-- 定义一个按键被松开事件
YcEventHelper.registerEvent('Player.InputKeyUp', function (event)
  if event.vkey == 'SPACE' then -- 按下空格键/跳跃键
    local objid = event.eventobjid -- 玩家迷你号
    if Yuxianjian.isFlying(objid) then -- 在飞行中
      Yuxianjian.stopUpFly(objid) -- 停止向上飞行
    end
  end
end)

-- 定义一个玩家运动状态改变事件
YcEventHelper.registerEvent('Player.MotionStateChange', function (event)
  if event.playermotion == PLAYERMOTION.SNEAK then -- 潜行
    local objid = event.eventobjid -- 玩家迷你号
    if Yuxianjian.isFlying(objid) then -- 在飞行中
      Yuxianjian.changeFlyState(objid, Yuxianjian.STATE.NONE) -- 取消飞行
    end
  end
end)

-- 定义一个玩家死亡事件
YcEventHelper.registerEvent('Player.Die', function (event)
  local objid = event.eventobjid -- 玩家迷你号
  if Yuxianjian.isFlying(objid) then -- 在飞行中
    Yuxianjian.changeFlyState(objid, Yuxianjian.STATE.NONE) -- 取消飞行
  end
end)
