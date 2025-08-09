class_name PlayScene
extends Control

signal resumed
signal main_menu

const BALLOON = preload("res://balloon/balloon.tscn")
const HOLOGRAPHIC = preload("res://styles/holographic.tres")

@export var characters: Array[Character] = []
@export var defaut_character_color: Color = Color.WHITE
const DIM_CHARACTER_COLOR: Color = Color(0.8, 0.8, 0.8)
const DIM_CHARACTER_SCALE: Vector2 = Vector2(0.98, 0.98)

@onready var backgrounds_container: Control = $Backgrounds
@onready var sprites: Control = $Sprites
@onready var voice_player: AudioStreamPlayer = $VoicePlayer
@onready var sound_player: AudioStreamPlayer = $SoundPlayer
@onready var skip_interval: Timer = $SkipInterval
@onready var screen_text: RichTextLabel = %ScreenText

var characters_dict: Dictionary[StringName, Character] = {}
var ballon: Balloon
var background: TextureRect
var music_player: AudioStreamPlayer
var ambience_player: AudioStreamPlayer
var history: Dictionary
var is_skipping: bool:
	get:
		return DialogueManager.is_skipping;
	set(value):
		if not DialogueManager.is_skipping and value:
			DialogueManager.is_skipping = value
			_on_skip_interval_timeout();
		else:
			DialogueManager.is_skipping = value
		if value:
			if skip_interval.is_stopped():
				skip_interval.start()
			voice_player.stop()
		else:
			skip_interval.stop()
var voiced: bool = false;
var _is_paused = false;
var resource: DialogueResource

func _ready() -> void:
	for character in characters:
		characters_dict[character.name] = character;

func _process(_delta: float) -> void:
	if not visible: return;
	#print(Input.is_action_pressed("Skip"), " or ",
			#ballon.is_skip_button_pressed, " and ", is_instance_valid(ballon), " and ",
			#ballon.dialogue_line.id in GameState.read_messages, " and ", \
			#not _is_paused, " and ", \
			#ballon.dialogue_line.responses.size() == 0)
	is_skipping = (Input.is_action_pressed("Skip") or (ballon and ballon.is_skip_button_pressed)) and \
			is_instance_valid(ballon) and \
			#ballon.dialogue_line.id in GameState.read_messages and \
			not _is_paused and \
			ballon.dialogue_line.responses.size() == 0

func play(dialogue_path: String, line_id: String = "start") -> void:
	DialogueManager.got_dialogue.connect(_got_dialogue)
	visible = true;
	resource = load(dialogue_path)
	#dialogue.dialogue_ended.connect(_dialogue_ended)
	ballon = DialogueManager.show_dialogue_balloon_scene(BALLOON, resource, line_id, \
			[self, screen_text]
	)
	ballon.on_prev.connect(_on_prev)
	ballon.on_next.connect(_on_next)
	
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
	if is_instance_valid(ballon):
		ballon.queue_free();
	ballon = null;
	music("", {"fade_out": 0.5})
	ambience("", {"fade_out": 0.5})
	_is_paused = false;
	voice_player.stream_paused = false;
	sound_player.stream_paused = false;
	voice_player.stop();
	sound_player.stop();
	_clear_scene(false, false)
	hide();

func set_background(bg_name: String, options: Dictionary = {}):
	var fade_in_value = options.get("fade_in", 1 if bg_name else 0)
	var fade_out_value = options.get("fade_out", 0 if bg_name else 1)
	
	if not bg_name: 
		if is_instance_valid(background):
			await fade_out(background, fade_out_value)
		return;
	
	
	var new_background = TextureRect.new();
	new_background.name = bg_name
	var viewport_size = get_viewport_rect().size;
	new_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	new_background.size = Vector2(viewport_size.x, viewport_size.y)
	
	
	var file = "res://backgrounds/%s.png" % bg_name
	if ResourceLoader.exists(file):
		new_background.texture = load(file)
		backgrounds_container.add_child(new_background)
	
		await fade_in(new_background, fade_in_value)
		
		if is_instance_valid(background):
			await fade_out(background, fade_out_value)
		background = new_background
	else:
		push_warning("no '%s' background found" % bg_name)
		if is_instance_valid(background):
			await fade_out(background, options.get("fade_out", 1))
		background = null

