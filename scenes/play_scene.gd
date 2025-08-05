class_name PlayScene
extends Control

signal resumed

@export var characters: Array[Character] = []

@onready var backgrounds_container: Control = $Backgrounds
@onready var sprites: Control = $Sprites
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var sound_player: AudioStreamPlayer = $SoundPlayer

const BALLOON = preload("res://balloon/balloon.tscn")

var characters_dict: Dictionary[StringName, Character] = {}
var ballon: Balloon
var background: TextureRect
var music_player: AudioStreamPlayer
var history: Dictionary

var _is_paused = false;

func _ready() -> void:
	for character in characters:
		characters_dict[character.name] = character;

func play(dialogue_path: String, line_id: String = "start") -> void:
	DialogueManager.got_dialogue.connect(_got_dialogue)
	visible = true;
	var dialogue = load(dialogue_path)
	
	ballon = DialogueManager.show_dialogue_balloon_scene(BALLOON, dialogue, line_id, [self])
	ballon.on_prev.connect(_on_prev)
	
	if line_id != "start":
		var step = history.get(line_id, null);
		if step: 
			await get_tree().process_frame
			await get_tree().process_frame
			restore_state(step)

func pause():
	_is_paused = true;
	if ballon:
		ballon.dialogue_label.is_paused = true
	voice_player.stream_paused = true;
	sound_player.stream_paused = true;

func resume(): 
	_is_paused = false;
	if ballon:
		ballon.dialogue_label.is_paused = false;
	voice_player.stream_paused = false;
	sound_player.stream_paused = false;
	resumed.emit();

func quit():
	DialogueManager.got_dialogue.disconnect(_got_dialogue)
	ballon.queue_free();
	ballon = null;
	music("", {"fade_out": 0.5})
	_is_paused = false;
	voice_player.stream_paused = false;
	sound_player.stream_paused = false;
	voice_player.stop();
	sound_player.stop();
	_clear_scene(false)
	hide();

func set_background(bg_name: String, options: Dictionary = {}):
	if not bg_name: return;
	var fade_in = options.get("fade_in", 0)
	var fade_out = options.get("fade_out", 0)
	var new_background = TextureRect.new();
	new_background.name = bg_name
	new_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	new_background.texture = load("res://backgrounds/%s.png" % bg_name)
	backgrounds_container.add_child(new_background)
	await _fade_out(background, fade_out)
	await _fade_in(new_background, fade_in)
	if new_background:
		background = new_background;

func add_character(ch_name: StringName, options: Dictionary = {}):
	var fade_in = options.get("fade_in", 0)
	var variant = options.get("variant", "neutral")
	var align = options.get("align", 0)
	
	var character: Character = characters_dict.get(ch_name, null);
	if not character:
		printerr("Character '%s' does not present in characters list" % ch_name)
		return;
	var sprite = character.sprites.get(variant, null) as Texture2D
	
	if not sprite:
		printerr("The character '%s' does not have variant '%s'" % [ch_name, variant])
	
	var character_sprite: CharacterSprite = sprites.find_child(ch_name, false, false)
	if character_sprite:
		push_warning("Character '%s' already present on scene" % ch_name)
	else:
		character_sprite = CharacterSprite.new()
		character_sprite.name = ch_name
		sprites.add_child(character_sprite)
	
	
	character_sprite.texture = sprite
	
	character_sprite.pivot_offset = Vector2(sprite.get_width() * align, sprite.get_height())
	
	character_sprite.position = Vector2((get_viewport_rect().size.x - sprite.get_width()) * align, get_viewport_rect().size.y - sprite.get_height())
	
	_fade_in(character_sprite, fade_in)
	
	character_sprite.align = align;
	character_sprite.variant = variant;


func remove_character(ch_name: String, options: Dictionary = {}):
	var fade_out = options.get("fade_out", 0)
	
	var texture_rect: TextureRect = sprites.find_child(ch_name, false, false)
	if not texture_rect:
		push_warning("Character '%s' missing on scene" % ch_name)
		
	_fade_out(texture_rect, fade_out, true);

