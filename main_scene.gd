extends Control

@export var characters: Array[Character] = []

@onready var backgrounds_container: Control = $Backgrounds
@onready var background: TextureRect = $Backgrounds/Background
@onready var sprites: Control = $Sprites

const TEST_DIALOGUE = preload("res://dialogues/test dialogue.dialogue")
const BALLOON = preload("res://balloon/balloon.tscn")

var characters_dict: Dictionary[StringName, Character] = {}
var ballon: Balloon

func _ready() -> void:
	for character in characters:
		characters_dict[character.name] = character;
	DialogueManager.got_dialogue.connect(_got_dialogue)
	
	ballon = DialogueManager.show_dialogue_balloon_scene(BALLOON, TEST_DIALOGUE, "start", [self])


func set_background(bg_name: String, options: Dictionary = {}):
	var fade_in = options.get("fade_in", 0)
	var fade_out = options.get("fade_out", 0)
	var new_background = TextureRect.new();
	new_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	new_background.texture = load("res://backgrounds/%s.png" % bg_name)
	backgrounds_container.add_child(new_background)
	await _fade_out(background, fade_out)
	await _fade_in(new_background, fade_in)
	background = new_background;


func add_character(ch_name: StringName, options: Dictionary = {}):
	var fade_in = options.get("fade_in", 0)
	var variant = options.get("variant", "neutral")
	var character_pos = options.get("align", 0)
	
	var character: Character = characters_dict.get(ch_name, null);
	if not character:
		printerr("Character '%s' does not present in characters list" % ch_name)
		return;
	var sprite = character.sprites.get(variant, null) as Texture2D
	
	if not sprite:
		printerr("The character '%s' does not have variant '%s'" % [ch_name, variant])
	
	var texture_rect: TextureRect = sprites.find_child(ch_name, false, false)
	if texture_rect:
		push_warning("Character '%s' already present on scene" % ch_name)
	else:
		texture_rect = TextureRect.new()
		texture_rect.name = ch_name
		sprites.add_child(texture_rect)
	
	texture_rect.texture = sprite
	
	texture_rect.pivot_offset = Vector2(sprite.get_width() * character_pos, sprite.get_height())
	
	texture_rect.position = Vector2((get_viewport_rect().size.x - sprite.get_width()) * character_pos, get_viewport_rect().size.y - sprite.get_height())
	
	_fade_in(texture_rect, fade_in)


func remove_character(ch_name: String, options: Dictionary = {}):
	var fade_out = options.get("fade_out", 0)
	
	var texture_rect: TextureRect = sprites.find_child(ch_name, false, false)
	if not texture_rect:
		push_warning("Character '%s' missing on scene" % ch_name)
		
	_fade_out(texture_rect, fade_out, true);


func _fade_in(texture: TextureRect, fade_duration: float):
	if not fade_duration: return
	texture.modulate = Color.TRANSPARENT
	var tween = get_tree().create_tween()
	tween.tween_property(texture, "modulate", Color.WHITE, fade_duration)
	await tween.finished;


func _fade_out(texture: TextureRect, fade_duration: float, remove: bool = true):
	if fade_duration: 
		var tween = get_tree().create_tween()
		tween.tween_property(texture, "modulate", Color.TRANSPARENT, fade_duration)
		await tween.finished;
	if remove:
		texture.queue_free()


func _got_dialogue(line: DialogueLine):
	var character_name = line.character
	var character = characters_dict.get(character_name, null) as Character
	if not character: # if character is not unknown to player it could have other name
		character_name = line.get_tag_value("ch")
		character = characters_dict.get(character_name, null)
	
	if not character:
		ballon.character_label.modulate = Color.WHITE;
		return;
		
	ballon.character_label.modulate = character.color;
	var texture_rect: TextureRect = sprites.find_child(character_name, false, false)
	
	if not texture_rect: return;
	
	var variant = Array(line.tags) \
			.filter(func (tag): return character.sprites.has(tag)).back()
	if variant:
		texture_rect.texture = character.sprites[variant];
