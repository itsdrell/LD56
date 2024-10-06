extends Node2D
class_name Bug

# percent in 0-100 range
@export var SilkGiveOnDeath = 10;

#captured vars
var captured : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func isCaptured() :
	return captured
	
func onEaten() :
	queue_free();
	return SilkGiveOnDeath;

func test() :
	print("parent")