func music(file_name: String, options: Dictionary = {}):
	if music_player and music_player.name == file_name: return
	
	var fade_in = options.get("fade_in", 0)
	var fade_out = options.get("fade_out", 0)
	
	var new_player: AudioStreamPlayer = null
	if file_name:
		new_player = AudioStreamPlayer.new()
		new_player.name = file_name
		new_player.stream = load("res://music/%s.mp3" % file_name)
	
	if new_player and fade_in:
		new_player.volume_linear = 0
		var tween = get_tree().create_tween()
		tween.tween_property(new_player, "volume_linear", 1, fade_in)
		
	
	if music_player and fade_out and music_player.playing:
		var old_player = music_player
		var tween = get_tree().create_tween()
		tween.tween_property(old_player, "volume_linear", 0, fade_out)
		tween.finished.connect(func (): 
				old_player.queue_free())
	
	if new_player:
		add_child(new_player);
		new_player.play();
	music_player = new_player


func sound(file_name: String, option: Dictionary = {}):
	if not file_name: return;
	sound_player.stream = load("res://sound/%s.mp3" % file_name)
	sound_player.play()

func restore_state(state: Dictionary):
	var music = state.get("music", "")
	var background = state.get("background", "")
	var sprites = state.get("sprites", {})
	var line_id = state.get("line_id")
	
	_clear_scene(music_player and music_player.name != music);
	
	set_background(background)
	
	for sprite_name in sprites:
		add_character(sprite_name, state.sprites[sprite_name])
	
	music(music)
	
	ballon.set_line(state.get("line_id"))

func get_current_state():
	return _save_step(ballon.dialogue_line)

func _clear_scene(clear_music: bool = false):
	var remove_node = Node.new();
	add_child(remove_node)
	for node in backgrounds_container.get_children():
		node.reparent(remove_node)
	background = null
	for node in sprites.get_children():
		node.reparent(remove_node)
	if clear_music and music_player:
		music_player.reparent(remove_node)
		music_player = null;
	remove_node.queue_free()

func _fade_in(texture: TextureRect, fade_duration: float):
	if not fade_duration: return
	texture.modulate = Color.TRANSPARENT
	var tween = get_tree().create_tween()
	tween.tween_property(texture, "modulate", Color.WHITE, fade_duration)
	await tween.finished;


func _fade_out(texture: TextureRect, fade_duration: float, remove: bool = true):
	if not texture: return
	if fade_duration: 
		var tween = get_tree().create_tween()
		tween.tween_property(texture, "modulate", Color.TRANSPARENT, fade_duration)
		await tween.finished;
	if remove:
		texture.queue_free()

func _save_step(line: DialogueLine) -> Dictionary:
	var step = {}
	step.line_id = line.id
	
	if background:
		step.background = background.name
	if music_player:
		step.music = music_player.name;
	
	step.sprites = {}
	for node in sprites.get_children():
		if node is CharacterSprite:
			step.sprites[node.name] = {
				"name": node.name,
				"align": node.align,
				"variant": node.variant,
			}
	
	return step;

func _got_dialogue(line: DialogueLine):
	if _is_paused:
		await resumed
	var voice_file = line.get_tag_value("v")
	if voice_file:
		voice_player.stream = load("res://voice/%s.mp3" % voice_file)
		voice_player.play();
	
	var character_name = line.character
	var character = characters_dict.get(character_name, null) as Character
	if not character: # if character is not unknown to player it could have other name
		character_name = line.get_tag_value("ch")
		character = characters_dict.get(character_name, null)
	
	if not character:
		ballon.character_label.modulate = Color.WHITE;
	else:
		ballon.character_label.modulate = character.color;
		var texture_rect: TextureRect = sprites.find_child(character_name, false, false)
		
		if texture_rect: 
			var variants = Array(line.tags) \
					.filter(func (tag): return character.sprites.has(tag))
			if not variants.is_empty():
				texture_rect.texture = character.sprites[variants.back()];
	
	history[line.id] = _save_step(line)
	if not GameState.read_messages.has(line.id):
		GameState.read_messages.append(line.id)
		GameState.save();

func _on_prev(line_id: String):
	var step = history.get(line_id, null);
	if not step: return;
	restore_state(step)
