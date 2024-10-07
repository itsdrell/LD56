extends Area2D

@export var speed = 200 # How fast the player will move (pixels/sec).
var edgeOfSprite 
var nextToSpider
var DesiredPosition

var inWebMode = false;
var StartingWebAnchorPoint;
var OriginalThreadAmountPercent = 0.0;
var isColliding = false;

var angle = PI / 4
var angleV = 0 
var angleA = 0
@export var WebLength = 16
@export var SwingGravity = .1
@export var SwingInputForce = 5
@export var AddedWebLength = 32
@export var WebScene : PackedScene

@export var ThreadConsumeRate = .5;
@export var ThreadRegenSpeed = 10
@export var PercentOfThreadLeft = 100;

var canExit = false;
var distanceNeeded = 16

var thePrey : Bug
var theCurrentInteract : Interact

#camera stuff
@export var CameraBounds : CollisionShape2D 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DesiredPosition = position
	if CameraBounds != null :
		var boundsPosX = CameraBounds.position.x
		var boundsPosY = CameraBounds.position.y
		var boundsSizeX = CameraBounds.shape.get_rect().size.x
		var boundsSizeY = CameraBounds.shape.get_rect().size.y
		print("hello")
		
		$FollowCamera.limit_right = boundsPosX + (boundsSizeX/2)
		$FollowCamera.limit_bottom = boundsPosY + (boundsSizeY/2)

func _draw() -> void:
	if inWebMode:
		draw_line(to_local(StartingWebAnchorPoint), to_local(position), Color.WHITE, 6)


func _process(delta):	
	
	if !inWebMode:
		UpdateNormalMovement(delta);
		PercentOfThreadLeft += ThreadRegenSpeed * delta
		PercentOfThreadLeft = clamp(PercentOfThreadLeft, 0, 100)
	else:
		WebModeUpdate(delta);
	
	var checkOverlaps = $Check.get_overlapping_bodies();
	
	if $SwingCollision.get_overlapping_bodies().size() == 0 :
		isColliding = false
	
	#todo can make this not in tick but w/e
	var progressBar = $SpiderHUDControl.get_node("SilkBar")
	progressBar.value = PercentOfThreadLeft
	
	DebugStuff()
	queue_redraw()
	
func DebugStuff() :
	
	if Input.is_action_just_pressed("zoom_in") :
		$FollowCamera.zoom += Vector2(1,1)
	if Input.is_action_just_released("zoom_out") :
		$FollowCamera.zoom -= Vector2(1, 1)
	
func WebModeUpdate(delta):
	if !isColliding :
		WebModeSwingMovement(delta)
	else:
		ResetWebSwingVars()
		WebModeWalkingMovement(delta)
		
	if Input.is_action_just_released("interact") and isColliding:
		EndWebMode(true)
		return
	
	# if we have gone back tot he start just exit the mode
	var distanceFromStart = StartingWebAnchorPoint.distance_to(position)
	if canExit and distanceFromStart <= 1 :
		EndWebMode(false) 
		return 
	else :
		if distanceFromStart > distanceNeeded :
			canExit = true
		
	PercentOfThreadLeft = OriginalThreadAmountPercent - (distanceFromStart * ThreadConsumeRate)

func ResetWebSwingVars() :
	DesiredPosition = position
	
func WebModeWalkingMovement(delta) :
	var velocity = CalculateVelocity()
	
	# dont move unless its to give back web if you are out
	if PercentOfThreadLeft <= 0 :
		var pos = position + (velocity * delta * speed)
		var currentDistance = StartingWebAnchorPoint.distance_to(position)
		var newDistance = StartingWebAnchorPoint.distance_to(pos)
		
		if newDistance > currentDistance :
			return
	
	position += (velocity * delta * speed)

