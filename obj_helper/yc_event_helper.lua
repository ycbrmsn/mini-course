--- 事件工具类 v1.0.1
--- created by 莫小仙 on 2022-07-06
--- last modified on 2023-08-05
YcEventHelper = {
  func = {}, -- { [eventname] = { f1, f2, f3, ... } }
  alias = {}, -- { [eventAlias] = eventname }
  -- 内置自定义事件
  CUSTOM_EVENT = {
    PLAYER_GAIN_EXP = 'Player.GainExp', -- 玩家获得经验
    PLAYER_DEFEAT_TASK_ACTOR = 'Player.DefeatTaskActor', -- 玩家击败任务生物
    PLAYER_ADD_TASK_ITEM = 'Player.AddTaskItem', -- 玩家获得任务道具
    PLAYER_LOSE_TASK_ITEM = 'Player.LoseTaskItem', -- 玩家失去任务道具
    PLAYER_CHANGE_MOVEABLE = 'Player.ChangeMoveable' -- 玩家是否能够移动设置改变
  }
}

--- 通过字符串添加事件别名，参数格式为：别名=事件名&别名=事件名
--- 例如：playerEnterGame=Game.AnyPlayer.EnterGame&playerLeaveGame=Game.AnyPlayer.LeaveGame
---@param str string 别名事件名字符串。格式：别名=事件名&别名=事件名
---@return nil
function YcEventHelper.addAliasByStr(str)
  local arr = YcStringHelper.split(str, '&') -- 以&拆分字符串成数组
  for i, s in ipairs(arr) do -- 遍历每一组缩写
    local arr2 = YcStringHelper.split(s, '=') -- 以=拆分字符串成数组
    YcEventHelper.alias[arr2[1]] = arr2[2] -- 缩写=事件名
  end
end

--- 通过表添加事件别名，参数为：{ 别名 = 事件名 }
---@param map table 别名事件名键值对
---@return nil
function YcEventHelper.addAliasByTable(map)
  for k, v in pairs(map) do -- 遍历表中所有属性
    YcEventHelper.alias[k] = v -- 缩写=事件名
  end
end

--- 获取事件实际的名称
---@param eventname string 事件名称/别名
---@return string 事件名称
function YcEventHelper.getRealname(eventname)
  return YcEventHelper.alias[eventname] or eventname -- 找不到别名就取当前名字
end

--- 注册事件
---@param eventname string 事件名称
---@param f function 需要执行的函数
---@return nil
function YcEventHelper.registerEvent(eventname, f)
  eventname = YcEventHelper.getRealname(eventname) -- 事件原始名称
  if not YcEventHelper.func[eventname] then -- 如果该事件没有注册过
    YcEventHelper.func[eventname] = {f} -- 初始化一个新数组
  else -- 如果注册过
    table.insert(YcEventHelper.func[eventname], f) -- 向数组中添加一个元素
  end
end

--- 触发事件
--- 通常是触发自定义事件，不建议触发游戏API事件（如Player.AddItem），除非你确定没问题
---@param eventname string 事件名称
---@param event table | nil 事件参数
---@return nil
function YcEventHelper.triggerEvent(eventname, event)
  eventname = YcEventHelper.getRealname(eventname) -- 事件原始名称
  local fs = YcEventHelper.func[eventname] -- 获取事件数组
  if fs then -- 如果存在，则遍历执行
    for i, f in ipairs(fs) do
      -- 捕获执行，避免一个事件出错后导致后续事件无法执行
      YcLogHelper.try(function()
        f(event)
      end)
    end
  end
end

--- 注册要触发的游戏API事件，用于绑定对应的游戏API事件
---@param eventnames string[] 事件名数组
---@return nil
function YcEventHelper.registerGameAPIEvents(eventnames)
  for i, eventname in ipairs(eventnames) do -- 遍历所有事件名称
    -- 注册相应事件
    ScriptSupportEvent:registerEvent(eventname, function(event)
      YcEventHelper.triggerEvent(eventname, event)
    end)
  end
