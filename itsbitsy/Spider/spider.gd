extends Area2D

@export var speed = 100 # How fast the player will move (pixels/sec).

var edgeOfSprite 
var nextToSpider
var DesiredPosition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DesiredPosition = position

func _draw() -> void:
	#draw_circle($Check.position, 64, Color.YELLOW)
	pass

func _process(delta):	
	
	var new_velocity = CalculateVelocity();
	if(new_velocity == Vector2.ZERO):
		return
	
	DesiredPosition = position + (new_velocity * delta * speed)
	
	$Check.position = $Check.to_local(DesiredPosition);

	queue_redraw()
	
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
	var checkOverlaps = $Check.get_overlapping_bodies();
	var isValidMoveLocation = !checkOverlaps.is_empty()
	
	if isValidMoveLocation :
		position = DesiredPosition
