--[[ 封装自定义UIAPI v1.0.0
  create by 莫小仙 on 2023-01-25
]]
CustomuiAPI = {}

--[[
  设置文本元件内容
  @param  {integer} objid 迷你号
  @param  {string} uiid 自定义界面的UIID
  @param  {string} elementid 元件的UIID
  @param  {string} text 显示的内容
  @return {boolean} 是否成功
]]
function CustomuiAPI.setText (objid, uiid, elementid, text)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Customui:setText(objid, uiid, elementid, text)
  end, '设置文本元件内容', 'objid=', objid, ',uiid=', uiid, ',elementid=', elementid, ',text=', text)
end

--[[
  设置文本元件图案纹理
  @param  {integer} objid 迷你号
  @param  {string} uiid 自定义界面的UIID
  @param  {string} elementid 元件的UIID
  @param  {string} url 图片ID
  @return {boolean} 是否成功
]]
function CustomuiAPI.setTexture (objid, uiid, elementid, url)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Customui:setTexture(objid, uiid, elementid, url)
  end, '设置文本元件图案纹理', 'objid=', objid, ',uiid=', uiid, ',elementid=', elementid, ',url=', url)
end

--[[
  设置元件大小
  @param  {integer} objid 迷你号
  @param  {string} uiid 自定义界面的UIID
  @param  {string} elementid 元件的UIID
  @param  {number} width 元件宽度
  @param  {number} height 元件高度
  @return {boolean} 是否成功
]]
function CustomuiAPI.setSize (objid, uiid, elementid, width, height)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Customui:setSize(objid, uiid, elementid, width, height)
  end, '设置元件大小', 'objid=', objid, ',uiid=', uiid, ',elementid=', elementid,
  	',width=', width, ',height=', height)
end

--[[
  设置文本元件字体大小
  @param  {integer} objid 迷你号
  @param  {string} uiid 自定义界面的UIID
  @param  {string} elementid 元件的UIID
  @param  {integer} size 字体大小
  @return {boolean} 是否成功
]]
function CustomuiAPI.setFontSize (objid, uiid, elementid, size)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Customui:setFontSize(objid, uiid, elementid, size)
  end, '设置文本元件字体大小', 'objid=', objid, ',uiid=', uiid, ',elementid=', elementid, ',size=', size)
end

--[[
  设置文本元件颜色
  @param  {integer} objid 迷你号
  @param  {string} uiid 自定义界面的UIID
  @param  {string} elementid 元件的UIID
  @param  {integer} color 16进制颜色值
  @return {boolean} 是否成功
]]
function CustomuiAPI.setColor (objid, uiid, elementid, color)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Customui:setColor(objid, uiid, elementid, color)
  end, '设置文本元件颜色', 'objid=', objid, ',uiid=', uiid, ',elementid=', elementid, ',color=', color)
end

--[[
  显示元件
  @param  {integer} objid 迷你号
  @param  {string} uiid 自定义界面的UIID
  @param  {string} elementid 元件的UIID
  @return {boolean} 是否成功
]]
function CustomuiAPI.showElement (objid, uiid, elementid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Customui:showElement(objid, uiid, elementid)
  end, '显示元件', 'objid=', objid, ',uiid=', uiid, ',elementid=', elementid)
end

--[[
  隐藏元件
  @param  {integer} objid 迷你号
  @param  {string} uiid 自定义界面的UIID
  @param  {string} elementid 元件的UIID
  @return {boolean} 是否成功
]]
function CustomuiAPI.hideElement (objid, uiid, elementid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Customui:hideElement(objid, uiid, elementid)
  end, '隐藏元件', 'objid=', objid, ',uiid=', uiid, ',elementid=', elementid)
end

--[[
  旋转元件
  @param  {integer} objid 迷你号
  @param  {string} uiid 自定义界面的UIID
  @param  {string} elementid 元件的UIID
  @param  {integer} rotate 旋转角度
  @return {boolean} 是否成功
]]
function CustomuiAPI.rotateElement (objid, uiid, elementid, rotate)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Customui:rotateElement(objid, uiid, elementid, rotate)
  end, '旋转元件', 'objid=', objid, ',uiid=', uiid, ',elementid=', elementid, ',rotate=', rotate)
