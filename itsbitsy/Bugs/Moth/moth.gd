extends Bug
@export var PathToFollow : PathFollow2D

#@export var ModulateSpeed : int
@export var MaxRotation : int
@export var FlutterAmount : int

var isHidden = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#check for lamp
	if ControlInteract.GetCurrentState() :
		$".".show()
	else: 
		$".".hide()
		$ImmunityTimer.start()
		captured = false
		$MothBody/AnimatedSprite2D.play("Flight")
		
		
	if (not isCaptured()) :	
		move(delta)
		flutter(delta)

func move(delta :float):
	#move towards closest path point
	#--- MOVEMENT ---
	# modulate speed
	# move towards target position 
	PathToFollow.progress += speed * delta

func flutter(delta:float):
	var exposedRotation = $MothBody.rotation_degrees
	var TargetFlutter = randf_range(-FlutterAmount, FlutterAmount)
	var resultRotation = (TargetFlutter * delta) + $MothBody.rotation_degrees
	var ClampedRotation = clamp(resultRotation, -MaxRotation, MaxRotation)
	$MothBody.rotation_degrees = ClampedRotation

func _on_captured_timer_timeout() -> void:
	captured = false
	webStuckIn.isBroken = true
	$ImmunityTimer.start()
	$MothBody/AnimatedSprite2D.stop()
	$MothBody/AnimatedSprite2D.play("Flight")

func _on_moth_body_entered(body: Node2D) -> void:
	if (body.is_in_group("Web")) and not captured and $ImmunityTimer.time_left == 0 : 
		if body.owner is Web : 
			if !body.owner.isBroken :
				captured = true
				webStuckIn = body.owner
				$MothBody/AnimatedSprite2D.stop()
				$MothBody/AnimatedSprite2D.play("Captured")
				$CapturedTimer.start()
