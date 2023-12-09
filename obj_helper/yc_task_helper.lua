--- 任务工具类 v1.0.0
--- created by 莫小仙 on 2023-11-12
---@class YcTaskHelper
---@field tasks "{ [playerid: integer]: YcPlayerTaskCollection }" 所有玩家的任务集合
---@field needItemTasks YcArray<YcTask> 需要任务存在道具（任务书）的任务数组
---@field currentId number 当前任务id，用于自动生成任务id
YcTaskHelper = {
  tasks = {},
  needItemTasks = YcArray:new(),
  currentId = 1000
}

---@alias YcPlayerTaskCollection "{ [taskid: integer]: YcRealTask | boolean }" 任务集合
---@alias YcPlayerRealTaskCollection "{ [taskid: integer]: YcRealTask }" 真实任务集合
---@alias YcRealTaskState "0" | "1" | "2" | "3" 任务状态(0该任务不存在1未完成2已完成3已结束)

--- 构造一个任务。如果需要任务书，则加入特定集合
---@param o YcTaskParam 任务参数
---@return YcTask 任务对象
function YcTaskHelper.newTask(o)
  if not o.id then -- 如果没有设置id
    o.id = YcTaskHelper.getNextTaskId()
  end
  local task = YcTask:new(o)
  if task.itemid then -- 如果需要任务书
    YcTaskHelper.registerNeedItemTask(task) -- 注册当前任务
  end
  return task
end

--- 构造一个真实任务
---@param playerid integer 玩家id/迷你号
---@param task YcTask 任务对象
---@return YcRealTask 真实任务对象
function YcTaskHelper.newRealTask(playerid, task)
  return YcRealTask:new(playerid, task)
end

--- 获取（自动生成）下一个任务id
---@return integer 任务id
function YcTaskHelper.getNextTaskId()
  YcTaskHelper.currentId = YcTaskHelper.currentId + 1 -- 当前任务id自增
  return YcTaskHelper.currentId
end

--- 获取玩家的指定任务
---@param playerid integer 玩家id/迷你号
---@param taskid integer 任务id
---@return YcRealTask | boolean | nil 真实任务。为boolean时表示这是一个虚拟任务，接受即完成/失败；为nil表示没有接受该任务
function YcTaskHelper.getTask(playerid, taskid)
  local tasks = YcTaskHelper.getTasks(playerid) -- 玩家任务集合
  return tasks[taskid]
end

--- 获取玩家已领取的所有任务
---@param playerid integer 玩家id/迷你号
---@return YcPlayerTaskCollection 任务集合
function YcTaskHelper.getTasks(playerid)
  if not YcTaskHelper.tasks[playerid] then -- 如果玩家的任务集合不存在
    YcTaskHelper.tasks[playerid] = {} -- 创建一个空的集合
  end
  return YcTaskHelper.tasks[playerid]
end

--- 判断玩家是否有该任务
---@param playerid integer 玩家id/迷你号
---@param taskid integer 任务id
---@return boolean 是否有该任务
function YcTaskHelper.hasTask(playerid, taskid)
  local task = YcTaskHelper.getTask(playerid, taskid)
  -- LogHelper.debug(tasks)
  -- if task then
  --   -- LogHelper.debug('has task: ', taskid)
  --   return true
  -- else
  --   -- LogHelper.debug('no task: ', taskid)
  --   return false
  -- end
  return task ~= nil
end

