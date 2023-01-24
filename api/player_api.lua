--[[ 封装玩家API v1.1.0
  create by 莫小仙 on 2022-06-13
  last modified on 2023-01-25
]]
PlayerAPI = {}

--[[
  获取玩家属性值
  @param  {integer} objid 迷你号
  @param  {integer} attrtype 属性类型
  @return {number | nil} 属性值，nil表示获取失败
]]
function PlayerAPI.getAttr (objid, attrtype)
  return YcApiHelper.callResultMethod(function ()
    return Player:getAttr(objid, attrtype)
  end, '玩家属性获取', 'objid=', objid, ',attrtype=', attrtype)
end

--[[
  设置玩家属性
  @param  {integer} objid 迷你号
  @param  {integer} attrtype 属性类型
  @param  {number} val 属性值
  @return {boolean} 是否成功
]]
function PlayerAPI.setAttr (objid, attrtype, val)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:setAttr(objid, attrtype, val)
  end, '玩家属性设置', 'objid=', objid, ',attrtype=', attrtype, ',val=', val)
end

--[[
  获取房主迷你号
  @return {number | nil} 迷你号，nil表示获取失败
]]
function PlayerAPI.getHostUin ()
  return YcApiHelper.callResultMethod(function ()
    return Player:getHostUin(objid, attrtype)
  end, '获取房主迷你号')
end

--[[
  判断是否是房主
  @param  {integer} objid 迷你号
  @return {boolean} 是否是房主
]]
function PlayerAPI.isMainPlayer (objid)
  return Player:isMainPlayer(objid) == ErrorCode.OK
end

--[[
  获取本地玩家的迷你号
  @return {integer | nil} 房主迷你号，nil表示没有房主
]]
function PlayerAPI.getMainPlayerUin ()
  return YcApiHelper.callResultMethod(function ()
    return Player:getMainPlayerUin()
  end, '获取本地玩家的uin')
end

--[[
  获取玩家比赛结果
  @param  {integer} objid 迷你号
  @return {integer | nil} 玩家比赛结果TEAM_RESULTS: 
    0胜负未定 TEAM_RESULTS.TEAM_RESULTS_NONE
    1游戏胜利 TEAM_RESULTS.TEAM_RESULTS_WIN
    2游戏结束 TEAM_RESULTS.TEAM_RESULTS_LOSE
    3游戏平局 TEAM_RESULTS.TEAM_RESULTS_DOGFALL
    nil表示获取失败
]]
function PlayerAPI.getGameResults (objid)
  return YcApiHelper.callResultMethod(function ()
    return Player:getGameResults(objid)
  end, '获取玩家比赛结果', 'objid=', objid)
end

--[[
  设置玩家比赛结果
  @param  {integer} objid 迷你号
  @param  {integer} result 比赛结果TEAM_RESULTS: 
    0胜负未定 TEAM_RESULTS.TEAM_RESULTS_NONE
    1游戏胜利 TEAM_RESULTS.TEAM_RESULTS_WIN
    2游戏结束 TEAM_RESULTS.TEAM_RESULTS_LOSE
    3游戏平局 TEAM_RESULTS.TEAM_RESULTS_DOGFALL 
  @return {boolean} 是否成功
]]
function PlayerAPI.setGameResults (objid, result)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:setGameResults(objid, result)
  end, '设置玩家比赛结果', 'objid=', objid, ',result=', result)
end

--[[
  获取玩家游戏分数
  @param  {integer} objid 迷你号
  @return {integer | nil} 玩家分数，nil表示获取失败
]]
function PlayerAPI.getGameScore (objid)
  return YcApiHelper.callResultMethod(function ()
    return Player:getGameScore(objid)
  end, '获取玩家游戏分数', 'objid=', objid)
end

--[[
  设置玩家游戏分数
  @param  {integer} objid 迷你号
  @param  {number} score 分数
  @return {boolean} 是否成功
]]
function PlayerAPI.setGameScore (objid, score)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:setGameScore(objid, score)
  end, '设置玩家游戏分数', 'objid=', objid, ',score=', score)
end

