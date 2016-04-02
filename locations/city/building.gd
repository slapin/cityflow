
extends Spatial
export var building_dimentions = Vector2(20.0, 20.0)
export var floor_height = 2.5
export var floor_number = 10
export var window_width = 1.2
export var window_height = 2.1
export var window_dist = 1.0
export var frame_width = 0.1
export(Material) var walls_material
export(Material) var window_frame_material
export(Material) var window_glass_material
# member variables here, example:
# var a=2
# var b="textvar"
onready var geom = get_node("geom")
func add_tri(s, uvs, pts):
	if uvs.size() != pts.size():
		return
	for k in range(uvs.size()):
		s.add_uv(uvs[k])
		s.add_vertex(pts[k])
func add_quad(s, pts):
	var uvs = [Vector2(0.0, 1.0), Vector2(0.0, 0.0), Vector2(1.0, 0.0), Vector2(1.0, 1.0)]
	var pts1 = [pts[0], pts[1], pts[3]]
	var pts2 = [pts[1], pts[2], pts[3]]
	var uvs1 = [uvs[0], uvs[1], uvs[3]]
	var uvs2 = [uvs[1], uvs[2], uvs[3]]
	add_tri(s, uvs1, pts1)
	add_tri(s, uvs2, pts2)

func make_wall_segment(s, lp, rp, bottom, top, dp, m):
	var p1
	var p2
	var p3
	var p4
	if m in [0, 2]:
		p1 = Vector3(lp,bottom, dp)
		p2 = Vector3(lp,top, dp)
		p3 = Vector3(rp,top, dp)
		p4 = Vector3(rp,bottom, dp)
	else:
		p1 = Vector3(dp, bottom, rp)
		p2 = Vector3(dp, top, rp)
		p3 = Vector3(dp, top, lp)
		p4 = Vector3(dp, bottom, lp)
	if m in [2, 3]:
		add_quad(s, [p1, p2, p3, p4])
	else:
		add_quad(s, [p4, p3, p2, p1])
func make_flat_segment(s, lp, rp, posy, near, far, m, side):
	var p1
	var p2
	var p3
	var p4
	if m in [0, 2]:
		p1 = Vector3(lp, posy, near)
		p2 = Vector3(lp, posy, far)
		p3 = Vector3(rp, posy, far)
		p4 = Vector3(rp, posy, near)
	else:
		p1 = Vector3(near, posy, rp)
		p2 = Vector3(far, posy, rp)
		p3 = Vector3(far, posy, lp)
		p4 = Vector3(near, posy, lp)
	if side:
		print([p1, p2, p3, p4])
		add_quad(s, [p1, p2, p3, p4])
	else:
		print([p4, p3, p2, p1])
		add_quad(s, [p4, p3, p2, p1])

func make_window_frame(s, lp, rp, bottom, top, dp, m):
	var dpp
	var fdp
	var fdpa
	var cor1
	var cor2
	if m == 2:
		dpp = dp + frame_width
		fdp = dp
		fdpa = dpp
		cor1 = 3
		cor2 = 1
	elif m == 0:
		dpp = dp - frame_width
		fdp = dp - frame_width
		fdpa = dp
		cor1 = 3
		cor2 = 1
	elif m == 3:
		dpp = dp + frame_width
		fdp = dp
		fdpa = dpp
		cor1 = 1
		cor2 = 3
	else:
		dpp = dp - frame_width
		fdp = dp - frame_width
		fdpa = dp
		cor1 = 1
		cor2 = 3
	make_wall_segment(s, lp, lp + frame_width, bottom + frame_width, top - frame_width, dpp, m)
	make_wall_segment(s, rp - frame_width, rp, bottom + frame_width, top - frame_width, dpp, m)
	make_wall_segment(s, lp, rp, bottom, bottom + frame_width, dpp, m)
	make_wall_segment(s, lp, rp, top - frame_width, top, dpp, m)
	make_wall_segment(s, lp, lp + frame_width, bottom + frame_width, top - frame_width, dpp, int(fmod((m + 2), 4)))
	make_wall_segment(s, rp - frame_width, rp, bottom + frame_width, top - frame_width, dpp, int(fmod((m + 2), 4)))
	make_wall_segment(s, lp, rp, bottom, bottom + frame_width, dp + frame_width, int(fmod((m + 2), 4)))
	make_wall_segment(s, lp, rp, top - frame_width, top, dp + frame_width, int(fmod((m + 2), 4)))
	make_flat_segment(s, lp, rp, bottom + frame_width, fdp, fdpa, m, false)
	make_flat_segment(s, lp, rp, bottom, fdp, fdpa, m, true)
	make_flat_segment(s, lp, rp, top - frame_width, fdp, fdpa, m, true)
	make_flat_segment(s, lp, rp, top, fdp, fdpa, m, false)
	make_wall_segment(s, dp, dpp, bottom, top, lp, int(fmod((m + cor1), 4)))
	make_wall_segment(s, dp, dpp, bottom, top, rp, int(fmod((m + cor2), 4)))
	make_wall_segment(s, dp, dpp, bottom + frame_width, top - frame_width, rp - frame_width, int(fmod((m + cor1), 4)))
	make_wall_segment(s, dp, dpp, bottom + frame_width, top - frame_width, lp + frame_width, int(fmod((m + cor2), 4)))
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	if not walls_material:
		walls_material = FixedMaterial.new()
		walls_material.set_parameter(walls_material.PARAM_DIFFUSE,Color(0.4,0.4,0.4,1))
	if not window_frame_material:
		window_frame_material = FixedMaterial.new()
		window_frame_material.set_parameter(window_frame_material.PARAM_DIFFUSE,Color(0.9,0.4,0.4,1))
	if not window_glass_material:
		window_glass_material = FixedMaterial.new()
		window_glass_material.set_parameter(window_glass_material.PARAM_DIFFUSE,Color(0.1,0.3,0.4,1))
