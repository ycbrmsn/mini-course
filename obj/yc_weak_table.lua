--- 弱表类 v1.0.0
--- created by 莫小仙 on 2023-12-20
---@class YcWeakTable : YcTable 弱表
YcWeakTable = YcTable:new({
  TYPE = 'YC_WEAK_TABLE'
})

--- 判断是否是一个弱表
---@param o any 需要判断的元素
---@return boolean 是否是弱表
function YcWeakTable.isWeakTable(o)
  return type(o) == 'table' and o.TYPE == YcWeakTable.TYPE
end

--- 实例化
---@param array table 数组
---@return YcWeakTable 弱表对象
function YcWeakTable:new(array)
  array = type(array) == 'table' and array or {} -- 如果array不是table，则赋值为空数组
  self.__index = self
  self.__mode = 'k'
  setmetatable(array, self)
  return array
end

--- 自定义表的输出内容
---@return string 输出内容
function YcWeakTable:__tostring()
  return YcStringHelper.toString(self)
end

-- 缩写
YcWTab = YcWeakTable
