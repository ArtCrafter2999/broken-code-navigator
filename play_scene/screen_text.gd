extends RichTextLabel

@onready var play_scene: PlayScene = $"../.."

func _ready() -> void:
	visible = false;
	pass

func screen_text(bbcode_text: String, options: Dictionary = {}):
	visible = true;
	var fade_in = options.get("fade_in", 1)
	var wait = options.get("wait", 1)
	var fade_out = options.get("fade_out", 1)
	
	parse_bbcode(bbcode_text);
	
	await play_scene.fade_in(self, fade_in);
	if not SkipManager.is_skipping:
		await get_tree().create_timer(wait).timeout
	await play_scene.fade_out(self, fade_out, false);
	visible = false;
