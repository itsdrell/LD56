extends Interact

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentState = false
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	pass

func _draw() -> void:
	if currentState :
		draw_circle($Area2D.position, 20, Color.SKY_BLUE)

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body)
	pass # Replace with function body.


func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area.name)
	
func ChangeState():
	currentState = !currentState
	return currentState
