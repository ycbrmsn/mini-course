--[[ 封装方块API v1.0.0
  create by 莫小仙 on 2023-01-15
]]
BlockAPI = {}

--[[
  判断指定位置是否是固体方块
  @param  {number} x 指定位置的x
  @param  {number} y 指定位置的y
  @param  {number} z 指定位置的z
  @return {boolean} 是否是固体方块
]]
function BlockAPI.isSolidBlock (x, y, z)
  return Block:isSolidBlock(x, y, z) == ErrorCode.OK
end

--[[
  判断指定位置是否是液体方块
  @param  {number} x 指定位置的x
  @param  {number} y 指定位置的y
  @param  {number} z 指定位置的z
  @return {boolean} 是否是液体方块
]]
function BlockAPI.isLiquidBlock (x, y, z)
  return Block:isLiquidBlock(x, y, z) == ErrorCode.OK
end

--[[
  判断指定位置是否是气体方块
  @param  {number} x 指定位置的x
  @param  {number} y 指定位置的y
  @param  {number} z 指定位置的z
  @return {boolean} 是否是气体方块
]]
function BlockAPI.isAirBlock (x, y, z)
  return Block:isAirBlock(x, y, z) == ErrorCode.OK
end

--[[
  获取指定位置的方块id
  @param  {number} x 指定位置的x
  @param  {number} y 指定位置的y
  @param  {number} z 指定位置的z
  @return {integer} 方块id
]]
function BlockAPI.getBlockID (x, y, z)
  return YcApiHelper.callResultMethod(function ()
    return Block:getBlockID(x, y, z)
  end, '获取方块id', 'x=', x, ',y=', y, ',z=', z)
end

--[[
  设置指定位置的方块数据
  @param  {number} x 指定位置的x
  @param  {number} y 指定位置的y
  @param  {number} z 指定位置的z
  @param  {integer} blockid 方块id
  @param  {integer} data 方块数据
  @return {boolean} 是否成功
]]
function BlockAPI.setBlockAll (x, y, z, blockid, data)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Block:setBlockAll(x, y, z, blockid, data)
  end, '设置方块数据', 'x=', x, ',y=', y, ',z=', z, ',blockid=', blockid, ',data=', data)
end

--[[
  获取指定位置的方块数据
  @param  {number} x 指定位置的x
  @param  {number} y 指定位置的y
  @param  {number} z 指定位置的z
  @return {integer} 方块数据
]]
function BlockAPI.getBlockData (x, y, z)
  return YcApiHelper.callResultMethod(function ()
    return Block:getBlockData(x, y, z)
  end, '获取方块数据', 'x=', x, ',y=', y, ',z=', z)
end

--[[
  摧毁指定位置的方块
  @param  {number} x 指定位置的x
  @param  {number} y 指定位置的y
  @param  {number} z 指定位置的z
  @param  {boolean} dropitem 是否掉落道具，默认为false不掉落
  @return {boolean} 是否成功
]]
function BlockAPI.destroyBlock (x, y, z, dropitem)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Block:destroyBlock(x, y, z, dropitem)
  end, '摧毁方块', 'x=', x, ',y=', y, ',z=', z, ',dropitem=', dropitem)
end

--[[
  在指定位置放置方块
  @param  {integer} blockid 方块id
  @param  {number} x 指定位置的x
  @param  {number} y 指定位置的y
  @param  {number} z 指定位置的z
  @param  {integer} face 方块朝向
  @param  {integer} color 方块颜色
  @return {boolean} 是否成功
]]
function BlockAPI.placeBlock (blockid, x, y, z, face, color)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Block:placeBlock(blockid, x, y, z, face, color)
  end, '放置方块', 'blockid=', blockid, ',x=', x, ',y=', y, ',z=', z, ',face=', face, ',color=', color)
end

--[[
  替换指定位置上的方块
  @param  {integer} blockid 方块id
  @param  {number} x 指定位置的x
  @param  {number} y 指定位置的y
  @param  {number} z 指定位置的z
  @param  {integer} face 方块朝向
  @param  {integer} color 方块颜色
  @return {boolean} 是否成功
]]
function BlockAPI.replaceBlock (blockid, x, y, z, face, color)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Block:replaceBlock(blockid, x, y, z, face, color)
  end, '替换方块', 'blockid=', blockid, ',x=', x, ',y=', y, ',z=', z, ',face=', face, ',color=', color)
