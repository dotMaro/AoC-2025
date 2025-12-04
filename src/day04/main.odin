package main

import "core:fmt"
import "core:strings"

main :: proc() {
	input :: #load("../../inputs/day04.txt", string)
	grid := strings.split_lines(input)

	total_removed_rolls: uint
	first_accessible_rolls: uint = 0
	removed_rolls := true
	for removed_rolls {
		removed_roll_count: uint
		grid, removed_roll_count = remove_accessible_rolls(grid)
		if first_accessible_rolls == 0 {
			first_accessible_rolls = removed_roll_count
		}
		total_removed_rolls += removed_roll_count

		removed_rolls = removed_roll_count > 0
	}

	fmt.printfln("Part 1. %d", first_accessible_rolls)
	fmt.printfln("Part 2. %d", total_removed_rolls)
}

remove_accessible_rolls :: proc(grid: []string) -> ([]string, uint) {
	new_grid := make([]string, len(grid))
	accessible_rolls: uint

	for row, y in grid {
		// I really tried to get strings.Builder to work but it kept including weird null characters etc.
		// in the output which was a nightmare to debug, hence me abusing strings.concatenate.
		new_row: string
		for position, x in row {
			switch position {
			case '.':
				new_row = strings.concatenate([]string{new_row, "."})
			case '@':
				if can_be_accessed(grid, x, y) {
					new_row = strings.concatenate([]string{new_row, "."})
					accessible_rolls += 1
				} else {
					new_row = strings.concatenate([]string{new_row, "@"})
				}
			case:
				fmt.panicf("unknown character %q", position)
			}
		}
		new_grid[y] = new_row
	}

	return new_grid, accessible_rolls
}

can_be_accessed :: proc(grid: []string, x, y: int) -> bool {
	max_x, max_y := len(grid[0])-1, len(grid)-1
	adjacent_rolls: u8
	for check_x in max(x-1, 0)..=min(x+1, max_x) {
		for check_y in max(y-1, 0)..=min(y+1, max_y) {
			if check_x == x && check_y == y {
				continue
			}

			if grid[check_y][check_x] == '@' {
				adjacent_rolls += 1
			}
		}
	}

	return adjacent_rolls < 4
}
