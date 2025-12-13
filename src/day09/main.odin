package main

import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
	input :: #load("../../inputs/day09.txt", string)

	lines, err := strings.split_lines(input)
	assert(err == nil)
	defer delete(lines)
	red_tiles := make([]Coordinate, len(lines))
	for line, i in lines {
		parts, err := strings.split_n(line, ",", 2)
		assert(err == nil)
		assert(len(parts) == 2)

		x, y: int
		ok: bool
		x, ok = strconv.parse_int(parts[0], 10)
		assert(ok)
		y, ok = strconv.parse_int(parts[1], 10)
		assert(ok)
		delete(parts)
			
		red_tiles[i] = Coordinate{x, y}
	}

	fmt.println("Part 1.", largest_area(red_tiles, false))
	fmt.println("Part 2.", largest_area(red_tiles, true))
}

Coordinate :: struct{x, y: int}

largest_area :: proc(vertices: []Coordinate, must_be_within_polygon: bool) -> int {
	largest_area: int
	for v1, i in vertices {
		v2_loop: for v2, i2 in vertices {
			x_diff, y_diff := abs(v1.x - v2.x) + 1, abs(v1.y - v2.y) + 1
			area := x_diff * y_diff
			if area <= largest_area {
				continue
			}
			if must_be_within_polygon {
				// This is a very naive solution that is not general, but
				// apparently it's good enough for both the example and the real input.
				max_y, min_y := max(v1.y, v2.y), min(v1.y, v2.y)
				max_x, min_x := max(v1.x, v2.x), min(v1.x, v2.x)

				last_vertex := vertices[len(vertices)-1]
				for v in vertices {
					if max(v.y, last_vertex.y) > min_y &&
						min(v.y, last_vertex.y) < max_y &&
						max(v.x, last_vertex.x) > min_x &&
						min(v.x, last_vertex.x) < max_x {
							continue v2_loop
						}
					last_vertex = v
				}
			}
			largest_area = area
		}
	}
	return largest_area
}

is_on_edge :: proc(vertices: []Coordinate, point: Coordinate) -> bool {
	last_vertex := vertices[len(vertices)-1]
	for vertex in vertices {
		if vertex.x == last_vertex.x && point.x == vertex.x &&
			point.y >= min(vertex.y, last_vertex.y) && point.y <= max(vertex.y, last_vertex.y) {
			return true
		}
		if vertex.y == last_vertex.y && point.y == vertex.y &&
			point.x >= min(vertex.x, last_vertex.x) && point.x <= max(vertex.x, last_vertex.x) {
			return true
		}
		last_vertex = vertex
	}
	return false
}

point_in_polygon :: proc(vertices: []Coordinate, from_x, to_x, y: int, max_x: int) -> bool {
	// Raycast to the right and count the intersections.
	// Credits to <https://en.wikipedia.org/wiki/Point_in_polygon#Ray_casting_algorithm>.
	intersections: uint
	last_result := false
	up_on_leave_edge := false
	for x := max_x; x >= from_x; x -= 1 {
		point := Coordinate{x, y}
		on_edge := is_on_edge(vertices, point)
		if on_edge && !up_on_leave_edge {
			intersections += 1
		}
		if !on_edge && last_result {
			if up_on_leave_edge {
				intersections += 1
				up_on_leave_edge = false
			} else {
				up_on_leave_edge = true
			}
		}
		// An odd amount of intersections means it's inside the polygon.
		in_polygon := intersections % 2 == 1
		if x <= to_x && !in_polygon {
			return false
		}
		last_result = on_edge
	}
	return true
}
