--- 弱数组类 v1.0.0
--- created by 莫小仙 on 2023-12-20
---@class YcWeakArray : YcArray 弱数组
YcWeakArray = YcArray:new({
  TYPE = 'YC_WEAK_ARRAY'
})

--- 判断是否是一个弱数组
---@param o any 需要判断的元素
---@return boolean 是否是弱数组
function YcWeakArray.isWeakArray(o)
  return type(o) == 'table' and o.TYPE == YcWeakArray.TYPE
end

--- 实例化
---@param array table 数组
---@return YcWeakArray 弱数组对象
function YcWeakArray:new(array)
  array = type(array) == 'table' and array or {} -- 如果array不是table，则赋值为空数组
  self.__index = self
  self.__mode = 'v'
  setmetatable(array, self)
  return array
end

--- 自定义表的输出内容
---@return string 输出内容
function YcWeakArray:__tostring()
  return YcStringHelper.concat('{', self:join(), '}')
end

-- 缩写
YcWArr = YcWeakArray
