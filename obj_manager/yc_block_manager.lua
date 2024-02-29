--- 方块管理类 v1.0.0
--- created by 莫小仙 on 2024-01-16
---@class YcBlockManager 方块管理类
---@field transparentBlockIds YcArray<Integer> 透明方块id数组
YcBlockManager = {
  transparentBlockIds = YcArray:new()
}

--- 指定一些id对应的方块是透明方块。这里主要指固体方块
---@vararg integer 方块id
function YcBlockManager.setTransparentBlock(...)
  YcBlockManager.transparentBlockIds:push(...)
end

--- 指定位置处是否是透明方块。
--- 这里认为液体、气体方块是透明的。固体方块除添加的外，都是不透明的
---@param x number 位置x
---@param y number 位置y
---@param z number 位置z
function YcBlockManager.isTransparentBlock(x, y, z)
  if BlockAPI.isSolidBlock(x, y, z) then -- 如果是固体方块
    local blockid = BlockAPI.getBlockID(x, y, z)
    return YcBlockManager.transparentBlockIds:includes(blockid)
  else -- 非固体方块
    return true
  end
end