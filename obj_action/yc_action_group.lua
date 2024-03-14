--- 行为组类 v1.0.0
--- created by 莫小仙 on 2024-03-13
---@class YcActionGroup 行为组
---@field _index integer 当前行动序数
---@field _actions YcArray<YcAction | YcActionGroup> 主行为/行为组数组
---@field _tempActions YcArray<YcAction | YcActionGroup> 临时行为/行为组数组
---@field _isTempActionRunning boolean 是否在执行临时行为
---@field _currentAction YcAction | YcActionGroup | nil 当前正在执行的行动/行动组
---@field _isPaused boolean 是否是暂停
---@field _group YcActionGroup | nil 所属行为组
---@field NAME string 行为组名称
YcActionGroup = {
  NAME = 'group'
}

--- 实例化一个行为组
---@param array table | nil 行为/行为组数组
function YcActionGroup:new(array)
  local o = {
    _index = 1,
    _actions = YcArray:new(),
    _tempActions = YcArray:new(),
    _isTempActionRunning = false,
    _currentAction = nil,
    _isPaused = false,
    _group = nil
  }
  if type(array) == 'table' then
    for i, action in ipairs(array) do
      YcActionGroup._tryAddAction(o._actions, action, o)
    end
  end
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 开始行动
function YcActionGroup:start()
  if self._tempActions:length() > 0 then -- 如果有临时行动
    local action = self._tempActions[1] -- 第一个临时行动
    if action ~= self._currentAction then -- 与当前行动不同
      if self._currentAction and not self._currentAction._isPaused then -- 如果当前行动正在执行
        YcLogHelper.debug('暂停当前行动')
        self._currentAction:pause() -- 暂停当前行动（此行动多半是主行动）
      end
      self._currentAction = action -- 重新记录当前行动
    else -- 与当前行动相同
      action:stop() -- 停止行动
    end
    self._isTempActionRunning = true -- 标记正在执行临时行动
    action:start() -- 开始行动
  elseif self._actions:length() then -- 如果有主行动
    self._index = 1 -- 重置序数
    local action = self._actions[self._index] -- 取第一个行动
    if action ~= self._currentAction then -- 与当前行动不同
      if self._currentAction and not self._currentAction._isPaused then -- 如果当前行动正在执行
        YcLogHelper.debug('停止当前行动')
        self._currentAction:stop() -- 停止当前行动
      end
      self._currentAction = action -- 重新记录当前行动
    else -- 与当前行动相同
      action:stop() -- 停止行动
    end
    action:start() -- 开始行动
  end
end

--- 暂停行动
function YcActionGroup:pause()
  if self._currentAction then
    self._currentAction.pause() -- 暂停行动
    self._isPaused = true -- 标记是暂停
  else
    YcLogHelper.warn('暂停行为组失败：没有行动')
  end
end

--- 恢复行动
function YcActionGroup:resume()
  if self._currentAction then
    self._currentAction.resume() -- 恢复行动
    self._isPaused = false -- 标记不是暂停
  else
    YcLogHelper.warn('恢复行为组失败：没有行动')
  end
end

--- 停止行动。这里会清空临时行动
---@param isTurnNext boolean | nil 停止行动后是否轮到下一个行动。默认不会
function YcActionGroup:stop(isTurnNext)
  if self._currentAction then
    self._currentAction:stop() -- 停止当前行动
    self._currentAction = nil -- 置空
    self._isPaused = false -- 标记不是暂停
    self._index = 1 -- 重置序号
    if self._tempActions:length() > 0 then -- 如果有临时行动
      self._tempActions = YcArray:new() -- 清空临时行动
    end
  else
    YcLogHelper.warn('停止行为组失败：没有行动')
  end
  if isTurnNext then
    self:turnNext()
  end
end