--[[
  获取玩家的排行
  @param  {integer} objid 迷你号
  @return {integer | nil} 玩家排行，nil表示获取失败
]]
function PlayerAPI.getGameRanking (objid)
  return YcApiHelper.callResultMethod(function ()
    return Player:getGameRanking(objid)
  end, '获取玩家的排行', 'objid=', objid)
end

--[[
  给玩家设置排行
  @param  {integer} objid 迷你号
  @param  {number} rank 分数
  @return {boolean} 是否成功
]]
function PlayerAPI.setGameRanking (objid, rank)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:setGameRanking(objid, rank)
  end, '给玩家设置排行', 'objid=', objid, ',rank=', rank)
end

--[[
  给玩家增加道具
  @param  {integer} objid 迷你号
  @param  {number} itemid 道具id
  @param  {integer} num 数量
  @param  {integer} prioritytype 优先类型：1是优先快捷栏2是优先背包栏
  @return {boolean} 是否成功
]]
function PlayerAPI.gainItems (objid, itemid, num, prioritytype)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:gainItems(objid, itemid, num, prioritytype)
  end, '给玩家增加道具', 'objid=', objid, ',itemid=', itemid, ',num=', num, ',prioritytype=', prioritytype)
end

--[[
  传送玩家到出生点
  @param  {integer} objid 迷你号
  @return {boolean} 是否成功
]]
function PlayerAPI.teleportHome (objid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:teleportHome(objid)
  end, '传送玩家到出生点', 'objid=', objid)
end

--[[
  获取玩家当前手持的物品id
  @param  {integer} objid 迷你号
  @return {integer | nil} 道具id，0表示空手，nil表示获取失败
]]
function PlayerAPI.getCurToolID (objid)
  return YcApiHelper.callResultMethod(function ()
    return Player:getCurToolID(objid)
  end, '获取玩家当前手持的物品id', 'objid=', objid)
end

--[[
  获取玩家昵称
  @param  {integer} objid 迷你号
  @return {string | nil} 昵称，nil表示获取失败
]]
function PlayerAPI.getNickname (objid)
  return YcApiHelper.callResultMethod(function ()
    return Player:getNickname(objid)
  end, '获取玩家昵称', 'objid=', objid)
end

--[[
  移走背包里的物品
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具类型id
  @param  {integer} num 道具数量
  @return {boolean} 是否成功
]]
function PlayerAPI.removeBackpackItem (objid, itemid, num)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:removeBackpackItem(objid, itemid, num)
  end, '移走背包里的物品', 'objid=', objid, ',itemid=', itemid, ',num=', num)
end

--[[
  获取玩家死亡次数
  @param  {integer} objid 迷你号
  @return {integer | nil} 死亡次数，nil表示获取失败
]]
function PlayerAPI.getDieTimes (objid)
  return YcApiHelper.callResultMethod(function ()
    return Player:getDieTimes(objid)
  end, '获取玩家死亡次数', 'objid=', objid)
end

--[[
  获取玩家剩下的生命次数
  @param  {integer} objid 迷你号
  @return {integer | nil} 剩下的生命次数，nil表示获取失败
]]
function PlayerAPI.getLeftLifeNum (objid)
  return YcApiHelper.callResultMethod(function ()
    return Player:getLeftLifeNum(objid)
  end, '获取玩家剩下的生命次数', 'objid=', objid)
end

--[[
  设置玩家队伍
  @param  {integer} objid 迷你号
  @param  {integer} teamid 队伍id，0~6，0表示无队伍
  @return {boolean} 是否成功
]]
function PlayerAPI.setTeam (objid, teamid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:setTeam(objid, teamid)
  end, '设置玩家队伍', 'objid=', objid, ',teamid=', teamid)
end

--[[
  获取玩家队伍
  @param  {integer} objid 迷你号
  @return {integer | nil} 队伍id，nil表示获取失败
]]
function PlayerAPI.getTeam (objid)
  return YcApiHelper.callResultMethod(function ()
    return Player:getTeam(objid)
  end, '获取玩家队伍', 'objid=', objid)
end

