@tool
class_name Qubert
extends CharacterBody2D

@onready var CollisionShape = $CollisionShape2D
@onready var MeshInstance   = $MeshInstance2D
@onready var AnimPlayer     = $AnimationPlayer

@export_category("Variables")
@export var MovementSpeed: float
@export var JumpStrength:  float
@export_flags_2d_physics var DefaultCollisionMask

@export_category("Scaled up Variables")
@export var BigJumpStrength: float
@export var BigFallingStrength: float
@export_flags_2d_physics var BigFallingCollisionMask

@export_category("Scaled down Variables")
@export var SlidingDuration:      float
@export var SlidingMovementSpeed: float

signal qubert_died

enum QubertSize      {
	LARGE,
	NORMAL,
	SMALL
}
enum QubertAnimation {
	BIGJUMP,
	BIGREJUMP,
	BIGSLAM,
	BIGFALLING,
	FALLING,
	JUMP,
	BEGINSMALLSLIDE,
	SMALLSLIDE,
	IDLE
}

var CurrentQubertSize         = QubertSize.NORMAL
var CurrentQubertAnimation    = QubertAnimation.IDLE
var GoingRight                = true
var HasAlreadyScaledUpInAir   = false
var HasAlreadyScaledDownInAir = false
var SlidingTimer              = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	self.collision_mask = DefaultCollisionMask


func _kill() -> void:
	self.queue_free()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	HandleAnimation(delta)


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	# Handle gravity
	if not is_on_floor():
		if CurrentQubertAnimation == QubertAnimation.BEGINSMALLSLIDE or CurrentQubertAnimation == QubertAnimation.SMALLSLIDE:
			velocity.y = 0
		elif CurrentQubertAnimation == QubertAnimation.BIGFALLING:
			velocity.y = BigFallingStrength
		else:
			velocity += get_gravity() * delta
			if velocity.y > 0:
				if CurrentQubertAnimation == QubertAnimation.BIGJUMP or CurrentQubertAnimation == QubertAnimation.BIGREJUMP:
					CurrentQubertAnimation = QubertAnimation.BIGFALLING
				else:
					CurrentQubertAnimation = QubertAnimation.FALLING

	# Move Qubert to the right
	if CurrentQubertAnimation == QubertAnimation.BIGFALLING or CurrentQubertAnimation == QubertAnimation.BIGJUMP:
		velocity.x = 0.0
	elif CurrentQubertAnimation == QubertAnimation.SMALLSLIDE:
		velocity.x = SlidingMovementSpeed if GoingRight else -SlidingMovementSpeed
	else:
		velocity.x = MovementSpeed if GoingRight else -MovementSpeed

	# Handle jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		Jump()

	# Scale up
	if Input.is_action_just_pressed("ScaleQubertUp") and is_on_floor():
		BigJump()

	# Scale down
	if Input.is_action_just_pressed("ScaleQubertDown") and (CurrentQubertAnimation != QubertAnimation.BEGINSMALLSLIDE or CurrentQubertAnimation != QubertAnimation.SMALLSLIDE):
		CurrentQubertAnimation = QubertAnimation.BEGINSMALLSLIDE

	# Apply velocity
	move_and_slide()


func Jump() -> void:
	velocity.y = -JumpStrength
	CurrentQubertAnimation = QubertAnimation.JUMP


func Slam() -> void:
	velocity.y = -BigJumpStrength


func BigJump() -> void:
	velocity.x = 0.0
	velocity.y = -BigJumpStrength
	CurrentQubertAnimation = QubertAnimation.BIGJUMP
	if not is_on_floor():
		HasAlreadyScaledUpInAir = true


func HandleAnimation(delta: float) -> void:
	if CurrentQubertAnimation == QubertAnimation.IDLE:
		CurrentQubertSize = QubertSize.NORMAL
		if AnimPlayer.current_animation != "QubertAnimations/IDLE":
			AnimPlayer.play("QubertAnimations/IDLE")

	if CurrentQubertAnimation == QubertAnimation.BIGJUMP:
		CurrentQubertSize = QubertSize.NORMAL
		if AnimPlayer.current_animation != "QubertAnimations/BIGJUMP":
			AnimPlayer.play("QubertAnimations/BIGJUMP")

	if CurrentQubertAnimation == QubertAnimation.BIGFALLING:
		collision_mask   = BigFallingCollisionMask
		CurrentQubertSize = QubertSize.LARGE
		if AnimPlayer.current_animation != "QubertAnimations/BIGFALLING":
			AnimPlayer.play("QubertAnimations/BIGFALLING")

		if is_on_floor():
			CurrentQubertAnimation = QubertAnimation.BIGSLAM
			Slam()

	if CurrentQubertAnimation == QubertAnimation.BIGSLAM:
		collision_mask   = DefaultCollisionMask
		CurrentQubertSize = QubertSize.NORMAL
		if AnimPlayer.current_animation != "QubertAnimations/BIGSLAM":
			AnimPlayer.play("QubertAnimations/BIGSLAM")

	if CurrentQubertAnimation == QubertAnimation.FALLING:
		CurrentQubertSize = QubertSize.NORMAL
		if AnimPlayer.current_animation != "QubertAnimations/FALLING":
			AnimPlayer.play("QubertAnimations/FALLING")

		if self.is_on_floor():
			CurrentQubertAnimation = QubertAnimation.IDLE

	if CurrentQubertAnimation == QubertAnimation.JUMP:
		CurrentQubertSize = QubertSize.NORMAL
		if AnimPlayer.current_animation != "QubertAnimations/JUMP":
			AnimPlayer.play("QubertAnimations/JUMP")

	if CurrentQubertAnimation == QubertAnimation.BEGINSMALLSLIDE:
		CurrentQubertSize = QubertSize.NORMAL
		if AnimPlayer.current_animation != "QubertAnimations/BEGINSMALLSLIDE":
			AnimPlayer.play("QubertAnimations/BEGINSMALLSLIDE")

		if self.is_on_wall():
			CurrentQubertAnimation = QubertAnimation.IDLE

	if CurrentQubertAnimation == QubertAnimation.SMALLSLIDE:
		CurrentQubertSize = QubertSize.SMALL
		if AnimPlayer.current_animation != "QubertAnimations/SMALLSLIDE":
			AnimPlayer.play("QubertAnimations/SMALLSLIDE")
			SlidingTimer = 0.0

		if self.is_on_wall():
			CurrentQubertAnimation = QubertAnimation.IDLE
			
		if SlidingTimer > SlidingDuration:
			CurrentQubertAnimation = QubertAnimation.IDLE
		
		SlidingTimer += delta


func OnAnimationFinished(anim_name: StringName) -> void:
	if anim_name == "QubertAnimations/BIGJUMP":
		CurrentQubertAnimation = QubertAnimation.BIGFALLING

	if anim_name == "QubertAnimations/BIGSLAM":
		CurrentQubertAnimation = QubertAnimation.IDLE
		pass

	if anim_name == "QubertAnimations/BEGINSMALLSLIDE":
		CurrentQubertAnimation = QubertAnimation.SMALLSLIDE
		pass

	if anim_name == "QubertAnimations/SMALLSLIDE":
		CurrentQubertAnimation = QubertAnimation.IDLE
		pass
		
	if anim_name == "QubertAnimations/JUMP":
		CurrentQubertAnimation = QubertAnimation.IDLE
		pass
