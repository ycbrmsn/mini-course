--- 真实任务类 v1.0.0
--- created by 莫小仙 on 2023-11-12
---@class YcRealTask 真实任务
---@field task YcTask 任务
---@field objectives YcArray<YcObjective> 任务目标信息
---@field querying boolean 任务是否正在查询中
---@field delivering boolean 任务是否正在交付中
---@field finish boolean 任务是否结束/关闭
---@field complete boolean 任务是否完成，如果不为空，则用来判断任务是否完成，常用于特殊类任务，通过手动设置是否完成
YcRealTask = {
  TYPE = 'YC_REAL_TASK'
}

--- 是否是一个任务对象
---@param o any 判断对象
---@return boolean 是否是
function YcRealTask.isRealTask(o)
  return type(o) == 'table' and o.TYPE == YcRealTask.TYPE
end

--- 实例化一个真实的任务
---@param playerid integer 玩家id/迷你号
---@param task YcTask 任务对象
---@return YcRealTask 真实任务对象
function YcRealTask:new(playerid, task)
  local o = {
    task = task,
    querying = false,
    delivering = false,
    finish = false
  }
  if task.objectives then -- 如果有任务目标（特殊任务可能没有任务目标，如送信任务）
    -- 遍历补全任务目标信息
    ---@param item YcObjective
    o.objectives = task.objectives:map(function(item)
      return item:copyAndInit(playerid)
    end)
  end
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 设置任务是否正在查询中
---@param isActive boolean 是否正在查询
---@return YcRealTask
function YcRealTask:setQuerying(isActive)
  self.querying = isActive
  return self
end

--- 设置任务是否正在交付中
---@param isActive boolean 是否正在交付
---@return YcRealTask
function YcRealTask:setDelivering(isActive)
  self.delivering = isActive
  return self
end

--- 设置任务临时状态
---@param category 'querying' | 'delivering' 临时状态分类
---@param isActive boolean 临时状态是否激活
---@return boolean 是否设置成功
function YcRealTask:setState(category, isActive)
  if category == 'querying' or category == 'delivering' then
    self[category] = isActive
    return true
  end
  return false
end

--- 重置任务临时状态
---@return YcRealTask
function YcRealTask:resetState()
  self.querying = false
  self.delivering = false
  return self
end

--- 任务是否正在查询中
---@return boolean 是否正在查询
function YcRealTask:isQuerying()
  return self.querying
end

--- 任务是否正在交付中
---@return boolean 是否正在交付
function YcRealTask:isDelivering()
  return self.delivering
end

--- 任务是否完成
---@param playerid integer 玩家id/迷你号
---@return boolean 是否完成
function YcRealTask:isComplete(playerid)
  if type(self.complete) == 'boolean' then -- 有complete属性表示该任务是手动设置完成状态，如一些自定义任务（送信后回报）
    return self.complete
  elseif not self.objectives then -- 没有任务目标
    return true -- 默认完成
  else -- 其他情况，检查任务目标数据
    ---@param item YcObjective
    return self.objectives:every(function(item)
      return item:isAchieved(playerid)
    end)
  end
end

--- 手动设置任务完成状态
---@param isComplete boolean 是否完成
---@return YcRealTask
function YcRealTask:setComplete(isComplete)
  self.complete = isComplete
  return self
end

--- 任务是否已经结束（关闭）
---@return boolean 是否结束
function YcRealTask:isFinish()
  return self.finish
end

--- 设置任务已结束（关闭）
---@return YcRealTask
function YcRealTask:setFinish()
  self.finish = true
  return self
end

--- 自定义表的输出内容
---@return string 输出内容
function YcRealTask:__tostring()
  return YcStringHelper.concat('{TYPE=', self.TYPE, ',id=', self.task.id, ',name=', self.task.name, '}')
end
