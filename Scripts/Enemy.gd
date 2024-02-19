extends CharacterBody2D

@onready var area_2d = $Area2D

var killphrase = ""
var hit_letters = []
	
func _ready():
	area_2d.connect("body_entered", Callable(self, "_on_body_entered"))
	set_killphrase("dog")
	#area_2d.connect("body_exited", Callable(self, "_on_body_exited"))

func set_killphrase(phrase):
	killphrase = phrase.to_upper()
	hit_letters = []
	for letter in killphrase:
		hit_letters.append(false)
	set_text(killphrase, [Color.RED, Color.GREEN, Color.BLUE])
	
func set_text(word: String, colors: Array[Color]):
	assert(word.length() == colors.size(), "word length and colors length must match.")
	var text = ""
	for i in range(word.length()):
		var color = colors[i].to_html()
		var char = word[i]
		text += "[color=%s]%s" % [color, char]
		
	get_node("Word").text = text
		
	
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
			hit_letter(letter_index)
			body.queue_free()
		else:
			#TODO move body to enemy bullet layer
			body.linear_velocity *= -0.8
		
#
#func _on_body_exited(body):
	#pass
	
func get_next_hittable_letter_index():
	for i in range(len(killphrase)):
		if !hit_letters[i]:
			return i
	return -1 # all letters hit

func hit_letter(index):
	if index < 0 or index >= len(hit_letters):
		return #bad index
	if hit_letters[index]:
		return # letter already hit
	hit_letters[index] = true
	#TODO play bullet sfx and stuff
	for hit in hit_letters:
		if !hit:
			return # not all letters hit yet
	#TODO play death sfx and stuff
	queue_free()
