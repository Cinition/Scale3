extends Node2D

@onready var CB = $CharacterBody2D
@export var MovementSpeed: float = 10
@export var JumpStrength: float = 100
@export var Gravity: float = 9.807

var GoingRight = true

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	var velocity = CB.velocity

	# Gravity
	if not CB.is_on_floor():
		velocity.y = velocity.y + Gravity;
	else:
		velocity.y = 0

	if Input.is_action_just_pressed("Jump") and CB.is_on_floor():
		velocity.y = -JumpStrength

	# Move Qubert to the right
	velocity.x = MovementSpeed if GoingRight else -MovementSpeed
	
	CB.velocity = velocity
	CB.move_and_slide()
