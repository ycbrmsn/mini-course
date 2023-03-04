--[[ 事件工具类 v1.0.0
  create by 莫小仙 on 2022-07-06
]]
YcEventHelper = {
  func = {}, -- { [eventname] = { f1, f2, f3, ... } }
  alias = {} -- { [eventAlias] = eventname }
}

--[[
  通过字符串添加事件别名，参数格式为：别名=事件名&别名=事件名
  例如：playerEnterGame=Game.AnyPlayer.EnterGame&playerLeaveGame=Game.AnyPlayer.LeaveGame
  @param  {string} str 别名事件名字符串
  @return {nil}
]]
function YcEventHelper.addAliasByStr (str)
  local arr = YcStringHelper.split(str, '&') -- 以&拆分字符串成数组
  for i, s in ipairs(arr) do -- 遍历每一组缩写
    local arr2 = YcStringHelper.split(s, '=') -- 以=拆分字符串成数组
    YcEventHelper.alias[arr2[1]] = arr2[2] -- 缩写=事件名
  end
end

--[[
  通过表添加事件别名，参数为：{ 别名 = 事件名 }
  @param  {table} map 别名事件名键值对
  @return {nil}
]]
function YcEventHelper.addAliasByTable (map)
  for k, v in pairs(map) do -- 遍历表中所有属性
    YcEventHelper.alias[k] = v -- 缩写=事件名
  end
end

--[[
  获取事件实际的名称
  @param  {string} eventname 事件名称/别名
  @return {string} 事件名称
]]
function YcEventHelper.getRealname (eventname)
  return YcEventHelper.alias[eventname] or eventname -- 找不到别名就取当前名字
end

--[[
  注册事件
  @param  {string} eventname 事件名称
  @param  {function} f 需要执行的函数
  @return {nil}
]]
function YcEventHelper.registerEvent (eventname, f)
  eventname = YcEventHelper.getRealname(eventname) -- 事件原始名称
  if not YcEventHelper.func[eventname] then -- 如果该事件没有注册过
    YcEventHelper.func[eventname] = { f } -- 初始化一个新数组
  else -- 如果注册过
    table.insert(YcEventHelper.func[eventname], f) -- 向数组中添加一个元素
  end
end

--[[
  触发事件
  @param  {string} eventname 事件名称
  @param  {table | nil} event 事件参数
  @return {nil}
]]
function YcEventHelper.triggerEvent (eventname, event)
  eventname = YcEventHelper.getRealname(eventname) -- 事件原始名称
  local fs = YcEventHelper.func[eventname] -- 获取事件数组
  if fs then -- 如果存在，则遍历执行
    for i, f in ipairs(fs) do
      -- 捕获执行，避免一个事件出错后导致后续事件无法执行
      YcLogHelper.try(function ()
        f(event)
      end)
    end
  end
end

--[[
  注册要触发的游戏API事件，用于绑定对应的游戏API事件
  @param  {table} eventnames 事件名数组
  @return {nil}
]]
function YcEventHelper.registerGameAPIEvents (eventnames)
  for i, eventname in ipairs(eventnames) do -- 遍历所有事件名称
    -- 注册相应事件
    ScriptSupportEvent:registerEvent(eventname, function (event)
      YcEventHelper.triggerEvent(eventname, event)
    end)
  end
end

-- 初始化

-- 事件名，对应所有的游戏事件。如果游戏事件有所改变，则随之调整
local eventnames = {
  -- 世界事件（4）
  'Weather.Changed',
  'Backpack.ItemTakeOut',
  'Backpack.ItemPutIn',
  'Backpack.ItemChange',
  -- 游戏逻辑（13）
  'Game.AnyPlayer.Defeat',
  'Game.AnyPlayer.EnterGame',
  'Game.AnyPlayer.LeaveGame',
  'Game.AnyPlayer.ReadStage',
  'Game.AnyPlayer.Victory',
  'Game.End',
  'Game.Hour',
  'Game.Load',
  'Game.Run',
  'Game.RunTime',
  'Game.Start',
  'Game.TimeOver',
  'minitimer.change',
  -- 玩家事件（40）
  'Player.AddBuff',
  'Player.AddItem',
  'Player.AreaIn',
  'Player.AreaOut',
  'Player.Attack',
  'Player.AttackHit',
  'Player.BackPackChange',
  'Player.BeHurt',
  'Player.ChangeAttr',
  'Player.ClickActor',
  'Player.ClickBlock',
  'Player.Collide',
  'Player.ConsumeItem',
  'Player.DamageActor',
  'Player.DefeatActor',
  'Player.Die',
  'Player.DiscardItem',
  'Player.DismountActor',
  'Player.EquipChange',
  'Player.EquipOff',
  'Player.EquipOn',
  'Player.Init',
  'Player.InputContent',
  'Player.InputKeyDown',
  'Player.InputKeyOnPress',
  'Player.InputKeyUp',
  'Player.JoinTeam',
  'Player.LevelModelUpgrade',
  'Player.MotionStateChange',
  'Player.MountActor',
  'Player.MoveOneBlockSize',
  'Player.NewInputContent',
  'Player.PickUpItem',
  'Player.PlayAction',
  'Player.RemoveBuff',
  'Player.Revive',
  'Player.SelectShortcut',
  'Player.ShortcutChange',
  'Player.UseItem',
  'QQMusic.PlayBegin',
  -- 生物事件（21）
  'Actor.AddBuff',
  'Actor.AreaIn',
  'Actor.AreaOut',
  'Actor.Attack',
  'Actor.AttackHit',
  'Actor.BeGreetedBy',
  'Actor.BeHurt',
  'Actor.Beat',
  'Actor.ChangeAttr',
  'Actor.ChangeMotion',
  'Actor.Collide',
  'Actor.Create',
  'Actor.Damage',
  'Actor.Die',
  'Actor.InteractEvent',
  'Actor.NewBeHurt',
  'Actor.Projectile.Hit',
  'Actor.RemoveBuff',
  'Actor.ReqHelp',
  'Actor.VillageBindPosChange',
  'Actor.VillagerFlagChange',
  -- 方块事件（9）
  'Block.Add',
  'Block.DestroyBy',
  'Block.Dig.Begin',
  'Block.Dig.Cancel',
  'Block.Dig.End',
  'Block.Fertilize',
  'Block.PlaceBy',
  'Block.Remove',
  'Block.Trigger',
  -- 道具事件（7）
  'DropItem.AreaIn',
  'DropItem.AreaOut',
  'Item.Disappear',
  'Item.Pickup',
  'Missile.AreaIn',
  'Missile.AreaOut',
  'Missile.Create',
  -- 特效事件（4）
  'Particle.Mob.OnCreate',
  'Particle.Player.OnCreate',
  'Particle.Pos.OnCreate',
  'Particle.Projectile.OnCreate',
  -- UI事件（4）
  'UI.Button.Click',
  'UI.Hide',
  'UI.Show',
  'UI.LostFocus'
}

-- 注册上述事件
YcEventHelper.registerGameAPIEvents(eventnames)
