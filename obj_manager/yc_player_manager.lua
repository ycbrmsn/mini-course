--- 玩家管理类 v1.0.0
--- created by 莫小仙 on 2023-12-20
---@class YcPlayerManager 玩家管理类
---@field _playerMap YcTable<integer, MyPlayer> 玩家字典
---@field removeStrategy string | integer 删除玩家信息策略：AT_ONCE玩家退出后立即删除，NO永远不删除，数字类型表示多少秒后删除
---@field needRotateCamera boolean 玩家看向某处是否需要调整镜头（一般来说，在三维视角中需要）
YcPlayerManager = {
  _playerMap = YcTable:new(),
  removeStrategy = 'AT_ONCE',
  needRotateCamera = true
}

-- 玩家进入游戏
ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.EnterGame]=], function(event)
  local objid = event.eventobjid
  if YcPlayerManager._addPlayer(objid) then -- 如果玩家信息已存在
    if type(YcPlayerManager.removeStrategy) == 'number' then -- 如果玩家信息是若干秒后删除
      YcTimeHelper.delAfterTimeTask(YcGameManager.REMOVE_PLAYER .. objid) -- 删除掉删除任务
    end
  end
end)

-- 玩家离开游戏
ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.LeaveGame]=], function(event)
  local objid = event.eventobjid
  if YcPlayerManager.removeStrategy == 'AT_ONCE' then -- 如果是立即删除
    YcPlayerManager._removePlayer(objid)
  elseif type(YcPlayerManager.removeStrategy) == 'number' then -- 表示几秒后删除
    -- 若干秒后删除玩家信息
    YcTimeHelper.newAfterTimeTask(function()
      YcPlayerManager._removePlayer(objid)
    end, YcPlayerManager.removeStrategy, YcGameManager.REMOVE_PLAYER .. objid)
  end
end)

--- 添加一个玩家对象
---@param objid integer 玩家id（迷你号）
---@return boolean 玩家信息是否已存在
function YcPlayerManager._addPlayer(objid)
  local player = YcPlayerManager._playerMap[objid]
  if player then -- 如果玩家信息已存在
    player:onEnterGameAgain()
    return true
  else -- 如果玩家信息不存在
    player = MyPlayer:new(objid) -- 实例化一个玩家
    player:onInit() -- 初始化
    YcPlayerManager._playerMap[objid] = player -- 记录玩家信息
    return false
  end
end

--- 清除玩家对象
---@param objid integer 玩家id（迷你号）
function YcPlayerManager._removePlayer(objid)
  YcPlayerManager._playerMap[objid] = nil
end

--- 获取玩家对象
---@param objid integer 玩家id（迷你号）
---@return MyPlayer 玩家对象
function YcPlayerManager.getPlayer(objid)
  return YcPlayerManager._playerMap[objid]
end

--- 遍历玩家对象
---@param f fun(player: MyPlayer, objid: integer): void 回调函数
function YcPlayerManager.playerPairs(f)
  YcPlayerManager._playerMap:pairs(f)
end
