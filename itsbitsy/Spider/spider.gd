extends Area2D

@export var speed = 200 # How fast the player will move (pixels/sec).
var edgeOfSprite 
var nextToSpider
var DesiredPosition

var inWebMode = false;
var StartingWebAnchorPoint;

var angle = PI / 4
var angleV = 0 
var angleA = 0
@export var WebLength = 16
@export var SwingGravity = .1
@export var SwingInputForce = 5
@export var AddedWebLength = 32
@export var WebScene : PackedScene

@export var ThreadConsumeRate = 5;
@export var PercentOfThreadLeft = 100;

var thePrey : Bug

#camera stuff
@export var WorldBounds : RectangleShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DesiredPosition = position

func _draw() -> void:
	if inWebMode:
		draw_line(to_local(StartingWebAnchorPoint), to_local(position), Color.WHITE, 6)


func _process(delta):	
	
	if !inWebMode:
		UpdateNormalMovement(delta);
	else:
		WebModeUpdate(delta);
	
	var checkOverlaps = $Check.get_overlapping_bodies();
	
	#todo can make this not in tick but w/e
	var progressBar = $SpiderHUDControl.get_node("SilkBar")
	progressBar.value = PercentOfThreadLeft
	
	queue_redraw()
	
func WebModeUpdate(delta):
	var desired_velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_down") and PercentOfThreadLeft > 0:
		WebLength += AddedWebLength * delta
		PercentOfThreadLeft -= ThreadConsumeRate * delta
		
	if Input.is_action_just_released("move_left"):
		angleV -= SwingInputForce * delta
	if Input.is_action_just_released("move_right"):
		angleV += SwingInputForce * delta
	if Input.is_action_just_released("interact"):
		EndWebMode()
		return

	var force = SwingGravity * sin(angle)
	angleA = (-1 * force) / WebLength
	angleV += angleA
	angle += angleV
	
	var xPos = WebLength * sin(angle) + StartingWebAnchorPoint.x
	var yPos = WebLength * cos(angle) + StartingWebAnchorPoint.y
	
	position = Vector2(xPos, yPos);
	
	angleV *= .99
	
func EndWebMode() :
	var newWeb = WebScene.instantiate()
	newWeb.add_point(to_local(StartingWebAnchorPoint))
	newWeb.add_point(to_local(position))
	newWeb.position = position
	DesiredPosition = position
	owner.add_child(newWeb)
	
	inWebMode = false
	WebLength = AddedWebLength

func OnInteract() :
	
	if thePrey != null : 
		var result = thePrey.onEaten()
		PercentOfThreadLeft += result
		thePrey = null
		return true
	
	if PercentOfThreadLeft > 0 : 
		inWebMode = true 
		StartingWebAnchorPoint = position
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
	
	if isValidMoveLocation :
		position = DesiredPosition

func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("Bugs") : 	
		var theGnat = area.owner
		if theGnat is Bug and inWebMode == false:
			if theGnat.isCaptured() : 
				thePrey = theGnat


func _on_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if thePrey != null :
		if area.owner == thePrey :
			thePrey = null


func _on_body_entered(body: Node2D) -> void:
	if body.owner is Web :
		body.owner.isSpiderOnMe = true
		

func _on_body_exited(body: Node2D) -> void:
	if body.owner is Web :
		body.owner.isSpiderOnMe = false