--- 获取玩家指定状态的真实任务集合。默认获取未结束的任务
---@param playerid integer 玩家id/迷你号
---@param state YcRealTaskState | nil 任务状态(0该任务不存在1未完成2已完成3已结束)
---@return YcPlayerRealTaskCollection 真实任务集合
function YcTaskHelper.getRealTasks(playerid, state)
  local tasks = {} -- 任务集合
  -- 遍历玩家的任务集合
  ---@param taskid integer 任务id
  ---@param task YcRealTask | boolean
  for taskid, task in pairs(YcTaskHelper.getTasks(playerid)) do
    if YcRealTask.isRealTask(task) then -- 如果是一个真实任务
      if state then -- 如果指定了任务状态
        local taskState = YcTaskHelper.getTaskState(playerid, taskid) -- 任务状态
        if state == taskState then -- 如果是指定的任务状态
          tasks[taskid] = task -- 将任务加入任务集合
        end
      elseif not task:isFinish() then -- 如果没有指定任务状态 并且 任务没有结束
        tasks[taskid] = task -- 将任务加入任务集合
      end
    end
  end
  return tasks
end

--- 新增玩家任务
---@param playerid integer 玩家id/迷你号
---@param taskid integer 任务id
---@param task YcTask 任务对象
---@return YcRealTask 真实任务
------------重载---------
---@overload fun(playerid: integer, taskid: integer) : nil -- 用于虚拟任务
---@overload fun(playerid: integer, task: YcTask) : YcRealTask -- 用于任务id自动生成
function YcTaskHelper.addTask(playerid, taskid, task)
  if type(taskid) == 'table' then -- 如果该参数是任务对象
    task = taskid -- 重新赋值task
    taskid = task.id -- 重新赋值taskid
  end
  local tasks = YcTaskHelper.getTasks(playerid) -- 玩家任务集合
  if task then -- 有任务对象
    local realTask = YcTaskHelper.newRealTask(playerid, task)
    tasks[taskid] = realTask -- 将任务加入任务集合
    return realTask
  else -- 反之，则是虚拟任务
    tasks[taskid] = true -- 将任务加入任务集合
  end
end

--- 尝试结束任务。已完成的任务才能结束
---@param playerid integer 玩家id/迷你号
---@param taskid integer 任务id
---@return boolean 任务是否已结束
function YcTaskHelper.tryFinishTask(playerid, taskid)
  local state = YcTaskHelper.getTaskState(playerid, taskid) -- 任务状态
  if state == 0 then -- 任务不存在
    return false
  elseif state == 1 then -- 未完成
    return false
  elseif state == 3 then -- 已结束
    return true
  else -- 已完成
    ---@type YcRealTask 真实任务（不存在任务state==0；虚拟任务的state==3）
    local task = YcTaskHelper.getTask(playerid, taskid)
    ---@param item YcObjective
    task.objectives:forEach(function(item)
      if item.category == 2 then -- 如果是需要交付道具的任务
        -- 遍历所有需要交付的道具，移除
        BackpackAPI.removeGridItemByItemID(playerid, item.itemid, item.total) -- 移除道具
      end
    end)
    -- 遍历所有任务奖励
    ---@param reward YcReward
    task.task.rewards:forEach(function(reward)
      if reward.category == 1 then -- 如果是奖励道具
        YcBackpackHelper.gainItem(playerid, reward.itemid, reward.num) -- 获取道具
      elseif reward.category == 2 then -- 如果是奖励经验
        local event = {
          eventobjid = playerid,
          num = reward.num
        }
        -- todo 触发事件不应该写在这里，应该是写在获得经验的函数中
        YcEventHelper.triggerEvent(YcEventHelper.CUSTOM_EVENT.PLAYER_GAIN_EXP, event) -- 触发玩家获得经验事件
      end
      if reward.f then -- 如果有回调
        reward.f(playerid) -- 执行回调函数
      end
    end)
    if task.itemid then -- 如果该任务需要任务书，则销毁任务书
      if YcBackpackHelper.hasItem(playerid, task.itemid, true) then -- 如果玩家身上有任务书
        BackpackAPI.removeGridItemByItemID(playerid, task.itemid, 1) -- 销毁1个
      end
    end
    task:setFinish() -- 设置任务已结束
    return true
  end
end

