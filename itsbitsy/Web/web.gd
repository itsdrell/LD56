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
		CreateCollision(get_point_position(1), get_point_position(0))
		doOnce = true
		
	if isBroken :
		if isSpiderOnMe == false and hasSpiderUsedOnce == true : 
			queue_free()
		if isSpiderOnMe :
			hasSpiderUsedOnce = true
			
	if isBroken :
		texture = BrokenWebTexture
		texture_mode = LINE_TEXTURE_STRETCH
		
	queue_redraw()

func _draw() -> void:
	
	var pos1 = get_point_position(1)
	var pos2 = get_point_position(0)
	
	#draw_circle(pos1, 8, Color.BLACK)
	#draw_circle(pos2, 8, Color.RED)

func CreateCollision(pos1, pos2):
	var child = $StaticBody2D.get_node("CollisionShape2D")
	
	var direction = (pos2 - pos1).normalized()
	var michael = atan2(direction.y, direction.x)

	child.shape.size = Vector2(abs(pos2.y), 16)
	var newPos = pos2 - (pos2 * .5)

	var newTransform : Transform2D = Transform2D(michael, newPos)
	child.transform = newTransform
