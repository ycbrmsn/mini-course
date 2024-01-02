--- 表工具类 v1.0.0
--- created by 莫小仙 on 2023-12-21
---@class YcTableHelper 表工具类
YcTableHelper = {}

--- 克隆表
---@param tab table 表
---@param deep boolean 是否是深克隆
---@return table 表
function YcTableHelper.clone(tab, deep)
  local t = {}
  if deep then -- 如果是深克隆
    for k, v in pairs(tab) do
      if type(v) == 'object' then -- 如果是对象
        t[k] = YcTableHelper.clone(tab, deep)
      else -- 如果不是对象
        t[k] = v
      end
    end
  else -- 如果是浅克隆
    for k, v in pairs(tab) do
      t[k] = v
    end
  end
  return t
end