--- 获取玩家的任务状态
---@param playerid integer 玩家id/迷你号
---@param taskid integer 任务id
---@return YcRealTaskState 任务状态(0该任务不存在1未完成2已完成3已结束)
function YcTaskHelper.getTaskState(playerid, taskid)
  local task = YcTaskHelper.getTask(playerid, taskid)
  if task == nil then -- 任务不存在
    return 0
  elseif YcRealTask.isRealTask(task) then -- 真实任务
    if task:isFinish() then -- 已结束
      return 3
    elseif task:isComplete(playerid) then -- 已完成
      return 2
    else
      return 1
    end
  else -- 无真实任务，表示是一个虚拟任务。虚拟任务接受即完成。
    return 3 -- 已结束
  end
end

--- 玩家击败生物后对任务的影响
--- 可能会触发玩家击败任务生物事件
---@param playerid integer 玩家id/迷你号
---@param actorid integer 生物类型id
function YcTaskHelper.playerDefeatActor(playerid, actorid)
  local realTasks = YcTaskHelper.getRealTasks(playerid) -- 玩家的真实任务集合
  -- 遍历所有任务
  ---@param taskid integer 任务id
  ---@param realTask YcRealTask 真实任务对象
  for taskid, realTask in pairs(realTasks) do
    -- 遍历该任务所有目标
    ---@param objective YcObjective
    realTask.objectives:forEach(function(objective)
      if objective.category == 1 then -- 如果是击败任务
        if actorid == objective.actorid then -- 如果当前生物是需要击败的生物
          objective.num = objective.num + 1 -- 记录数量加1
          local isAchieved -- 任务目标是否是之前已经达到的
          local state = YcTaskHelper.getTaskState(playerid, taskid) -- 任务状态
          if objective.num <= objective.total then -- 如果未超过任务数量
            isAchieved = false
          else -- 已超过任务数量
            isAchieved = true
          end
          -- event为事件参数，包括玩家id/迷你号、生物类型、任务、任务状态
          local event = {
            eventobjid = playerid,
            isAchieved = isAchieved,
            objective = objective:clone(),
            realTask = realTask,
            state = state
          }
          YcEventHelper.triggerEvent(YcEventHelper.CUSTOM_EVENT.PLAYER_DEFEAT_TASK_ACTOR, event) -- 触发玩家击败任务生物事件（自定义事件）
        end
      end
    end)
  end
end

--- 玩家获得道具后对任务的影响
--- 可能会触发玩家获取任务道具事件
---@param playerid integer 玩家id/迷你号
---@param itemid integer 道具类型id
---@param itemnum integer 获得的任务道具的数量
function YcTaskHelper.playerAddItem(playerid, itemid, itemnum)
  local realTasks = YcTaskHelper.getRealTasks(playerid) -- 玩家的真实任务集合
  -- 遍历所有任务
  ---@param taskid integer 任务id
  ---@param task YcRealTask 真实任务对象
  for taskid, realTask in pairs(realTasks) do
    -- 遍历该任务所有目标
    ---@param objective YcObjective
    realTask.objectives:forEach(function(objective)
      if objective.category == 2 then -- 如果是交付任务
        -- 遍历所有需要交付的道具
        if itemid == objective.itemid then -- 如果当前道具需要交付
          local num = YcBackpackHelper.getItemNumAndGrids(playerid, itemid) -- 获取身上道具总数（不包括装备栏）
          -- LogHelper.debug('当前有', num)
          if not objective.num or objective.num ~= num then -- 当前数量发生变化时提示
            local isAchieved = false -- 任务目标是否是之前已经达到的
            objective.num = num -- 记录道具数量
            if num >= objective.total then -- 如果道具数量达到任务目标
              if not objective.enough then -- 之前道具不够(enough是此处新引入的一个标志属性)
                objective.enough = true -- 标记为足够
              else -- 如果之前已足够
                isAchieved = true
              end
            else -- 道具数量未达到目标
              objective.enough = false -- 标记为不足够
            end
            -- event为事件参数，包括玩家id/迷你号、获得的任务道具数量、任务目标、任务
            local event = {
              eventobjid = playerid,
              itemnum = itemnum,
              isAchieved = isAchieved,
              objective = objective:clone(),
              realTask = realTask
            }
            YcEventHelper.triggerEvent(YcEventHelper.CUSTOM_EVENT.PLAYER_ADD_TASK_ITEM, event) -- 触发玩家获得任务道具事件（自定义事件）
          end
        end
      end
    end)
  end
