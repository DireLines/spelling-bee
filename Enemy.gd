extends RigidBody2D

@onready var collision_shape_2d = $CollisionShape2D

func _ready():
	connect("body_shape_entered",Callable(self, "_on_body_entered"))
	connect("body_shape_exited",Callable(self, "_on_body_exited"))
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	print(body.name, " is now having fun :D")

func _on_body_exited(body):
	print(body.name, " is no longer having fun :(")
