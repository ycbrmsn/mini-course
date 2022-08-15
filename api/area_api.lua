--[[ 封装区域API v1.0.0
  create by 莫小仙 on 2022-08-15
]]
AreaAPI = {}

--[[
  @param  {table} pos 中心位置
  @param  {table} dim 尺寸
  @return {integer | nil} 区域id，nil表示创建区域失败 
]]
function AreaAPI.createAreaRect (pos, dim)
  return YcApiHelper.callResultMethod(function ()
    return Area:createAreaRect(pos, dim)
  end, '根据中心位置创建矩形区域', 'pos=', pos, ',dim=', dim)
end

--[[
  @param  {table} posBeg 起点位置
  @param  {table} podEnd 终点位置
  @return {integer | nil} 区域id，nil表示创建区域失败
]]
function AreaAPI.createAreaRectByRange (posBeg, posEnd)
  return YcApiHelper.callResultMethod(function ()
    return Area:createAreaRectByRange(posBeg, posEnd)
  end, '根据起始点创建矩形区域', 'posBeg=', posBeg, ',posEnd=', posEnd)
end

--[[
  @param  {integer} areaid 区域id
  @return {boolean} 是否成功
]]
function AreaAPI.destroyArea (areaid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Area:destroyArea(areaid)
  end, '销毁区域', 'areaid=', areaid)
end

--[[
  @param  {table} pos 位置
  @return {integer | nil} 区域id，nil表示没有找到所属区域
]]
function AreaAPI.getAreaByPos (pos)
  return YcApiHelper.callResultMethod(function ()
    return Area:getAreaByPos(pos)
  end, '通过位置查找区域', 'pos=', pos)
end

--[[
  @param  {integer} areaid 区域id
  @param  {number} x x方向偏移
  @param  {number} y y方向偏移
  @param  {number} z z方向偏移
  @return {boolean} 是否成功
]]
function AreaAPI.offsetArea (areaid, x, y, z)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Area:offsetArea(areaid, x, y, z)
  end, '区域偏移', 'areaid=', areaid, ',x=', x, ',y=', y, ',z=', z)
end

--[[
  @param  {integer} areaid 区域id
  @param  {number} x x方向偏移
  @param  {number} y y方向偏移
  @param  {number} z z方向偏移
  @return {boolean} 是否成功
]]
function AreaAPI.expandArea (areaid, x, y, z)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Area:expandArea(areaid, x, y, z)
  end, '扩大区域', 'areaid=', areaid, ',x=', x, ',y=', y, ',z=', z)
end

--[[
  报错？
  @param  {integer} areaid 区域id
  @return {pos | nil} 区域中间点位置，nil表示获取失败
]]
function AreaAPI.getAreaCenter (areaid)
  return YcApiHelper.callResultMethod(function ()
    return Area:getAreaCenter(areaid)
  end, '获取区域中间点', 'areaid=', areaid)
end

--[[
  @param  {integer} areaid 区域id
  @return {number | nil} 区域x方向边长，nil表示获取失败
  @return {number | nil} 区域y方向边长，nil表示获取失败
  @return {number | nil} 区域z方向边长，nil表示获取失败
]]
function AreaAPI.getAreaRectLength (areaid)
  return YcApiHelper.callResultMethod(function ()
    return Area:getAreaRectLength(areaid)
  end, '获取区域各边长', 'areaid=', areaid)
end

--[[
  @param  {integer} areaid 区域id
  @return {table | nil} 区域起点位置，nil表示获取失败
  @return {table | nil} 区域终点位置，nil表示获取失败
]]
function AreaAPI.getAreaRectRange (areaid)
  return YcApiHelper.callResultMethod(function ()
    return Area:getAreaRectRange(areaid)
  end, '获取区域范围', 'areaid=', areaid)
end

--[[
  @param  {integer} areaid 区域id
  @return {table | nil} 区域内的一个随机位置，nil表示获取失败
]]
function AreaAPI.getRandomPos (areaid)
  return YcApiHelper.callResultMethod(function ()
    return Area:getRandomPos(areaid)
  end, '获取区域内的一个随机位置', 'areaid=', areaid)
end

--[[
  检测行为者是否在区域内
  @param  {integer} areaid 区域id
  @param  {integer} objid 行为者id
  @return {boolean} 行为者是否在区域内
]]
function AreaAPI.objInArea (areaid, objid)
  return Area:objInArea(areaid, objid) == ErrorCode.OK
