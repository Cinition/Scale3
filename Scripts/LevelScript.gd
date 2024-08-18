extends Node2D

@onready var qubert = $Qubert
@onready var Goal = $Goal
@onready var Camera = $Camera

const GameOverMenu = preload("res://Levels/Menus/GameOverMenu.tscn")
const GameWonMenu = preload("res://Levels/Menus/YouWonMenu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	qubert.qubert_died.connect(_on_qubert_dead.bind())
	Goal.qubert_finished.connect(_on_qubert_finished.bind())
	get_tree().paused = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_qubert_dead() -> void:
	var gameOver = GameOverMenu.instantiate()
	Camera.add_child(gameOver)
	get_tree().paused = true
	
func _on_qubert_finished() -> void:
	get_tree().paused = true
	var gameWon = GameWonMenu.instantiate()
	Camera.add_child(gameWon)
	
