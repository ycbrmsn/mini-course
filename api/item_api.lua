--[[ 封装道具API v1.0.0
  create by 莫小仙 on 2022-06-19
]]
ItemAPI = {}

--[[
  @param  {integer} itemid 道具id
  @return {string | nil} 道具名称，nil表示获取失败
]]
function ItemAPI.getItemName (itemid)
  return YcApiHelper.callResultMethod(function ()
    return Item:getItemName(itemid)
  end, '获取道具名称', 'itemid=', itemid)
end

--[[
  @param  {integer} objid 对象id
  @return {integer | nil} 道具id，nil表示获取失败
]]
function ItemAPI.getItemId (objid)
  return YcApiHelper.callResultMethod(function ()
    return Item:getItemId(objid)
  end, '获取itemid', 'objid=', objid)
end

--[[
  @param  {integer} objid 掉落物id
  @return {integer | nil} 掉落物数量，nil表示获取失败
]]
function ItemAPI.getDropItemNum (objid)
  return YcApiHelper.callResultMethod(function ()
    return Item:getDropItemNum(objid)
  end, '获取掉落物数量', 'objid=', objid)
end
