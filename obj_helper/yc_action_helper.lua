--- 行为工具类 v1.0.0
--- created by 莫小仙 on 2024-03-14
YcActionHelper = {}

--- 获取当前具体的行为
---@param action YcAction | YcActionGroup 行为/行为组
function YcActionHelper.getCurrentAction(action)
  if not action then -- 如果不存在
    return nil
  elseif action.NAME == YcActionGroup.NAME then -- 如果是行为组
    return YcActionHelper.getCurrentAction(action._currentAction)
  else
    return action
  end
end