extends Node

@onready var enemy = load("res://Prefabs/enemy.tscn")

func spawnEnemy():
	var instance = enemy.instantiate()
	add_child(instance)
	instance.initialize()

func _on_timer_timeout():
	spawnEnemy()
