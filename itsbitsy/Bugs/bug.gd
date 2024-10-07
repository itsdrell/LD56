extends Node2D
class_name Bug

# percent in 0-100 range
@export var SilkGiveOnDeath = 10;
@export var speed = 20 #pixels/sec

#captured vars
var captured : bool = false
var webStuckIn : Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func isCaptured() :
	return captured
	
func onReleased() :
	pass
	
func onEaten() :
	queue_free();
	return SilkGiveOnDeath;

func test() :
	print("parent")