end

-- 初始化

-- 事件名，对应所有的游戏事件。如果游戏事件有所改变，则随之调整
local eventnames = {
-- 世界事件（4）
'Weather.Changed', 'Backpack.ItemTakeOut', 'Backpack.ItemPutIn', 'Backpack.ItemChange',
-- 游戏逻辑（13）
'Game.AnyPlayer.Defeat', 'Game.AnyPlayer.EnterGame', 'Game.AnyPlayer.LeaveGame', 'Game.AnyPlayer.ReadStage',
'Game.AnyPlayer.Victory', 'Game.End', 'Game.Hour', 'Game.Load', 'Game.Run', 'Game.RunTime', 'Game.Start',
'Game.TimeOver', 'minitimer.change',
-- 玩家事件（40）
'Player.AddBuff', 'Player.AddItem', 'Player.AreaIn', 'Player.AreaOut', 'Player.Attack', 'Player.AttackHit',
'Player.BackPackChange', 'Player.BeHurt', 'Player.ChangeAttr', 'Player.ClickActor', 'Player.ClickBlock',
'Player.Collide', 'Player.ConsumeItem', 'Player.DamageActor', 'Player.DefeatActor', 'Player.Die', 'Player.DiscardItem',
'Player.DismountActor', 'Player.EquipChange', 'Player.EquipOff', 'Player.EquipOn', 'Player.Init', 'Player.InputContent',
'Player.InputKeyDown', 'Player.InputKeyOnPress', 'Player.InputKeyUp', 'Player.JoinTeam', 'Player.LevelModelUpgrade',
'Player.MotionStateChange', 'Player.MountActor', 'Player.MoveOneBlockSize', 'Player.NewInputContent',
'Player.PickUpItem', 'Player.PlayAction', 'Player.RemoveBuff', 'Player.Revive', 'Player.SelectShortcut',
'Player.ShortcutChange', 'Player.UseItem', 'QQMusic.PlayBegin',
-- 生物事件（21）
'Actor.AddBuff', 'Actor.AreaIn', 'Actor.AreaOut', 'Actor.Attack', 'Actor.AttackHit', 'Actor.BeGreetedBy',
'Actor.BeHurt', 'Actor.Beat', 'Actor.ChangeAttr', 'Actor.ChangeMotion', 'Actor.Collide', 'Actor.Create', 'Actor.Damage',
'Actor.Die', 'Actor.InteractEvent', 'Actor.NewBeHurt', 'Actor.Projectile.Hit', 'Actor.RemoveBuff', 'Actor.ReqHelp',
'Actor.VillageBindPosChange', 'Actor.VillagerFlagChange',
-- 方块事件（9）
'Block.Add', 'Block.DestroyBy', 'Block.Dig.Begin', 'Block.Dig.Cancel', 'Block.Dig.End', 'Block.Fertilize',
'Block.PlaceBy', 'Block.Remove', 'Block.Trigger',
-- 道具事件（7）
'DropItem.AreaIn', 'DropItem.AreaOut', 'Item.Disappear', 'Item.Pickup', 'Missile.AreaIn', 'Missile.AreaOut',
'Missile.Create',
-- 特效事件（4）
'Particle.Mob.OnCreate', 'Particle.Player.OnCreate', 'Particle.Pos.OnCreate', 'Particle.Projectile.OnCreate',
-- UI事件（4）
'UI.Button.Click', 'UI.Hide', 'UI.Show', 'UI.LostFocus'}

-- 注册上述事件
YcEventHelper.registerGameAPIEvents(eventnames)

-- 不知道为什么每秒执行一次的事件被官方搞没了，这里自定义实现一个Game.RealSecond
ScriptSupportEvent:registerEvent([=[Game.Run]=], function(event)
  if YcTimeHelper.getFrame() % 20 == 0 then -- 20帧为一秒
    YcEventHelper.triggerEvent('Game.RealSecond')
  end
end)
