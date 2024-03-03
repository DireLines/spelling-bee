extends RigidBody2D

@export var speed: int = 50
@export var max_forward_speed: int = 200
@export var max_reverse_speed: int = 125
@export var dampening: float = 5.0

@onready var sprite_2d = $Sprite2D
@onready var area_2d = $Area2D
@onready var health_display = $Health


var max_health = 3
var health = max_health
var dead = false

var score = 0

var bullet_prefab = preload("res://Prefabs/bullet.tscn")

func _ready():
	area_2d.connect("body_entered", Callable(self, "_on_body_entered"))
	health = max_health
	refresh_health_display()
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
	if dead:
		return
	var velocity = get_input()
	apply_central_impulse(velocity*delta)
	var max_speed = max_forward_speed
	if Input.is_action_pressed("right_click"):
		max_speed = max_reverse_speed
	if linear_velocity.length() >= max_speed:
		linear_velocity = max_speed*linear_velocity.normalized()
	var mouse_pos = get_global_mouse_position()
	sprite_2d.flip_h = mouse_pos.x < position.x

func hurt():
	#TODO play hit sfx and stuff
	health -= 1
	refresh_health_display()
	if health <= 0:
		die()

func _on_body_entered(body):
	if body.name == "Enemy":
		hurt()
		var hit_direction = (position - body.position).normalized()
		var knockback_force = 200
		apply_central_impulse(hit_direction*knockback_force)
		return
	var label = body.get_node_or_null("Letter")
	if label == null:
		return
	hurt()
	body.queue_free()


func _unhandled_input(event):
	if dead:
		return
	if event is InputEventKey:
		if event.pressed:
			var c = char(event.keycode)
			if c >= 'A' and c <= 'Z':
				load_bullet(c)

func refresh_health_display():
	var disptext = "[font_size=12][center]"
	for i in range(health):
		disptext+="❤️"
	for i in range(max_health-health):
		disptext+="🖤"
	health_display.text = disptext

func die():
	#TODO play die sfx and stuff
	var disptext = "[center]I'M SORRY\nTHAT IS INCORRECT\nSCORE: %d" % score
	health_display.text = disptext
	sprite_2d.hide()
	dead = true
	
func load_bullet(letter:String):
	var bullet = bullet_prefab.instantiate()
	get_tree().get_root().get_node("Main").add_child(bullet)
	bullet.position = position
	var mouse_pos = get_global_mouse_position()	
	bullet.linear_velocity = (mouse_pos - position).normalized() * 450
	bullet.get_node("Letter").text = letter

