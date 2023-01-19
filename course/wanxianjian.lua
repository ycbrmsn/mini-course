--[[ 简化版万仙剑 v1.0.0
  create by 莫小仙 on 2023-01-19
]]
Wanxianjian = YcItem:new({
  TARGET_LOCATION = {
    APPEAR = 2, -- 飞剑出现时的前方距离
    FORWARD = 6, -- 飞剑落下时的前方距离
    UP = 20 -- 飞剑落下时高度
  },
  SPEED = {
    FLY_UP = 1, -- 向上飞行的速度
    FLY_DOWN = 0.8 -- 向下飞行的速度
  },
  DISAPPEAR_TIME = 3, -- 插入方块后几秒消失
  HALF_WIDTH = 1, -- 飞剑出现区域的半边长
  DIM = YcPosition:new(5, 10, 5), -- 飞剑搜索区域大小
  SEARCH_TIME = 5, -- 飞剑搜索时长（秒），超过该时间则飞机不再进行索敌
  -- 地图相关属性
  itemid = 4097, -- 万仙剑道具类型id。不同地图取值可能不同
  projectileItemid = 4098 -- 飞行的万仙剑道具类型id。不同地图取值可能不同
})

--[[
  使用万仙剑技能
  @param  {integer} objid 玩家迷你号
  @param  {integer} itemnum 使用的道具数量，此时此参数没有意义
  @return {nil}
]]
function Wanxianjian:useItem (objid, itemnum)
  Wanxianjian.upFly(objid, self)
end

--[[
  召唤出万仙剑向上飞行
  @param  {integer} objid 玩家迷你号
  @param  {YcItem} item 道具对象
  @return {nil}
]]
function Wanxianjian.upFly (objid, item)
  local pos = YcCacheHelper.getYcPosition(objid) -- 玩家位置
  local dx, dy, dz = ActorAPI.getFaceDirection(objid) -- 玩家朝向
  local p = YcActorHelper.getDistancePosition(objid, Wanxianjian.TARGET_LOCATION.APPEAR) -- 前方飞剑出现时的位置
  local dstPos = YcActorHelper.getDistancePosition(objid, Wanxianjian.TARGET_LOCATION.FORWARD) -- 前方飞剑下落的水平位置
  dstPos.y = dstPos.y + Wanxianjian.TARGET_LOCATION.UP -- 调整高度位置
  local projectileid = WorldAPI.spawnProjectileByDir(objid,
    Wanxianjian.projectileItemid, p.x, p.y + 1, p.z, dx, dy, dz, 0) -- 创建飞行的万仙剑
  -- 1秒后向上飞行
  YcTimeHelper.newAfterTimeTask(function ()
    ActorAPI.appendSpeed(projectileid, 0, Wanxianjian.SPEED.FLY_UP, 0) -- 向上飞行
  end, 1)
  -- 2秒后销毁上升飞剑，并降下飞剑
  YcTimeHelper.newAfterTimeTask(function ()
    YcCacheHelper.despawnActor(projectileid) -- 销毁上升的万仙剑
    Wanxianjian.downFly(objid, dstPos, item) -- 降下飞剑
  end, 2)
end

--[[
  万仙剑下落攻击
  @param  {integer} objid 玩家迷你号
  @param  {table} dstPos 万仙剑下落位置中心
  @param  {YcItem} item 道具对象
  @return {nil}
]]
function Wanxianjian.downFly (objid, dstPos, item)
  local arr = {} -- 记录所有飞剑出现位置
  local infos = {} -- 记录所有飞剑的信息
  local size = Wanxianjian.HALF_WIDTH -- 半宽
  local y = dstPos.y -- y轴位置
  -- 循环生成所有飞剑出现位置
  for i = dstPos.x - size, dstPos.x + size do
    for j = dstPos.z - size, dstPos.z + size do
      table.insert(arr, YcPosition:new(i, y, j))
    end
  end
  Wanxianjian.createRandomPosSword(objid, arr, infos, item) -- 创建所有飞剑
  Wanxianjian.searchAndAttack(objid, infos) -- 飞剑搜索目标并发起攻击
end

