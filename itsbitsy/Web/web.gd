extends Line2D

var doOnce = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !doOnce :
		CreateCollision(get_point_position(0), get_point_position(1))
		doOnce = true

func CreateCollision(pos1, pos2):
	var child = $StaticBody2D.get_node("CollisionShape2D")
	child.shape.a = pos1;
	child.shape.b = pos2;
