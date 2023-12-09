--- 向量工具类 v1.0.1
--- created by 莫小仙 on 2022-07-31
--- last modified on 2023-08-06
YcVectorHelper = {}

--- 获得两个二维向量的夹角
---@param x1 number | YcVector2 | table{ x: number, y: number } 数值或二维向量对象或二维向量表
---@param y1 number | YcVector2 | table{ x: number, y: number } 数值或二维向量对象或二维向量表
---@param x2 number | nil 数值或nil
---@param y2 number | nil 数值或nil
---@return number | nil 角度制夹角，nil表示参数错误
function YcVectorHelper.getTwoVector2Angle(x1, y1, x2, y2)
  if type(x2) == 'number' and type(y2) == 'number' and type(x1) == 'number' and type(y1) == 'number' then -- 4个数值
    return YcVectorHelper.getTwoVector2Angle(YcVector2:new(x1, y1), YcVector2:new(x2, y2))
  elseif YcVector2.isVector2(x1) and YcVector2.isVector2(y1) then -- 两个二维向量
    local cosAngle = x1:dot(y1) / x1:length() / y1:length()
    return math.deg(math.acos(cosAngle))
  elseif type(x1) == 'table' and type(y1) == 'table' then -- 两个表
    return YcVectorHelper.getTwoVector2Angle(YcVector2:new(x1), YcVector2:new(y1))
  end
  local msg =
    YcStringHelper.concat('获取二维向量夹角参数错误：x1=', x1, ',y1=', y1, ',x2=', x2, ',y2=', y2)
  error(msg)
end

--- 获得两个三维向量的夹角
---@param x1 number | YcVector3 | table{ x: number, y: number, z: number } 数值或三维向量对象或三维向量表
---@param y1 number | YcVector3 | table{ x: number, y: number, z: number } 数值或三维向量对象或三维向量表
---@param z1 number | nil 数值或nil
---@param x2 number | nil 数值或nil
---@param y2 number | nil 数值或nil
---@param z2 number | nil 数值或nil
---@return number | nil 角度制夹角，nil表示参数错误
function YcVectorHelper.getTwoVector3Angle(x1, y1, z1, x2, y2, z2)
  if type(x2) == 'number' and type(y2) == 'number' and type(z2) == 'number' and type(x1) == 'number' and type(y1) ==
    'number' and type(z1) == 'number' then -- 6个数值
    return YcVectorHelper.getTwoVector3Angle(YcVector3:new(x1, y1, z1), YcVector3:new(x2, y2, z2))
  elseif YcVector3.isVector3(x1) and YcVector3.isVector3(y1) then -- 两个三维向量
    local cosAngle = x1:dot(y1) / x1:length() / y1:length()
    return math.deg(math.acos(cosAngle))
  elseif type(y1) == 'table' and type(x1) == 'table' then -- 两个表
    return YcVectorHelper.getTwoVector3Angle(YcVector3:new(x1), YcVector3:new(y1))
  end
  local msg = YcStringHelper.concat('获取三维向量夹角参数错误：x1=', x1, ',y1=', y1, ',z1=', z1, ',x2=',
    x2, ',y2=', y2, ',z2=', z2)
  error(msg)
end

--- 获取生物水平旋转角度。忽略y方向，直接与正南方向向量取夹角即可
---@param vec3 table{ x: number, y: number, z: number } 朝向
---@return number 角度
function YcVectorHelper.getActorFaceYaw(vec3)
  local tempAngle = YcVectorHelper.getTwoVector2Angle(0, -1, vec3.x, vec3.z)
  if vec3.x > 0 then
    tempAngle = -tempAngle
  end
  return tempAngle
end

--- 获取玩家水平旋转角度。忽略y方向，计算与正北方向向量夹角（仅当使用第一人称相关视角）
---@param vec3 table{ x: number, y: number, z: number } 朝向
---@return number 角度
function YcVectorHelper.getPlayerFaceYaw(vec3)
  local tempAngle = YcVectorHelper.getTwoVector2Angle(0, 1, vec3.x, vec3.z)
  if vec3.x < 0 then
    tempAngle = -tempAngle
  end
  return tempAngle
end

--- 获取竖直旋转角度
--- 使水平方向上的两个分量对应相同，就可以保证两向量在同一个竖直平面上。然后取到的夹角就是竖直方向上的夹角
---@param vec3 table{ x: number, y: number, z: number } 朝向
---@return number 角度
function YcVectorHelper.getActorFacePitch(vec3)
  local tempAngle = YcVectorHelper.getTwoVector3Angle(vec3.x, 0, vec3.z, vec3:get())
  if vec3.y > 0 then
    tempAngle = -tempAngle
  end
  return tempAngle
end

--- 获得一个指定方向、指定大小的向量，可用于吸引/排斥效果
---@param srcPos table{ x: number, y: number, z: number } 起点位置
---@param dstPos table{ x: number, y: number, z: number } 终点位置
---@param value number | nil 向量大小，默认为1
---@return YcVector3 向量
function YcVectorHelper.getTargetVector3(srcPos, dstPos, value)
  value = value or 1
  local vec3 = YcVector3:new(srcPos, dstPos)
  vec3 = vec3:normalize()
  return vec3 * value
end

--- 获得一个随机方向、指定大小的向量
---@param value number | nil 向量大小，默认为1
---@return YcVector3 向量
function YcVectorHelper.getRandomVector3(value)
  value = value or 1
  local vec3 = YcVector3:new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
  vec3 = vec3:normalize()
  return vec3 * value
end
