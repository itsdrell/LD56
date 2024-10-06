extends Line2D
class_name Web

@export var BrokenWebTexture : Texture

var doOnce = false
var isBroken = false;
var hasSpiderUsedOnce = false;
var isSpiderOnMe = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !doOnce :
		CreateCollision(get_point_position(0), get_point_position(1))
		doOnce = true
		
	if isBroken :
		if isSpiderOnMe == false and hasSpiderUsedOnce == true : 
			queue_free()
		if isSpiderOnMe :
			hasSpiderUsedOnce = true
			
	if isBroken :
		texture = BrokenWebTexture
		texture_mode = LINE_TEXTURE_STRETCH

func CreateCollision(pos1, pos2):
	var child = $StaticBody2D.get_node("CollisionShape2D")
	child.shape.a = pos1;
	child.shape.b = pos2;