end

--- 玩家失去道具后对任务的影响
---@param playerid integer 玩家id/迷你号
---@param itemid integer 道具id
---@param itemnum integer 失去的任务道具的数量
function YcTaskHelper.playerLoseItem(playerid, itemid, itemnum)
  local realTasks = YcTaskHelper.getRealTasks(playerid) -- 玩家的真实任务集合
  -- 遍历所有任务
  ---@param realTask YcRealTask 真实任务对象
  for taskid, realTask in pairs(realTasks) do
    ---@param objective YcObjective
    realTask.objectives:map(function(objective)
      if objective.category == 2 then -- 如果是交付任务
        if itemid == objective.itemid then -- 如果当前道具是需要交付的道具
          local num = YcBackpackHelper.getItemNumAndGrids(playerid, itemid) -- 获取身上道具总数（不包括装备栏）
          objective.num = num -- 记录道具数量
          -- event为事件参数，包括玩家、任务目标、失去的任务道具数量、任务
          local event = {
            eventobjid = playerid,
            objective = objective:clone(),
            itemnum = itemnum,
            realTask = realTask
          }
          YcEventHelper.triggerEvent(YcEventHelper.CUSTOM_EVENT.PLAYER_LOSE_TASK_ITEM, event) -- 触发玩家失去任务道具事件（自定义事件）
        end
      end
    end)
  end
end

--- 注册需要任务存在道具（任务书）的任务
---@param task YcTask 任务
function YcTaskHelper.registerNeedItemTask(task)
  YcTaskHelper.needItemTasks:push(task)
end

-- 事件相关

local playerDefeatActor = function(event)
  local playerid = event.eventobjid -- 迷你号
  local toobjid = event.toobjid -- 被击败对象的id
  local actorid -- 生物类型id
  if ActorAPI.isPlayer(toobjid) then -- 击败了玩家
    actorid = -1 -- 规定玩家的actorid为-1
  else -- 击败了生物
    actorid = CreatureAPI.getActorID(toobjid) -- 设置生物类型id
  end
  YcTaskHelper.playerDefeatActor(playerid, actorid) -- 玩家击败生物后的一些处理
end
ScriptSupportEvent:registerEvent([=[Player.DefeatActor]=], playerDefeatActor) -- 玩家击败生物事件

local playerAddItem = function(event)
  local playerid = event.eventobjid -- 迷你号
  local itemid = event.itemid -- 道具类型
  local itemnum = event.itemnum -- 道具数量
  YcTaskHelper.playerAddItem(playerid, itemid, itemnum) -- 玩家新增道具后的处理
end
ScriptSupportEvent:registerEvent([=[Player.AddItem]=], playerAddItem) -- 玩家新增道具事件

local playerConsumeItem = function(event)
  local playerid = event.eventobjid -- 迷你号
  local itemid = event.itemid -- 道具类型
  local itemnum = event.itemnum -- 道具数量
  YcTaskHelper.playerLoseItem(playerid, itemid, itemnum) -- 玩家消耗道具后的处理
end
ScriptSupportEvent:registerEvent([=[Player.ConsumeItem]=], playerConsumeItem) -- 玩家消耗道具事件

local playerDiscardItem = function(event)
  local playerid = event.eventobjid -- 迷你号
  local itemid = event.itemid -- 道具类型
  local itemnum = event.itemnum -- 道具数量
  YcTaskHelper.playerLoseItem(playerid, itemid, itemnum) -- 玩家丢弃道具后的处理
end
ScriptSupportEvent:registerEvent([=[Player.DiscardItem]=], playerDiscardItem) -- 玩家丢弃道具事件