end

--[[
  检测区域内是否有某个方块
  @param  {integer} areaid 区域id
  @param  {integer} blockid 方块类型id
  @return {boolean} 是否有该方块
]]
function AreaAPI.blockInArea (areaid, blockid)
  return Area:blockInArea(areaid, blockid) == ErrorCode.OK
end

--[[
  位置是否在区域内
  @param  {table} pos 位置
  @param  {integer} areaid 区域id
  @return {boolean} 是否在区域内
]]
function AreaAPI.posInArea (pos, areaid)
  return Area:posInArea(pos, areaid) == ErrorCode.OK
end

--[[
  @param  {integer} areaid 区域id
  @return {table} 玩家迷你号数组
]]
function AreaAPI.getAreaPlayers (areaid)
  return YcApiHelper.callResultMethod(function ()
    return Area:getAreaPlayers(areaid)
  end, '获取区域中的所有玩家', 'areaid=', areaid)
end

--[[
  该接口第二次调用会报错？
  @param  {integer} areaid 区域id
  @return {table} 生物id数组
]]
function AreaAPI.getAreaCreatures (areaid)
  return YcApiHelper.callResultMethod(function ()
    return Area:getAreaCreatures(areaid)
  end, '获取区域中的生物', 'areaid=', areaid)
end

--[[
  @param  {integer} areaid 区域id
  @param  {integer} blockid 方块类型id
  @param  {integer} face 朝向，似乎没用
  @return {boolean} 是否成功
]]
function AreaAPI.fillBlock (areaid, blockid, face)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Area:fillBlock(areaid, blockid, face)
  end, '用方块填充区域', 'areaid=', areaid, ',blockid=', blockid, ',face=', face)
end

--[[
  @param  {integer} areaid 区域id
  @param  {integer} blockid 方块类型id
  @return {boolean} 是否成功
  ]]
function AreaAPI.clearAllBlock (areaid, blockid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Area:clearAllBlock(areaid, blockid)
  end, '清空区域内的全部方块', 'areaid=', areaid, ',blockid=', blockid)
end

--[[
  @param  {integer} areaid 区域id
  @param  {table} destStartPos 目标区域的起始位置
  @return {boolean} 是否成功
  ]]
function AreaAPI.cloneArea (areaid, destStartPos)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Area:cloneArea(areaid, destStartPos)
  end, '复制区域内方块到另一个区域', 'areaid=', areaid, ',destStartPos=', destStartPos)
end

--[[
  @param  {table} srcPos 原始位置
  @param  {table} dim 偏移尺寸
  @return {table | nil} 偏移后的位置，nil表示获取失败
]]
function AreaAPI.getPosOffset (srcPos, dim)
  return YcApiHelper.callResultMethod(function ()
    return Area:getPosOffset(srcPos, dim)
  end, '获取偏移后的位置', 'srcPos=', srcPos, ',dim=', dim)
end

--[[
  @param  {integer} areaid 区域id
  @param  {integer} srcBlockid 需要被替换的方块类型id
  @param  {integer} destBlockid 替换后的方块类型id
  @param  {integer} face 朝向，似乎没用
  @return {boolean} 是否成功
]]
function AreaAPI.replaceAreaBlock (areaid, srcBlockid, destBlockid, face)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Area:replaceAreaBlock(areaid, srcBlockid, destBlockid, face)
  end, '替换方块类型为新的方块类型', 'areaid=', areaid, ',srcBlockid=', srcBlockid,
    ',destBlockid=', destBlockid, ',face=', face)
end

--[[
  @param  {integer} blockid 方块类型id
  @param  {table} posBeg 区域起始位置
  @param  {table} posEnd 区域结束位置
  @return {boolean} 是否有该种方块
]]
function AreaAPI.blockInAreaRange (blockid, posBeg, posEnd)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Area:blockInAreaRange(blockid, posBeg, posEnd)
  end, '区域范围内是否有某种方块', 'blockid=', blockid, ',posBeg=', posBeg, ',posEnd=', posEnd)
end