end

--[[
  设置透明度
  @param  {integer} objid 迷你号
  @param  {string} uiid 自定义界面的UIID
  @param  {string} elementid 元件的UIID
  @param  {integer} alpha 透明度
  @return {boolean} 是否成功
]]
function CustomuiAPI.setAlpha (objid, uiid, elementid, alpha)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Customui:setAlpha(objid, uiid, elementid, alpha)
  end, '设置透明度', 'objid=', objid, ',uiid=', uiid, ',elementid=', elementid, ',alpha=', alpha)
end

--[[
  设置状态
  @param  {integer} objid 迷你号
  @param  {string} uiid 自定义界面的UIID
  @param  {string} elementid 元件的UIID
  @param  {integer} state 状态
  @return {boolean} 是否成功
]]
function CustomuiAPI.setState (objid, uiid, elementid, state)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Customui:setState(objid, uiid, elementid, state)
  end, '设置状态', 'objid=', objid, ',uiid=', uiid, ',elementid=', elementid, ',state=', state)
end

--[[
  设置位置
  @param  {integer} objid 迷你号
  @param  {string} uiid 自定义界面的UIID
  @param  {string} elementid 元件的UIID
  @param  {number} x 位置的x
  @param  {number} y 位置的y
  @return {boolean} 是否成功
]]
function CustomuiAPI.setPosition (objid, uiid, elementid, x, y)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Customui:setPosition(objid, uiid, elementid, x, y)
  end, '设置位置', 'objid=', objid, ',uiid=', uiid, ',elementid=', elementid, ',x=', x, ',y=', y)
end

--[[
  获取道具类型图标
  @param  {integer} itemid 道具类型ID
  @return {integer} 道具类型图标id
]]
function CustomuiAPI.getItemIcon (itemid)
  return YcApiHelper.callResultMethod(function ()
    return Customui:getItemIcon(itemid)
  end, '获取道具类型图标', 'itemid=', itemid)
end

--[[
  获取生物图标id
  @param  {integer} objid 生物id
  @return {integer} 生物图标id
]]
function CustomuiAPI.getMonsterObjIcon (objid)
  return YcApiHelper.callResultMethod(function ()
    return Customui:getMonsterObjIcon(objid)
  end, '获取生物图标id', 'objid=', objid)
end

--[[
  获取生物类型图标id
  @param  {integer} actorid 生物类型id
  @return {integer} 生物图标id
]]
function CustomuiAPI.getMonsterIcon (actorid)
  return YcApiHelper.callResultMethod(function ()
    return Customui:getMonsterIcon(actorid)
  end, '获取生物类型图标id', 'actorid=', actorid)
end

--[[
  获取状态类型图标id
  @param  {integer} buffid 状态类型id
  @return {integer} 状态图标id
]]
function CustomuiAPI.getStatusIcon (buffid)
  return YcApiHelper.callResultMethod(function ()
    return Customui:getStatusIcon(buffid)
  end, '获取状态类型图标id', 'buffid=', buffid)
end

--[[
  获取方块类型图标id
  @param  {integer} blockid 方块类型id
  @return {integer} 方块图标id
]]
function CustomuiAPI.getBlockIcon (blockid)
  return YcApiHelper.callResultMethod(function ()
    return Customui:getBlockIcon(blockid)
  end, '获取方块类型图标id', 'blockid=', blockid)
end

--[[
  获取角色类型图标id
  @param  {integer} objid 迷你号
  @return {integer} 角色图标id
]]
function CustomuiAPI.getRoleIcon (objid)
  return YcApiHelper.callResultMethod(function ()
    return Customui:getRoleIcon(objid)
  end, '获取角色类型图标id', 'objid=', objid)
end

--[[
  获取玩家快捷栏道具图标id
  @param  {integer} objid 迷你号
  @param  {integer} index 快捷栏索引（1~8）
  @return {integer} 道具图标id
]]
function CustomuiAPI.getShuctIcon (objid, index)
  return YcApiHelper.callResultMethod(function ()
    return Customui:getShuctIcon(objid, index)
  end, '获取玩家快捷栏道具图标id', 'objid=', objid, ',index=', index)
end