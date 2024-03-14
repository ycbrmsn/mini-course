--- 区域内自由活动行为类
--- created by 莫小仙 on 2024-03-12
---@class YcFreeAreaAction 区域内自由活动行为
---@field _actor YcActor 行为者
---@field _positions YcArray<YcPosition> 位置点数组。每两个构成一个区域
---@field _timeGap number 两次移动的时间间隔
---@field _isOpenAI boolean 是否打开AI
---@field _t string | number 类型
---@field _isPaused boolean 是否是暂停
---@field _group YcActionGroup | nil 所属行为组
---@field NAME string 行为名称
YcFreeAreaAction = YcAction:new({
  NAME = 'freeArea'
})

---@class YcFreeAreaActionOption 区域内自由活动行为的其他配置信息
---@field timeGap number | nil 两次移动的时间间隔。默认为7秒
---@field isOpenAI boolean | nil 是否打开AI。默认关闭
---@field actions table | nil 一次移动结束后
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
  local timeGap = option.timeGap or 7 -- 默认7秒
  local isOpenAI = option.isOpenAI == true -- 默认为false
  local pos
  local o = {
    _actor = actor,
    _positions = posList,
    _timeGap = timeGap,
    _isOpenAI = isOpenAI
  }
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
    ActorAPI.tryMoveToPos(self._actor.objid, tx, ty, tz, self._actor.defaultSpeed) -- 移动到随机位置
  end
  self._t = YcTimeHelper.newAfterTimeTask(function()
    self:_run()
  end, self._timeGap)
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
    self:turnNext()
  end
end
