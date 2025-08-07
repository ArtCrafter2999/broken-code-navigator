@tool
extends RichTextEffect
class_name RichTextObfuscated

# Syntax: [matrix clean=0.0 dirty=1.0 span=50][/matrix]

# Define the tag name.
var bbcode = "obfuscated"

# Gets TextServer for retrieving font information.
func get_text_server():
	return TextServerManager.get_primary_interface()

func _process_custom_fx(char_fx):
	char_fx.glyph_index = get_text_server()\
			.font_get_glyph_index(char_fx.font, 1, 
			randi_range("A".unicode_at(0), "z".unicode_at(0)),
			#["0","1"].pick_random().unicode_at(0),
			0)
	return true
