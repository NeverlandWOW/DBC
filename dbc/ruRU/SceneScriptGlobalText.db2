WDC4         � �(����9�   ի  ����             0                      �      �     t                                                                      �   �   6  K  �  �  �,  �,  92  W2  �A  �A  �L  �L  -O  BO  t[  �[  �j  �j  z  ;z  t�  ��  ͘  �  П  �  "�  C�  ��  ��  0�  K�  ��  ��  ��  �  �  >�  m�  ��  ��  ��  ��  �  ��  ��  ��  ��  t  �  3 X �  � �   Global Functions - Scene --
-- Scene Functions
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there Object\ObjectClient\SceneScriptGlobal\
--

function Scene:WaitTimer(waitTime)
	local timer = self:Timer(waitTime)
	self:Wait(timer)
end

function Scene:WaitCondition(conditionFunc, freq, maxTime)
	local elapsed = 0;
	if not freq or freq == 0 then
		-- Poll every frame. Reuse the same sync object to avoid allocations
		local timer = self:Timer(0)
		while conditionFunc() ~= true or (maxTime and maxTime < elapsed) do
			elapsed = elapsed + .01;
			timer:Reset()
			self:Wait(timer)
		end
	else
		-- Poll at a certain frequency
		while conditionFunc() ~= true or (maxTime and maxTime < elapsed) do
			elapsed = elapsed + freq;
			self:WaitTimer(freq)
		end
	end
end

function Scene:WaitEvent(freq, keepEvent)
	local waitCondition = function()
		local event = self:PeekEvent()
		if event and event.type ~= SceneEventType.None then
			return true
		else
			return false
		end
	end
	
	self:WaitCondition(waitCondition, freq)
	local event = self:PeekEvent()
	assert(event ~= nil)
	if (keepEvent ~= true) then
		self:PopEvent()
	end
	return event
end

--
-- CreateActorAndWaitForLoad
--  create a single actor and wait for it to be fully renderable
--
function Scene:CreateActorAndWaitForLoad(createData, fadeInTime)
	local actorList = self:CreateActorsAndWaitForLoad({createData}, fadeTime)
	return actorList[1]
end

--
-- CreateActorsAndWaitForLoad
--   create a set of actors and wait for all of them to be renderable
--
function Scene:CreateActorsAndWaitForLoad(createDataList, fadeInTime)
	local actorList = {}
	for index, createData in pairs(createDataList) do
		local actor = self:SpawnActor(createData)
		actorList[index] = actor
	end

	self:WaitForActorsToLoad(actorList, fadeInTime)
	return actorList
end

--
-- WaitForActorsToLoad
--   hide all a list of actors and fade them in when all ready
--
function Scene:WaitForActorsToLoad(actorList, fadeInTime)
	if not fadeInTime then
		fadeInTime = 0.5
	end

	for index, actor in pairs(actorList) do
		actor:SetInteractible(false)
		actor:SetHidden(true)
		actor:Fade(0, 0)
	end

	local waitCondition = function()
		-- all actors must be renderable
		for index, actor in pairs(actorList) do
			if not actor:IsReadyToDisplay() then
				return false
			end
		end
		return true
	end
	self:WaitCondition(waitCondition)

	-- fade in the actors
	for index, actor in pairs(actorList) do
		actor:SetHidden(false)
		actor:Fade(1, fadeInTime)
	end

	-- wait until faded in
	if fadeInTime > 0 then
		self:WaitTimer(fadeInTime)
	end

	-- make everything interactible again
	for index, actor in pairs(actorList) do
		actor:SetInteractible(true)
	end
end

--
-- AddCoroutineWithParams
--   add a coroutine to run next frame, called with parameters
--
function Scene:AddCoroutineWithParams(func, ...)
	local params = {...}
	local paramBindFunc = function()
		func(unpack(params))
	end

	self:AddCoroutine(paramBindFunc)
end

--
-- Editor Functions
--
if (not TimelineKeyField) then
	TimelineKeyField =  { }
end

function TimelineKeyField:Default()
	local data =
	{
		boolData = false;
		integerData = 0;
		floatData = 0;
		transformData = Transform:New();
		stringData = "";
	}
	setmetatable(data, self.__meta)
	return data
end

if (not TimelineKey) then
	TimelineKey =  { }
end

function TimelineKey:Default()
	local data =
	{
		keyIndex = 0;
		keyID = 0;
		eventID = 0;
		propertyIndex = 0;
		actorID = 0;
		actorName = ""; -- deprecate
		keyTime = 0;
		keyFields = { };
		eventFields = { };
	}
	setmetatable(data, self.__meta)
	return data
end


--
-- SceneEvent Functions
--
function SceneEvent:Default()
	local evt = 
	{
		type = SceneEventType.None;
		timeStamp =  Global Functions - Actor --
-- Actor Functions
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

function Actor:WaitCondition(...)
	local scene = self:GetScene()
	if scene then
		scene:WaitCondition(...)
	end
end

function Actor:WaitCastingComplete(checkAnims, spellID)
	local waitCondition = function()
		return ((not self:IsCasting()) and ((not checkAnims) or (checkAnims ~= true) or
		(
			((not spellID) or (not self:HasSpellEffect(spellID))) and
			(not self:IsPlayingSpellPreCastAnim()) and
			(not self:IsPlayingSpellCastAnim()) and
			(not self:IsPlayingCombatAction())
		)))
	end
	self:WaitCondition(waitCondition)
end

function Actor:WaitCastSpell(...)
	self:CastSpell(...)
	self:WaitCastingComplete()
end

function Actor:WaitMissilesReleased(spellVisualInstanceID)
	local waitCondition = function()
		return not self:HasPendingMissiles(spellVisualInstanceID)
	end
	self:WaitCondition(waitCondition)
end

function Actor:WaitMissilesImpacted(spellVisualInstanceID)
	local waitCondition = function()
		return not self:HasPendingOrInFlightMissiles(spellVisualInstanceID)
	end
	self:WaitCondition(waitCondition)
end

function Actor:WaitReadyToDisplay()
	local waitCondition = function()
		return not self:IsReadyToDisplay()
	end
	self:WaitCondition(waitCondition)
end

--
-- ActorAOISettings Functions
--
function ActorAOISettings:Default()
	local lod = 
	{
		priority = ActorAOIPriority.Always;
		range = ActorAOIRange.Infinite;
		minRange = ActorAOIRange.None or 0;
	}
	if (self.__meta) then
		setmetatable(lod, self.__meta)
	end
	return lod
end

--
-- Backwards Compatibility
--
if (not Linkage) then
	Linkage = 
	{
		Default = 0,
	}
end

--
-- ActorFadeRegionSettings Functions
--

-- backwards compatibility
if (not ActorFadeRegionSettings) then
	ActorFadeRegionSettings = { }
end

function ActorFadeRegionSettings:Default()
	local fr = 
	{
		active = false,
		radius = 0.0,
		includePlayer = true,
		excludePlayers = false,
		excludeNonPlayers = false,
		includeSounds = false,
		includeWMOs = false,	
	}
	if (self.__meta) then
		setmetatable(fr, self.__meta)
	end
	return fr
end

--
-- ActorPlayerMount Functions
--

-- backwards compatibility
if (not ActorPlayerMount) then
	ActorPlayerMount = { }
end

function ActorPlayerMount:Default()
	local m = 
	{
		dragonRidingMount = false;
	}
	if (self.__meta) then
		setmetatable(m, self.__meta)
	end
	return m
end

--
-- ActorCreateData Functions
--
function ActorCreateData:Default()
	local c =
	{
		playerCloneToken = "",
		playerCloneIsNative = true,
		itemID = 0,
		itemAppearanceModifierID = 0,
		creatureID = 0,
		creatureDisplaySetIndex = 0,
		creatureDisplayID = 0,
		playerSummon = false,
		playerMount = ActorPlayerMount:Default(),
		wmoFileDataID = 0, -- deprecated
		wmoGameObjectDisplayID = 0,
		model = "",
		modelFileID = 0,
		scale = 1.0,
		facingOffset = 0.0,
		name = "",
		transform = Transform:New(),
		hoverHeight = 0.0,
		groundSnap = true,
		interactible = true,
		selectable = false,
		floatingTooltip = true,
		hasShadow = false,
		smoothPhase = false,
		trackGround = false,
		noTransformUpdates = false,
		copyAnim = false,
		freezeAnim = false,
		noShadow = false,
		disableUpdates = false,
		aoiSettings = ActorAOISettings:Default(),
		overrideReaction = ReactionType.Default,
		overrideMinLod = 0,
		overrideLinkage = Linkage.Default,
		sceneEditorActorID = 0,
		fadeRegionSettings = ActorFadeRegionSettings:Default(),
	}
	setmetatable(c, self.__meta)
	return c
end

function ActorCreateData:New(_id, _trans, _scale)
	local c = ActorCreateData:Default()

	c.creatureID = _id or c.creatureID
	c.scale = _scale or c.scale
	c.transform = _trans

	return c
end

function  Global Functions - Math --
-- Math
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

--
-- Vector Functions
--
function Vector:New(_x, _y, _z)
	local v = { x = _x or 0, y = _y or 0, z = _z or 0 }
	setmetatable(v, self.__meta)
	return v
end

function Vector:ToString()
	return string.format("(%.3f, %.3f, %.3f)", self.x, self.y, self.z)
end

Vector.Concat = function(a, b)
	local stringA = a
	if type(stringA) ~= "string" then
		stringA = a:ToString()
	end

	local stringB = b
	if type(stringB) ~= "string" then
		stringB = b:ToString()
	end

	return (stringA .. stringB)
end

Vector.Add = function(a, b)
	return Vector:New(a.x + b.x, a.y + b.y, a.z + b.z)
end

Vector.Sub = function(a, b)
	return Vector:New(a.x - b.x, a.y - b.y, a.z - b.z)
end

Vector.Mul = function(a, b)
	if type(a) == "number" then
		return Vector:New(a * b.x, a * b.y, a * b.z)
	else
		return Vector:New(a.x * b, a.y * b, a.z * b)
	end
end

Vector.Div = function(a, b)
	if type(b) == "number" then
		return Vector.Mul(a, 1.0 / b)
	end
end

Vector.Neg = function(a)
	return Vector:New(-a.x, -a.y, -a.z)
end

Vector.Magnitude = function(v)
	return math.sqrt(v.x*v.x + v.y*v.y + v.z*v.z)
end

Vector.Normalize = function(v)
	local magnitude = v:Magnitude();
	if (magnitude > 0.001) then
		return Vector:New(
				v.x/magnitude, 
				v.y/magnitude, 
				v.z/magnitude);
	else
		return Vector:New(1, 0, 0)
	end
end

Vector.CrossProduct = function ( a, b ) 
	-- TODO - end result is normalized, go through and fix
	-- usage cases
	return a:UnitCrossProduct(b)
end

Vector.UnitCrossProduct = function ( a, b ) 
	local normalA, normalB = a:Normalize(), b:Normalize();
	return normalA:CrossProductOfUnitVectors(normalB)
end

Vector.CrossProductOfUnitVectors = function ( a, b ) 
	return Vector:New( 
		((a.y * b.z) - (a.z * b.y)),
		((a.z * b.x) - (a.x * b.z)),
		((a.x * b.y) - (a.y * b.x)))
end

Vector.Dist = function ( a, b ) 
	return math.pow (math.pow( a.x-b.x, 2 ) + 
					 math.pow( a.y-b.y, 2 ) +  
					 math.pow( a.z-b.z, 2 ) , 0.5 );
end

Vector.DistXY = function ( a, b ) 
	return math.pow (math.pow( a.x-b.x, 2 ) + 
					 math.pow( a.y-b.y, 2 ), 0.5 );
end

Vector.UnitVectorFromAtoB = function ( a, b ) 
	local offset = b - a
	local dist = offset:Magnitude()
	if (dist > 0.001) then
		return offset * (1.0/dist)
	else
		return Vector:New(1, 0, 0)	
	end
end 

-- add funnctions to the metatable
Vector.__meta.__tostring = Vector.ToString
Vector.__meta.__add = Vector.Add
Vector.__meta.__sub = Vector.Sub
Vector.__meta.__mul = Vector.Mul
Vector.__meta.__div = Vector.Div
Vector.__meta.__unm = Vector.Neg
Vector.__meta.__len = Vector.Magnitude
Vector.__meta.__concat = Vector.Concat

--
-- Transform Functions
--
function Transform:New(v, _yaw, _pitch, _roll)
	local t =
	{
		position = v or Vector:New(),
		yaw = _yaw or 0,
		pitch = _pitch or 0,
		roll = _roll or 0
	}
	setmetatable(t, self.__meta)
	return t
end

--
-- Color Functions
--
if (not Color) then
	Color =  { }
end

function Color:New(_r, _g, _b, _a)
	local c =
	{
		r = _r or 0,
		g = _g or 0,
		b = _b or 0,
		a = _a or 255,
	}
	setmetatable(c, self.__meta)
	return c
end
 Global Constants - Animation --
-- Animation
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

-- Useful Anim Kit IDs
AnimKits =
{
	OneShotSplitBody		= 2127;
	OneShotUpperBody		= 2128;
	OneShotFullBody			= 2129;
	OneShotFullBodyLow		= 2813;
	LoopingSplitBody		= 2130;
	LoopingUpperBody		= 2131;
	LoopingFullBody			= 2132;
	LoopingSplitBodyRide	= 4039;
}

-- matches the AnimKitBoneSet table
AnimKitBoneSets =
{
	Default = -1;
	FullBody = 0;
	UpperBody = 1;
	RightShoulder = 2;
	LeftShoulder = 3;
	Head = 4;
	RightArm = 5;
	LeftArm = 6;
	RightHand = 7;
	LeftHand = 8;
	Jaw = 9;
	FaceUpperIGC = 18;
	FaceLowerIGC = 19;
	FaceHairIGC = 20;
	FaceBeardIGC = 21;
	RightEye = 22;
	LeftEye = 23;
	RightUpperEyelid = 24;
	LeftUpperEyelid = 25;
	RightLowerEyelid = 26;
	LeftLowerEyelid = 27;
	RightWing = 28;	
	LeftWing = 29;
}

-- Construct an animation table out of the 5 individual anim tables
-- When we have removed the 4000 character limit we can eliminate this step

Animations = { }

function AddToAnimTable(subTable)
	for animName, id in pairs(subTable) do
		Animations[animName] = id
	end
end

AddToAnimTable(AnimTable1)
AddToAnimTable(AnimTable2)
AddToAnimTable(AnimTable3)
AddToAnimTable(AnimTable4)

-- avoid duplicate memory
AnimTable1 = nil
AnimTable2 = nil
AnimTable3 = nil
AnimTable4 = nil
 Global Functions - Actor Movement --
-- Actor Movement Helper Functions
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

function Actor:WaitMovementComplete()
	local moveTimeRemaining = 0
	if (Actor.GetRemainingMoveTime) then
		moveTimeRemaining = self:GetRemainingMoveTime()
	end
	
	if (moveTimeRemaining > 0) then
		local scene = self:GetScene()
		scene:WaitTimer(moveTimeRemaining)
	else
		local waitCondition = function()
			return not self:IsMoving()
		end
		self:WaitCondition(waitCondition)
	end
end

function Actor:WaitMoveToRel(...)
	self:MoveToRel(...)
	self:WaitMovementComplete()
end

function Actor:WaitMoveSplineRel(...)
	self:MoveSplineRel(...)
	self:WaitMovementComplete()
end

function Actor:WaitMoveToAbs(...)
	self:MoveToAbs(...)
	self:WaitMovementComplete()
end

function Actor:WaitMoveSplineAbs(...)
	self:MoveSplineAbs(...)
	self:WaitMovementComplete()
end

function Actor:WaitMove(...)
	self:Move(...)
	self:WaitMovementComplete()
end

function Actor:JumpToAbs(target, time, gravity)
	if ((not target) or (not time) or (time < 0.01)) then
		return
	end
	if ((not gravity) or (math.abs(gravity) < 0.01)) then
		gravity = 9.8
	end

	local startPos = self:GetPosition()
	local offset = target - startPos
	local flatDir = Vector:New(offset.x, offset.y)
	local horizDist = flatDir:Magnitude()
	if (horizDist < 0.01) then
		return
	end
	
	-- normalize
	flatDir = flatDir * (1.0 / horizDist)

	local vertDist = offset.z

	-- equations of motion are
	-- x(t) = Vx*t
	-- y(t) = -0.5*g*t*t + V0y*t
	
	local horizV = horizDist/time
	local vertV = 0.5*gravity*time + vertDist/time

	-- construct spline points
	local numPoints = 8
	local jumpData = MoveData:Default(numPoints)
	jumpData.posControl = MovePosControl.PointTime;
	jumpData.yawControl = MoveRotControl.Tangent;
	jumpData.animKitID = 3566

	for i = 1,numPoints do
		local t = time*i/numPoints
		local horiz = horizV*t
		local vert = -0.5*gravity*t*t + vertV*t

		jumpData.points[i].time = t
		jumpData.points[i].pos = startPos + flatDir*horiz + Vector:New(0,0,vert)
	end

	self:SetSnapToGround(false)
	self:Move(jumpData)
end

function Actor:WaitJumpToAbs(...)
	self:JumpToAbs(...)
	self:WaitMovementComplete()
	self:SetSnapToGround(true)
end

--
-- Actor Move Data
--
function MovePoint:Default()
	local p =
	{
		pos = Vector:New();
		lookAt = Vector:New();
		time = 0.0;
		speed = 1.0;
		yaw = 0.0;
		pitch = 0.0;
		roll = 0.0;
	}
	setmetatable(p, self.__meta)
	return p
end

function MoveData:Default(numPoints)
	local d =
	{
		isRelative = false;
		isGroundSnapping = false;
		teleportToFirstPoint = false;
		forceGroundSnapPositionZ = false;
		noDefaultAnimation = false;
		preserveCurrentVelocity = false;
		noFacingBlend = false;
		animKitID = 0;
		posControl = MovePosControl.TotalTime;
		yawControl = MoveRotControl.None;
		pitchControl = MoveRotControl.None;
		rollControl = MoveRotControl.None;
		time = 0.0;
		speed = 1.0;
		points = { };
		pathID = 0;
		initialTime = 0.0;
		moveRate = 1.0;
	}
	if (numPoints and numPoints > 0) then
		for i = 1,numPoints do
			table.insert(d.points, MovePoint:Default())
		end
	end

	setmetatable(d, self.__meta)
	return d
end

local holdYawPitchRollMoveData
function Actor:HoldYawPitchRoll(yaw, pitch, roll, holdTime, blendInTime, blendOutTime)

	if not holdYawPitchRollMoveData then
		holdYawPitchRollMoveData = MoveData:Default(5)
		holdYawPitchRollMoveData.posControl = MovePosControl.PointTime
		holdYawPitchRollMoveData.yawControl = MoveRotControl.Angle
		holdYawPitchRollMoveData.pitchControl = MoveRotControl.Angle
		holdYawPitchRollMoveData.rollControl = MoveRotControl.Angle
		holdYawPitchRollMoveData.noDefaultAnimation = true
	end

	-- defaults
	yaw  Global Functions - Actor Animation --
-- Actor Anim Kit Data
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

if (not AnimKitData) then
	AnimKitData = { }
	AnimKitBlendType = { }
	AnimKitSpeedType = { }
end

function AnimKitData:Default()
	local d =
	{
		animKitID = 0;
		isMaintained = false;
		animOverride = Animations.None;
		boneSetIDOverride = AnimKitBoneSets.Default;
		variationOverride = -1;	-- -1 indicates randomly pick variations
		startTimeOverrideMS = 0;
		startTimeOverrideProgress = 0;
		blendOverrideType = AnimKitBlendType.None or 0;
		blendOverrideMS = 0;
		blendOutOverrideMS = 0;
		speedOverrideType = AnimKitSpeedType.None or 0;
		speedOverrideValue = 0;
		blendWeightOverride = 1;
	}

	setmetatable(d, self.__meta)
	return d
end


--
-- Animation Helper Functions
--
function Actor:PlayLoopingAnimKit(animKitID)	return self:PlayAnimKit(animKitID, true, Animations.None)			end
function Actor:PlayLoopingSplitBodyAnim(anim)	return self:PlayAnimKit(AnimKits.LoopingSplitBody, false, anim)		end
function Actor:PlayLoopingUpperBodyAnim(anim)	return self:PlayAnimKit(AnimKits.LoopingUpperBody, false, anim)		end
function Actor:PlayLoopingFullBodyAnim(anim)	return self:PlayAnimKit(AnimKits.LoopingFullBody, false, anim)		end

function Actor:StopLoopingSplitBodyAnim()		return self:StopAnimKit(AnimKits.LoopingSplitBody)					end
function Actor:StopLoopingUpperBodyAnim()		return self:StopAnimKit(AnimKits.LoopingUpperBody)					end
function Actor:StopLoopingFullBodyAnim()		return self:StopAnimKit(AnimKits.LoopingFullBody)					end

function Actor:PlayOneShotAnimKit(animKitID)	return self:PlayAnimKit(animKitID, false, Animations.None)			end
function Actor:PlayOneShotSplitBodyAnim(anim)	return self:PlayAnimKit(AnimKits.OneShotSplitBody, true, anim)		end
function Actor:PlayOneShotUpperBodyAnim(anim)	return self:PlayAnimKit(AnimKits.OneShotUpperBody, true, anim)		end
function Actor:PlayOneShotFullBodyAnim(anim)	return self:PlayAnimKit(AnimKits.OneShotFullBody, true, anim)		end

function Actor:WaitAnimKitComplete(animKit)
	if not animKit then
		return
	end
	local waitCondition = function()
		return animKit:IsStopped()
	end
	self:WaitCondition(waitCondition)
end

function Actor:WaitPlayOneShotAnimKit(animKitID)	self:WaitAnimKitComplete(self:PlayAnimKit(animKitID, false, Animations.None))		end
function Actor:WaitPlayOneShotSplitBodyAnim(anim)	self:WaitAnimKitComplete(self:PlayAnimKit(AnimKits.OneShotSplitBody, true, anim))	end
function Actor:WaitPlayOneShotUpperBodyAnim(anim)	self:WaitAnimKitComplete(self:PlayAnimKit(AnimKits.OneShotUpperBody, true, anim))	end
function Actor:WaitPlayOneShotFullBodyAnim(anim)	self:WaitAnimKitComplete(self:PlayAnimKit(AnimKits.OneShotFullBody, true, anim))	end
 Global Functions - Actor Sound --
-- Actor Sound Helper Functions
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

function Actor:WaitSoundKitComplete(soundKit)
	if not soundKit then
		return
	end
	local waitCondition = function()
		return soundKit:IsStopped()
	end
	self:WaitCondition(waitCondition)
end

function Actor:WaitBroadcastSoundComplete()
	local waitCondition = function()
		if (self:IsPlayingDialogSound()) then
			return false
		else
			return true
		end
	end
	self:WaitCondition(waitCondition)
end Global Functions - Debug --
-- Debug
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

-- Alias
Broadcast = print;
Print = print;

-- Debug stuff
--
function DEBUG_TABLE(table, depth, lookup)
	if ( not depth ) then
		depth = 0;
	end

	if ( depth > 20 ) then
		return;
	end

	local prefix = "";

	for i=1,depth do
		prefix = prefix.."    ";
	end

	if ( type(table) == "table" ) then 
		for k,v in pairs(table) do	
			local label;
			if ( lookup ) then 
				label = GetStateLabel(k);
			end
			if ( k == "__meta" or k == "__index" ) then 
				Print(prefix.." K :"..k.." V: ".."Unprintable!");
			elseif ( type(v) == "table" ) then 
				if ( label ) then 
					Print(prefix.." K: "..label.." V: { ");
				else
					Print(prefix.." K: "..k.." V: { ");
				end
				DEBUG_TABLE(v, depth+1, lookup); 
				Print(prefix.."  }");
			else
				if ( label ) then 
					Print(prefix.." K: "..label.." V: "..tostring(v));
				else
					Print(prefix.." K: "..k.." V: "..tostring(v));
				end
			end
		end
	else
		Print(prefix.." "..tostring(table) );
	end
end

-- Pet battle specific debug tools - remove this later
function GetStateLabel(zub)
	for k,v in pairs (STATE_LOOKUP) do
		if ( v == zub ) then
			return k;
		end
	end

	return zub;
end

STATE_LOOKUP = {
    STATE_Is_Dead = 1;
    STATE_maxHealthBonus = 2;
    STATE_speedBonus = 3;
    STATE_Stat_Kharma = 4;
    STATE_healthBonus = 17;
    STATE_Stat_Power = 18;
    STATE_Stat_Stamina = 19;
    STATE_Stat_Speed = 20;
    STATE_Mechanic_IsPoisoned = 21;
    STATE_Mechanic_IsStunned = 22;
    STATE_Mod_DamageDealtPercent = 23;
    STATE_Mod_DamageTakenPercent = 24;
    STATE_Mod_SpeedPercent = 25;
    STATE_Ramping_DamageID = 26;
    STATE_Ramping_DamageUses = 27;
    STATE_Condition_WasDamagedThisTurn = 28;
    STATE_untargettable = 29;
    STATE_Mechanic_IsUnderground = 30;
    STATE_Last_HitTaken = 31;
    STATE_Last_HitDealt = 32;
    STATE_Mechanic_IsFlying = 33;
    STATE_Mechanic_IsBurning = 34;
    STATE_turnLock = 35;
    STATE_swapLock = 36;
    STATE_Stat_CritChance = 40;
    STATE_Stat_Accuracy = 41;
    STATE_Passive_Critter = 42;
    STATE_Passive_Beast = 43;
    STATE_Passive_Humanoid = 44;
    STATE_Passive_Flying = 45;
    STATE_Passive_Dragon = 46;
    STATE_Passive_Elemental = 47;
    STATE_Passive_Mechanical = 48;
    STATE_Passive_Magic = 49;
    STATE_Passive_Undead = 50;
    STATE_Passive_Aquatic = 51;
    STATE_Mechanic_IsChilled = 52;
    STATE_Weather_BurntEarth = 53;
    STATE_Weather_ArcaneStorm = 54;
    STATE_Weather_Moonlight = 55;
    STATE_Weather_Darkness = 56;
    STATE_Weather_Sandstorm = 57;
    STATE_Weather_Blizzard = 58;
    STATE_Weather_Mud = 59;
    STATE_Weather_Rain = 60;
    STATE_Weather_Sunlight = 61;
    STATE_Weather_LightningStorm = 62;
    STATE_Weather_Windy = 63;
    STATE_Mechanic_IsWebbed = 64;
    STATE_Mod_HealingDealtPercent = 65;
    STATE_Mod_HealingTakenPercent = 66;
    STATE_Mechanic_IsInvisible = 67;
};

 Global Constants - Animation Table 1 --
-- Animation Table 1
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

AnimTable1 =
{  
	None = -1;
	Stand = 0;
	Death = 1;
	Spell = 2;
	Stop = 3;
	Walk = 4;
	Run = 5;
	Dead = 6;
	Rise = 7;
	StandWound = 8;
	CombatWound = 9;
	CombatCritical = 10;
	ShuffleLeft = 11;
	ShuffleRight = 12;
	Walkbackwards = 13;
	Stun = 14;
	HandsClosed = 15;
	AttackUnarmed = 16;
	Attack1H = 17;
	Attack2H = 18;
	Attack2HL = 19;
	ParryUnarmed = 20;
	Parry1H = 21;
	Parry2H = 22;
	Parry2HL = 23;
	ShieldBlock = 24;
	ReadyUnarmed = 25;
	Ready1H = 26;
	Ready2H = 27;
	Ready2HL = 28;
	ReadyBow = 29;
	Dodge = 30;
	SpellPrecast = 31;
	SpellCast = 32;
	SpellCastArea = 33;
	NPCWelcome = 34;
	NPCGoodbye = 35;
	Block = 36;
	JumpStart = 37;
	Jump = 38;
	JumpEnd = 39;
	Fall = 40;
	SwimIdle = 41;
	Swim = 42;
	SwimLeft = 43;
	SwimRight = 44;
	SwimBackwards = 45;
	AttackBow = 46;
	FireBow = 47;
	ReadyRifle = 48;
	AttackRifle = 49;
	Loot = 50;
	ReadySpellDirected = 51;
	ReadySpellOmni = 52;
	SpellCastDirected = 53;
	SpellCastOmni = 54;
	BattleRoar = 55;
	ReadyAbility = 56;
	Special1H = 57;
	Special2H = 58;
	ShieldBash = 59;
	EmoteTalk = 60;
	EmoteEat = 61;
	EmoteWork = 62;
	EmoteUseStanding = 63;
	EmoteTalkExclamation = 64;
	EmoteTalkQuestion = 65;
	EmoteBow = 66;
	EmoteWave = 67;
	EmoteCheer = 68;
	EmoteDance = 69;
	EmoteLaugh = 70;
	EmoteSleep = 71;
	EmoteSitGround = 72;
	EmoteRude = 73;
	EmoteRoar = 74;
	EmoteKneel = 75;
	EmoteKiss = 76;
	EmoteCry = 77;
	EmoteChicken = 78;
	EmoteBeg = 79;
	EmoteApplaud = 80;
	EmoteShout = 81;
	EmoteFlex = 82;
	EmoteShy = 83;
	EmotePoint = 84;
	Attack1HPierce = 85;
	Attack2HLoosePierce = 86;
	AttackOff = 87;
	AttackOffPierce = 88;
	Sheath = 89;
	HipSheath = 90;
	Mount = 91;
	RunRight = 92;
	RunLeft = 93;
	MountSpecial = 94;
	Kick = 95;
	SitGroundDown = 96;
	SitGround = 97;
	SitGroundUp = 98;
	SleepDown = 99;
	Sleep = 100;
	SleepUp = 101;
	SitChairLow = 102;
	SitChairMed = 103;
	SitChairHigh = 104;
	LoadBow = 105;
	LoadRifle = 106;
	AttackThrown = 107;
	ReadyThrown = 108;
	HoldBow = 109;
	HoldRifle = 110;
	HoldThrown = 111;
	LoadThrown = 112;
	EmoteSalute = 113;
	KneelStart = 114;
	KneelLoop = 115;
	KneelEnd = 116;
	AttackUnarmedOff = 117;
	SpecialUnarmed = 118;
	StealthWalk = 119;
	StealthStand = 120;
	Knockdown = 121;
	EatingLoop = 122;
	UseStandingLoop = 123;
	ChannelCastDirected = 124;
	ChannelCastOmni = 125;
	Whirlwind = 126;
	Birth = 127;
	UseStandingStart = 128;
	UseStandingEnd = 129;
	CreatureSpecial = 130;
	Drown = 131;
	Drowned = 132;
	FishingCast = 133;
	FishingLoop = 134;
	Fly = 135;
	EmoteWorkNoSheathe = 136;
	EmoteStunNoSheathe = 137;
	EmoteUseStandingNoSheathe = 138;
	SpellSleepDown = 139;
	SpellKneelStart = 140;
	SpellKneelLoop = 141;
	SpellKneelEnd = 142;
	Sprint = 143;
	InFlight = 144;
	Spawn = 145;
	Close = 146;
	Closed = 147;
	Open = 148;
	Opened = 149;
	Destroy = 150;
	Destroyed = 151;
	Rebuild = 152;
	Custom0 = 153;
	Custom1 = 154;
	Custom2 = 155;
	Custom3 = 156;
	Despawn = 157;
	Hold = 158;
	Decay = 159;
	BowPull = 160;
	BowRelease = 161;
	ShipStart = 162;
	ShipMoving = 163;
	ShipStop = 164;
	GroupArrow = 165;
	Arrow = 166;
	CorpseArrow = 167;
	GuideArrow = 168;
	Sway = 169;
	DruidCatPounce = 170;
	DruidCatRip = 171;
	DruidCatRake = 172;
	DruidCatRavage = 173;
	DruidCatClaw = 174;
	DruidCatCower = 175;
	DruidBearSwipe = 176;
	DruidBearBite = 177;
	DruidBearMaul = 178;
	DruidBearBash = 179;
	DragonTail = 180;
	DragonStomp = 181;
	DragonSpit = 182;
	DragonSpitHover = 183;
	DragonSpitFly = 184;
	EmoteYes = 185;
	EmoteNo = 186;
	JumpLandRun = 187;
	LootHold = 188;
	LootUp = 189;
	StandHigh = 190;
	Impact = 191;
	LiftOff = 192;
	 Global Constants - Animation Table 2 --
-- Animation Table 2
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

AnimTable2 = {
	Submerge = 201;
	Submerged = 202;
	Cannibalize = 203; 
	ArrowBirth = 204;
	GroupArrowBirth = 205;
	CorpseArrowBirth = 206;
	GuideArrowBirth = 207;
	EmoteTalkNoSheathe = 208;
	EmotePointNoSheathe = 209;
	EmoteSaluteNoSheathe = 210;
	EmoteDanceSpecial = 211;
	Mutilate = 212;
	CustomSpell01 = 213;
	CustomSpell02 = 214;
	CustomSpell03 = 215;
	CustomSpell04 = 216;
	CustomSpell05 = 217;
	CustomSpell06 = 218;
	CustomSpell07 = 219;
	CustomSpell08 = 220;
	CustomSpell09 = 221;
	CustomSpell10 = 222;
	StealthRun = 223;
	Emerge = 224;
	Cower = 225;
	Grab = 226;
	GrabClosed = 227;
	GrabThrown = 228;
	FlyStand = 229;
	FlyDeath = 230;
	FlySpell = 231;
	FlyStop = 232;
	FlyWalk = 233;
	FlyRun = 234;
	FlyDead = 235;
	FlyRise = 236;
	FlyStandWound = 237;
	FlyCombatWound = 238;
	FlyCombatCritical = 239;
	FlyShuffleLeft = 240;
	FlyShuffleRight = 241;
	FlyWalkbackwards = 242;
	FlyStun = 243;
	FlyHandsClosed = 244;
	FlyAttackUnarmed = 245;
	FlyAttack1H = 246;
	FlyAttack2H = 247;
	FlyAttack2HL = 248;
	FlyParryUnarmed = 249;
	FlyParry1H = 250;
	FlyParry2H = 251;
	FlyParry2HL = 252;
	FlyShieldBlock = 253;
	FlyReadyUnarmed = 254;
	FlyReady1H = 255;
	FlyReady2H = 256;
	FlyReady2HL = 257;
	FlyReadyBow = 258;
	FlyDodge = 259;
	FlySpellPrecast = 260;
	FlySpellCast = 261;
	FlySpellCastArea = 262;
	FlyNPCWelcome = 263;
	FlyNPCGoodbye = 264;
	FlyBlock = 265;
	FlyJumpStart = 266;
	FlyJump = 267;
	FlyJumpEnd = 268;
	FlyFall = 269;
	FlySwimIdle = 270;
	FlySwim = 271;
	FlySwimLeft = 272;
	FlySwimRight = 273;
	FlySwimBackwards = 274;
	FlyAttackBow = 275;
	FlyFireBow = 276;
	FlyReadyRifle = 277;
	FlyAttackRifle = 278;
	FlyLoot = 279;
	FlyReadySpellDirected = 280;
	FlyReadySpellOmni = 281;
	FlySpellCastDirected = 282;
	FlySpellCastOmni = 283;
	FlyBattleRoar = 284;
	FlyReadyAbility = 285;
	FlySpecial1H = 286;
	FlySpecial2H = 287;
	FlyShieldBash = 288;
	FlyEmoteTalk = 289;
	FlyEmoteEat = 290;
	FlyEmoteWork = 291;
	FlyEmoteUseStanding = 292;
	FlyEmoteTalkExclamation = 293;
	FlyEmoteTalkQuestion = 294;
	FlyEmoteBow = 295;
	FlyEmoteWave = 296;
	FlyEmoteCheer = 297;
	FlyEmoteDance = 298;
	FlyEmoteLaugh = 299;
	FlyEmoteSleep = 300;
	FlyEmoteSitGround = 301;
	FlyEmoteRude = 302;
	FlyEmoteRoar = 303;
	FlyEmoteKneel = 304;
	FlyEmoteKiss = 305;
	FlyEmoteCry = 306;
	FlyEmoteChicken = 307;
	FlyEmoteBeg = 308;
	FlyEmoteApplaud = 309;
	FlyEmoteShout = 310;
	FlyEmoteFlex = 311;
	FlyEmoteShy = 312;
	FlyEmotePoint = 313;
	FlyAttack1HPierce = 314;
	FlyAttack2HLoosePierce = 315;
	FlyAttackOff = 316;
	FlyAttackOffPierce = 317;
	FlySheath = 318;
	FlyHipSheath = 319;
	FlyMount = 320;
	FlyRunRight = 321;
	FlyRunLeft = 322;
	FlyMountSpecial = 323;
	FlyKick = 324;
	FlySitGroundDown = 325;
	FlySitGround = 326;
	FlySitGroundUp = 327;
	FlySleepDown = 328;
	FlySleep = 329;
	FlySleepUp = 330;
	FlySitChairLow = 331;
	FlySitChairMed = 332;
	FlySitChairHigh = 333;
	FlyLoadBow = 334;
	FlyLoadRifle = 335;
	FlyAttackThrown = 336;
	FlyReadyThrown = 337;
	FlyHoldBow = 338;
	FlyHoldRifle = 339;
	FlyHoldThrown = 340;
	FlyLoadThrown = 341;
	FlyEmoteSalute = 342;
	FlyKneelStart = 343;
	FlyKneelLoop = 344;
	FlyKneelEnd = 345;
	FlyAttackUnarmedOff = 346;
	FlySpecialUnarmed = 347;
	FlyStealthWalk = 348;
	FlyStealthStand = 349;
	FlyKnockdown = 350;
	FlyEatingLoop = 351;
	FlyUseStandingLoop = 352;
	FlyChannelCastDirected = 353;
	FlyChannelCastOmni = 354;
	FlyWhirlwind = 355;
	FlyBirth = 356;
	FlyUseStandingStart = 357;
	FlyUseStandingEnd = 358;
	FlyCreatureSpecial = 359;
	FlyDrown = 360;
	FlyDrowned = 361;
	FlyFishingCast = 362;
	FlyFishingLoop = 363;
	FlyFly = 364;
	 Global Constants - Animation Table 3 --
-- Animation Table 3
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

AnimTable3 = {
	FlyDruidCatRip = 400;
	FlyDruidCatRake = 401;
	FlyDruidCatRavage = 402;
	FlyDruidCatClaw = 403;
	FlyDruidCatCower = 404;
	FlyDruidBearSwipe = 405;
	FlyDruidBearBite = 406;
	FlyDruidBearMaul = 407;
	FlyDruidBearBash = 408;
	FlyDragonTail = 409; 
	FlyDragonStomp = 410;
	FlyDragonSpit = 411;
	FlyDragonSpitHover = 412;
	FlyDragonSpitFly = 413; 
	FlyEmoteYes = 414;
	FlyEmoteNo = 415;
	FlyJumpLandRun = 416;
	FlyLootHold = 417;
	FlyLootUp = 418;
	FlyStandHigh = 419;
	FlyImpact = 420;
	FlyLiftOff = 421;
	FlyHover = 422;
	FlySuccubusEntice = 423;
	FlyEmoteTrain = 424;
	FlyEmoteDead = 425;
	FlyEmoteDanceOnce = 426;
	FlyDeflect = 427;
	FlyEmoteEatNoSheathe = 428;
	FlyLand = 429;
	FlySubmerge = 430;
	FlySubmerged = 431;
	FlyCannibalize = 432;
	FlyArrowBirth = 433;
	FlyGroupArrowBirth = 434;
	FlyCorpseArrowBirth = 435;
	FlyGuideArrowBirth = 436;
	FlyEmoteTalkNoSheathe = 437;
	FlyEmotePointNoSheathe = 438;
	FlyEmoteSaluteNoSheathe = 439;
	FlyEmoteDanceSpecial = 440;
	FlyMutilate = 441;
	FlyCustomSpell01 = 442;
	FlyCustomSpell02 = 443;
	FlyCustomSpell03 = 444;
	FlyCustomSpell04 = 445;
	FlyCustomSpell05 = 446;
	FlyCustomSpell06 = 447;
	FlyCustomSpell07 = 448;
	FlyCustomSpell08 = 449;
	FlyCustomSpell09 = 450;
	FlyCustomSpell10 = 451;
	FlyStealthRun = 452;
	FlyEmerge = 453;
	FlyCower = 454;
	FlyGrab = 455;
	FlyGrabClosed = 456;
	FlyGrabThrown = 457;
	ToFly = 458;
	ToHover = 459;
	ToGround = 460;
	FlyToFly = 461;
	FlyToHover = 462;
	FlyToGround = 463;
	Settle = 464;
	FlySettle = 465;
	DeathStart = 466;
	DeathLoop = 467;
	DeathEnd = 468;
	FlyDeathStart = 469;
	FlyDeathLoop = 470;
	FlyDeathEnd = 471;
	DeathEndHold = 472;
	FlyDeathEndHold = 473;
	Strangulate = 474;
	FlyStrangulate = 475;
	ReadyJoust = 476;
	LoadJoust = 477;
	HoldJoust = 478;
	FlyReadyJoust = 479;
	FlyLoadJoust = 480;
	FlyHoldJoust = 481;
	AttackJoust = 482;
	FlyAttackJoust = 483;
	ReclinedMount = 484;
	FlyReclinedMount = 485;
	ToAltered = 486;
	FromAltered = 487;
	FlyToAltered = 488;
	FlyFromAltered = 489;
	InStocks = 490;
	FlyInStocks = 491;
	VehicleGrab = 492;
	VehicleThrow = 493;
	FlyVehicleGrab = 494;
	FlyVehicleThrow = 495;
	ToAlteredPostSwap = 496;
	FromAlteredPostSwap = 497;
	FlyToAlteredPostSwap = 498;
	FlyFromAlteredPostSwap = 499;
	ReclinedMountPassenger = 500;
	FlyReclinedMountPassenger = 501;
	Carry2H = 502;
	Carried2H = 503;
	FlyCarry2H = 504;
	FlyCarried2H = 505;
	EmoteSniff = 506;
	EmoteFlySniff = 507;
	AttackFist1H = 508;
	FlyAttackFist1H = 509;
	AttackFist1HOff = 510;
	FlyAttackFist1HOff = 511;
	ParryFist1H = 512;
	FlyParryFist1H = 513;
	ReadyFist1H = 514;
	FlyReadyFist1H = 515;
	SpecialFist1H = 516;
	FlySpecialFist1H = 517;
	EmoteReadStart = 518;
	FlyEmoteReadStart = 519;
	EmoteReadLoop = 520;
	FlyEmoteReadLoop = 521;
	EmoteReadEnd = 522;
	FlyEmoteReadEnd = 523;
	SwimRun = 524;
	FlySwimRun = 525;
	SwimWalk = 526;
	FlySwimWalk = 527;
	SwimWalkBackwards = 528;
	FlySwimWalkBackwards = 529;
	SwimSprint = 530;
	FlySwimSprint = 531;
	MountSwimIdle = 532;
	FlyMountSwimIdle = 533;
	MountSwimBackwards = 534;
	FlyMountSwimBackwards = 535;
	MountSwimLeft = 536;
	FlyMountSwimLeft = 537;
	MountSwimRight = 538;
	FlyMountSwimRight = 539;
	MountSwimRun = 540;
	FlyMountSwimRun = 541;
	MountSwimSprint = 542;
	FlyMountSwimSprint = 543;
	MountSwimWalk = 544;
	FlyMountSwimWalk = 545;
	MountSwimWalkBackwards = 546;
	FlyMountSwimWalkBackwards = 547;
	MountFlightIdle = 548;
	FlyMountFlightIdle = 549;
	MountFlightBackwards = 550;
	FlyMountFlightBackwards = 551;
	MountFlightLeft = 552;
	FlyMountFlightLeft = 553;
	MountFlightRight = 554;
	FlyMountFlightRight =  Global Constants - Animation Table 4 --
-- Animation Table 4
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

AnimTable4 =
{
	FlySpellKneelLoop = 370;
	FlySpellKneelEnd = 371;
	FlySprint = 372;
	FlyInFlight = 373;
	FlySpawn = 374;
	FlyClose = 375;
	FlyClosed = 376;
	FlyOpen = 377;
	FlyOpened = 378;
	FlyDestroy = 379;
	FlyDestroyed = 380;
	FlyRebuild = 381;
	FlyCustom0 = 382;
	FlyCustom1 = 383;
	FlyCustom2 = 384;
	FlyCustom3 = 385;
	FlyDespawn = 386;
	FlyHold = 387;
	FlyDecay = 388; 
	FlyBowPull = 389;
	FlyBowRelease = 390;
	FlyShipStart = 391;
	FlyShipMoving = 392;
	FlyShipStop = 393;
	FlyGroupArrow = 394;
	FlyArrow = 395;
	FlyCorpseArrow = 396;
	FlyGuideArrow = 397;
	FlySway = 398;
	FlyDruidCatPounce = 399;
--
	BartenderEmoteTalk = 600;
	FlyBartenderEmoteTalk = 601;
	BartenderEmotePoint = 602;
	FlyBartenderEmotePoint = 603;
	BarmaidStand = 604;
	FlyBarmaidStand = 605;
	BarmaidWalk = 606;
	FlyBarmaidWalk = 607;
	BarmaidRun = 608;
	FlyBarmaidRun = 609;
	BarmaidShuffleLeft = 610;
	FlyBarmaidShuffleLeft = 611;
	BarmaidShuffleRight = 612;
	FlyBarmaidShuffleRight = 613;
	BarmaidEmoteTalk = 614;
	FlyBarmaidEmoteTalk = 615;
	BarmaidEmotePoint = 616;
	FlyBarmaidEmotePoint = 617;
	MountSelfIdle = 618;
	FlyMountSelfIdle = 619;
	MountSelfWalk = 620;
	FlyMountSelfWalk = 621;
	MountSelfRun = 622;
	FlyMountSelfRun = 623;
	MountSelfSprint = 624;
	FlyMountSelfSprint = 625;
	MountSelfRunLeft = 626;
	FlyMountSelfRunLeft = 627;
	MountSelfRunRight = 628;
	FlyMountSelfRunRight = 629;
	MountSelfShuffleLeft = 630;
	FlyMountSelfShuffleLeft = 631;
	MountSelfShuffleRight = 632;
	FlyMountSelfShuffleRight = 633;
	MountSelfWalkBackwards = 634;
	FlyMountSelfWalkBackwards = 635;
	MountSelfSpecial = 636;
	FlyMountSelfSpecial = 637;
	MountSelfJump = 638;
	FlyMountSelfJump = 639;
	MountSelfJumpStart = 640;
	FlyMountSelfJumpStart = 641;
	MountSelfJumpEnd = 642;
	FlyMountSelfJumpEnd = 643;
	MountSelfJumpLandRun = 644;
	FlyMountSelfJumpLandRun = 645;
	MountSelfStart = 646;
	FlyMountSelfStart = 647;
	MountSelfFall = 648;
	FlyMountSelfFall = 649;
	Stormstrike = 650;
	FlyStormstrike = 651;
	ReadyJoustNoSheathe = 652;
	FlyReadyJoustNoSheathe = 653;
	Slam = 654;
	FlySlam = 655;
	DeathStrike = 656;
	FlyDeathStrike = 657;
	SwimAttackUnarmed = 658;
	FlySwimAttackUnarmed = 659;
	SpinningKick = 660;
	FlySpinningKick = 661;
	RoundHouseKick = 662;
	FlyRoundHouseKick = 663;
	RollStart = 664;
	FlyRollStart = 665;
	Roll = 666;
	FlyRoll = 667;
	RollEnd = 668;
	FlyRollEnd = 669;
	PalmStrike = 670;
	FlyPalmStrike = 671;
	MonkOffenseAttackUnarmed = 672;
	FlyMonkOffenseAttackUnarmed = 673;
	MonkOffenseAttackUnarmedOff = 674;
	FlyMonkOffenseAttackUnarmedOff = 675;
	MonkOffenseParryUnarmed = 676;
	FlyMonkOffenseParryUnarmed = 677;
	MonkOffenseReadyUnarmed = 678;
	FlyMonkOffenseReadyUnarmed = 679;
	MonkOffenseSpecialUnarmed = 680;
	FlyMonkOffenseSpecialUnarmed = 681;
	MonkDefenseAttackUnarmed = 682;
	FlyMonkDefenseAttackUnarmed = 683;
	MonkDefenseAttackUnarmedOff = 684;
	FlyMonkDefenseAttackUnarmedOff = 685;
	MonkDefenseParryUnarmed = 686;
	FlyMonkDefenseParryUnarmed = 687;
	MonkDefenseReadyUnarmed = 688;
	FlyMonkDefenseReadyUnarmed = 689;
	MonkDefenseSpecialUnarmed = 690;
	FlyMonkDefenseSpecialUnarmed = 691;
	MonkHealAttackUnarmed = 692;
	FlyMonkHealAttackUnarmed = 693;
	MonkHealAttackUnarmedOff = 694;
	FlyMonkHealAttackUnarmedOff = 695;
	MonkHealParryUnarmed = 696;
	FlyMonkHealParryUnarmed = 697;
	MonkHealReadyUnarmed = 698;
	FlyMonkHealReadyUnarmed = 699;
	MonkHealSpecialUnarmed = 700;
	FlyMonkHealSpecialUnarmed = 701;
	FlyingKick = 702;
	FlyFlyingKick = 703;
	FlyingKickStart = 704;
	FlyFlyingKickStart = 705;
	FlyingKickEnd = 706;
	FlyFlyingKickEnd = 707;
	CraneStart = 708;
	FlyCraneStart  Global Constants - Animation Table 5 --
-- Animation Table 5
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

AnimTable5 =
{
	FlyMountFlightWalk = 561;
	MountFlightWalkBackwards = 562;
	FlyMountFlightWalkBackwards = 563;
	MountFlightStart = 564;
	FlyMountFlightStart = 565;
	MountSwimStart = 566;
	FlyMountSwimStart = 567;
	MountSwimLand = 568;
	FlyMountSwimLand = 569;
	MountSwimLandRun = 570;
	FlyMountSwimLandRun = 571;
	MountFlightLand = 572;
	FlyMountFlightLand = 573;
	MountFlightLandRun = 574;
	FlyMountFlightLandRun = 575;
	ReadyBlowDart = 576;
	FlyReadyBlowDart = 577;
	LoadBlowDart = 578;
	FlyLoadBlowDart = 579;
	HoldBlowDart = 580;
	FlyHoldBlowDart = 581;
	AttackBlowDart = 582;
	FlyAttackBlowDart = 583;
	CarriageMount = 584;
	FlyCarriageMount = 585;
	CarriagePassengerMount = 586;
	FlyCarriagePassengerMount = 587;
	CarriageMountAttack = 588;
	FlyCarriageMountAttack = 589;
	BartenderStand = 590;
	FlyBartenderStand = 591;
	BartenderWalk = 592;
	FlyBartenderWalk = 593;
	BartenderRun = 594;
	FlyBartenderRun = 595;
	BartenderShuffleLeft = 596;
	FlyBartenderShuffleLeft = 597;
	BartenderShuffleRight = 598;
	FlyBartenderShuffleRight = 599;
	ThousandFists = 716;
	FlyThousandFists = 717;
	MonkHealReadySpellDirected = 718;
	FlyMonkHealReadySpellDirected = 719;
	MonkHealReadySpellOmni = 720;
	FlyMonkHealReadySpellOmni = 721;
	MonkHealSpellCastDirected = 722;
	FlyMonkHealSpellCastDirected = 723;
	MonkHealSpellCastOmni = 724;
	FlyMonkHealSpellCastOmni = 725;
	MonkHealChannelCastDirected = 726;
	FlyMonkHealChannelCastDirected = 727;
	MonkHealChannelCastOmni = 728;
	FlyMonkHealChannelCastOmni = 729;
	Torpedo = 730;
	FlyTorpedo = 731;
}
 Global Functions - Matrix Math --
-- Matrix Math
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

-- I'm not validating sizes. Assuming 4x
function MultiplyMatrixes ( ... )
	local matrixA = select(1, ...)
	local matrixB = select(2, ...)

	local newMatrix = {};

	-- Cheap and easy ... can expand or make generic later if needed
	for row = 1, 4 do
		for col = 1, 4 do
			for m = 1, 4 do 
				newMatrix[row] = newMatrix[row] or {};
				newMatrix[row][col] = newMatrix[row][col] or 0;
				newMatrix[row][col] = newMatrix[row][col] + matrixA[row][m] * matrixB[m][col];
			end
		end
	end

	-- Do this many times if required
	if ( select("#", ...) > 2 ) then
		return MultiplyMatrixes ( newMatrix, select(3, ...) );
	end

	return newMatrix;	
end

function ApplyMatrixToVectorPoint( matrixA, vector )
	if ( matrixA == nil ) then
		print("ERROR: MatrixA is nil");
	end

	local matrixB = { 
			[1] = { vector.x };
			[2] = { vector.y };
			[3] = { vector.z };
			[4] = { 1 };
	};

	local newMatrix = {};

	-- Cheap and easy ... can expand or make generic later if needed
	for row = 1, 4 do
		-- col max = #matrixB[1] ?
		for col = 1, 1 do
			for m = 1, 4 do 
				newMatrix[row] = newMatrix[row] or {};
				newMatrix[row][col] = newMatrix[row][col] or 0;
				newMatrix[row][col] = newMatrix[row][col] + matrixA[row][m] * matrixB[m][col];
			end
		end
	end

	-- Pass back a new vector
	return Vector:New( newMatrix[1][1], newMatrix[2][1], newMatrix[3][1] );
end

function CreateTranslationMatrix( deltaX, deltaY, deltaZ )
	local matrix = {
		[1] = { 1, 0, 0, deltaX };
		[2] = { 0, 1, 0, deltaY };
		[3] = { 0, 0, 1, deltaZ };
		[4] = { 0, 0, 0, 1 };
	};

	return matrix;
end

function CreateRotationMatrixAroundX( angle )
	local cos, sin = math.cos(angle), math.sin(angle)
	local matrix = {
		[1] = { 1,    0,    0, 0 };
		[2] = { 0,  cos, -sin, 0 };
		[3] = { 0,  sin,  cos, 0 };
		[4] = { 0,    0,    0, 1 };
	};
	return matrix;
end

function CreateRotationMatrixAroundY( angle )
	local cos, sin = math.cos(angle), math.sin(angle)
	local matrix = {
		[1] = { 1,    0,    0, 0 };
		[2] = { 0,  cos, -sin, 0 };
		[3] = { 0,  sin,  cos, 0 };
		[4] = { 0,    0,    0, 1 };
	};
	return matrix;
end

function CreateRotationMatrixAroundZ( angle )
	local cos, sin = math.cos(angle), math.sin(angle)
	local matrix = {
		[1] = {  cos, -sin, 0, 0 };
		[2] = {  sin,  cos, 0, 0 };
		[3] = {    0,    0, 1, 0 };
		[4] = {    0,    0, 0, 1 };
	};
	return matrix;
end

function CopyMatrix ( M )
	local matrix = {};

	for k,v in pairs( M ) do 
		matrix[k] = {};

		for k2,v2 in pairs( v ) do 
			matrix[k][k2] = v2;
		end
	end

	return matrix;
end

function LocalToWorldMatrix( target, source )
	local forward = target - source;
	forward = forward:Normalize()

	local up = Vector:New(0,0,1);
	local side = forward:CrossProduct( up );

	up = side:CrossProduct( forward );

	-- Create the matrix
	local matrix = CreateTranslationMatrix( Vector:New(0,0,0) );
	matrix[1][1], matrix[1][2], matrix[1][3]  = forward.x, side.x, up.x;
	matrix[2][1], matrix[2][2], matrix[2][3]  = forward.y, side.y, up.y;
	matrix[3][1], matrix[3][2], matrix[3][3]  = forward.z, side.z, up.z;

	-- Translate
	matrix[1][4] = source.x
	matrix[2][4] = source.y
	matrix[3][4] = source.z

	-- Return
	return matrix;
end

function WorldToLocalMatrix( target, source )
	local M = CopyMatrix ( LocalToWorldMatrix( target, source ) )

	return InvertMatrix ( M );
end

function InvertMatrix( M )
	local oldX 
	local oldY 
	local oldZ

	oldX, oldY, oldZ = M[1][4], M[2][4], M[3][4];

	-- Swap values
	M[2][1], M[1][2] = M[1][2], M[2][1];
	M[3][1], M[1][3] = M[1][3], M[3][1];
	M[3][2], M[2][3] = M[2][3], M[3][2];
	
	-- Translate
	M[1][4] =  Global Functions - Actor Interaction --
-- Actor Interaction Helper Functions
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

function Actor:WaitRightClick()
	local rightClickCount = self:GetRightClickCount()
	local waitCondition = function()
		local currentCount = self:GetRightClickCount()
		return (currentCount ~= rightClickCount)
	end
	self:WaitCondition(waitCondition)
end

local RightClickListenerCoroutine

function Actor:AddOnRightClickListener(listenFreq, listenFunc, ...)
	local env = getfenv(2)
	if (not env.RightClickListeners) then
		-- add a listener map to the local environment if we don't already have one
		-- NOTE: we create the table in the calling functions environment
		-- print("Adding listener map")
		env.RightClickListeners = 
		{
			nextID = 0;
			activeListeners = { };
		}
	end

	local listenerID = env.RightClickListeners.nextID
	env.RightClickListeners.nextID = env.RightClickListeners.nextID + 1
	
	local activeListener = { }
	activeListener.ID = listenerID
	activeListener.actor = self
	activeListener.freq = listenFreq
	activeListener.func = listenFunc
	activeListener.params = {...}

	-- add to the listener table
	env.RightClickListeners.activeListeners[listenerID] = activeListener

	-- kick off a listening coroutine
	local scene = self:GetScene()
	scene:AddCoroutineWithParams(RightClickListenerCoroutine, listenerID)

	return listenerID
end

function Actor:CancelOnRightClickListener(listenerID)
	local env = getfenv(2)
	if (env.RightClickListeners and listenerID) then
		env.RightClickListeners.activeListeners[listenerID] = nil
	end
end

--
-- Internal Listener implementation
--
RightClickListenerCoroutine = function(listenerID)
	local env = getfenv(2)
	local clickCount = 0
	local timer

	while true do
		if (not env.RightClickListeners) then
			return
		end

		local listener = env.RightClickListeners.activeListeners[listenerID]
		if (not listener) then
			return
		end

		if (not listener.actor or (listener.actor:IsDespawned() == true)) then
			env.RightClickListeners.activeListeners[listenerID] = nil
			return
		end

		local currentClickCount = listener.actor:GetRightClickCount()
		if (currentClickCount ~= clickCount) then
			-- click occured
			env.RightClickListeners.activeListeners[listenerID] = nil
			listener.func(unpack(listener.params))
			return
		end

		local scene = listener.actor:GetScene()
		if (not timer) then
			timer = scene:Timer(listener.freq)
		else
			timer:Reset()
		end
		scene:Wait(timer)
	end
end [1] Global Functions - Actor Movement = yaw or 0
	pitch = pitch or 0
	roll = roll or 0
	blendInTime = blendInTime or 0
	belndOutTime = blendOutTime or 0
	holdTime = holdTime or 100000 -- 'forever'

	local transform = self:GetTransform()

	-- build a spline so that we get a straight line segment
	for i=1,4 do
		holdYawPitchRollMoveData.points[i].pos = transform.position
		holdYawPitchRollMoveData.points[i].yaw = yaw
		holdYawPitchRollMoveData.points[i].pitch = pitch
		holdYawPitchRollMoveData.points[i].roll = roll
	end

	holdYawPitchRollMoveData.points[5].pos = transform.position
	holdYawPitchRollMoveData.points[5].yaw = transform.yaw
	holdYawPitchRollMoveData.points[5].pitch = transform.pitch
	holdYawPitchRollMoveData.points[5].roll = transform.roll

	if (blendInTime + blendOutTime > holdTime) then
		holdYawPitchRollMoveData.points[1].time = 0
		holdYawPitchRollMoveData.points[2].time = 0
		holdYawPitchRollMoveData.points[3].time = holdTime
		holdYawPitchRollMoveData.points[4].time = holdTime
		holdYawPitchRollMoveData.points[5].time = holdTime
	else
		holdYawPitchRollMoveData.points[1].time = 0.5*blendInTime
		holdYawPitchRollMoveData.points[2].time = blendInTime
		holdYawPitchRollMoveData.points[3].time = holdTime - blendOutTime
		holdYawPitchRollMoveData.points[4].time = holdTime - 0.5*blendOutTime
		holdYawPitchRollMoveData.points[5].time = holdTime
	end

	self:Move(holdYawPitchRollMoveData)
end
 Global Constants - Attachments --
-- Attachments
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

AttachmentPoint =
{
	None				= -1;
	MountMain			=  0;
	Shield				=  0;
	HandRight			=  1;
	HandLeft			=  2;
	ElbowRight			=  3;
	ElbowLeft			=  4;
	ShoulderRight		=  5;
	ShoulderLeft		=  6;
	KneeRight			=  7;
	KneeLeft			=  8;
	HipRight			=  9;
	HipLeft				= 10;
	Helm				= 11;
	Back				= 12;
	ShoulderFlapRight	= 13;
	ShoulderFlapLeft	= 14;
	ChestBloodFront		= 15;
	ChestBloodBack		= 16;
	Breath				= 17;
	PlayerName			= 18;
	Base				= 19;
	Head				= 20;
	SpellLeftHand		= 21;
	SpellRightHand		= 22;
	Special1			= 23;
	Special2			= 24;
	Special3			= 25;
	SheathMainHand		= 26;
	SheathOffHand		= 27;
	SheathShield		= 28;
	PlayerNameMounted	= 29;
	LargeWeaponLeft		= 30;
	LargeWeaponRight	= 31;
	HipWeaponLeft		= 32;
	HipWeaponRight		= 33;
	Chest				= 34;
	HandArrow			= 35;
	Bullet				= 36;
	SpellHandOmni		= 37;
	SpellHandDirected	= 38;
	VehicleSeat1		= 39;
	VehicleSeat2		= 40;
	VehicleSeat3		= 41;
	VehicleSeat4		= 42;
	VehicleSeat5		= 43;
	VehicleSeat6		= 44;
	VehicleSeat7		= 45;
	VehicleSeat8		= 46;
	LeftFoot			= 47;
	RightFoot			= 48;
	ShieldNoGlove		= 49;
	SpineLow			= 50;
	AlteredShoulderR	= 51;
	AlteredShoulderL	= 52;
	BeltBuckle			= 53;
	SheathCrossbow		= 54;
	HeadTop				= 55;
}

--
-- Actor Attachment Kit Data
--
if (not AttachmentData) then
	AttachmentData = { }
end

function AttachmentData:Default()
	local d =
	{
		parentActor = nil;
		parentAttachment = AttachmentPoint.None;
		childAttachment  = AttachmentPoint.None;
		useChildAttachOrientation = false;
		useTargetOffset = false;
		useParentAsMount = false;
		targetOffset = Transform:New();
		transitionTime = 0;
		respectGroundSnap = false;
	}

	setmetatable(d, self.__meta)
	return d
end Global Functions - Actor Vehicles --
-- Actor Vehicles
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

local jumpOntoOffsetZ = 0.25
local RideVehicleActorInternal
local VehicleSystemDebug

--------------------------------------------------------------------------------
function JumpRideVehicleActor(riderActor, vehicleActor, jumpTime, seatAttach, seatOffset, jumpOffset, seatAngles, riderAttach, useRiderAttachOrientation, useVehicleAsMount)
	if (not riderActor) then
		return 0
	end

	local jumpVehicleRideData = { }

	jumpVehicleRideData.jumpTime = jumpTime or 1.0
	jumpVehicleRideData.seatAttach = seatAttach or AttachmentPoint.MountMain
	jumpVehicleRideData.seatOffset = seatOffset or Vector:New()
	jumpVehicleRideData.seatAngles = seatAngles or Vector:New()
	jumpVehicleRideData.jumpOffset = jumpOffset or Vector:New(0, 0, jumpOntoOffsetZ)
	jumpVehicleRideData.riderAttach = riderAttach or AttachmentPoint.None
	jumpVehicleRideData.useRiderAttachOrientation = useRiderAttachOrientation or false
	jumpVehicleRideData.useVehicleAsMount = useVehicleAsMount or false
	jumpVehicleRideData.rideAnim = Animations.Mount
	
	-- NOTE: structured like this to avoid a tail call, which complicated getfenv in the internal function
	local attachTime = RideVehicleActorInternal(vehicleActor, riderActor, jumpVehicleRideData)
	return attachTime
end

--------------------------------------------------------------------------------
function WaitJumpRideVehicleActor(riderActor, ...)
	if (not riderActor) then
		return
	end

	local jumpTime = JumpRideVehicleActor(riderActor, ...)
	if (jumpTime > 0) then
		(riderActor:GetScene()):WaitTimer(jumpTime)
	end
end

--------------------------------------------------------------------------------
function JumpExitVehicleActor(riderActor, exitPoint, jumpTime)
	if (not riderActor) then
		return 0
	end

	local jumpExitVehicleRideData =	{ }
	jumpExitVehicleRideData.jumpTime = jumpTime or 1.0
	jumpExitVehicleRideData.jumpAbs = exitPoint or (riderActor:GetPosition() + Vector:New(0, 0, -jumpOntoOffsetZ))
	local attachTime = RideVehicleActorInternal(nil, riderActor, jumpExitVehicleRideData)
	return attachTime
end

--------------------------------------------------------------------------------
function WaitJumpExitVehicleActor(riderActor, ...)
	if (not riderActor) then
		return
	end

	local jumpTime = JumpExitVehicleActor(riderActor, ...)
	if (jumpTime > 0) then
		(riderActor:GetScene()):WaitTimer(jumpTime)
		riderActor:SetSnapToGround(true)
	end
end

--------------------------------------------------------------------------------
function RideVehicleActor(riderActor, vehicleActor, blendTime, seatAttach, seatOffset, seatAngles, rideAnim)
	local blendVehicleRideData = { }

	blendVehicleRideData.attachBlendTime = blendTime or 0.0
	blendVehicleRideData.seatAttach = seatAttach or AttachmentPoint.MountMain
	blendVehicleRideData.seatOffset = seatOffset or Vector:New()
	blendVehicleRideData.seatAngles = seatAngles or Vector:New()
	blendVehicleRideData.riderAttach = riderAttach or AttachmentPoint.None
	blendVehicleRideData.rideAnim = rideAnim or Animations.Mount

	local attachTime = RideVehicleActorInternal(vehicleActor, riderActor, blendVehicleRideData)
	return attachTime
end

--------------------------------------------------------------------------------
function WaitRideVehicleActor(riderActor, ...)
	local rideTime = RideVehicleActor(riderActor, ...)
	if (rideTime > 0) then
		(riderActor:GetScene()):WaitTimer(rideTime)
	end
end

--------------------------------------------------------------------------------
-- INTERNAL VEHICLE FUNCTIONS
--   Call the functions above, please contact Darren Williams if you need
--   additional functionality
 [1] Global Functions - Actor Vehicles --------------------------------------------------------------------------------

--
-- Vehicle Ride Data is a table with the following options
-- {
--	jumpTime
--	seatAttach
--	seatOffset
--  seatAngles
--  attachBlendTime
--  jumpAbs			:   world space location for the end of the jump
--  jumpOffset		:	if above not specified, world space offset for the jump to finish at from the target attach point
--  riderAttach		:   attachment point of the rider to attach to the seat attach, defaults to root
--  useRiderAttachOrientation : apply the orientation of the rider attachment point
--  rideAnim		:	animation to play while riding
--}
--

local rideVehicleAttachData
local rideVehicleMaxAttachBlendTime = 0.25
local GetVehicleSystem
local RideVehicleAttachValid
local RideVehicleActorStartAttach

--------------------------------------------------------------------------------
RideVehicleActorInternal = function(vehicleActor, riderActor, vehicleRideData)
	if (not vehicleRideData or type(vehicleRideData) ~= "table" ) then
		return 0
	end

	if (not riderActor) then
		return 0
	end

	-- stop current ride and remove from manager
	StopRidingVehicleActorInternal(riderActor)

	-- add to the manager
	local vehicleAttachment = { }
	vehicleAttachment.vehicleActor = vehicleActor
	vehicleAttachment.riderActor = riderActor
	vehicleAttachment.data = vehicleRideData

	local vehicleSystem = GetVehicleSystem()
	vehicleSystem.vehicleAttachments[riderActor] = vehicleAttachment

	-- set default values
	vehicleRideData.jumpTime		= vehicleRideData.jumpTime or 0
	vehicleRideData.seatAttach		= vehicleRideData.seatAttach or AttachmentPoint.None
	vehicleRideData.seatOffset		= vehicleRideData.seatOffset or Vector:New()
	vehicleRideData.seatAngles		= vehicleRideData.seatAngles or Vector:New()
	vehicleRideData.jumpOffset		= vehicleRideData.jumpOffset or Vector:New()
	vehicleRideData.riderAttach		= vehicleRideData.riderAttach or AttachmentPoint.None
	vehicleRideData.useRiderAttachOrientation = vehicleRideData.useRiderAttachOrientation or false
	vehicleRideData.useVehicleAsMount = vehicleRideData.useVehicleAsMount or false

	vehicleAttachment.riderActor:SetSnapToGround(false)

	-- start a jump if needed
	local jumpEndPos
	if (vehicleRideData.jumpTime > 0) then
		jumpEndPos = vehicleRideData.jumpAbs
		if (not jumpEndPos and vehicleAttachment.vehicleActor) then
			local offsetTransform = Transform:New(vehicleRideData.seatOffset)
			local mountAttachTransform = vehicleAttachment.vehicleActor:GetAttachmentTransform(vehicleRideData.seatAttach, offsetTransform, vehicleRideData.jumpTime)
			jumpEndPos = mountAttachTransform.position + vehicleRideData.jumpOffset
		end

		if (jumpEndPos) then
			-- contain attach blend time within the jump time
			vehicleAttachment.attachBlendTime = vehicleRideData.attachBlendTime or rideVehicleMaxAttachBlendTime
			if (vehicleAttachment.attachBlendTime > vehicleRideData.jumpTime) then
				vehicleAttachment.attachBlendTime = vehicleRideData.jumpTime*0.5
			end

			vehicleAttachment.riderActor:JumpToAbs(jumpEndPos, vehicleRideData.jumpTime)
		end
	elseif (vehicleRideData.attachBlendTime) then
		vehicleAttachment.attachBlendTime = vehicleRideData.attachBlendTime
	end

	-- delay the attachment if jumping
	if (vehicleAttachment.vehicleActor) then
		if (jumpEndPos) then
			-- queue up attaching
			(riderActor:GetScene()):AddCoroutineWithParams(RideVehicleActorStartAttach, vehicleAttachment)
		else
			-- start attachment immediately
			RideVehicleActorStartAttach(vehicleAttachment)
		end
	end

	if (vehicleRideData.jumpTime > 0) then
		return vehicleRideData.jumpTime
	else
		return (vehicleRideData.attachBlendTime or 0)
	end
end

--------------------------------------------------------------------------------
function  [2] Global Functions - Actor Vehicles StopRidingVehicleActorInternal(riderActor)
	local vehicleSystem = GetVehicleSystem()
	if (not riderActor or not vehicleSystem) then
		return
	end

	local vehicleAttachment = vehicleSystem.vehicleAttachments[riderActor]

	-- remove from the current managed list if it is in there
	if (vehicleAttachment) then
		if (vehicleAttachment.rideAnimKit) then
			vehicleAttachment.rideAnimKit:Stop()
		end
		vehicleSystem.vehicleAttachments[riderActor] = nil
	end

	riderActor:SetRelativeTo(nil)
end

--------------------------------------------------------------------------------
RideVehicleActorStartAttach = function(vehicleAttachment)
	if (RideVehicleAttachValid(vehicleAttachment) ~= true) then
		return
	end

	if (not vehicleAttachment.riderActor) then
		return
	end

	local attachBlendTime = vehicleAttachment.attachBlendTime or 0
	local delayTime = (vehicleAttachment.data.jumpTime or 0) - attachBlendTime
	if (delayTime > 0) then
		(vehicleAttachment.riderActor:GetScene()):WaitTimer(delayTime)

		if (RideVehicleAttachValid(vehicleAttachment) ~= true) then
			return
		end
	end

	if (not rideVehicleAttachData) then
		rideVehicleAttachData = AttachmentData:Default()
	end
	rideVehicleAttachData.parentActor = vehicleAttachment.vehicleActor
	rideVehicleAttachData.parentAttachment = vehicleAttachment.data.seatAttach
	rideVehicleAttachData.childAttachment = vehicleAttachment.data.riderAttach
	rideVehicleAttachData.useChildAttachOrientation = vehicleAttachment.data.useRiderAttachOrientation
	rideVehicleAttachData.useTargetOffset = true
	rideVehicleAttachData.useParentAsMount = vehicleAttachment.data.useVehicleAsMount
	rideVehicleAttachData.targetOffset = Transform:New(vehicleAttachment.data.seatOffset, vehicleAttachment.data.seatAngles.x, vehicleAttachment.data.seatAngles.y, vehicleAttachment.data.seatAngles.z)
	rideVehicleAttachData.transitionTime = attachBlendTime
	vehicleAttachment.riderActor:SetAttachedTo(rideVehicleAttachData)

	-- play a ride anim if necessary
	if (vehicleAttachment.data.rideAnim) then
		vehicleAttachment.rideAnimKit = vehicleAttachment.riderActor:PlayAnimKit(AnimKits.LoopingSplitBodyRide, false, vehicleAttachment.data.rideAnim)
	end
end

--------------------------------------------------------------------------------
RideVehicleAttachValid = function(vehicleAttachment)
	if (not vehicleAttachment or type(vehicleAttachment) ~= "table") then
		return false
	end
	if (not vehicleAttachment.riderActor) then
		return false
	end

	local vehicleSystem = GetVehicleSystem()
	if (not vehicleSystem) then
		return false
	end

	local currentRiderAttachment = vehicleSystem.vehicleAttachments[vehicleAttachment.riderActor]
	if (currentRiderAttachment ~= vehicleAttachment) then
		return false
	end

	return true
end

--------------------------------------------------------------------------------
GetVehicleSystem = function()
	-- return or create a vehicle system for this environment

	-- iterate up the stack until we get an environment that is not global
	local stackLevel = 1
	local myEnv = getfenv(stackLevel)
	local env
	while ((not env) or (env == myEnv)) do
		stackLevel = stackLevel + 1
		env = getfenv(stackLevel)
	end

	local vehicleSystem
	if (not env) then
		VehicleSystemDebug("ERROR: couldn't find environment for vehicle system")
	elseif (not env._VehicleSystem) then
		VehicleSystemDebug("Adding vehicle system to environment")
		vehicleSystem = 
		{
			vehicleAttachments = { };
		}
		env._VehicleSystem = vehicleSystem
	else
		vehicleSystem = env._VehicleSystem
	end
	return vehicleSystem
end

--------------------------------------------------------------------------------
local debugEnabled = false
VehicleSystemDebug = function(msg)
	if (debugEnabled == true) then
		print("VEHCILE_SYS: " .. tostring(msg))
	end
end

 Global Constants - TextEffect Styles --
-- TextEffect Styles
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

-- Text Effect Styles
TextEffectStyle =
{
	Garrison				= 6;
	Metal					= 7;
	Parchment				= 8;
	IronHordeMetal			= 9;
	BlueGradient			= 10;
	Legion					= 11;
}
 [1] Global Functions - Scene 0;
		timeSeconds = 0;
		integerData = 0;
		floatData = 0;
		stringData = "";
		vectorData = Vector:New();
		
		-- timeline editor
		editorTimeSeconds = 0;
		editorKey = TimelineKey:Default();		
	}
	setmetatable(evt, self.__meta)
	return evt
end Global Functions - Table Wrappers --
-- Table Wrappers
-- These Scripts have been added to SVN, if you make a change here, update it
-- also there \Object\ObjectClient\SceneScriptGlobal\
--

-- Dummy functions that simply return the passed value back.
-- These are used by the editor to indicate which table type a magic number is
-- e.g. sid(1234) is spell 1234, cid(1234) is creature 1234

local wrappers =
{
    animationData = 'adid',
    animKit = 'akid',
    broadcastText = 'btid',
    cameraEffect = 'ceid',
    cameraMode = 'cmid',
    creature = 'cid',
    creatureDisplayInfo = 'cdiid',
	fileData = 'fid',
	gameObjectDisplayInfo = 'gdi',
	item = 'iid',
    movie = 'mid',
    screenEffect = 'seid',
    soundKit = 'skid',
	spell = 'sid',
    spellVisual = 'svid',
	weather = 'wid',
}

local env = getfenv();
for t, shortcut in pairs(wrappers) do
	env[shortcut] = function(id) return id end;
end [1] Global Functions - Actor ActorCreateData:NewDisplay(_creatureID, _displayId, _trans, _scale)
	local c = ActorCreateData:Default()

	c.creatureID = _creatureID or c.creatureID
	c.creatureDisplayID = _displayID or c.creatureDisplayID
	c.scale = _scale or c.scale
	c.transform = _trans

	return c
end

function ActorCreateData:NewModel(_name, _modelFile, _trans, _scale)
	local c = ActorCreateData:Default()

	if type(_modelFile) == "number" then
		c.modelFileID = _modelFile
	else
		c.model = _modelFile
	end
	c.scale = _scale or c.scale
	c.name = _name
	c.transform = _trans

	return c
end


--
-- ActorHeadLookData Functions
--
-- backwards compatibility
if (not ActorHeadLookData) then
	ActorHeadLookData = { }
end

function ActorHeadLookData:Default()
	local afd =
	{
		headLookType = HeadLookType.None,
		facingAngleYaw = 0.0,
		facingAnglePitch = 0.0,
		target = nil,
		targetActivePlayer = false,
		offset = { x=0, y=0, z=0 },
		facingToPos = { x=0, y=0, z=0 },
		increaseLookAtPitchAngle = false,
		isPersistent = true,
		headFacingTurnRate = 0.0,
	}
	
	setmetatable(afd, self.__meta)
	return afd
end


--[[
function ScaleData:Default()
	local d =
	{
		scale = 1.0;
		scaleDuration = 2000;
	}

	setmetatable(d, self.__meta)
	return d
end
]] [1] Global Constants - Animation Table 1 Hover = 193;
	SuccubusEntice = 194;
	EmoteTrain = 195;
	EmoteDead = 196;
	EmoteDanceOnce = 197;
	Deflect = 198;
	EmoteEatNoSheathe = 199;
	Land = 200;}
 [1] Global Constants - Animation Table 2 FlyEmoteWorkNoSheathe = 365;
	FlyEmoteStunNoSheathe = 366;
	FlyEmoteUseStandingNoSheathe = 367;
	FlySpellSleepDown = 368;
	FlySpellKneelStart = 369;
}
 [1] Global Constants - Animation Table 3 555;
	MountFlightRun = 556;
	FlyMountFlightRun = 557;
	MountFlightSprint = 558;
	FlyMountFlightSprint = 559;
	MountFlightWalk = 560;
}
 [1] Global Constants - Animation Table 4 = 709;
	CraneLoop = 710;
	FlyCraneLoop = 711;
	CraneEnd = 712;
	FlyCraneEnd = 713;
	Despawned = 714;
	FlyDespawned = 715;
}
 [1] Global Functions - Matrix Math -oldX
	M[2][4] = -oldY
	M[3][4] = -oldZ

	return M
end    	   
   /   =   >   F  c  �  �  �  �  �    %  �(  �(  �(  �(  �(  �N  �O  �U  6g  ѫ  ҫ  ӫ  ԫ  ի  