--- 轮到下一个行动
function YcActionGroup:turnNext()
  if self._currentAction then -- 如果有当前行动
    self._currentAction:stop() -- 停止当前行动
  end
  if self._isTempActionRunning then -- 如果正在执行临时行动
    self._tempActions:shift() -- 移除第一个
    local action = self._tempActions[1] -- 取第一个行动
    if action then -- 如果找到行动
      if action._isPaused then -- 如果是暂停的
        action:resume() -- 恢复行动
      else -- 不是暂停的
        action:start() -- 开始行动
      end
    else -- 没有找到行动
      self._isTempActionRunning = false -- 标记不执行临时行动了
      self._index = self._index - 1 -- 因为递归一开始会加1，为了保证序号不变，所以这里减1
      self:startNext()
    end
  else -- 在执行主行动
    self._index = self._index + 1 -- 序号递增
    ---@type YcAction | YcActionGroup
    local action = self._actions[self._index] -- 取下一个行动
    if action then -- 如果找到行动
      if action._isPaused then -- 如果是暂停的
        action:resume() -- 恢复行动
      else -- 不是暂停的
        action:start() -- 开始行动
      end
    else -- 没有找到行动，说明没有下一个行动了
      if self._group then -- 如果有所属行为组
        self._group:startNext() -- 所属行为组开始下一个行动
      else -- 没有所属行为组，那么表示没有后续了
        -- 暂时就什么都不做了
      end
    end
  end
end

--- 尝试开始临时行动。如果有临时行动正在执行，那么继续执行
function YcActionGroup:tryStartTemp()
  if self._isTempActionRunning then -- 如果正在执行临时行动
    if self._currentAction._isPaused then -- 临时行动暂停了
      self._currentAction:resume() -- 恢复
    else -- 临时行动在执行
      -- 不做什么，继续执行
    end
  else -- 如果是在执行主行动
    self:start()
  end
end

--- 向行为数组尾部添加一个或多个行为/行为组
---@vararg YcAction | YcActionGroup 需要添加的行为/行为组
---@return YcActionGroup 行为组
function YcActionGroup:push(...)
  local num = select('#', ...)
  for i = 1, num, 1 do
    local action = select(i, ...)
    YcActionGroup._tryAddAction(self._actions, action, self)
  end
  return self
end

--- 向临时行为数组尾部添加一个或多个行为/行为组
---@vararg YcAction | YcActionGroup 需要添加的行为/行为组
---@return YcActionGroup 行为组
function YcActionGroup:pushTemp(...)
  local num = select('#', ...)
  for i = 1, num, 1 do
    local action = select(i, ...)
    YcActionGroup._tryAddAction(self._tempActions, action, self)
  end
  return self
end

--- 清空所有行为
function YcActionGroup:clear()
  self:stop()
  self._actions = YcArray:new()
  self._tempActions = YcArray:new()
  return self
end

--- 获取指定序号的行为/行为组
---@param index integer 序号
---@return YcAction | YcActionGroup | nil 行为/行为组/空
function YcActionGroup:get(index)
  return self._actions[index]
end

--- 设置指定序号的行为/行为组
---@param action YcAction | YcActionGroup
---@param index integer | nil 序号。默认第一个
---@return YcActionGroup 行为组
function YcActionGroup:set(action, index)
  index = index or 1
  ---@type YcAction | YcActionGroup
  local oldAction = self._actions[index] -- 老行动
  if oldAction and oldAction == self._currentAction and not oldAction._isPaused then -- 如果老行动是当前在执行的行动
    oldAction:stop() -- 停止老行动
    if action then
      action:start() -- 开始新行动
    end
  end
  self._actions[index] = action
  return self
end

--- 设置所属行为组
---@param group YcActionGroup 所属行为组
---@return YcActionGroup 行为组
function YcActionGroup:setGroup(group)
  self._group = group
  return self
end

--- 尝试新增一个行为/行为组
---@param array YcArray<YcAction | YcActionGroup> 行为/行为组数组
---@param action YcAction | YcActionGroup 行为/行为组
---@param group YcActionGroup 行为组
function YcActionGroup._tryAddAction(array, action, group)
  if action.setGroup then -- 如果有setGroup方法，我就认为这是一个action或actionGroup
    action:setGroup(group)
    array:push(action)
  end
end
