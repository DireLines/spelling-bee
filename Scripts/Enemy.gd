extends CharacterBody2D

@onready var area_2d = $Area2D

var killphrase = ""
var hit_letters = []

func _ready():
	area_2d.connect("body_entered", Callable(self, "_on_body_entered"))
	killphrase = "BEE"
	for letter in killphrase:
		hit_letters.append(false)
	#area_2d.connect("body_exited", Callable(self, "_on_body_exited"))

func get_next_hittable_letter_index():
	for i in range(len(killphrase)):
		if !hit_letters[i]:
			return i
	return -1 # all letters hit

func _on_body_entered(body):
	var label = body.get_node_or_null("Letter")
	if label != null:
		var letter = label.text
		var letter_index = get_next_hittable_letter_index()
		if letter_index == -1:
			print("enemy already dead")
			return # all letters hit - enemy already dead
		var needed_letter = killphrase[letter_index]
		if letter == needed_letter:
			hit_letters[letter_index] = true
			print("right letter")
		else:
			print("wrong letter")
			#TODO throw bullet back at player
		
#
#func _on_body_exited(body):
	#pass