--[[
  获取当前饱食度
  @param  {integer} objid 迷你号
  @return {number | nil} 饱食度，nil表示获取失败
]]
function PlayerAPI.getFoodLevel (objid)
  return YcApiHelper.callResultMethod(function ()
    return Player:getFoodLevel(objid)
  end, '获取当前饱食度', 'objid=', objid)
end

--[[
  设置玩家饱食度
  @param  {integer} objid 迷你号
  @param  {number} foodLevel 饱食度
  @return {boolean} 是否成功
]]
function PlayerAPI.setFoodLevel (objid, foodLevel)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:setFoodLevel(objid, foodLevel)
  end, '设置玩家饱食度', 'objid=', objid, ',foodLevel=', foodLevel)
end

--[[
  获取当前所用快捷栏键
  @param  {integer} objid 迷你号
  @return {integer | nil} 快捷栏序号，0~7，nil表示获取失败
]]
function PlayerAPI.getCurShotcut (objid)
  return YcApiHelper.callResultMethod(function ()
    return Player:getCurShotcut(objid)
  end, '获取当前所用快捷栏键', 'objid=', objid)
end

--[[
  设置当前玩家手持的道具消耗
  @param  {integer} objid 迷你号
  @param  {integer} num 道具数量
  @return {boolean} 是否成功
]]
function PlayerAPI.onCurToolUsed (objid, num)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:onCurToolUsed(objid, num)
  end, '设置当前玩家手持的道具消耗', 'objid=', objid, ',num=', num)
end

--[[
  设置技能CD
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具id
  @param  {number} cd 冷却时长
  @return {boolean} 是否成功
]]
function PlayerAPI.setSkillCD (objid, itemid, cd)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:setSkillCD(objid, itemid, cd)
  end, '设置技能CD', 'objid=', objid, ',itemid=', itemid, ',cd=', cd)
end

--[[
  复活玩家到指定点
  @param  {integer} objid 迷你号
  @param  {number} x 位置的x
  @param  {number} y 位置的y
  @param  {number} z 位置的z
  @return {boolean} 是否成功
]]
function PlayerAPI.reviveToPos (objid, x, y, z)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:reviveToPos(objid, x, y, z)
  end, '复活玩家到指定点', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z)
end

--[[
  改变玩家复活点位置
  @param  {integer} objid 迷你号
  @param  {number} x 位置的x
  @param  {number} y 位置的y
  @param  {number} z 位置的z
  @return {boolean} 是否成功
]]
function PlayerAPI.setRevivePoint (objid, x, y, z)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:setRevivePoint(objid, x, y, z)
  end, '改变玩家复活点位置', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z)
end

--[[
  玩家乘上坐骑
  @param  {integer} objid 迷你号
  @param  {integer} toobjid 坐骑id
  @param  {integer} posindex 位置序号
  @return {boolean} 是否成功
]]
function PlayerAPI.mountActor (objid, toobjid, posindex)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:mountActor(objid, toobjid, posindex)
  end, '玩家乘上坐骑', 'objid=', objid, ',toobjid=', toobjid, ',posindex=', posindex)
end

--[[
  玩家播放动画
  @param  {integer} objid 迷你号
  @param  {integer} actid 动作id
  @return {boolean} 是否成功
]]
function PlayerAPI.playAct (objid, actid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:playAct(objid, actid)
  end, '玩家播放动画', 'objid=', objid, ',actid=', actid)
end

--[[
  对玩家显示飘窗文字
  @param  {integer} objid 迷你号
  @param  {string} info 飘窗文字
  @return {boolean} 是否成功
]]
function PlayerAPI.notifyGameInfo2Self (objid, info)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:notifyGameInfo2Self(objid, info)
  end, '对玩家显示飘窗文字', 'objid=', objid, ',info=', info)
end

--[[
  旋转玩家镜头
  @param  {integer} objid 迷你号
  @param  {number} yaw 水平旋转角度
  @param  {number} pitch 竖直旋转角度，0为水平方向
  @return {boolean} 是否成功
]]
function PlayerAPI.rotateCamera (objid, yaw, pitch)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:rotateCamera(objid, yaw, pitch)
  end, '旋转玩家镜头', 'objid=', objid, ',yaw=', yaw, ',pitch=', pitch)
end