func add_character(ch_name: StringName, options: Dictionary = {}):
	var fade_in_value = options.get("fade_in", 0)
	var variant = options.get("variant", "neutral")
	var align = options.get("align", 0)
	var talking = options.get("talking", false)
	var ch_z_index = options.get("z_index", 0)
	var holographic = options.get("holographic", false)
	
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
		character_sprite.talking = talking
		character_sprite.z_index = ch_z_index
		sprites.add_child(character_sprite)
	
	
	character_sprite.material = HOLOGRAPHIC if holographic else null
	
	character_sprite.texture = sprite
	
	character_sprite.pivot_offset = Vector2(sprite.get_width() * align, sprite.get_height())
	
	character_sprite.position = Vector2((get_viewport_rect().size.x - sprite.get_width()) * align, get_viewport_rect().size.y - sprite.get_height())
	
	fade_in(character_sprite, fade_in_value)
	character_sprite.align = align;
	character_sprite.variant = variant;
	character_sprite.holographic = holographic

func change_character(ch_name: String, options: Dictionary = {}):
	var variant = options.get("variant", null)
	var align = options.get("align", null)
	var align_dur = options.get("align_dur", 0.6)
	var ch_z_index = options.get("z_index", null)
	
	var character: Character = characters_dict.get(ch_name, null);
	if not character:
		printerr("Character '%s' does not present in characters list" % ch_name)
		return;
	
	var character_sprite: CharacterSprite = sprites.find_child(ch_name, false, false)
	if not character:
		printerr("Character '%s' does not present on the scene" % ch_name)
		return;
	
	if ch_z_index or ch_z_index == 0:
		character_sprite.z_index = ch_z_index;
	
	var sprite = character.sprites.get(variant if variant else "neutral", null) as Texture2D
	
	if variant:
		if not sprite:
			push_warning("The character '%s' does not have variant '%s'" % [ch_name, variant])
			return;
			
		character_sprite.texture = sprite
		character_sprite.variant = variant
	
	if align or align == 0:
		character_sprite.align = align
		var new_pivot = Vector2(sprite.get_width() * align, sprite.get_height());
		var new_position = Vector2((get_viewport_rect().size.x - sprite.get_width()) * align, get_viewport_rect().size.y - sprite.get_height());
		if not is_skipping:
			var tween = create_tween().set_trans(Tween.TRANS_SINE)
			tween.tween_property(character_sprite, 
					"pivot_offset", 
					new_pivot,
					align_dur)
			tween.tween_property(character_sprite, 
					"position", 
					new_position,
					align_dur)
			await tween.finished
		else: 
			character_sprite.pivot_offset = new_pivot
			character_sprite.position = new_position

func remove_character(ch_name: String, options: Dictionary = {}):
	var fade_out_value = options.get("fade_out", 0)
	
	var texture_rect: Control = sprites.find_child(ch_name, false, false)
	if not texture_rect:
		push_warning("Character '%s' missing on scene" % ch_name)
	
	fade_out(texture_rect, fade_out_value, true);

func remove_all_characters(options: Dictionary = {}):
	for node in sprites.get_children():
		remove_character(node.name, options)

func ambience(file_name: String, options: Dictionary = {}):
	options["ambience"] = true
	music(file_name, options)

func music(file_name: String, options: Dictionary = {}):
	if music_player and music_player.name == file_name: return
	
	var fade_in_value = options.get("fade_in", 0)
	var fade_out_value = options.get("fade_out", 0)
	var is_ambience = options.get("ambience", false)
	
	var new_player: AudioStreamPlayer = null
	var file = "res://%s/%s.mp3" % \
				["ambience" if is_ambience else "music", file_name]
	if file_name:
		if ResourceLoader.exists(file):
			new_player = AudioStreamPlayer.new()
			new_player.name = file_name
			new_player.stream = load(file)
		else:
			push_warning("no '%s' %s found" % [file_name, "ambience" if is_ambience else "music"])
	
	if new_player and fade_in:
		new_player.volume_linear = 0
		var tween = get_tree().create_tween()
		tween.tween_property(new_player, "volume_linear", 1, fade_in_value)
	
	var old_player = ambience_player if is_ambience else music_player
	
	if old_player:
		if fade_out and old_player.playing:
			var tween = get_tree().create_tween()
			tween.tween_property(old_player, "volume_linear", 0, fade_out_value)
			tween.finished.connect(func (): 
					old_player.queue_free())
		else:
			old_player.queue_free()
	
	if new_player:
		add_child(new_player);
		new_player.play();
	
	if is_ambience:
		ambience_player = new_player
	else:
		music_player = new_player

