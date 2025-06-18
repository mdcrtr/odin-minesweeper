package main

import "core:math/rand"

Grid :: struct {
	width:  int,
	height: int,
	cells:  []Cell,
}

grid_init :: proc(grid: ^Grid, config: Config) {
	grid.width = config.grid_width
	grid.height = config.grid_height
	grid.cells = make([]Cell, config.grid_width * config.grid_height)
	grid_fill(grid, config.bomb_count)
}

grid_free :: proc(grid: ^Grid) {
	if grid.cells == nil {
		return
	}
	delete(grid.cells)
	grid.cells = nil
	grid.width = 0
	grid.height = 0
}

grid_fill :: proc(grid: ^Grid, num_bombs: int) {
	x := 0
	y := 0
	for i := 0; i < len(grid.cells); i += 1 {
		grid.cells[i] = cell_init(TILE, x, y)
		x += 1
		if x >= grid.width {
			x = 0
			y += 1
		}
	}
	bombs_to_place := num_bombs
	for bombs_to_place > 0 {
		x = rand.int_max(grid.width)
		y = rand.int_max(grid.height)
		cell := grid_get_cell(grid, x, y)
		if !cell.bomb {
			cell.bomb = true
			bombs_to_place -= 1
		}
	}
	grid_count_neighbour_bombs(grid)
}

grid_get_cell :: proc(grid: ^Grid, x: int, y: int) -> ^Cell {
	if x < 0 || x >= grid.width || y < 0 || y >= grid.height {
		return nil
	}
	return &grid.cells[y * grid.width + x]
}

grid_get_neighbour_cells :: proc(grid: ^Grid, x: int, y: int) -> [8]^Cell {
	return {
		grid_get_cell(grid, x - 1, y - 1),
		grid_get_cell(grid, x, y - 1),
		grid_get_cell(grid, x + 1, y - 1),
		grid_get_cell(grid, x - 1, y),
		grid_get_cell(grid, x + 1, y),
		grid_get_cell(grid, x - 1, y + 1),
		grid_get_cell(grid, x, y + 1),
		grid_get_cell(grid, x + 1, y + 1),
	}
}

count_bombs :: proc(cells: []^Cell) -> int {
	bomb_count := 0
	for cell in cells {
		if cell != nil && cell.bomb {
			bomb_count += 1
		}
	}
	return bomb_count
}

grid_count_neighbour_bombs :: proc(grid: ^Grid) {
	for y := 0; y < grid.height; y += 1 {
		for x := 0; x < grid.width; x += 1 {
			neighbours := grid_get_neighbour_cells(grid, x, y)
			bomb_count := count_bombs(neighbours[:])
			grid_get_cell(grid, x, y).bomb_count = bomb_count
		}
	}
}

grid_draw :: proc(grid: ^Grid) {
	for y := 0; y < grid.height; y += 1 {
		for x := 0; x < grid.width; x += 1 {
			cell := grid_get_cell(grid, x, y)
			cell_draw(cell^)
		}
	}
}

grid_reveal :: proc(grid: ^Grid, x: int, y: int) {
	if x < 0 || x >= grid.width || y < 0 || y >= grid.height {
		return
	}

	cell := grid_get_cell(grid, x, y)
	if cell.bomb || cell.state != .HIDDEN {
		return
	}

	cell_reveal(cell)

	if cell.bomb_count > 0 {
		return
	}

	grid_reveal(grid, x - 1, y - 1)
	grid_reveal(grid, x, y - 1)
	grid_reveal(grid, x + 1, y - 1)
	grid_reveal(grid, x - 1, y)
	grid_reveal(grid, x + 1, y)
	grid_reveal(grid, x - 1, y + 1)
	grid_reveal(grid, x, y + 1)
	grid_reveal(grid, x + 1, y + 1)
}

grid_reveal_bombs :: proc(grid: ^Grid) {
	for &cell in grid.cells {
		if cell.bomb {
			cell_reveal(&cell)
		}
	}
}

grid_is_win :: proc(grid: ^Grid) -> bool {
	for cell in grid.cells {
		flag := cell.state == .FLAGGED
		if cell.bomb != flag {
			return false
		}
	}
	return true
}
