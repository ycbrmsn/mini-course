--- 游戏管理类 v1.0.0
--- created by 莫小仙 on 2024-01-03
---@class YcGameManager 游戏管理类
YcGameManager = {
  REMOVE_PLAYER = 'removePlayer'
}

-- 世界小时时间变化
ScriptSupportEvent:registerEvent([=[Game.Hour]=], function(event)
  YcLogHelper.try(function()
    local hour = event.hour
    -- 遍历NPC
    YcNpcManager.npcPairs(function(npc)
      npc:onHour(hour) -- NPC在几点做什么
    end)
    -- 遍历玩家
    YcPlayerManager.playerPairs(function(player)
      player:onHour(hour) -- 玩家在几点做什么
    end)
  end)
end)
