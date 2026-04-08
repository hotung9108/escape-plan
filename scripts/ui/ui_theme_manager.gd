extends Node
class_name UIThemeManager

static func apply_theme(node: Node):
	_apply_recursive(node)

static func _apply_recursive(node: Node):
	if node is Panel:
		var style = StyleBoxFlat.new()
		# Dark dim layer covering the entire screen
		style.bg_color = Color(0.02, 0.01, 0.01, 0.85) 
		node.add_theme_stylebox_override("panel", style)
	
	elif node is Button:
		# Minimalist Gritty Horror button
		var normal = StyleBoxFlat.new()
		normal.bg_color = Color(0, 0, 0, 0) # Transparent background
		normal.border_width_bottom = 2
		normal.border_color = Color(0.6, 0.1, 0.1, 0.0) # Hidden border normally
		
		var hover = normal.duplicate()
		hover.border_color = Color(0.8, 0.1, 0.1, 0.8) # Red underline on hover
		
		node.add_theme_stylebox_override("normal", normal)
		node.add_theme_stylebox_override("hover", hover)
		node.add_theme_stylebox_override("pressed", hover)
		node.add_theme_stylebox_override("focus", normal)
		
		node.add_theme_font_size_override("font_size", 24)
		node.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85, 1.0))
		node.add_theme_color_override("font_hover_color", Color(1.0, 0.1, 0.1, 1.0))

	elif node is Label:
		# Titles
		var is_title = node.text in ["Escape Plan", "Settings", "Pause Game", "YOU WIN!", "YOU LOSE!"]
		if is_title:
			node.add_theme_font_size_override("font_size", 48)
			node.add_theme_color_override("font_color", Color(0.9, 0.1, 0.1, 1.0))
			node.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 1.0))
			node.add_theme_constant_override("shadow_offset_x", 3)
			node.add_theme_constant_override("shadow_offset_y", 3)
		else:
			node.add_theme_font_size_override("font_size", 24)
			node.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
			
	for child in node.get_children():
		_apply_recursive(child)
