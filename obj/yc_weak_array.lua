--- 弱数组类 v1.0.0
--- created by 莫小仙 on 2023-12-12
---@class YcWeakArray 弱数组
YcWeakArray = YcArray:new({
  TYPE = 'YC_WEAK_ARRAY',
  __mode = 'v'
})

--- 判断是否是一个弱数组
---@param o any 需要判断的元素
---@return boolean 是否是弱数组
function YcWeakArray.isWeakArray(o)
  return type(o) == 'table' and o.TYPE == YcWeakArray.TYPE
end

--- 自定义表的输出内容
---@return string 输出内容
function YcWeakArray:__tostring()
  return YcStringHelper.concat('{', self:join(), '}')
end