--[[
  改变玩家视角模式
  @param  {integer} objid 迷你号
  @param  {integer} viewmode 视角模式VIEWPORTTYPE
    0主视角     VIEWPORTTYPE.MAINVIEW
    1背视角     VIEWPORTTYPE.BACKVIEW
    2正视角     VIEWPORTTYPE.FRONTVIEW
    3背视角2    VIEWPORTTYPE.BACK2VIEW
    4俯视角     VIEWPORTTYPE.TOPVIEW
    5自定义视角 VIEWPORTTYPE.CUSTOMVIEW
  @param  {boolean} islock 是否锁定
  @return {boolean} 是否成功
]]
function PlayerAPI.changeViewMode (objid, viewmode, islock)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:changeViewMode(objid, viewmode, islock)
  end, '改变玩家视角模式', 'objid=', objid, ',viewmode=', viewmode, ',islock=', islock)
end

--[[
  设置玩家行为属性状态
  @param  {integer} objid 迷你号
  @param  {integer} actionattr 玩家行为属性PLAYERATTR，如设置玩家可移动
  @param  {boolean} switch 是否开启
  @return {boolean} 是否成功
]]
function PlayerAPI.setActionAttrState (objid, actionattr, switch)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:setActionAttrState(objid, actionattr, switch)
  end, '设置玩家行为属性状态', 'objid=', objid, ',actionattr=', actionattr,
    ',switch=', switch)
end

--[[
  获取玩家特殊属性的状态
  @param  {integer} objid 迷你号
  @param  {integer} actionattr 玩家行为属性PLAYERATTR，如设置玩家可移动
  @return {boolean} 是否开启
]]
function PlayerAPI.checkActionAttrState (objid, actionattr)
  return Player:checkActionAttrState(objid, actionattr) == ErrorCode.OK
end

--[[
  设置玩家位置
  @param  {integer} objid 迷你号
  @param  {number} x 位置的x
  @param  {number} y 位置的y
  @param  {number} z 位置的z
  @return {boolean} 是否成功
]]
function PlayerAPI.setPosition (objid, x, y, z)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:setPosition(objid, x, y, z)
  end, '设置玩家位置', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z)
end

--[[
  获取玩家准星位置
  @param  {integer} objid 迷你号
  @return {number | nil} 位置的x，nil表示获取失败
  @return {number | nil} 位置的y，nil表示获取失败
  @return {number | nil} 位置的z，nil表示获取失败
]]
function PlayerAPI.getAimPos (objid)
  return YcApiHelper.callResultMethod(function ()
    return Player:getAimPos(objid)
  end, '获取玩家准星位置', 'objid=', objid)
end

--[[
  设置玩家道具设置属性
  @param  {integer} objid 迷你号
  @param  {integer} itemid 道具id
  @param  {integer} attrtype 属性类型
    1道具不可丢弃 PLAYERATTR.ITEM_DISABLE_THROW
    2道具不可掉落 PLAYERATTR.ITEM_DISABLE_DROP
  @param  {boolean} switch 是否开启
  @return {boolean} 是否成功
]]
function PlayerAPI.setItemAttAction (objid, itemid, attrtype, switch)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:setItemAttAction(objid, itemid, attrtype, switch)
  end, '设置玩家道具设置属性', 'objid=', objid, ',itemid=', itemid, ',attrtype=',
    attrtype, ',switch=', switch)
end

--[[
  对玩家播放背景音乐
  @param  {integer} objid 迷你号
  @param  {integer} musicid 音效id
  @param  {number} volume 音量，声音大小
  @param  {number} pitch 音调，包括低音、中音、高音的do、rui、mi
  @param  {boolean} isLoop 是否循环播放
  @return {boolean} 是否成功
]]
function PlayerAPI.playMusic (objid, musicid, volume, pitch, isLoop)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:playMusic(objid, musicid, volume, pitch, isLoop)
  end, '对玩家播放背景音乐', 'objid=', objid, ',musicid=', musicid, ',volume=',
    volume, ',pitch=', pitch, ',isLoop=', isLoop)
end

--[[
  停止播放玩家背景音乐
  @param  {integer} objid 迷你号
  @return {boolean} 是否成功
]]
function PlayerAPI.stopMusic (objid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:stopMusic(objid)
  end, '停止播放玩家背景音乐', 'objid=', objid)
