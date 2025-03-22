package main

import rl "vendor:raylib"

texture: rl.Texture2D

loadTexture :: proc(path: cstring) {
    texture = rl.LoadTexture(path)
}

spr :: proc(id: int, x: int, y: int) {
    sx := id % 16
    sy := id / 16
    source := rl.Rectangle{f32(sx * S), f32(sy * S), S, S}
    dest := rl.Vector2{f32(x * S) , f32(y * S)}
    rl.DrawTextureRec(texture, source, dest, rl.WHITE)
}