func WebModeSwingMovement(delta) :
	var desired_velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_down") and PercentOfThreadLeft > 0:
		WebLength += AddedWebLength * delta
		
	if Input.is_action_pressed("move_up") :
		WebLength -= AddedWebLength * delta
		
	if Input.is_action_just_released("move_left"):
		angleV -= SwingInputForce * delta
	if Input.is_action_just_released("move_right"):
		angleV += SwingInputForce * delta
	
	var force = SwingGravity * sin(angle)
	angleA = (-1 * force) / WebLength
	angleV += angleA
	angle += angleV
	
	var xPos = WebLength * sin(angle) + StartingWebAnchorPoint.x
	var yPos = WebLength * cos(angle) + StartingWebAnchorPoint.y
	
	position = Vector2(xPos, yPos);
	
	angleV *= .99	
	
func EndWebMode(spawnWeb) :
	
	if spawnWeb :
		var newWeb = WebScene.instantiate()
		
		var testasd = to_local(StartingWebAnchorPoint)
		var tesadf = to_local(position)
		
		newWeb.add_point(to_local(StartingWebAnchorPoint))
		newWeb.add_point(to_local(position))
		newWeb.position = position
		owner.add_child(newWeb)
	
	DesiredPosition = position
	inWebMode = false
	canExit = false;
	WebLength = AddedWebLength

func StartWebMode() :
		inWebMode = true 
		StartingWebAnchorPoint = position
		OriginalThreadAmountPercent = PercentOfThreadLeft

func OnInteract() :
	
	if thePrey != null : 
		var result = thePrey.onEaten()
		PercentOfThreadLeft += result
		thePrey = null
		return true
		
	if theCurrentInteract != null : 
		var resuilt = theCurrentInteract.ChangeState()
		return true

	if PercentOfThreadLeft > 0 : 
		StartWebMode()
		return true
		
	return false

func UpdateNormalMovement(delta):
	
	if Input.is_action_just_released("interact"):
		var didWeInteract = OnInteract()
		if didWeInteract : 
			return
	
	var new_velocity = CalculateVelocity();
	if(new_velocity == Vector2.ZERO):
		return
	
	DesiredPosition = position + (new_velocity * delta * speed)
	
	$Check.position = $Check.to_local(DesiredPosition);
	$RayCast2D.position = to_local(position);
	$RayCast2D.target_position = to_local(DesiredPosition) + new_velocity * 10
	
	#if !$RayCast2D.is_colliding() :
	#	var dir = (DesiredPosition - position).normalized()
	#	var dot = dir.dot(Vector2.UP)
		
	#	if dot < 0 :
	#		StartWebMode()
	
func CalculateVelocity() -> Vector2:
	var desired_velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		desired_velocity.x += 1
	if Input.is_action_pressed("move_left"):
		desired_velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		desired_velocity.y += 1
	if Input.is_action_pressed("move_up"):
		desired_velocity.y -= 1
		
	return desired_velocity.normalized()

func _physics_process(delta):
	if inWebMode : 
		return
	
	var checkOverlaps = $Check.get_overlapping_bodies();
	var isValidMoveLocation = !checkOverlaps.is_empty()
	
	isValidMoveLocation = $RayCast2D.is_colliding()
	#print($RayCast2D.get_collider())
	
	if isValidMoveLocation :
		position = DesiredPosition

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("Bugs") : 	
		var theGnat = area.owner
		if theGnat is Bug and inWebMode == false:
			if theGnat.isCaptured() : 
				thePrey = theGnat
	
	if area.is_in_group("Interacts") : 	
		var theInteract = area.owner
		if theInteract is Interact and inWebMode == false:
			theCurrentInteract = theInteract


func _on_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if thePrey != null :
		if area.owner == thePrey :
			thePrey = null
			
	if theCurrentInteract != null :
		if area.owner == theCurrentInteract :
			theCurrentInteract = null


func _on_body_entered(body: Node2D) -> void:
	if body.owner is Web :
		body.owner.isSpiderOnMe = true
		
	#isColliding = true;

func _on_body_exited(body: Node2D) -> void:
	if body.owner is Web :
		body.owner.isSpiderOnMe = false


func _on_swing_collision_body_entered(body: Node2D) -> void:
	isColliding = true;
	
	print(body)
