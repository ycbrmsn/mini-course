--- 表类 v1.0.0
--- created by 莫小仙 on 2023-12-20
---@class YcTable 表
YcTable = {
  TYPE = 'YC_TABLE'
}

--- 实例化
---@param o table 表
---@return YcTable 表对象
function YcTable:new(o)
  o = type(o) == 'table' and o or {} -- 如果o不是table，则赋值为空表
  self.__index = self
  setmetatable(o, self)
  return o
end

--- 遍历表
---@param f fun(currentValue: any, currentKey: any): void 回调函数
---@return YcTable 原表
function YcTable:pairs(f)
  for k, v in pairs(self) do
    f(v, k)
  end
  return self
end

--- 克隆表对象。默认浅克隆
---@param deep boolean 是否是深克隆
---@return YcTable 表对象
function YcTable:clone(deep)
  local tab = self.__index:new()
  if deep then -- 如果是深克隆
    for k, v in pairs(self) do
      if type(v) == 'table' then -- 如果是对象
        if type(v.clone) == 'function' then -- 如果有克隆方法
          tab[k] = v:clone(deep)
        else -- 如果没有克隆方法
          tab[k] = YcTableHelper.clone(v, deep)
        end
      else -- 如果不是对象
        tab[k] = v
      end
    end
  else -- 如果是浅克隆
    for k, v in pairs(self) do
      tab[k] = v
    end
  end
  return tab
end

--- 自定义表的输出内容
---@return string 输出内容
function YcTable:__tostring()
  return YcStringHelper.toString(self)
end

-- 缩写
YcTab = YcTable