--[[
  @param  {table} posBeg 区域起始位置
  @param  {table} posEnd 区域结束位置
  @param  {integer} objType 行为者类型？
  @return {table | nil} 行为者id数组，nil表示获取失败
]]
function AreaAPI.getAllObjsInAreaRange (posBeg, posEnd, objType)
  return YcApiHelper.callResultMethod(function ()
    return Area:getAllObjsInAreaRange(posBeg, posEnd, objType)
  end, '获取区域范围内全部对象', 'posBeg=', posBeg, ',posEnd=', posEnd, ',objType=', objType)
end

--[[
  @param  {table} posBeg 区域起始位置
  @param  {table} posEnd 区域结束位置
  @param  {table} objTypes 行为者类型数组
  @return {table | nil} 行为者id数组，nil表示获取失败
]]
function AreaAPI.getAllObjsInAreaRangeByObjTypes (posBeg, posEnd, objTypes)
  return YcApiHelper.callResultMethod(function ()
    return Area:getAllObjsInAreaRangeByObjTypes(posBeg, posEnd, objTypes)
  end, '获取区域范围内全部对象', 'posBeg=', posBeg, ',posEnd=', posEnd, ',objTypes=', objTypes)
end

--[[
  @param  {table} posBeg 区域起始位置
  @param  {table} posEnd 区域结束位置
  @return {table | nil} 玩家迷你号数组，nil表示获取失败
  ]]
function AreaAPI.getAllPlayersInAreaRange (posBeg, posEnd)
  return YcApiHelper.callResultMethod(function ()
    return Area:getAllPlayersInAreaRange(posBeg, posEnd)
  end, '获取区域范围内全部玩家', 'posBeg=', posBeg, ',posEnd=', posEnd)
end

--[[
  @param  {table} posBeg 区域起始位置
  @param  {table} posEnd 区域结束位置
  @return {table | nil} 生物id数组，nil表示获取失败
  ]]
function AreaAPI.getAllCreaturesInAreaRange (posBeg, posEnd)
  return YcApiHelper.callResultMethod(function ()
    return Area:getAllCreaturesInAreaRange(posBeg, posEnd)
  end, '获取区域范围内全部生物', 'posBeg=', posBeg, ',posEnd=', posEnd)
end

--[[
  @param  {table} posBeg 区域起始位置
  @param  {table} posEnd 区域结束位置
  @param  {integer} blockid 方块类型id
  @param  {integer} face 朝向，似乎没用
  @return {boolean} 是否成功
]]
function AreaAPI.fillBlockAreaRange (posBeg, posEnd, blockid, face)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Area:fillBlockAreaRange(posBeg, posEnd, blockid, face)
  end, '用方块填充区域范围', 'posBeg=', posBeg, ',posEnd=', posEnd, ',blockid=', blockid,
    ',face=', face)
end

--[[
  @param  {table} posBeg 区域起始位置
  @param  {table} posEnd 区域结束位置
  @param  {integer} blockid 方块类型id
  @return {boolean} 是否成功
]]
function AreaAPI.clearAllBlockAreaRange (posBeg, posEnd, blockid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Area:clearAllBlockAreaRange(posBeg, posEnd, blockid)
  end, '清空区域范围内方块', 'posBeg=', posBeg, ',posEnd=', posEnd, ',blockid=', blockid)
end

--[[
  @param  {table} posBeg 区域起始位置
  @param  {table} posEnd 区域结束位置
  @param  {table} destStartPos 目标区域的起始位置
  @return {boolean} 是否成功
  ]]
function AreaAPI.cloneAreaRange (posBeg, posEnd, destStartPos)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Area:cloneAreaRange(posBeg, posEnd, destStartPos)
  end, '复制区域范围内方块到另一个区域', 'posBeg=', posBeg, ',posEnd=', posEnd,
    ',destStartPos=', destStartPos)
end

--[[
  @param  {table} posBeg 区域起始位置
  @param  {table} posEnd 区域结束位置
  @param  {integer} srcBlockid 需要被替换的方块类型id
  @param  {integer} destBlockid 替换后的方块类型id
  @param  {integer} face 朝向，似乎没用
  @return {boolean} 是否成功
]]
function AreaAPI.replaceAreaRangeBlock (posBeg, posEnd, srcBlockid, destBlockid, face)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Area:replaceAreaRangeBlock(posBeg, posEnd, srcBlockid, destBlockid, face)
  end, '替换区域范围方块', 'posBeg=', posBeg, ',posEnd=', posEnd, ',srcBlockid=', srcBlockid,
    ',destBlockid=', destBlockid, ',face=', face)
end
