extends RigidBody2D

@export var speed: int = 50
@export var max_forward_speed: int = 400
@export var max_reverse_speed: int = 100
@export var dampening: float = 5.0

@onready var sprite_2d = $Sprite2D

func get_input():
	var velocity = Vector2()
	velocity = -linear_velocity * dampening
	var mouse_pos = get_global_mouse_position()
	if Input.is_action_pressed("left_click"):
		velocity = (mouse_pos - position) * speed
	if Input.is_action_pressed("right_click"):
		velocity = (position - mouse_pos) * speed
	return velocity
func _physics_process(delta):
	rotation = 0
	var velocity = get_input()
	apply_central_impulse(velocity*delta)
	var max_speed = max_forward_speed
	if Input.is_action_pressed("right_click"):
		max_speed = max_reverse_speed
	if linear_velocity.length() >= max_speed:
		linear_velocity = max_speed*linear_velocity.normalized()
	var mouse_pos = get_global_mouse_position()
	sprite_2d.flip_h = mouse_pos.x < position.x

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			var c = char(event.keycode)
			if c >= 'A' and c <= 'Z':
				load_bullet(c)

var bullet_prefab = preload("res://bullet.tscn")
func load_bullet(letter:String):
	var bullet = bullet_prefab.instantiate()
	get_tree().get_root().add_child(bullet)
	bullet.position = position
	var mouse_pos = get_global_mouse_position()	
	bullet.linear_velocity = (mouse_pos - position).normalized() * 500
	bullet.get_node("Letter").text = letter
	get_node("Letter").text = letter