end

--[[
  使玩家获得游戏胜利
  @param  {integer} objid 迷你号
  @return {boolean} 是否成功
]]
function PlayerAPI.setGameWin (objid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:setGameWin(objid)
  end, '使玩家获得游戏胜利', 'objid=', objid)
end

--[[
  设置检测掉落物半径
  @param  {integer} objid 迷你号
  @param  {number} radius 检测半径
  @return {boolean} 是否成功
]]
function PlayerAPI.setCheckBoxScale (objid, radius)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:setCheckBoxScale(objid, radius)
  end, '设置检测掉落物半径', 'objid=', objid, ',radius=', radius)
end

--[[
  打开可以操作的箱子
  @param  {integer} objid 迷你号
  @param  {number} x 位置的x
  @param  {number} y 位置的y
  @param  {number} z 位置的z
  @return {boolean} 是否成功
]]
function PlayerAPI.openBoxByPos (objid, x, y, z)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:openBoxByPos(objid, x, y, z)
  end, '打开可以操作的箱子', 'objid=', objid, ',x=', x, ',y=', y, ',z=', z)
end

--[[
  改变玩家移动方式
  @param  {integer} objid 迷你号
  @param  {integer} moveType 移动方式
  @return {boolean} 是否成功
]]
function PlayerAPI.changPlayerMoveType (objid, moveType)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:changPlayerMoveType(objid, moveType)
  end, '改变玩家移动方式', 'objid=', objid, ',moveType=', moveType)
end

--[[
  抖动玩家镜头
  @param  {integer} objid 迷你号
  @param  {number} duration 持续时间
  @param  {number} power 强度
  @return {boolean} 是否成功
]]
function PlayerAPI.shakeCamera (objid, duration, power)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:shakeCamera(objid, duration, power)
  end, '抖动玩家镜头', 'objid=', objid, ',duration=', duration, ',power=', power)
end

--[[
  停止抖动玩家镜头
  @param  {integer} objid 迷你号
  @return {boolean} 是否成功
]]
function PlayerAPI.stopShakeCamera (objid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:stopShakeCamera(objid)
  end, '停止抖动玩家镜头', 'objid=', objid)
end

--[[
  玩家播放qq音乐
  @param  {integer} objid 迷你号
  @param  {integer} musicId 音乐id
  @param  {number} volume 音量
  @param  {boolean} isLoop 是否循环
  @return {boolean} 是否成功
]]
function PlayerAPI.playQQMusic (objid, musicId, volume, isLoop)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:playQQMusic(objid, musicId, volume, isLoop)
  end, '玩家播放qq音乐', 'objid=', objid, ',musicId=', musicId, ',volume=', volume, ',isLoop=', isLoop)
end

--[[
  暂停/恢复/停止玩家的QQ音乐
  @param  {integer} operate 操作
    0暂停 QQMUSICOP.PAUSE
    1恢复 QQMUSICOP.RESUME
    2停止 QQMUSICOP.STOP
  @param  {integer} objid 迷你号
  @return {boolean} 是否成功
]]
function PlayerAPI.operateQQMusic (operate, objid)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:operateQQMusic(operate, objid)
  end, '暂停/恢复/停止玩家的QQ音乐', 'operate=', operate,' ,objid=', objid)
end

--[[
  打开一个UI界面
  @param  {integer} objid 迷你号
  @param  {string} uiname 自定义界面的UIID
  @return {boolean} 是否成功
]]
function PlayerAPI.openUIView (objid, uiname)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:openUIView(objid, uiname)
  end, '打开一个UI界面', 'objid=', objid, ',uiname=', uiname)
end

--[[
  隐藏一个UI界面
  @param  {integer} objid 迷你号
  @param  {string} uiname 自定义界面的UIID
  @return {boolean} 是否成功
]]
function PlayerAPI.hideUIView (objid, uiname)
  return YcApiHelper.callIsSuccessMethod(function ()
    return Player:hideUIView(objid, uiname)
  end, '隐藏一个UI界面', 'objid=', objid, ',uiname=', uiname)
end