func sound(file_name: String, options: Dictionary = {}):
	var awaiting = options.get("await", false)
	
	if not file_name: return;
	var file = "res://sound/%s.mp3" % file_name
	if not ResourceLoader.exists(file):
		push_warning("no '%s' sound found" % file_name)
		return;
	sound_player.stream = load(file)
	sound_player.play()
	if awaiting:
		await sound_player.finished

func restore_state(state: Dictionary):
	var music_name = state.get("music", "")
	var ambience_name = state.get("ambience", "")
	var scene_background = state.get("background", "")
	var sprites_on_scene = state.get("sprites", {})
	var line_id = state.get("line_id")
	var next_id = state.get("next_id")
	voiced = state.get("voiced", false)
	
	_clear_scene(
			music_player and music_player.name != music_name, \
			ambience_player and ambience_player.name != ambience_name);
	
	set_background(scene_background, {"fade_out": 0, "fade_in": 0})
	
	for sprite_name in sprites_on_scene:
		add_character(sprite_name, sprites_on_scene[sprite_name])
	
	music(music_name)
	ambience(ambience_name)
	
	var stack: Array = next_id.split("|")
	stack.pop_front()
	var id_trail: String = "" if stack.size() == 0 else "|" + "|".join(stack)
	ballon.set_line(line_id + id_trail)

func get_current_state():
	return _save_step(ballon.dialogue_line)

func fade_in(texture: Control, fade_duration: float):
	if is_skipping or not fade_duration: return
	texture.modulate = Color.TRANSPARENT
	var tween = get_tree().create_tween()
	tween.tween_property(texture, "modulate", Color.WHITE, fade_duration)
	await tween.finished;

func fade_out(texture: Control, fade_duration: float, remove: bool = true):
	if not texture: return
	var remove_node
	if remove:
		remove_node = Control.new()
		texture.add_sibling(remove_node)
		texture.reparent(remove_node)
	if is_skipping:
		if remove:
			texture.queue_free()
		return;
	if fade_duration: 
		var tween = get_tree().create_tween()
		tween.tween_property(texture, "modulate", Color.TRANSPARENT, fade_duration)
		await tween.finished;
	if remove:
		remove_node.queue_free()

func _clear_scene(clear_music: bool = false, clear_ambience: bool = false):
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
	if clear_ambience and ambience_player:
		ambience_player.reparent(remove_node)
		ambience_player = null;
	remove_node.queue_free()

func _save_step(line: DialogueLine) -> Dictionary:
	var step = {}
	step.line_id = line.id
	step.next_id = line.next_id
	
	if background:
		step.background = background.name
	if music_player:
		step.music = music_player.name;
	if ambience_player:
		step.ambience = ambience_player.name;
	step.voiced = voiced;
	
	step.sprites = {}
	for node in sprites.get_children():
		if node is CharacterSprite:
			step.sprites[node.name] = {
				"name": node.name,
				"align": node.align,
				"variant": node.variant,
				"talking": node.talking,
				"z_index": node.z_index,
				"holographic": node.holographic
			}
	
	return step;

func _get_line(line_id: String) -> DialogueLine:
	var value = ballon.resource.lines[line_id]
	return DialogueLine.new(value)

