extends Control

@onready var FirstPanel = $FirstPanel
@onready var LevelPanel = $LevelPanel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed_exit() -> void:
	get_tree().quit()


func _on_button_pressed_levels() -> void:
	FirstPanel.visible = false
	LevelPanel.visible = true


func _on_button_pressed_tutorial() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/TutorialLevel.tscn")
