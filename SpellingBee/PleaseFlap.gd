extends AnimationPlayer

@onready var anim_player = $"."
# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("flap")

