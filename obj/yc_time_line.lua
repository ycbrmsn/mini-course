--- 时间线 v1.0.0
--- created by 莫小仙 on 2024-02-29
---@class YcTimeLine : YcTable
---@field _jobs YcArray<YcTimeLineJobInfo> 任务目标集合
---@field _index number 该执行的任务序号
---@field _t string | number | nil 下一个任务类型。nil表示没有下一个任务了
---@field _f nil | fun(): void 时间线结束时执行的函数。
YcTimeLine = YcTable:new({
  TYPE = 'YC_TIME_LINE'
})

---@class YcTimeLineJobInfo 任务信息
---@field f fun(): void 执行函数
---@field seconds number 与下一个任务执行相差几秒
YcTimeLineJobInfo = {}

--- 是否是一个时间线对象
---@param o any 判断对象
---@return boolean 是否是时间线对象
function YcTimeLine.isTimeLine(o)
  return type(o) == 'table' and o.TYPE == YcTimeLine.TYPE
end

--- 实例化时间线
---@return YcTimeLine 时间线对象
function YcTimeLine:new()
  local o = {
    _jobs = YcArray:new(),
    _index = 1
  }
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 新增任务
---@param f fun(): void 执行函数
---@param seconds number | nil 上一个任务结束后，等待几秒再执行当前任务。nil表示立即执行
function YcTimeLine:add(f, seconds)
  self._jobs:push({
    f = f,
    seconds = seconds
  })
  return self
end

--- 时间线结束后执行
---@param f fun(): void 执行函数
---@return YcTimeLine 时间线对象
function YcTimeLine:onComplete(f)
  self._f = f
  return self
end

--- 执行时间线中的任务
---@return YcTimeLine 时间线对象
function YcTimeLine:run()
  if self._index <= self._jobs:length() then
    ---@type YcTimeLineJobInfo
    local job = self._jobs[self._index] -- 当前任务
    if job.seconds and job.seconds > 0 then -- 如果设置了秒数
      self._t = YcTimeHelper.newAfterTimeTask(function ()
        self:_run(job)
      end, job.seconds, self._t)
    else -- 如果没有设置秒数
      -- 立即执行
      self:_run(job)
    end
  else
    self._t = nil
    if type(self._f) == 'function' then
      self._f()
    end
  end
  return self
end

--- 执行一次时间线中的任务
---@param job YcTimeLineJobInfo 任务
function YcTimeLine:_run(job)
  job.f()
  self._index = self._index + 1
  self:run()
end

--- 停止时间线
function YcTimeLine:stop()
  if self._t then
    YcTimeHelper.delAfterTimeTask(self._t)
  end
end
