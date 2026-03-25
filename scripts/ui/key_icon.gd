extends AspectRatioContainer
class_name keyIcon

func set_color(color: Color):
	get_node("TextureRect").modulate = color
