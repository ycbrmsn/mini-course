--[[
  怪物攻击最丑玩家
  原理：玩家进入游戏后有一个随机的颜值，颜值最低的玩家为绿队，其他玩家为蓝队。玩家被击败后重置颜值。
  而怪物也是蓝队，所以怪物会攻击颜值最低的玩家。不用红队是因为从很久以前开始红队就有个bug。
  这里偷懒就没有写改变怪物队伍的方法了，规定用插件设置好怪物的队伍为蓝队。
  如果想用脚本实现，这里仅说一下思路：开启一个计时器，每隔一定时间搜索最丑玩家周围的所有生物，将他们改为蓝队。
  create by 莫小仙 on 2021-07-20
]]
math.randomseed(os.time()) -- 重置随机数种子，避免每次开局随机数相同（不过到底有没有必要，我没有测试）
Ugliest = {
  info = {}, -- 玩家id与颜值信息 objid -> val
  objid = nil -- 记录最丑玩家的id
}

-- 重置玩家颜值，并给一个提示
function Ugliest.resetVal (objid)
  local val = math.random(25, 75) -- 25~75的随机数
  Ugliest.info[objid] = val -- 记录玩家颜值
  Chat:sendSystemMsg('当前颜值：' .. val, objid) -- 给指定玩家显示聊天框信息
end

-- 找出最丑玩家，即颜值最小的玩家
function Ugliest.find ()
  local min = 10000 -- 最小值，先取一个很大的值作为初始值
  local id -- 最丑玩家的id
  for objid, val in pairs(Ugliest.info) do
    if (min > val) then -- 发现更小的颜值
      min = val
      id = objid
    end
  end
  return id
end

-- 根据颜值重置数据包括队伍
function Ugliest.reset ()
  local id = Ugliest.find() -- 最丑玩家id
  if (not(id)) then -- id不存在表示当前没有玩家
    Ugliest.objid = nil
  elseif (Ugliest.objid) then -- 存在表示之前已经有最丑玩家了
    if (id ~= Ugliest.objid) then -- 不相同表示最丑玩家发生了变化
      Ugliest.changeTeam(Ugliest.objid) -- 之前最丑玩家恢复为蓝队
      Ugliest.objid = id -- 记录最丑玩家
      Ugliest.changeTeam(Ugliest.objid, true) -- 新最丑玩家变为绿队
    end
  else -- 不存在表示之前没有玩家
    Ugliest.objid = id
    Ugliest.changeTeam(Ugliest.objid, true)
  end
end

-- 改变玩家队伍，change表示是否需要改变队伍为绿队
function Ugliest.changeTeam (objid, change)
  local teamid = change and 3 or 2 -- 2为蓝队3为绿队
  Team:changePlayerTeam(objid, teamid) -- 改变玩家队伍
end

-- 玩家进入游戏事件
local function playerEnterGame (event)
  Ugliest.resetVal(event.eventobjid) -- 设置玩家颜值
  Ugliest.reset()
end

-- 玩家离开游戏事件
local function playerLeaveGame (event)
  Ugliest.info[event.eventobjid] = nil -- 删除玩家颜值信息
  Ugliest.reset()
end

-- 玩家被击败事件
local function playerDie (event)
  Ugliest.resetVal(event.eventobjid) -- 重置玩家颜值
  Ugliest.reset()
end

ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=], playerEnterGame) -- 玩家进入游戏
ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.LeaveGame]=], playerLeaveGame) -- 玩家离开游戏
ScriptSupportEvent:registerEvent([=[Player.Die]=], playerDie) -- 玩家被击败