func _set_talking(character_sprite: CharacterSprite = null):
	var dim_characters = sprites.get_children()\
			.filter(func (node): return node is CharacterSprite) as Array[CharacterSprite]
	var tween: Tween = null
	
	if character_sprite and character_sprite in dim_characters:
		dim_characters.erase(character_sprite)
		if not character_sprite.talking:
			if not tween:
				tween = get_tree().create_tween().set_parallel(true)
			character_sprite.talking = true;
			tween.tween_property(character_sprite, "self_modulate", Color.WHITE, 0.1)
			tween.tween_property(character_sprite, "scale", Vector2(1, 1), 0.1)
	
	for sprite in dim_characters:
		if not sprite.talking:
			continue;
		if not tween:
			tween = get_tree().create_tween().set_parallel(true)
		sprite.talking = false
		tween.tween_property(sprite, "self_modulate", DIM_CHARACTER_COLOR, 0.1)
		tween.tween_property(sprite, "scale", DIM_CHARACTER_SCALE, 0.1)

func _load_voice(character_name: String, line: DialogueLine):
	if is_skipping: return;
	
	var voice_file_name = line.get_tag_value("v")
	
	if not voice_file_name:
		if not voiced: return;
		voice_file_name = ""
		
		if character_name:
			voice_file_name = character_name + "_"
			
		var fixed_line = line.text;
		for sym in ",.?!():»«…": 
			fixed_line = fixed_line.replace(sym, "")
			
		var regex = RegEx.new()
		regex.compile("\\s[—]\\s")
		fixed_line = regex.sub(fixed_line, " ", true)
		
		voice_file_name += fixed_line.strip_edges().substr(0, nth_symbol(fixed_line, " ", 3))
		
		regex.compile("\\[.+?\\]")
		voice_file_name = regex.sub(voice_file_name, "", true)
		
		
		regex = RegEx.new()
		regex.compile("\\s+")
		voice_file_name = regex.sub(voice_file_name, " ", true)
		
		for sym in "'’-": 
			voice_file_name = voice_file_name.replace(sym, "_")
		
		voice_file_name = voice_file_name.replace(" ", "_")
	
	print(voice_file_name.to_lower())
	var voice_file = "res://voice/%s.mp3" % voice_file_name.to_lower()
	
	if ResourceLoader.exists(voice_file):
		voice_player.stream = load(voice_file)
		voice_player.play();
	else:
		voice_player.stop();

func _got_dialogue(line: DialogueLine):
	if _is_paused:
		await resumed
	
	var character_name = line.character
	var character = characters_dict.get(character_name, null) as Character
	if not character: # if character is not unknown to player it could have other name
		var ch_tag = line.get_tag_value("ch")
		if ch_tag:
			character_name = ch_tag
			character = characters_dict.get(character_name, null)
	
	_load_voice(character_name, line)
	
	
	if not character:
		ballon.character_label.modulate = defaut_character_color;
		_set_talking(null)
	else:
		ballon.character_label.modulate = character.color;
		var texture_rect: CharacterSprite = sprites.find_child(character_name, false, false)
		
		if texture_rect: 
			var variants = Array(line.tags) \
					.filter(func (tag): return character.sprites.has(tag))
			if not variants.is_empty():
				var variant = variants.back()
				texture_rect.texture = character.sprites[variant];
				texture_rect.variant = variant
			_set_talking(texture_rect)
		else:
			_set_talking(null)
	
	history[line.id] = _save_step(line)

func nth_symbol(string: String, what: String, n: int, from: int = 0):
	var index = string.find(what, from)
	if n == 1:
		return index;
	if index > 0:
		return nth_symbol(string, what, n-1, index+1)
	else:
		return string.length()

func _on_next(prev_line: DialogueLine, _next_line: DialogueLine):
	if not GameState.read_messages.has(prev_line.id):
		GameState.read_messages.append(prev_line.id)
		GameState.save();

func _on_prev(line_id: String):
	var step: Dictionary
	var id = line_id;
	while not step:
		var saved_step = history.get(id, null);
		
		if not saved_step: return;
		
		var line = _get_line(saved_step["line_id"])
		
		if line.tags.has("screen"):
			var index = ballon.history.find(line.id)
		
			if index > 0:
				id = ballon.history[index-1]
				continue
		step = saved_step;
	if not step: return;
	
	restore_state(step)

func _on_skip_interval_timeout() -> void:
	#print(ballon.history, " ", ballon.dialogue_line.next_id)
	if is_skipping and ballon and not DialogueManager.is_mutating:
		ballon.next(ballon.dialogue_line.next_id)

func dialogue_ended(ended_resoruce: DialogueResource):
	main_menu.emit()
