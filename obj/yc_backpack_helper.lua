--[[ 背包工具类 v1.0.2
  create by 莫小仙 on 2022-06-14
]]
YcBackpackHelper = {
  SHORTCUT = BACKPACK_TYPE.SHORTCUT, -- 快捷栏
  INVENTORY = BACKPACK_TYPE.INVENTORY, -- 存储栏
  EQUIP = BACKPACK_TYPE.EQUIP -- 装备栏
}

--[[
  判断玩家背包里是否有某道具
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具id
  @param  {boolean} containEquip 是否包含装备栏，默认不包含
  @return {boolean} 是否有该道具
  @return {integer | nil} 道具所在背包栏 1快捷栏 2储存栏 3装备栏，nil表示没有该道具
]]
function YcBackpackHelper.hasItem (objid, itemid, containEquip)
  local r1 = BackpackAPI.hasItemByBackpackBar(objid, YcBackpackHelper.SHORTCUT, itemid) -- 快捷栏
  if r1 then -- 在快捷栏找到了
    return r1, YcBackpackHelper.SHORTCUT
  else -- 在快捷栏里没找到
    local r2 = BackpackAPI.hasItemByBackpackBar(objid, YcBackpackHelper.INVENTORY, itemid) -- 存储栏
    if r2 then -- 在存储栏找到了
      return r2, YcBackpackHelper.INVENTORY
    else -- 在存储栏里没找到
      if containEquip then -- 表示需要在装备栏寻找
        local r3 = BackpackAPI.hasItemByBackpackBar(objid, YcBackpackHelper.EQUIP, itemid) -- 装备栏
        if r3 then -- 在装备栏找到了
          return r3, YcBackpackHelper.EQUIP
        else -- 在装备栏里没找到
          return r3
        end
      else -- 不需要在装备栏中寻找
        return r2
      end
    end
  end
end

--[[
  某背包栏中指定道具总数及该道具所在道具格数组
  背包栏依次从快捷栏、存储栏、装备栏开始检测
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具id
  @param  {boolean} containEquip 是否包含装备栏
  @return {integer} 所在背包栏道具总数
  @return {table} 所在背包栏的道具格id数组
]]
function YcBackpackHelper.getItemNum (objid, itemid, containEquip)
  local r, bartype = YcBackpackHelper.hasItem(objid, itemid, containEquip)
  if r then
    return BackpackAPI.getItemNumByBackpackBar(objid, bartype, itemid)
  else
    return 0, {}
  end
end

--[[
  获取快捷栏中指定道具总数及道具格数组
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具id
  @return {integer | nil} 背包里某个道具总数，nil表示获取失败
  @return {table | nil} 道具所在道具格id数组，nil表示获取失败
]]
function YcBackpackHelper.getItemNumByShortcut (objid, itemid)
  return BackpackAPI.getItemNumByBackpackBar(objid, YcBackpackHelper.SHORTCUT, itemid)
end

--[[
  获取存储栏中指定道具总数及道具格数组
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具id
  @return {integer | nil} 背包里某个道具总数，nil表示获取失败
  @return {table | nil} 道具所在道具格id数组，nil表示获取失败
]]
function YcBackpackHelper.getItemNumByInventory (objid, itemid)
  return BackpackAPI.getItemNumByBackpackBar(objid, YcBackpackHelper.INVENTORY, itemid)
end

--[[
  获取装备栏中指定道具总数及道具格数组
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具id
  @return {integer | nil} 背包里某个道具总数，nil表示获取失败
  @return {table | nil} 道具所在道具格id数组，nil表示获取失败
]]
function YcBackpackHelper.getItemNumByEquip (objid, itemid)
  return BackpackAPI.getItemNumByBackpackBar(objid, YcBackpackHelper.EQUIP, itemid)
end

