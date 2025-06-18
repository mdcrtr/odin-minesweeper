package main

import rl "vendor:raylib"

texture: rl.Texture2D
atlas: [32]rl.Rectangle

loadTexture :: proc(path: cstring) {
	texture = rl.LoadTexture(path)
	for i in 0 ..< len(atlas) {
		sx := i % 16
		sy := i / 16
		atlas[i] = rl.Rectangle{f32(sx * S), f32(sy * S), S, S}
	}
}

spr :: proc(id: int, x: int, y: int) {
	dest := rl.Vector2{f32(x), f32(y)}
	rl.DrawTextureRec(texture, atlas[id], dest, rl.WHITE)
}

point_in_rec_r :: proc(point: rl.Vector2, rect: rl.Rectangle) -> bool {
	return(
		point.x >= rect.x &&
		point.x < rect.x + rect.width &&
		point.y >= rect.y &&
		point.y < rect.y + rect.height \
	)
}

point_in_rec_v :: proc(point: rl.Vector2, rpos: rl.Vector2, rsize: rl.Vector2) -> bool {
	return(
		point.x >= rpos.x &&
		point.x < rpos.x + rsize.x &&
		point.y >= rpos.y &&
		point.y < rpos.y + rsize.y \
	)
}

point_in_rec :: proc {
	point_in_rec_r,
	point_in_rec_v,
}
