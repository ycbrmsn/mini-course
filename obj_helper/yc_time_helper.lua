--- 时间工具类 v1.4.4
--- created by 莫小仙 on 2022-05-22
--- last modified on 2024-01-02
YcTimeHelper = {
  globalIndex = 0, -- 全局计数器，主要用于默认类型t
  frame = 0, -- 帧数
  frameInfo = {}, -- 帧存储信息
  afterTimeTaskInfo = {}, -- { [frame] = { { f = f, t = t }, ... } }
  afterTimeOnceTaskInfo = {}, -- { [frame] = { [t] = f } }
  canPerformTaskInfo = {}, -- { [t] = frame }
  --[[
    从效率方面考虑，从两个纬度保存相同信息
    {
      t = { [t] = { f = f, t = t, frame = frame, frames = frames } },
      frame = { [frame] = { { f = f, t = t, frame = frame, frames = frames }, ... }
    }
  ]]
  intervalTaskInfo = {
    t = {},
    frame = {}
  },
  continueTaskInfo = {} -- { { f = f, t = t, frames = frames }, ... }
}

--- 获取下一个序数
function YcTimeHelper._getNextGlobalIndex()
  YcTimeHelper.globalIndex = YcTimeHelper.globalIndex + 1
  return YcTimeHelper.globalIndex
end

--- 获取帧数
function YcTimeHelper.getFrame()
  return YcTimeHelper.frame
end

--- 帧数递增
---@return nil
function YcTimeHelper._addFrame()
  if YcTimeHelper.frameInfo[YcTimeHelper.frame] then -- 如果上一帧有记录
    YcTimeHelper.frameInfo[YcTimeHelper.frame] = nil -- 清除历史数据
  end
  YcTimeHelper.frame = YcTimeHelper.frame + 1
end

--- 获取当前帧指定键的信息
---@param key string 键
---@return table | nil 信息，nil表示信息不存在
function YcTimeHelper.getFrameInfo(key)
  if not YcTimeHelper.frameInfo[YcTimeHelper.frame] then -- 如果当前帧没有任何信息
    return nil
  end
  return YcTimeHelper.frameInfo[YcTimeHelper.frame][key]
end

--- 设置当前帧信息
---@param key string 键
---@param value table 信息
---@return nil
function YcTimeHelper.setFrameInfo(key, value)
  if not YcTimeHelper.frameInfo[YcTimeHelper.frame] then -- 如果当前帧没有任何信息
    YcTimeHelper.frameInfo[YcTimeHelper.frame] = {}
  end
  YcTimeHelper.frameInfo[YcTimeHelper.frame][key] = value
end

------- 几秒后执行任务 -------

--- 添加任务
--- 框架内调用
---@param f function 执行函数
---@param frame integer 帧数
---@param t string 类型
---@return nil
function YcTimeHelper._addAfterTimeTask(f, frame, t)
  local tasks = YcTimeHelper.afterTimeTaskInfo[frame]
  if not tasks then -- 没找到任何任务，则在该帧初始化一个任务数组
    tasks = {}
    YcTimeHelper.afterTimeTaskInfo[frame] = tasks
  end
  table.insert(tasks, {
    f = f,
    t = t
  }) -- 添加任务
end

--- 删除任务。t和frame不同同时不存在。
--- 供使用方法
---@param t string | number | nil 任务类型，nil表示删除指定帧数的所有任务
---@param frame integer | nil 帧数，nil表示删除指定类型的所有任务
---@return nil
function YcTimeHelper.delAfterTimeTask(t, frame)
  if not t and frame then -- 没有指定类型而有帧数，表示删除该帧的所有任务
    YcTimeHelper.afterTimeTaskInfo[frame] = nil
  elseif t and frame then -- 同时指定了类型与帧，表示删除该帧下的特定类型任务
    local tasks = YcTimeHelper.afterTimeTaskInfo[frame]
    if tasks then -- 该帧有任务数组
      for i = #tasks, 1, -1 do -- 倒序遍历任务
        if tasks[i] and tasks[i].t == t then -- 类型相同
          YcTimeHelper.afterTimeTaskInfo[frame][i] = nil -- 删除任务
        end
      end
    end
  elseif t and not frame then -- 有类型而没有指定帧，表示删除该类型的所有任务
    for k, tasks in pairs(YcTimeHelper.afterTimeTaskInfo) do -- 遍历所有帧信息
      YcTimeHelper.delAfterTimeTask(t, k)
    end
  else -- 没有参数，则不操作
    -- do nothing
  end
end

--- 运行任务
--- 框架内调用
---@return nil
function YcTimeHelper._runAfterTimeTasks()
  local frame = YcTimeHelper.frame
  local tasks = YcTimeHelper.afterTimeTaskInfo[frame]
  if tasks then -- 任务数组存在
    for i, task in ipairs(tasks) do -- 循环任务数组
      if task then -- 任务不为nil
        YcLogHelper.try(task.f)
      end
    end
    YcTimeHelper.delAfterTimeTask(nil, frame) -- 清除该帧所有任务
  end
end

--- 生成任务。用于几秒后执行函数
--- 供使用方法
---@param f function 执行函数
---@param seconds number | nil 延迟秒数。默认为1秒
---@param t string | number | nil 类型，nil则是自动生成一个数字类型
---@return string | number 任务类型。删除任务时可能会用到
---@return integer 执行时的帧数
function YcTimeHelper.newAfterTimeTask(f, seconds, t)
  if type(f) ~= 'function' then -- 如果f不是函数，则不创建
    return
  end
  seconds = seconds or 1 -- 默认为1秒后
  local frame = math.ceil(seconds * 20) -- 秒数转换为帧数
  frame = frame + YcTimeHelper.frame -- 实际帧数
  local t = t or YcTimeHelper._getNextGlobalIndex() -- 任务类型默认为一个全局序数
  YcTimeHelper._addAfterTimeTask(f, frame, t)
  return t, frame
end
------- end -------

------- 几秒后执行一次任务，会清除掉之前还未执行的同种任务 -------

--- 添加任务
--- 框架内调用
---@param f function 执行函数
---@param frame integer 延迟帧数
---@param t string | number 任务类型
---@return nil
function YcTimeHelper._addAfterTimeOnceTask(f, frame, t)
  local taskMap = YcTimeHelper.afterTimeOnceTaskInfo[frame]
  if not taskMap then -- 该帧对应任务映射不存在
    taskMap = {}
    YcTimeHelper.afterTimeOnceTaskInfo[frame] = taskMap
  end
  taskMap[t] = f -- 设置任务映射
end

--- 删除任务。t和frame不同同时不存在。
--- 供使用方法
---@param t string | number | nil 任务类型，nil表示删除指定帧数的所有任务
---@param frame integer | nil 帧数，nil表示删除指定类型的所有任务
---@return nil
function YcTimeHelper.delAfterTimeOnceTask(t, frame)
  if not t and frame then -- 没有类型而有帧数，则删除该帧下的所有任务
    YcTimeHelper.afterTimeOnceTaskInfo[frame] = nil
  elseif t and frame then -- 有类型有帧数，则删除将来最后一次执行时间与当前时间之间的相同类型的任务
    for i = frame, YcTimeHelper.frame, -1 do -- 遍历时间
      local taskMap = YcTimeHelper.afterTimeOnceTaskInfo[i] -- 任务映射
      if taskMap and taskMap[t] then -- 任务映射存在 且 有该类型的任务
        taskMap[t] = nil -- 删除任务
      end
    end
  elseif t and not frame then -- 有类型而没有帧数，表示删除该类型的所有任务
    for k, taskMap in pairs(YcTimeHelper.afterTimeOnceTaskInfo) do -- 遍历所有帧信息
      if taskMap and taskMap[t] then -- 任务映射存在 且 有该类型的任务
        taskMap[t] = nil -- 删除任务
      end
    end
  end
end

--- 运行任务
--- 框架内调用
---@return nil
function YcTimeHelper._runAfterTimeOnceTasks()
  local frame = YcTimeHelper.frame
  local taskMap = YcTimeHelper.afterTimeOnceTaskInfo[frame]
  if taskMap then -- 找到任务映射
    for t, f in pairs(taskMap) do
      YcLogHelper.try(f)
    end
    YcTimeHelper.delAfterTimeOnceTask(nil, frame) -- 删除任务映射
  end
end

--- 生成任务。用于几秒后执行一次。会删除掉在这个执行时间之前的还没有执行的同种任务
--- 供使用方法
---@param f function 执行函数
---@param seconds number 延迟秒数
---@param t string | number | nil 任务类型，默认为default
---@return string | number 任务类型
---@return integer 执行时的帧数
function YcTimeHelper.newAfterTimeOnceTask(f, seconds, t)
  if type(f) ~= 'function' then -- 如果f不是函数，则不创建
    return
  end
  seconds = seconds or 1 -- 默认为1秒后
  local frame = math.ceil(seconds * 20) -- 秒数转换为帧数
  frame = frame + YcTimeHelper.frame -- 实际帧数
  local t = t or 'default' -- 任务类型默认为default
  YcTimeHelper.delAfterTimeOnceTask(t, frame) -- 清空还未执行的同类型任务
  YcTimeHelper._addAfterTimeOnceTask(f, frame, t)
  return t, frame
end
------- end -------

------- 与上次的同种任务执行时间间隔超过多长时，本次才会执行任务 -------

--- 生成任务
--- 供使用方法
---@param f function 执行函数
---@param seconds number 间隔秒数
---@param t string | number | nil 任务类型，默认为default
---@return integer 还剩多少时间（帧数）将会执行
function YcTimeHelper.newCanPerformTask(f, seconds, t)
  if type(f) ~= 'function' then -- 如果f不是函数，则不进行后续操作
    return -1
  end
  seconds = seconds or 1
  t = t or 'default'
  local prevFrame = YcTimeHelper.canPerformTaskInfo[t] -- 最后执行的帧数
  if not prevFrame then -- 表示没有执行过
    YcTimeHelper.canPerformTaskInfo[t] = YcTimeHelper.frame -- 记录执行时间
    YcLogHelper.try(f)
    return 0
  else -- 表示之前执行过
    local remainingTime = prevFrame + math.ceil(seconds * 20) - YcTimeHelper.frame -- 剩余间隔时间
    if remainingTime <= 0 then -- 表示间隔时间已经足够了
      YcTimeHelper.canPerformTaskInfo[t] = YcTimeHelper.frame -- 记录执行时间
      YcLogHelper.try(f)
      return 0
    else -- 间隔时间不够
      return remainingTime
    end
  end
end

--- 删除任务执行记录
--- 供使用方法
---@param t string | number | nil 任务类型，默认为default
---@return nil
function YcTimeHelper.delCanPerformTaskRecord(t)
  t = t or 'default'
  if YcTimeHelper.canPerformTaskInfo[t] then -- 如果该类型有执行记录
    YcTimeHelper.canPerformTaskInfo[t] = nil -- 清除记录
  end
end
------- end -------

------- 定时重复执行任务，满足条件后结束 -------

--- 添加任务
--- 框架内调用
---@param f function 执行函数
---@param frames integer 间隔帧数
---@param t string | number 任务类型
---@return nil
function YcTimeHelper._addIntervalTask(f, frames, t)
  local frame = YcTimeHelper.frame + frames -- 下一次执行时间
  local info = {
    f = f,
    t = t,
    frame = frame,
    frames = frames
  }
  YcTimeHelper.intervalTaskInfo.t[t] = info -- 设置类型信息
  -- 设置帧信息
  if not YcTimeHelper.intervalTaskInfo.frame[frame] then -- 对应帧信息数组不存在
    YcTimeHelper.intervalTaskInfo.frame[frame] = {info}
  else -- 信息数组已存在
    table.insert(YcTimeHelper.intervalTaskInfo.frame[frame], info)
  end
end

--- 删除任务
--- 供使用方法
---@param t string | number | nil 任务类型，nil表示删除指定帧数的所有任务
---@param frame integer | nil 帧数，nil表示删除指定类型的所有任务
---@return boolean 是否删除成功
function YcTimeHelper.delIntervalTask(t, frame)
  if t then -- 通过类型删除，会删除frame数组中对应信息
    local info = YcTimeHelper.intervalTaskInfo.t[t]
    if info then -- 存在该类型任务
      -- 删除frame对应信息
      local arr = YcTimeHelper.intervalTaskInfo.frame[info.frame]
      if arr then -- 信息数组存在
        for i = #arr, 1, -1 do -- 倒序遍历
          if arr[i] and arr[i].t == info.t then -- 类型相同
            table.remove(arr, i) -- 删除数组中信息
            break -- 跳出循环，因为同一帧不会有两个类型相同的信息
          end
        end
      end
      -- 删除t对应信息
      YcTimeHelper.intervalTaskInfo.t[t] = nil
      return true
    else -- 不存在
      -- do nothing
    end
  elseif frame then -- 通过frame删除
    local arr = YcTimeHelper.intervalTaskInfo.frame[frame]
    if arr then -- 信息数组存在
      for i = #arr, 1, -1 do -- 倒序遍历
        local info = arr[i]
        if info then -- 存在信息
          table.remove(arr, i) -- 删除数组中信息
          YcTimeHelper.intervalTaskInfo.t[info.t] = nil -- 删除t对应信息
          break
        end
      end
      return true
    else -- 不存在，表示没有信息
      -- do nothing
    end
  end
  return false
end

--- 运行任务
--- 框架内调用
---@return nil
function YcTimeHelper._runIntervalTasks()
  local frame = YcTimeHelper.frame
  local arr = YcTimeHelper.intervalTaskInfo.frame[frame]
  if arr then -- 找到任务信息数组
    local nextTimeInfos = {} -- 下一次还要执行的任务
    for i, info in ipairs(arr) do
      YcLogHelper.try(function()
        local result = info.f()
        if result then -- 满足条件
          -- do nothing
        else -- 不满足条件
          table.insert(nextTimeInfos, info) -- 记录下这些任务
        end
      end)
    end
    YcTimeHelper.delIntervalTask(nil, frame) -- 删除该帧的所有任务映射
    -- 添加还需要下次执行的任务
    for i, info in ipairs(nextTimeInfos) do
      YcTimeHelper._addIntervalTask(info.f, info.frames, info.t)
    end
  end
end

--- 生成任务。用于定时重复执行任务，满足条件后结束
--- 供使用方法
---@param f function 执行函数
---@param seconds number 间隔秒数
---@param t string | number | nil 任务类型，默认为default
---@return nil
function YcTimeHelper.newIntervalTask(f, seconds, t)
  if type(f) ~= 'function' then -- 如果f不是函数，则不进行后续操作
    return
  end
  seconds = seconds or 1
  t = t or 'default'
  local info = YcTimeHelper.intervalTaskInfo.t[t] -- 定时任务信息
  if info then -- 执行过该定时任务
    if info.frame > YcTimeHelper.frame then -- 时间在当前时间之后，则更新原任务
      info.f = f -- 更新执行函数
      info.frames = math.ceil(seconds * 20) -- 更新时间间隔
    elseif info.frame == YcTimeHelper.frame then -- 时间为当前时间，表示马上要执行了
      YcTimeHelper.delIntervalTask(t) -- 删除定时任务信息，使下一行可以重用此函数
      YcTimeHelper.newIntervalTask(f, seconds, t) -- 重新调用
    else -- 时间在之前
      -- 计算帧数差值。
      -- info.frames可能与seconds对应帧数不同，应当以seconds对应帧数为准
      local frameDiff = YcTimeHelper.frame - info.frame - math.ceil(seconds * 20) -- 帧数差值
      if frameDiff >= 0 then -- 表示时间间隔足够
        YcTimeHelper.delIntervalTask(t) -- 删除定时任务信息，使下一行可以重用此函数
        YcTimeHelper.newIntervalTask(f, seconds, t) -- 重新调用
      else -- 时间间隔还不够，则更新任务
        YcTimeHelper.delIntervalTask(t) -- 删除定时任务信息
        YcTimeHelper._addIntervalTask(f, frameDiff, t) -- 添加任务
      end
    end
  else -- 没有执行过该定时任务
    local result = f() -- 执行并获取返回值
    if result then -- 返回值为真，表示满足条件，则没有后续操作
      -- do nothing
    else -- 不满足条件，则添加任务，等待下次执行
      YcTimeHelper._addIntervalTask(f, math.ceil(seconds * 20), t)
    end
  end
end
------- end -------

------- 持续执行多长时间 -------
--- 添加任务
--- 框架内调用
---@param f function 执行函数
---@param frames integer 持续执行多久（帧数）
---@param t string | number 任务类型
function YcTimeHelper._addContinueTask(f, frames, t)
  local task
  for i, info in ipairs(YcTimeHelper.continueTaskInfo) do -- 遍历所有持续任务
    if info.t == t then -- 找到相同类型
      task = info
      break
    end
  end
  if task then -- 该类型任务已存在，则更新任务
    task.f = f
    task.frames = frames
  else -- 该任务类型不存在，则添加任务
    task = {
      f = f,
      t = t,
      frames = frames
    }
    table.insert(YcTimeHelper.continueTaskInfo, task)
  end
end

--- 删除任务
--- 供使用方法
---@param t string | number | nil 任务类型，默认为default
---@return boolean 是否删除成功
function YcTimeHelper.delContinueTask(t)
  t = t or 'default'
  for i = #YcTimeHelper.continueTaskInfo, 1, -1 do -- 倒序遍历所有任务
    local info = YcTimeHelper.continueTaskInfo[i]
    if info and info.t == t then -- 类型相同
      table.remove(YcTimeHelper.continueTaskInfo, i) -- 删除该任务
      return true -- 返回结果，因为同类型任务只会有一个
    end
  end
  return false
end

--- 运行任务
--- 框架内调用
---@return nil
function YcTimeHelper._runContinueTasks()
  -- 顺序执行
  for i, info in ipairs(YcTimeHelper.continueTaskInfo) do -- 遍历所有任务
    if info.frames > 0 then -- 表示还有剩余时间
      info.frames = info.frames - 1 -- 剩余帧数减1
    end
    YcLogHelper.try(function()
      info.f(info.frames) -- 执行函数
    end)
  end
  -- 倒序删除
  for i = #YcTimeHelper.continueTaskInfo, 1, -1 do
    local info = YcTimeHelper.continueTaskInfo[i]
    if info and info.frames == 0 then -- 没有剩余时间，则删除掉
      table.remove(YcTimeHelper.continueTaskInfo, i) -- 删除该任务
    end
  end
end

--- 生成任务。用于持续执行任务多长时间
--- 供使用方法
---@param f function 执行函数
---@param seconds number | nil 持续执行多久（帧数），默认为一直执行
---@param t string | number | nil 任务类型默认为default
---@return nil
function YcTimeHelper.newContinueTask(f, seconds, t)
  if type(f) ~= 'function' then -- 如果f不是函数，则不进行后续操作
    return
  end
  seconds = seconds or -1 -- 所有负数时间表示一直执行
  t = t or 'default'
  local frames = seconds < 0 and -1 or math.ceil(seconds * 20) -- 持续时间（帧数）
  YcTimeHelper._addContinueTask(f, frames, t) -- 添加任务
end
------- end -------

-- 游戏运行时函数
local runGame = function()
  YcTimeHelper._addFrame() -- 帧数递增
  YcTimeHelper._runAfterTimeTasks() -- 运行当前帧对应的 一定时间后执行的任务
  YcTimeHelper._runAfterTimeOnceTasks() -- 运行当前帧对应的 一定时间后才会执行的任务
  YcTimeHelper._runIntervalTasks() -- 运行当前帧对应的 定时任务
  YcTimeHelper._runContinueTasks() -- 运行当前帧对应的 持续执行任务
end

ScriptSupportEvent:registerEvent([=[Game.Run]=], runGame) -- 游戏运行时注册事件
