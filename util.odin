package main

import rl "vendor:raylib"

texture: rl.Texture2D
atlas: [32]rl.Rectangle

loadTexture :: proc(path: cstring) {
    texture = rl.LoadTexture(path)
    for i in 0..<len(atlas) {
        sx := i % 16
        sy := i / 16
        atlas[i] = rl.Rectangle{f32(sx * S), f32(sy * S), S, S}
    }
}

spr :: proc(id: int, x: int, y: int) {
    dest := rl.Vector2{f32(x) , f32(y)}
    rl.DrawTextureRec(texture, atlas[id], dest, rl.WHITE)
}