--[[
  获取背包栏指定道具的总数及所在道具格数组
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具id
  @param  {boolean} containEquip 是否包含装备栏
  @return {integer | nil} 道具总数
  @return {table | nil} 道具所在道具格id数组
]]
function YcBackpackHelper.getItemNumAndGrids (objid, itemid, containEquip)
  local num1, arr1 = YcBackpackHelper.getItemNumByShortcut(objid, itemid)
  if not num1 then -- 表示快捷栏没找到
    num1, arr1 = 0, {}
  end
  local num2, arr2 = YcBackpackHelper.getItemNumByInventory(objid, itemid)
  if not num2 then -- 表示物品栏没找到
    num2, arr2 = 0, {}
  end
  local num3, arr3
  if containEquip then -- 包含装备栏
    num3, arr3 = YcBackpackHelper.getItemNumByEquip(objid, itemid)
  end
  if not num3 then -- 表示没搜索装备栏或在装备栏没找到
    num3, arr3 = 0, {}
  end
  local num = num1 + num2 + num3
  local arr = {}
  if num > 0 then -- 找到道具
    -- 遍历快捷栏，加入道具格
    for i, v in ipairs(arr1) do
      table.insert(arr, v)
    end
    -- 遍历存储栏，加入道具格
    for i, v in ipairs(arr2) do
      table.insert(arr, v)
    end
    -- 遍历装备栏，加入道具格
    for i, v in ipairs(arr3) do
      table.insert(arr, v)
    end
  end
  return num, arr
end

--[[
  获取玩家指定背包栏的第一个空的道具格
  @param  {integer} objid 迷你号
  @param  {integer} bartype 1快捷栏 2储存栏 3装备栏
  @return {integer | nil} 道具格id，nil表示没有空道具格
]]
function YcBackpackHelper.getFirstEmptyGridByBartype (objid, bartype)
  local begGrid, endGrid = BackpackAPI.getBackpackBarIDRange(bartype)
  for i = begGrid, endGrid do
    local itemid, num = BackpackAPI.getGridItemID(objid, i)
    if itemid == 0 then
      return i
    end
  end
  return nil
end

--[[
  获取玩家第一个空的道具格，从快捷栏到存储栏
  @param  {integer} objid 迷你号
  @return {integer | nil} 道具格id，nil表示没有空道具格
  @return {integer | nil} 道具所在背包栏 1快捷栏 2储存栏，nil表示没有空道具格
]]
function YcBackpackHelper.getFirstEmptyGrid (objid)
  local bartypes = { YcBackpackHelper.SHORTCUT, YcBackpackHelper.INVENTORY }
  local index = 1
  while index <= #bartypes do
    local bartype = bartypes[index]
    local gridid = YcBackpackHelper.getFirstEmptyGridByBartype(objid, bartype)
    if gridid then
      return gridid, bartype
    end
    index = index + 1
  end
  return nil, nil
end

--[[
  获得道具，背包空间不足则丢地上
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具id
  @param  {integer} num 道具数量
  @return {boolean} 是否成功
]]
function YcBackpackHelper.gainItem (objid, itemid, num)
  num = num or 1
  local spaceNum = BackpackAPI.calcSpaceNumForItem(objid, itemid) or 0 -- 剩余空间
  if spaceNum >= num then -- 空间足够
    return BackpackAPI.addItem(objid, itemid, num)
  else -- 空间不够
    local realNum = BackpackAPI.addItem(objid, itemid, spaceNum) -- 把剩余空间先装满
    local x, y, z = YcCacheHelper.getPosition(objid) -- 玩家位置
    WorldAPI.spawnItem(x, y, z, itemid, num - spaceNum) -- 装不下的部分丢地上
    return realNum
  end
end

--[[
  获取玩家当前手持道具的道具格id
  @param  {integer} objid 迷你号
  @return {integer | nil} 快捷栏id，nil表示获取失败
]]
function YcBackpackHelper.getCurShotcutGrid (objid)
  local shotcut = PlayerAPI.getCurShotcut(objid)
  return shotcut and shotcut + 1000 or shotcut -- 类似三目运算
end