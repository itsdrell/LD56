extends Bug
signal hit

@export var speed = 20 #pixels/sec
@export var wanderStep = 45 #distance between each wander

#movement vars
var wanderMax = 0 #set in ready by the WanderArea shape
var targetPosition = Vector2.ZERO
var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$WaitTimer.start(randf_range(0.5,1))
	wanderMax = $WanderArea.shape.radius - $GnatBody/CollisionShape2D.shape.radius
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not captured : move(delta)
	#queue_redraw()

func test() :
	print("child")
	super.test()
	
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

func _on_gnat_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Web")) and not captured and $ImmunityTimer.time_left == 0 : 
		if body.owner is Web : 
			if !body.owner.isBroken :
				captured = true
				webStuckIn = body.owner
				$GnatBody/AnimatedSprite2D.stop()
				$GnatBody/AnimatedSprite2D.play("Captured")
				$CapturedTimer.start()

func _on_captured_timer_timeout() -> void:
	captured = false
	webStuckIn.isBroken = true
	$ImmunityTimer.start()
	$GnatBody/AnimatedSprite2D.stop()
	$GnatBody/AnimatedSprite2D.play("Flight")
