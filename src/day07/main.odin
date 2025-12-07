package main

import "core:fmt"
import "core:strings"

main :: proc() {
	input :: #load("../../inputs/day07.txt", string)
	tachyon_diagram := parse_tachyon_diagram(input)
	
	fmt.println("Step 1.", step_until_end_of_manifold(&tachyon_diagram))
	fmt.println("Step 2.", possible_timelines(&tachyon_diagram))
}

Tachyon_Diagram :: struct {
	source: Coordinate,
	splitters: map[Coordinate]struct{},
	beam_heads: map[Coordinate]struct{},
	size_x, size_y: int,
}

Coordinate :: struct {
	x, y: int
}

parse_tachyon_diagram :: proc(s: string) -> Tachyon_Diagram {
	lines, err := strings.split_lines(s)
	assert(err == nil)
	defer delete(lines)

	source_x: int
	for r, i in lines[0] {
		if r == 'S' {
			source_x = i
			break
		}
	}
	
	splitters := make(map[Coordinate]struct{})
	for line, y in lines[1:] {
		for r, x in line {
			if r == '^' {
				splitters[Coordinate{x, y+1}] = struct{}{}
			}
		}
	}

	return Tachyon_Diagram{
		source = Coordinate{source_x, 0},
		splitters = splitters,
		beam_heads = make(map[Coordinate]struct{}),
		size_x = len(lines[0]),
		size_y = len(lines),
	}
}


possible_timelines :: proc(diagram: ^Tachyon_Diagram) -> int {
	cache := make(map[Coordinate]int)
	defer delete(cache)
	return step_beam(diagram, &cache, diagram.source)
}

step_beam :: proc(diagram: ^Tachyon_Diagram, cache: ^map[Coordinate]int, beam: Coordinate) -> int {
	cache := cache
	
	new_coord := Coordinate{beam.x, beam.y+1}
	if new_coord.y == diagram.size_y-1 {
		return 1
	}

	cached_timelines, cache_hit := cache[new_coord]
	if cache_hit {
		return cached_timelines
	}

	timelines: int
	_, hit_splitter := diagram.splitters[new_coord]
	if hit_splitter {
		timelines += step_beam(diagram, cache, Coordinate{new_coord.x-1, new_coord.y})
		timelines += step_beam(diagram, cache, Coordinate{new_coord.x+1, new_coord.y})
	} else {
		timelines += step_beam(diagram, cache, new_coord)
	}
	cache[new_coord] = timelines
	return timelines
}

step_until_end_of_manifold :: proc(diagram: ^Tachyon_Diagram) -> int {
	hit_end := false
	hit_splitter_count: int
	for !hit_end {
		hits: int
		hits, hit_end = step(diagram)
		hit_splitter_count += hits
	}
	return hit_splitter_count
}

step :: proc(diagram: ^Tachyon_Diagram) -> (int, bool) {
	d := diagram
	if len(d.beam_heads) == 0 {
		// Spawn a beam from source.
		d.beam_heads[d.source] = struct{}{}
		return 0, false
	}

	new_beam_heads := make(map[Coordinate]struct{})
	hit_splitter_count: int
	end_of_manifold := false
	for beam in d.beam_heads {
		new_coord := Coordinate{beam.x, beam.y+1}
		if new_coord.y == d.size_y-1 {
			end_of_manifold = true
		}
		_, hit_splitter := d.splitters[new_coord]
		if hit_splitter {
			hit_splitter_count += 1
			new_beam_heads[Coordinate{new_coord.x-1, new_coord.y}] = struct{}{}
			new_beam_heads[Coordinate{new_coord.x+1, new_coord.y}] = struct{}{}
		} else {
			new_beam_heads[new_coord] = struct{}{}
		}
	}

	delete(d.beam_heads)
	d.beam_heads = new_beam_heads

	return hit_splitter_count, end_of_manifold
}

print_diagram :: proc(diagram: ^Tachyon_Diagram) {
	builder := strings.builder_make_none()
	defer strings.builder_destroy(&builder)
	for y in 0..<diagram.size_y {
		for x in 0..<diagram.size_x {
			coord := Coordinate{x, y}

			if coord.x == diagram.source.x && coord.y == diagram.source.y {
				strings.write_rune(&builder, 'S')
				continue
			}
			
			_, is_beam := diagram.beam_heads[coord]
			if is_beam {
				strings.write_rune(&builder, '|')
				continue
			}

			_, is_splitter := diagram.splitters[coord]
			if is_splitter {
				strings.write_rune(&builder, '^')
				continue
			}

			strings.write_rune(&builder, '.')
		}
		strings.write_rune(&builder, '\n')
	}

	fmt.println(strings.to_string(builder))
}
