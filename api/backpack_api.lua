--[[ 封装背包API v1.0.0
  create by 莫小仙 on 2022-06-04
]]
BackpackAPI = {}

--[[
  @param  {integer} bartype: 1快捷栏 2储存栏 3装备栏
  @return {integer | nil} 道具格起始ID，nil表示获取失败
  @return {integer | nil} 道具格末尾ID，nil表示获取失败
]]
function BackpackAPI.getBackpackBarIDRange (bartype)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:getBackpackBarIDRange(bartype)
  end, '获取道具背包栏ID范围', 'bartype=', bartype)
end

--[[
  @param  {integer} bartype 1快捷栏 2储存栏 3装备栏
  @return {integer | nil} 背包栏大小，nil表示获取失败
]]
function BackpackAPI.getBackpackBarSize (bartype)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:getBackpackBarSize(bartype)
  end, '获取道具背包栏大小', 'bartype=', bartype)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} gridid 道具格id
  @param  {integer} itemid 道具id
  @param  {integer | nil} num 道具数量，默认为1
  @param  {integer | nil} durability 耐久度，默认为满
  @return {boolean} 是否成功
]]
function BackpackAPI.setGridItem (objid, gridid, itemid, num, durability)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Backpack:setGridItem(objid, gridid, itemid, num, durability)
  end, '设置背包格道具', 'objid=', objid, ',gridid=', gridid, ',itemid=', itemid, ',num=', num, ',durability=', durability)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} gridid 道具格id
  @param  {integer | nil} num 道具数量，默认全部
  @return {boolean} 是否成功
]]
function BackpackAPI.removeGridItem (objid, gridid, num)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Backpack:removeGridItem(objid, gridid, num)
  end, '通过道具格移除道具', 'objid=', objid, ',gridid=', gridid, ',num=', num)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具id
  @param  {integer | nil} num 道具数量，默认全部
  @return {integer | nil} 成功移除数量，nil表示移除失败
]]
function BackpackAPI.removeGridItemByItemID (objid, itemid, num)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:removeGridItemByItemID(objid, itemid, num)
  end, '通过道具id移除道具', 'objid=', objid, ',itemid=', itemid, ',num=', num)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} bartype 1快捷栏 2储存栏 3装备栏
  @return {boolean} 是否成功
]]
function BackpackAPI.clearPack (objid, bartype)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Backpack:clearPack(objid, bartype)
  end, '清空指定背包栏', 'objid=', objid, ',bartype=', bartype)
end

