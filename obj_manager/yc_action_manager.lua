--- 行为管理类 v1.0.0
--- created by 莫小仙 on 2024-03-06
---@class YcActionManager 行为管理类
---@field _runningAction YcTable<integer, YcRunningAction> 区域id -> 奔跑行为
YcActionManager = {
  _runningAction = YcTable:new(),
  RUN_AREA_DIM = { x = 0, y = 0, z = 0 }
}

--- 设置奔跑行为的区域id
---@param action YcRunAction 奔跑行为
function YcActionManager.addRunArea(action)
  local pos = action._positions[action._index] -- 奔跑目标位置
  local areaid = AreaAPI.createAreaRect(pos, YcActionManager.RUN_AREA_DIM) -- 创建区域
  YcActionManager._runningAction[areaid] = action -- 记录区域-行为映射
  action._areaid = areaid
end

-- 生物进入区域
ScriptSupportEvent:registerEvent([=[Actor.AreaIn]=], function(event)
  local areaid = event.areaid
  ---@type YcRunAction
  local action = YcActionManager._runningAction[areaid]
  if action then -- 如果找到奔跑行为
    AreaAPI.destroyArea(areaid) -- 删除区域
    action._areaid = nil
    YcTimeHelper.delAfterTimeTask(action._t) -- 停止定时移动
    action:onReach()
  end
end)