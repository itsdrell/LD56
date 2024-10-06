extends Area2D

@export var speed = 100 # How fast the player will move (pixels/sec).

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DesiredPosition = position

func _draw() -> void:
	#draw_circle($Check.position, 64, Color.YELLOW)

	if inWebMode:
		draw_line(to_local(StartingWebAnchorPoint), to_local(position), Color.WHITE, 6)


func _process(delta):	
	
	if !inWebMode:
		UpdateNormalMovement(delta);
	else:
		WebModeUpdate(delta);
	
	queue_redraw()
	
func WebModeUpdate(delta):
	var desired_velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_down"):
		WebLength += AddedWebLength * delta
		
	if Input.is_action_just_released("move_left"):
		angleV -= SwingInputForce * delta
	if Input.is_action_just_released("move_right"):
		angleV += SwingInputForce * delta
	#if Input.is_action_just_released("interact"):
		#var newWeb = WebScene.instantiate()
		#newWeb.add_point(StartingWebAnchorPoint)
		#newWeb.add_point(position)
		#newWeb.position = StartingWebAnchorPoint
		#add_child(newWeb)

	var force = SwingGravity * sin(angle)
	angleA = (-1 * force) / WebLength
	angleV += angleA
	angle += angleV
	
	var xPos = WebLength * sin(angle) + StartingWebAnchorPoint.x
	var yPos = WebLength * cos(angle) + StartingWebAnchorPoint.y
	
	position = Vector2(xPos, yPos);
	
	angleV *= .99
	
func UpdateNormalMovement(delta):
	
	if Input.is_action_pressed("interact"):
		inWebMode = true 
		StartingWebAnchorPoint = position
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