#	var mesh = geom.get_mesh()
	var mesh = Mesh.new()
	var wall_surface = SurfaceTool.new()
	var window_frame_surface = SurfaceTool.new()
	var window_glass_surface = SurfaceTool.new()
	wall_surface.set_material(walls_material)
	wall_surface.begin(VS.PRIMITIVE_TRIANGLES)
	window_frame_surface.set_material(window_frame_material)
	window_frame_surface.begin(VS.PRIMITIVE_TRIANGLES)
	window_glass_surface.set_material(window_glass_material)
	window_glass_surface.begin(VS.PRIMITIVE_TRIANGLES)
	var window_space = window_width + window_dist
	var n_windows = Vector2(int(building_dimentions.x / window_space), int(building_dimentions.y / window_space))
	var w_off = building_dimentions - n_windows * window_space
	for k in range(0, floor_number):
		var bottom_y = k * floor_height
		var window_bottom_y = bottom_y + floor_height / 2 - window_height / 2
		var window_top_y = window_bottom_y + window_height
		var floor_top_y = bottom_y + floor_height
		for m in range(0, 4):
			var lp
			var rp
			var dp
			var uvs
			var pts
			if m in [0, 2]:
				lp = -building_dimentions.x / 2.0
				rp = building_dimentions.x / 2.0
				if m == 0:
					dp = -building_dimentions.y / 2.0
				else:
					dp = building_dimentions.y / 2.0
			elif m in [1, 3]:
				lp = -building_dimentions.y / 2.0
				rp = building_dimentions.y / 2.0
				if m == 1:
					dp = -building_dimentions.x / 2.0
				else:
					dp = building_dimentions.x / 2.0
			make_wall_segment(wall_surface, lp, rp, bottom_y, window_bottom_y, dp, m)
			var ioff
			var lposw
			var rposw
			var topw
			var pw
			var mid
			if m in [0, 2]:
				pw = range(0, int(n_windows.x))
				ioff = w_off.y / 2.0
				mid = building_dimentions.x / 2.0
			else:
				pw = range(0, int(n_windows.y))
				ioff = w_off.y / 2.0
				mid = building_dimentions.y / 2.0
			lposw = - mid
			rposw = lposw + ioff
			topw = window_bottom_y +  window_height
			make_wall_segment(wall_surface, lposw, rposw, window_bottom_y, topw, dp, m)
			# walls around window
			for w in pw:
				lposw = w * window_space  - mid  + ioff
				rposw = lposw + window_space / 2.0 - window_width / 2.0
				make_wall_segment(wall_surface, lposw, rposw, window_bottom_y, topw, dp, m)
				make_window_frame(window_frame_surface, rposw, rposw + window_width,  window_bottom_y, topw, dp, m)
				make_wall_segment(window_glass_surface, rposw + frame_width, rposw + window_width - frame_width, window_bottom_y + frame_width, topw - frame_width, dp, m)
				lposw = rposw + window_width
				rposw = lposw + window_space / 2.0 - window_width / 2.0
				make_wall_segment(wall_surface, lposw, rposw, window_bottom_y, topw, dp, m)
				
			lposw = mid - ioff
			rposw = mid
			make_wall_segment(wall_surface, lposw, rposw, window_bottom_y, topw, dp, m)
			make_wall_segment(wall_surface, lp, rp, window_top_y, floor_top_y, dp, m)
	wall_surface.generate_normals()
	wall_surface.index()
	wall_surface.commit(mesh)
	window_frame_surface.generate_normals()
	window_frame_surface.index()
	window_frame_surface.commit(mesh)
	window_glass_surface.generate_normals()
	window_glass_surface.index()
	window_glass_surface.commit(mesh)
	geom.set_mesh(mesh)
