--- 看行为类 v1.0.0
---created by 莫小仙 on 2024-03-06
---@class YcRunAction : YcAction 奔跑行为
---@field _actor YcActor 行为者
---@field _positions YcPosition[] 移动位置
---@field _dir 'normal' | 'reverse' | 'alternate' 方向。正向/反向/正反交替
---@field _count integer 移动次数。从头到尾或从尾到头共几次
---@field _waitSeconds integer 一次奔跑结束后如果还有移动次数，那么下次开始前等待的秒数。默认为0
---@field _isApproach boolean 是否是靠近。如果是靠近，则到达目标方块外一圈位置则算是到达；反之在需要到达目标方块位置
---@field _index integer 向第几个位置奔跑
---@field _total integer 已经移动的次数
---@field _currentWaitSeconds integer 开始下次奔跑还需要等待的秒数
---@field _t string | number 类型
---@field _areaid integer 区域id
---@field _x number 行为者所在位置x
---@field _y number 行为者所在位置y
---@field _z number 行为者所在位置z
---@field _seconds integer 在同一个位置停留的时长
---@field _isPaused boolean 是否是暂停
---@field _group YcActionGroup | nil 所属行为组
---@field NAME string 行为名称
---@field TIMEOUT number 超时时长。在原地几秒没动表示超时
YcRunAction = YcAction:new({
  NAME = 'run',
  TIMEOUT = 5 -- 5秒没动则为超时
})

---@class YcRunActionOption 奔跑行为的其他配置信息
---@param dir 'normal' | 'reverse' | 'alternate' | nil 方向。正向/反向/正反交替。默认正向
---@param count integer | nil 移动次数。从头到尾或从尾到头共几次。默认1次
---@param waitSeconds number 下一次奔跑行为开始前等待的秒数。当还有下次移动行为时有效。默认为0。
---@param isApproach boolean 是否是靠近。如果是靠近，则到达目标方块外一圈位置则算是到达；反之在需要到达目标方块位置
YcRunActionOption = {}

--- 实例化一个奔跑行为
---@param actor YcActor 行为者
---@param positions YcPosition[] 移动位置
---@param option YcRunActionOption | nil 奔跑行为的其他配置信息
---@return YcRunAction 奔跑行为
function YcRunAction:new(actor, positions, option)
  option = option or {}
  local dir = option.dir or 'normal'
  local count = option.count or 1
  local waitSeconds = option.waitSeconds or 0
  local isApproach = option.isApproach or false
  local o = {
    _actor = actor,
    _positions = positions,
    _dir = dir,
    _count = count,
    _waitSeconds = waitSeconds,
    _isApproach = isApproach,
    _index = 1,
    _total = 0,
    _seconds = 0
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 开始行动
function YcRunAction:start()
  CreatureAPI.setAIActive(self._actor.objid, false) -- 停止AI
  self._index = 1
  self._total = 0
  self._seconds = 0
  self._currentWaitSeconds = 0
  if self._positions then -- 如果有位置信息
    self:_run()
  end
end

--- 一次行动
function YcRunAction:_run()
  if self._currentWaitSeconds > 0 then -- 还有等待时间
    self._currentWaitSeconds = self._currentWaitSeconds - 1
    self._t = YcTimeHelper.newAfterTimeTask(function()
      self:_run()
    end)
  else -- 没有等待时间了
    local pos = self._positions[self._index]
    if not self._areaid then -- 还没有区域id
      YcActionManager.addRunArea(self)
    end
    -- 位置取方块的中间，不然可能进入不了区域
    local x = math.floor(pos.x) + 0.5
    local y = math.floor(pos.y) + 0.5
    local z = math.floor(pos.z) + 0.5
    ActorAPI.tryMoveToPos(self._actor.objid, x, y, z, self._actor.defaultSpeed)
    self._t = YcTimeHelper.newAfterTimeTask(function()
      YcLogHelper.debug('t: ', self._t)
      local cx, cy, cz = self._actor:getPosition() -- 当前位置
      if cx == self._x and cy == self._y and cz == self._z then -- 如果与上次位置相同
        self._seconds = self._seconds + 1 -- 停留秒数加1
        if self._seconds > YcRunAction.TIMEOUT then -- 超时没动
          self._actor:setPosition(pos) -- 直接移动到目的地
        end
      else -- 位置有所不同
        self._x, self._y, self._z = cx, cy, cz
        self._seconds = 0
      end
      self:_run()
    end)
  end
end

--- 暂停行动
function YcRunAction:pause()
  self._isPaused = true -- 标记是暂停
  if self._areaid then -- 如果有区域id（当在奔跑结束后等待时，是没有区域id的）
    YcActionManager.delRunArea(self)
  end
  if self._t then
    YcTimeHelper.delAfterTimeTask(self._t) -- 移除任务
    self._t = nil
  end
  local x, y, z = self._actor:getPosition()
  ActorAPI.tryMoveToPos(self._actor.objid, x, y, z, self._actor.defaultSpeed) -- 寻路到当前生物位置
end

--- 恢复行动
function YcRunAction:resume()
  if self._index == 0 or self._index == #self._positions + 1 then -- 表示已经结束了
    self:runNext()
  else
    CreatureAPI.setAIActive(self._actor.objid, false) -- 停止AI
    self._seconds = 0
    self._currentWaitSeconds = 0
    if self._positions then -- 如果有位置信息
      self:_run()
    end
  end
end

--- 停止行动
---@param isTurnNext boolean | nil 停止行动后是否轮到下一个行动。默认不会
function YcRunAction:stop(isTurnNext)
  self:pause()
  self._index = 0 -- 标记结束
  if isTurnNext then
    self:_turnNext()
  end
end

--- 到达位置点区域
function YcRunAction:onReach()
  YcLogHelper.debug('onReach')
  if #self._positions == 1 then -- 如果只有一个位置
    self:_turnNext() -- 轮到下一个行动
  else -- 有多个位置
    if self._dir == 'normal' then -- 正向
      self._index = self._index + 1
    elseif self._dir == 'reverse' then -- 反向
      self._index = self._index - 1
    else -- 正反交替
      if self._total % 2 == 0 then -- 正向
        self._index = self._index + 1
      else -- 反向
        self._index = self._index - 1
      end
    end
    self:_checkIndex(self._dir == 'alternate')
  end
end

--- 检测序数，判断是不是结束了
---@param isAlternate boolean 是否是正反交替
function YcRunAction:_checkIndex(isAlternate)
  if self._index == 0 then -- 反向结束了
    self._total = self._total + 1
    if self._count == -1 or self._total < self._count then -- 无限次数 或 还有次数
      if isAlternate then -- 正反交替
        -- 当前该正向了
        self._index = 2
      else -- 继续反向
        self._index = #self._positions
      end
      self._currentWaitSeconds = self._waitSeconds -- 重置等待时间
      self:_run()
    else -- 没有次数了
      self:_turnNext() -- 轮到下一个行动
    end
  elseif self._index == #self._positions + 1 then -- 正向结束了
    self._total = self._total + 1
    if self._count == -1 or self._total < self._count then -- 无限次数 或 还有次数
      if isAlternate then -- 正反交替
        -- 当前该反向了
        self._index = #self._positions - 1
      else -- 继续正向
        self._index = 1
      end
      self._currentWaitSeconds = self._waitSeconds -- 重置等待时间
      self:_run()
    else -- 没有次数了
      self:_turnNext() -- 轮到下一个行动
    end
  else -- 还没有结束
    self:_run()
  end
end