end

--[[
  设置blockalldata通知周围方块?
  @param  {number} x 指定位置的x
  @param  {number} y 指定位置的y
  @param  {number} z 指定位置的z
  @param  {integer} blockid 方块id
  @return {boolean} 是否成功
]]
function BlockAPI.setBlockAllForUpdate (x, y, z, blockid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Block:setBlockAllForUpdate(x, y, z, blockid)
  end, '设置blockalldata通知周围方块', 'x=', x, ',y=', y, ',z=', z, ',blockid=', blockid)
end

--[[
  设置blockalldata更新当前位置方块?
  @param  {number} x 指定位置的x
  @param  {number} y 指定位置的y
  @param  {number} z 指定位置的z
  @param  {integer} blockid 方块id
  @return {boolean} 是否成功
]]
function BlockAPI.setBlockAllForNotify (x, y, z, blockid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Block:setBlockAllForNotify(x, y, z, blockid)
  end, '设置blockalldata更新当前位置方块', 'x=', x, ',y=', y, ',z=', z, ',blockid=', blockid)
end

--[[
  设置方块设置属性状态，如可破坏、可掉落等
  @param  {integer} blockid 方块id
  @param  {integer} attrtype 方块属性状态值
  @param  {boolean} switch true是，false否
  @return {boolean} 是否成功
]]
function BlockAPI.setBlockSettingAttState (blockid, attrtype, switch)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Block:setBlockSettingAttState(blockid, attrtype, switch)
  end, '设置方块设置属性状态', 'blockid=', blockid, ',attrtype=', attrtype, ',switch=', switch)
end

--[[
  获取方块设置属性状态
  @param  {integer} blockid 方块id
  @param  {integer} attrtype 方块属性状态值
  @return {boolean} 方块设置属性状态
]]
function BlockAPI.getBlockSettingAttState (blockid, attrtype)
  return YcApiHelper.callResultMethod(function ()
    return Block:getBlockSettingAttState(pos)
  end, '获取方块设置属性状态', 'blockid=', blockid, ',attrtype=', attrtype)
end

--[[
  获取开关状态
  @param  {table} pos 开关位置
  @return {boolean} 是否打开
]]
function BlockAPI.getBlockSwitchStatus (pos)
  return YcApiHelper.callResultMethod(function ()
    return Block:getBlockSwitchStatus(pos)
  end, '获取功能方块的开关状态', 'pos=', pos)
end

--[[
  设置开关状态
  @param  {table} pos 开关位置
  @param  {boolean} isActive 是否打开
  @return {boolean} 是否成功
]]
function BlockAPI.setBlockSwitchStatus (pos, isActive)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Block:setBlockSwitchStatus(pos, isActive)
  end, '设置功能方块的开关状态', 'pos=', pos, ',isActive=', isActive)
end

--[[
  通过方向获取方块data值
  @param  {integer} blockid 方块id
  @param  {integer} dir 朝向 0西 1东 2南 3北 4下 5上
  @return {integer} 方块的data
]]
function BlockAPI.getBlockDataByDir (blockid, dir)
  return YcApiHelper.callResultMethod(function ()
    return Block:getBlockDataByDir(blockid, dir)
  end, '通过方向获取方块data值', 'blockid=', blockid, ',dir=', dir)
end

--[[
  获取指定位置方块的通电状态
  @param  {table} pos 方块的位置
  @return {boolean} 是否通电
]]
function BlockAPI.getBlockPowerStatus (pos)
  return YcApiHelper.callResultMethod(function ()
    return Block:getBlockPowerStatus(pos)
  end, '获取方块的通电状态', 'pos=', pos)
end

--[[
  获取随机方块id
  @return {integer} 随机方块id
]]
function BlockAPI.randomBlockID ()
  return YcApiHelper.callResultMethod(function ()
    return Block:randomBlockID()
  end, '获取随机方块id')
end