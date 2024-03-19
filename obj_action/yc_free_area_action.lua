--- 区域内自由活动行为类
--- created by 莫小仙 on 2024-03-12
---@class YcFreeAreaAction 区域内自由活动行为
---@field _actor YcActor 行为者
---@field _positions YcArray<YcPosition> 位置点数组。每两个构成一个区域
---@field _isOpenAI boolean 是否打开AI
---@field _actionGroup YcActionGroup 一次行动的行为组
---@field _t string | number 类型
---@field _isPaused boolean 是否是暂停
---@field _group YcActionGroup | nil 所属行为组
---@field NAME string 行为名称
YcFreeAreaAction = YcAction:new({
  NAME = 'freeArea'
})

---@class YcFreeAreaActionOption 区域内自由活动行为的其他配置信息
---@field isOpenAI boolean | nil 是否打开AI。默认关闭
---@field actions table | nil 一次移动结束后的其他行为
YcFreeAreaActionOption = {}

--- 实例化一个区域内自动活动行为
---@param actor YcActor 行为者
---@param positions table 位置数组
---@param option YcFreeAreaActionOption
function YcFreeAreaAction:new(actor, positions, option)
  if positions and #positions % 2 ~= 0 then
    YcLogHelper.warn('位置数量不是偶数')
  end
  local posList
  if YcArray.isArray(positions) then
    posList = positions
  else
    posList = YcArray:new(positions)
  end
  option = option or {}
  local isOpenAI = option.isOpenAI == true -- 默认为false
  local o = {
    _actor = actor,
    _positions = posList,
    _isOpenAI = isOpenAI
  }
  YcFreeAreaAction._setActionGroup(o, actor, option)
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 开始行动
function YcFreeAreaAction:start()
  CreatureAPI.setAIActive(self._actor.objid, self._isOpenAI) -- 修改AI开启状态
  self._isPaused = false
  self:_run()
end

--- 一次行动
function YcFreeAreaAction:_run()
  local x, y, z = self._actor:getPosition()
  if x then -- 如果找到行为者位置
    local countArea = math.floor(#self._positions / 2) -- 区域总数
    local areaIndex = math.random(1, countArea) -- 随机取一个区域的序号
    local pos1 = self._positions[areaIndex * 2 - 1] -- 构成区域的第一个位置
    local pos2 = self._positions[areaIndex * 2] -- 构成区域的第二个位置
    local tx, ty, tz = YcPositionHelper.getRandomPosByRange(pos1.x, pos1.y, pos1.z, pos2.x, pos2.y, pos2.z)
    ---@type YcRunAction
    local action = self._actionGroup:get(1) -- 第一个是奔跑行为
    action._positions = {YcPosition:new(tx, ty, tz)} -- 重置位置
    self._actionGroup:start()
    -- ActorAPI.tryMoveToPos(self._actor.objid, tx, ty, tz, self._actor.defaultSpeed) -- 移动到随机位置
  else
    self._t = YcTimeHelper.newAfterTimeTask(function()
      self:_run()
    end)
  end
end

--- 暂停行动
function YcFreeAreaAction:pause()
  self._isPaused = true -- 标记是暂停
  local x, y, z = self._actor:getPosition()
  if x then -- 如果找到位置
    ActorAPI.tryMoveToPos(self._actor.objid, x, y, z, self._actor.defaultSpeed) -- 移动到当前位置
  end
  if self._t then
    YcTimeHelper.delAfterTimeTask(self._t) -- 删除任务
    self._t = nil
  else
    self._actionGroup:stop()
  end
end

--- 恢复行动
function YcFreeAreaAction:resume()
  self:start()
end

--- 停止行动
---@param isTurnNext boolean | nil 停止行动后是否轮到下一个行动。默认不会
function YcFreeAreaAction:stop(isTurnNext)
  self:pause()
  if isTurnNext then
    self:_turnNext()
  end
end

function YcFreeAreaAction._setActionGroup(o, actor, option)
  local actions = option.actions or {YcWaitAction:new(actor)} -- 默认等待3秒
  table.insert(actions, 1, YcRunAction:new(actor, {})) -- 跑行为放第一个
  local actionGroup = YcActionGroup:new(actions, function()
    o:_run()
  end) -- 所有行为放入行为组中，并设置行为结束调用方法
  o._actionGroup = actionGroup
end
