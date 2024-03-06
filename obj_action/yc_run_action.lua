--- 看行为类 v1.0.0
---created by 莫小仙 on 2024-03-06
---@class YcRunAction : YcAction 奔跑行为
---@field _actor YcActor 行为者
---@field _positions YcPosition[] 移动位置
---@field _index integer 向第几个位置奔跑
---@field _dir 'normal' | 'reverse' | 'alternate' 方向。正向/反向/正反交替
---@field _count integer 移动次数。从头到尾或从尾到头共几次
---@field _total integer 已经移动的次数
---@field _t string | number 类型
---@field _areaid integer 区域id
YcRunAction = YcAction:new()

--- 实例化一个奔跑行为
---@param actor YcActor 行为者
---@param positions YcPosition[] 移动位置
---@param dir 'normal' | 'reverse' | 'alternate' | nil 方向。正向/反向/正反交替。默认正向
---@param count integer | nil 移动次数。从头到尾或从尾到头共几次。默认1次
---@return YcRunAction 奔跑行为
function YcRunAction:new(actor, positions, dir, count)
  dir = dir or 'normal'
  count = count or 1
  local o = {
    _actor = actor,
    _positions = positions,
    _index = 1,
    _dir = dir,
    _count = count,
    _total = 0
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 开始行动
function YcRunAction:start()
  CreatureAPI.setAIActive(self._actor.objid, false) -- 停止AI
  if self._positions then -- 如果有位置信息
    self:_run()
  end
end

--- 一次行动
function YcRunAction:_run()
  local pos = self._positions[self._index]
  if not self._areaid then -- 还没有区域id
    YcActionManager.addRunArea(self)
  end
  ActorAPI.tryNavigationToPos(self._actor.objid, pos.x, pos.y, pos.z)
  self._t = YcTimeHelper.newAfterTimeTask(function()
    self:_run()
  end)
end

--- 结束行动
function YcRunAction:stop()
  YcTimeHelper.delAfterTimeTask(self._t) -- 移除任务
  ActorAPI.tryNavigationToPos(self._actor.objid, self._actor:getPosition()) -- 寻路到当前生物位置
end

--- 到达位置点区域
function YcRunAction:onReach()
  if #self._positions == 1 then -- 如果只有一个位置
    self:runNext() -- 开始下一个行动
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
      self:_run()
    else -- 没有次数了
      self:runNext() -- 开始下一个行动
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
      self:_run()
    else -- 没有次数了
      self:runNext() -- 开始下一个行动
    end
  else -- 还没有结束
    self:_run()
  end
end
