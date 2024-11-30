extends Evidence

""" setup gives the donut a random color"""
func setup():
	$Donut/Frosting.material.albedo_color = Color(randf(), randf(), randf(), 1.0)