--[[
  在指定的随机位置创建飞剑
  @param  {integer} objid 发动技能的执行者id
  @param  {table} arr 飞剑出现的位置数组
  @param  {table} infos 飞剑的信息数组
  @param  {YcItem} item 道具对象
  @return {nil}
]]
function Wanxianjian.createRandomPosSword (objid, arr, infos, item)
  if #arr > 0 then -- 如果还有位置
    local speedY = Wanxianjian.SPEED.FLY_DOWN -- 下落速度
    local index = math.random(1, #arr) -- 随机位置的序号
    local p = arr[index] -- 随机位置
    local projectileid = WorldAPI.spawnProjectileByDir(objid,
      Wanxianjian.projectileItemid, p.x, p.y, p.z, 0, -1, 0, 0) -- 创建飞剑
    local speedVector3 = YcVector3:new(0, -Wanxianjian.SPEED.FLY_UP, 0) -- 下落速度向量
    ActorAPI.appendSpeed(projectileid, speedVector3:get()) -- 向下落
    table.insert(infos, {
      exists = true, -- 是否存在
      projectileid = projectileid, -- 飞剑id
      speedVector3 = speedVector3, -- 速度向量
      pos = p, -- 位置
      frames = 0 -- 位置未改变的帧数
    }) -- 记录飞剑信息
    table.remove(arr, index) -- 移除数组中该位置
    YcItemHelper.recordProjectile(projectileid, objid, item) -- 记录投掷物信息，可以激活该道具投掷物命中事件
    YcItemHelper.recordMissileSpeed(projectileid, speedVector3) -- 记录投掷物速度
    -- 0.1秒后创建下一把飞剑
    YcTimeHelper.newAfterTimeTask(function ()
      Wanxianjian.createRandomPosSword(objid, arr, infos, item)
    end, 0.1)
  end
end

--[[
  飞剑搜索目标并发起攻击
  @param  {integer} objid 发动技能的执行者id
  @param  {table} infos 飞剑的信息数组
  @return {nil}
]]
function Wanxianjian.searchAndAttack (objid, infos)
  local teamid = YcCacheHelper.getTeam(objid) -- 获取发动者队伍id
  YcTimeHelper.newContinueTask(function ()
    for i, v in ipairs(infos) do
      if v.exists then -- 如果飞剑还存在
        local pos = YcCacheHelper.getYcPosition(v.projectileid) -- 获取飞剑位置
        if pos then -- 飞剑存在，则搜索飞剑周围目标
          if pos:equals(v.pos) then -- 如果飞剑位置没变
            v.frames = (v.frames or 0) + 1 -- 帧数加1
            if v.frames > 20 then -- 如果超过20帧没有动
              v.exists = false -- 标记飞剑不存在
              -- 几秒后销毁飞剑
              YcTimeHelper.newAfterTimeTask(function ()
                YcCacheHelper.despawnActor(v.projectileid)
              end, Wanxianjian.DISAPPEAR_TIME)
            end
          else -- 如果飞剑位置发生了变化
            v.pos = pos -- 更新位置
            v.frames = 0 -- 重置帧数
          end
          local objids = YcActorHelper.getAllCreaturesArroundPos(pos, Wanxianjian.DIM, teamid) -- 查询区域内与玩家不同队的所有生物
          if not objids or #objids == 0 then -- 如果没有找到任何生物
            objids = YcActorHelper.getAllPlayersArroundPos(pos, Wanxianjian.DIM, teamid) -- 查询区域内与玩家不同队的所有玩家
          end
          objids = YcActorHelper.getAliveActors(objids) -- 查找数组中存活着的执行者
          if objids and #objids > 0 then -- 如果发现目标则跟踪目标
            local targetObjid = YcActorHelper.getNearestActor(objids, pos) -- 最近的目标
            ActorAPI.appendSpeed(v.projectileid, -v.speedVector3.x, -v.speedVector3.y, -v.speedVector3.z) -- 给一个相反的速度使其停下来
            local dstPos = YcCacheHelper.getYcPosition(targetObjid) -- 目标位置
            local speedVector3 = YcVectorHelper.getTargetVector3(pos, dstPos, 1) -- 获取飞剑朝向目标位置大小为1的向量
            ActorAPI.appendSpeed(v.projectileid, speedVector3.x, speedVector3.y, speedVector3.z) -- 使飞剑以1的速度朝目标飞行
            v.speedVector3 = speedVector3 -- 记录飞剑速度
            YcItemHelper.recordMissileSpeed(v.projectileid, speedVector3) -- 记录飞剑速度
          end
        else -- 如果飞剑不存在
          v.exists = false
        end
      end
    end
  end, Wanxianjian.SEARCH_TIME)
end