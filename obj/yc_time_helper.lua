--[[
  时间工具类 v1.1.0
  create by 莫小仙 on 2022-05-22
]]
YcTimeHelper = {
  globalIndex = 0, -- 全局计数器，主要用于默认类型t
  frame = 0, -- 帧数
  frameInfo = {}, -- 帧存储信息
  afterTimeTaskInfo = {}, -- frame -> { { f -> f, t -> t }, { f -> f, t -> t }, ... }
  afterTimeOnceTaskInfo = {} -- frame -> { t -> f, t -> f, ... }
}

-- 获取下一个序数
function YcTimeHelper.getNextGlobalIndex ()
  YcTimeHelper.globalIndex = YcTimeHelper.globalIndex + 1
  return YcTimeHelper.globalIndex
end

-- 获取帧数
function YcTimeHelper.getFrame ()
  return YcTimeHelper.frame
end

-- 帧数递增
function YcTimeHelper.addFrame ()
  if YcTimeHelper.frameInfo[YcTimeHelper.frame] then -- 如果上一帧有记录
    YcTimeHelper.frameInfo[YcTimeHelper.frame] = nil -- 清除历史数据
  end
  YcTimeHelper.frame = YcTimeHelper.frame + 1
end

-- 获取当前帧信息
function YcTimeHelper.getFrameInfo (key)
  if not YcTimeHelper.frameInfo[YcTimeHelper.frame] then -- 如果当前帧没有任何信息
    return nil
  end
  return YcTimeHelper.frameInfo[YcTimeHelper.frame][key]
end

-- 设置当前帧信息
function YcTimeHelper.setFrameInfo (key, value)
  if not YcTimeHelper.frameInfo[YcTimeHelper.frame] then -- 如果当前帧没有任何信息
    YcTimeHelper.frameInfo[YcTimeHelper.frame] = {}
  end
  YcTimeHelper.frameInfo[YcTimeHelper.frame][key] = value
end

-- 添加任务
function YcTimeHelper.addAfterTimeTask (f, frame, t)
  local tasks = YcTimeHelper.afterTimeTaskInfo[frame]
  if not tasks then -- 没找到任何任务，则在该帧初始化一个任务数组
    tasks = {}
    YcTimeHelper.afterTimeTaskInfo[frame] = tasks
  end
  table.insert(tasks, { f = f, t = t }) -- 添加任务
end

-- 删除任务
function YcTimeHelper.delAfterTimeTasks (t, frame)
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
      YcTimeHelper.delAfterTimeTasks(t, k)
    end
  else -- 没有参数，则不操作
    -- do nothing
  end
end

-- 运行任务
function YcTimeHelper.runAfterTimeTasks ()
  local frame = YcTimeHelper.frame
  local tasks = YcTimeHelper.afterTimeTaskInfo[frame]
  if tasks then -- 任务数组存在
    for i, task in ipairs(tasks) do -- 循环任务数组
      if task then -- 任务不为nil
        task.f()
      end
    end
    YcTimeHelper.delAfterTimeTasks(nil, frame) -- 清除该帧所有任务
  end
end

-- 生成任务
function YcTimeHelper.newAfterTimeTask (f, seconds, t)
  if type(f) ~= 'function' then -- 如果f不是函数，则不创建
    return
  end
  seconds = seconds or 1 -- 默认为1秒后
  local frame = math.ceil(seconds * 20) -- 秒数转换为帧数
  frame = frame + YcTimeHelper.frame -- 实际帧数
  local t = t or YcTimeHelper.getNextGlobalIndex() -- 任务类型默认为一个全局序数
  YcTimeHelper.addAfterTimeTask(f, frame, t)
  return t
end

-- 添加任务
function YcTimeHelper.addAfterTimeOnceTask (f, frame, t)
  local taskMap = YcTimeHelper.afterTimeOnceTaskInfo[frame]
  if not taskMap then -- 该帧对应任务映射不存在
    taskMap = {}
    YcTimeHelper.afterTimeOnceTaskInfo[frame] = taskMap
  end
  taskMap[t] = f -- 设置任务映射
end

-- 删除任务
function YcTimeHelper.delAfterTimeOnceTasks (t, frame)
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

-- 运行任务
function YcTimeHelper.runAfterTimeOnceTasks ()
  local frame = YcTimeHelper.frame
  local taskMap = YcTimeHelper.afterTimeOnceTaskInfo[frame]
  if taskMap then -- 找到任务映射
    for t, f in pairs(taskMap) do
      f()
    end
    YcTimeHelper.delAfterTimeOnceTasks(nil, frame) -- 删除任务映射
  end
end

-- 生成任务
function YcTimeHelper.newAfterTimeOnceTask (f, seconds, t)
  if type(f) ~= 'function' then -- 如果f不是函数，则不创建
    return
  end
  seconds = seconds or 1 -- 默认为1秒后
  local frame = math.ceil(seconds * 20) -- 秒数转换为帧数
  frame = frame + YcTimeHelper.frame -- 实际帧数
  local t = t or 'default' -- 任务类型默认为default
  YcTimeHelper.delAfterTimeOnceTasks(t, frame) -- 清空还未执行的同类型任务
  YcTimeHelper.addAfterTimeOnceTask(f, frame, t)
  return t
end

-- 游戏运行时函数
local runGame = function ()
  YcTimeHelper.addFrame() -- 帧数递增
  YcTimeHelper.runAfterTimeTasks() -- 运行当前帧对应任务
  YcTimeHelper.runAfterTimeOnceTasks() -- 运行当前帧对应任务
end

ScriptSupportEvent:registerEvent([=[Game.Run]=], runGame) -- 游戏运行时注册事件