--[[
  @param  {integer} objid 迷你号
  @return {boolean} 是否成功
]]
function BackpackAPI.clearAllPack (objid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Backpack:clearAllPack(objid)
  end, '清空全部背包栏', 'objid=', objid)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} gridsrc 原背包栏id
  @param  {integer} griddst 目标背包栏id
  @param  {integer | nil} num 道具数量，默认全部
  @return {boolean} 是否成功
]]
function BackpackAPI.moveGridItem (objid, gridsrc, griddst, num)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Backpack:moveGridItem(objid, gridsrc, griddst, num)
  end, '移动背包道具', 'objid=', objid, ',gridsrc=', gridsrc, ',griddst=', griddst, ',num=', num)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} gridsrc 原背包栏id
  @param  {integer} griddst 目标背包栏id
  @return {boolean} 是否成功
]]
function BackpackAPI.swapGridItem (objid, gridsrc, griddst)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Backpack:swapGridItem(objid, gridsrc, griddst)
  end, '交换背包道具', 'objid=', objid, ',gridsrc=', gridsrc, ',griddst=', griddst)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具id
  @param  {integer | nil} num 道具数量，默认为1
  @return {boolean} 是否有足够空间存放道具
]]
function BackpackAPI.enoughSpaceForItem (objid, itemid, num)
  return Backpack:enoughSpaceForItem(objid, itemid, num) == ErrorCode.OK
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具id
  @return {integer | nil} 背包能存放的道具剩余总数量，nil表示计算失败
]]
function BackpackAPI.calcSpaceNumForItem (objid, itemid)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:calcSpaceNumForItem(objid, itemid)
  end, '计算背包能存放的道具剩余总数量', 'objid=', objid, ',itemid=', itemid)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} bartype 1快捷栏 2储存栏 3装备栏
  @return {integer | nil} 背包栏有道具的格子数量，nil表示获取信息失败
  @return {table | nil} 有道具的道具格id数组，nil表示获取信息失败
]]
function BackpackAPI.getBackpackBarValidList (objid, bartype)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:getBackpackBarValidList(objid, bartype)
  end, '获取背包道具栏有道具的道具格信息', 'objid=', objid, ',bartype=', bartype)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} bartype 1快捷栏 2储存栏 3装备栏
  @return {integer | nil} 背包栏道具种类数量，nil表示获取信息失败
  @return {table | nil} 各种道具的道具数量数组，nil表示获取信息失败
]]
function BackpackAPI.getBackpackBarItemList (objid, bartype)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:getBackpackBarItemList(objid, bartype)
  end, '获取背包道具栏道具种类信息', 'objid=', objid, ',bartype=', bartype)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} bartype 1快捷栏 2储存栏 3装备栏
  @param  {integer} itemid 道具id
  @return {boolean} 背包里是否有某个道具
]]
function BackpackAPI.hasItemByBackpackBar (objid, bartype, itemid)
  return Backpack:hasItemByBackpackBar(objid, bartype, itemid) == ErrorCode.OK
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} bartype 1快捷栏 2储存栏 3装备栏
  @param  {integer} itemid 道具id
  @return {integer | nil} 背包里某个道具总数，nil表示获取失败
  @return {table | nil} 道具所在背包格id数组，nil表示获取失败
]]
function BackpackAPI.getItemNumByBackpackBar (objid, bartype, itemid)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:getItemNumByBackpackBar(objid, bartype, itemid)
  end, '获取背包道具栏某个道具总数', 'objid=', objid, ',bartype=', bartype, ',itemid=', itemid)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} bartype 1快捷栏 2储存栏 3装备栏
  @return {integer | nil} 道具id，nil表示获取失败
  @return {integer | nil} 道具数量，nil表示获取失败
]]
function BackpackAPI.getGridItemID (objid, bartype)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:getGridItemID(objid, bartype)
  end, '获取指定背包栏道具信息', 'objid=', objid, ',bartype=', bartype)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} gridid 道具格id
  @return {string | nil} 道具名称，nil表示获取失败
]]
function BackpackAPI.getGridItemName (objid, gridid)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:getGridItemName(objid, gridid)
  end, '获取指定道具格道具名称', 'objid=', objid, ',gridid=', gridid)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} gridid 道具格id
  @return {integer | nil} 该道具堆叠数量，nil表示获取失败
  @return {integer | nil} 该道具最大堆叠数量，nil表示获取失败
]]
function BackpackAPI.getGridStack (objid, gridid)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:getGridStack(objid, gridid)
  end, '获取背包指定道具格道具堆叠信息', 'objid=', objid, ',gridid=', gridid)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} gridid 道具格id
  @return {integer | nil} 该道具耐久度，nil表示获取失败
  @return {integer | nil} 该道具最大耐久度，nil表示获取失败
]]
function BackpackAPI.getGridDurability (objid, gridid)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:getGridDurability(objid, gridid)
  end, '获取背包指定道具格道具耐久度', 'objid=', objid, ',gridid=', gridid)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} gridid 道具格id
  @return {integer | nil} 该道具附魔数量，nil表示获取失败
  @return {table | nil} 该道具附魔id数组，nil表示获取失败
]]
function BackpackAPI.getGridEnchantList (objid, gridid)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:getGridEnchantList(objid, gridid)
  end, '获取背包指定道具格道具附魔信息', 'objid=', objid, ',gridid=', gridid)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} gridid 道具格id
  @return {integer | nil} 该道具工具类型，nil表示获取失败
]]
function BackpackAPI.getGridToolType (objid, gridid)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:getGridToolType(objid, gridid)
  end, '获取背包指定道具格道具工具类型', 'objid=', objid, ',gridid=', gridid)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具id
  @param  {integer} num 道具数量
  @return {integer | nil} 成功添加的数量，nil表示添加失败
]]
function BackpackAPI.addItem (objid, itemid, num)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:addItem(objid, itemid, num)
  end, '添加道具到背包', 'objid=', objid, ',itemid=', itemid, ',num=', num)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} gridid 道具格id
  @param  {integer | nil} num 道具数量，默认为全部
  @return {boolean} 是否成功
]]
function BackpackAPI.discardItem (objid, gridid, num)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Backpack:discardItem(objid, gridid, num)
  end, '丢弃背包某个格子里的道具', 'objid=', objid, ',gridid=', gridid, ',num=', num)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} gridid 道具格id
  @return {integer | nil} 道具数量，nil表示获取失败
]]
function BackpackAPI.getGridNum (objid, gridid)
  return YcApiHelper.callResultMethod(function ()
    return Backpack:getGridNum(objid, gridid)
  end, '获取背包某个格子的道具数量', 'objid=', objid, ',gridid=', gridid)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} resid 资源id
  @return {boolean} 是否成功
]]
function BackpackAPI.actEquipUpByResID (objid, resid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Backpack:actEquipUpByResID(objid, resid)
  end, '玩家穿上装备', 'objid=', objid, ',resid=', resid)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} equipid 资源id
  @return {boolean} 是否成功
]]
function BackpackAPI.actEquipOffByEquipID (objid, equipid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Backpack:actEquipOffByEquipID(objid, equipid)
  end, '玩家脱下装备', 'objid=', objid, ',equipid=', equipid)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} resid 资源id
  @return {boolean} 是否成功
]]
function BackpackAPI.actCreateEquip (objid, resid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Backpack:actCreateEquip(objid, resid)
  end, '创建装备', 'objid=', objid, ',resid=', resid)
end

--[[
  @param  {integer} objid 迷你号
  @param  {integer} equipid 资源id
  @return {boolean} 是否成功
]]
function BackpackAPI.actDestructEquip (objid, equipid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Backpack:actDestructEquip(objid, equipid)
  end, '销毁装备', 'objid=', objid, ',equipid=', equipid)
end