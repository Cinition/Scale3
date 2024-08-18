@tool
class_name Qubert
extends CharacterBody2D

@onready var CollisionShape = $CollisionShape2D
@onready var MeshInstance = $MeshInstance2D

@export_category("Assets")
@export var LargeQubertMesh:  QuadMesh
@export var NormalQubertMesh: QuadMesh
@export var SmallQubertMesh:  QuadMesh
@export var QubertTexture:    Texture2D

@export_category("Variables")
@export var MovementSpeed:  float
@export var JumpStrength:   float
@export var ScaledDuration: float

signal qubert_died

enum QubertSize {LARGE, NORMAL, SMALL}

var CurrentQubertSize = QubertSize.NORMAL
var GoingRight        = true
var ScaledTimer       = 0.0

func _ready() -> void:
	SetQubertTo(QubertSize.NORMAL)

func _kill() -> void:
	qubert_died.emit()
	self.queue_free()
	

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if Input.is_action_pressed("ScaleQubertUp") and CurrentQubertSize == QubertSize.NORMAL:
		CurrentQubertSize = QubertSize.LARGE
		ScaledTimer       = ScaledDuration
		SetQubertTo(QubertSize.LARGE)

	if Input.is_action_pressed("ScaleQubertDown") and CurrentQubertSize == QubertSize.NORMAL:
		CurrentQubertSize = QubertSize.SMALL
		ScaledTimer       = ScaledDuration
		SetQubertTo(QubertSize.SMALL)

	if CurrentQubertSize != QubertSize.NORMAL:
		ScaledTimer -= delta
		if ScaledTimer < 0.0:
			CurrentQubertSize = QubertSize.NORMAL
			SetQubertTo(QubertSize.NORMAL)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	# Handle gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		Jump()

	# Move Qubert to the right
	velocity.x = MovementSpeed if GoingRight else -MovementSpeed

	# Apply velocity
	move_and_slide()


func Jump() -> void:
	velocity.y = -JumpStrength


func SetQubertTo(value: QubertSize) -> void:
	if value == QubertSize.LARGE:
		MeshInstance.set_mesh(LargeQubertMesh);
		
		var shape = RectangleShape2D.new()
		shape.size = LargeQubertMesh.size
		CollisionShape.set_shape(shape);
	elif value == QubertSize.SMALL:
		MeshInstance.set_mesh(SmallQubertMesh);
		
		var shape = RectangleShape2D.new()
		shape.size = SmallQubertMesh.size
		CollisionShape.set_shape(shape);
	else:
		MeshInstance.set_mesh(NormalQubertMesh);
		
		var shape = RectangleShape2D.new()
		shape.size = NormalQubertMesh.size
		CollisionShape.set_shape(shape);
