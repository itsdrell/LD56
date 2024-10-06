extends Node2D

@export var speed = 20 #pixels/sec
@export var wanderStep = 45 #distance between each wander

var wanderMax = 0 #set in ready by the WanderArea shape
var targetPosition = Vector2.ZERO
var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WaitTimer.start(randf_range(0.5,1))
	wanderMax = $WanderArea.shape.radius - $GnatBody/CollisionShape2D.shape.radius
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move(delta)	
	#queue_redraw()

#func _draw() -> void:
	#draw_circle($InitialSpawnPoint.position, wanderMax, Color.SKY_BLUE)
	#draw_circle($InitialSpawnPoint.position, 3, Color.YELLOW)
	#draw_circle(targetPosition, 3, Color.DARK_RED)
	
func move(delta: float):
	#--- MOVEMENT ---
	# move towards target position
	if ($WaitTimer.time_left == 0) : velocity = $GnatBody.position.direction_to(targetPosition) * speed
	# if near target postion, wait
	if ($GnatBody.position.distance_to(targetPosition) < (speed * 0.1) and $WaitTimer.time_left == 0):
		$WaitTimer.start()
		velocity = Vector2.ZERO
	
	$GnatBody.position += velocity * delta
	# repeat
	
func pickPoint():
	targetPosition = $GnatBody.position + Vector2(randi_range(-wanderStep,wanderStep),randi_range(-wanderStep,wanderStep))
	while (targetPosition.distance_to($InitialSpawnPoint.position) > wanderMax ): targetPosition = $GnatBody.position + Vector2(randi_range(-wanderStep,wanderStep),randi_range(-wanderStep,wanderStep))
	targetPosition = targetPosition.round()
	
func _on_wait_timer_timeout() -> void:
	pickPoint()
