--- 行为管理类 v1.0.0
--- created by 莫小仙 on 2024-03-06
---@class YcActionManager 行为管理类
---@field _runningAction YcTable<integer, YcRunningAction> 区域id -> 奔跑行为
---@field RUN_AREA_DIM table{ x: number, y: number, z: number } 奔跑目标位置区域大小
---@field APPROACH_AREA_DIM table{ x: number, y: number, z: number } 奔跑靠近目标位置区域大小
YcActionManager = {
  _runningAction = YcTable:new(),
  RUN_AREA_DIM = {
    x = 0,
    y = 0,
    z = 0
  },
  APPROACH_AREA_DIM = {
    x = 1,
    y = 1,
    z = 1
  }
}

--- 设置奔跑行为的区域id
---@param action YcRunAction 奔跑行为
function YcActionManager.addRunArea(action)
  local pos = action._positions[action._index] -- 奔跑目标位置
  -- 靠近创建大区域，奔跑创建小区域
  local dim = action._isApproach and YcActionManager.APPROACH_AREA_DIM or YcActionManager.RUN_AREA_DIM
  local areaid = AreaAPI.createAreaRect(pos, dim) -- 创建区域
  YcActionManager._runningAction[areaid] = action -- 记录区域-行为映射
  action._areaid = areaid
end

--- 删除奔跑区域相关
---@param action YcRunAction 奔跑行为
function YcActionManager.delRunArea(action)
  AreaAPI.destroyArea(action._areaid) -- 删除区域
  YcActionManager._runningAction[action._areaid] = nil -- 删除行为映射
  action._areaid = nil -- 删除区域id
end

-- 生物进入区域
ScriptSupportEvent:registerEvent([=[Actor.AreaIn]=], function(event)
  local areaid = event.areaid
  ---@type YcRunAction
  local action = YcActionManager._runningAction[areaid]
  YcLogHelper.debug('进入区域')
  if action then -- 如果找到奔跑行为
    YcActionManager.delRunArea(action)
    YcTimeHelper.delAfterTimeTask(action._t) -- 停止定时移动
    action:onReach()
  end
end)
