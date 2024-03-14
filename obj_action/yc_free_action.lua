--- 自由活动行为类
--- created by 莫小仙 on 2024-03-12
---@class YcFreeAction 自由活动行为
---@field _actor YcActor 行为者
---@field _distanceOnce number 一次移动的最远距离
---@field _timeGap number 两次移动的时间间隔
---@field _isOpenAI boolean 是否打开AI
---@field _t string | number 类型
---@field _isPaused boolean 是否是暂停
---@field _group YcActionGroup | nil 所属行为组
---@field NAME string 行为名称
YcFreeAction = YcAction:new({
  NAME = 'free'
})

---@class YcFreeActionOption 自由活动行为的其他配置信息
---@field distanceOnce number 一次移动的最远距离。默认为7米
---@field timeGap number 两次移动的时间间隔。默认为7秒
---@field isOpenAI boolean 是否打开AI。默认关闭
YcFreeActionOption = {}

--- 实例化一个自动活动行为
---@param actor YcActor 行为者
---@param option YcFreeActionOption
function YcFreeAction:new(actor, option)
  option = option or {}
  local distanceOnce = option.distanceOnce or 7
  local timeGap = option.timeGap or 7 -- 默认7秒
  local isOpenAI = option.isOpenAI == true -- 默认为false
  local o = {
    _actor = actor,
    _distanceOnce = distanceOnce,
    _timeGap = timeGap,
    _isOpenAI = isOpenAI
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 开始行动
function YcFreeAction:start()
  CreatureAPI.setAIActive(self._actor.objid, self._isOpenAI) -- 修改AI开启状态
  self._isPaused = false
  self:_run()
end

--- 一次行动
function YcFreeAction:_run()
  local x, y, z = self._actor:getPosition()
  if x then -- 如果找到行为者位置
    local tx, ty, tz = YcPositionHelper.getRandomPosAroundPos(x, y, z, self._distanceOnce)
    ActorAPI.tryMoveToPos(self._actor.objid, tx, ty, tz, self._actor.defaultSpeed) -- 移动到随机位置
  end
  self._t = YcTimeHelper.newAfterTimeTask(function()
    self:_run()
  end, self._timeGap)
end

--- 暂停行动
function YcFreeAction:pause()
  self._isPaused = true -- 标记是暂停
  local x, y, z = self._actor:getPosition()
  if x then -- 如果找到位置
    ActorAPI.tryMoveToPos(self._actor.objid, x, y, z, self._actor.defaultSpeed) -- 移动到当前位置
  end
  if self._t then
    YcTimeHelper.delAfterTimeTask(self._t) -- 删除任务
    self._t = nil
  end
end

--- 恢复行动
function YcFreeAction:resume()
  self:start()
end

--- 停止行动
---@param isTurnNext boolean | nil 停止行动后是否轮到下一个行动。默认不会
function YcFreeAction:stop(isTurnNext)
  self:pause()
  if isTurnNext then
    self:turnNext()
  end
end
