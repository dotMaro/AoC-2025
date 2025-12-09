package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:math"
import "core:slice"

main :: proc() {
	input :: #load("../../inputs/day08.txt", string)

	junction_boxes := parse_junction_boxes(input)
	for i in 0..<1000 {
		fmt.printfln("%d/%d", i, 999)
		connect_closest_unconnected_junction_boxes(&junction_boxes)
	}
	fmt.println("Part 1.", multiply_circuit_sizes(junction_boxes))

	product: int
	all_in_one_circuit := false
	i := 0
	for !all_in_one_circuit {
		if i % 100 == 0 {
			fmt.println(i)
		}
		i += 1
		all_in_one_circuit, product = connect_closest_unconnected_junction_boxes(&junction_boxes)
	}
	fmt.println("Part 2.", product)
}

Junction_Box :: struct{
	using coordinates: Coordinates,
	connections: [dynamic]^Junction_Box,
}

Coordinates :: struct{x, y, z: int}

parse_junction_boxes :: proc(s: string) -> []Junction_Box {
	lines := strings.split_lines(s)
	defer delete(lines)
	boxes := make([]Junction_Box, len(lines))
	for line, i in lines {
		parts, err := strings.split_n(line, ",", 3)
		assert(err == nil)
		assert(len(parts) == 3)

		x, y, z: int
		ok: bool
		x, ok = strconv.parse_int(parts[0], 10)
		assert(ok)
		y, ok = strconv.parse_int(parts[1], 10)
		assert(ok)
		z, ok = strconv.parse_int(parts[2], 10)
		assert(ok)

		boxes[i] = Junction_Box{{x, y, z}, make([dynamic]^Junction_Box)}
	}

	return boxes
}

box_equals :: #force_inline proc(b1, b2: Junction_Box) -> bool {
	return b1.x == b2.x && b1.y == b2.y && b1.z == b2.z
}

connect_closest_unconnected_junction_boxes :: proc(boxes: ^[]Junction_Box) -> (all_in_one_circuit: bool, product_of_x: int) {
	boxes := boxes

	closest1, closest2: ^Junction_Box
	smallest_distance: f32 = 99999999.0
	for &b1, i1 in boxes {
		for &b2, i2 in boxes {
			if i1 == i2 {
				continue
			} 
			already_directly_connected := false
			for c in b1.connections {
				if box_equals(c^, b2) {
					already_directly_connected = true
				}
			}
			if already_directly_connected {
				continue
			}
			dist := distance(b1, b2)
			if dist < smallest_distance {
				closest1, closest2 = &b1, &b2
				smallest_distance = dist
			}
		}
	}

	// Add bi-directional connection.
	append(&closest1.connections, closest2)
	append(&closest2.connections, closest1)

	// Check if a circuit containing all boxes was made.
	visited := make(map[Coordinates]struct{})
	circuit := find_circuit(closest1^, &visited)
	defer delete(circuit)
	delete(visited)
	if len(circuit) == len(boxes) {
		return true, closest1.x * closest2.x
	}
	
	return false, 0
}

multiply_circuit_sizes :: proc(boxes: []Junction_Box) -> int {
	included := make(map[Coordinates]struct{}, len(boxes))
	circuit_sizes := make([dynamic]int)
	for b in boxes {
		if b.coordinates in included {
			continue
		}
		visited := make(map[Coordinates]struct{})
		circuit := find_circuit(b, &visited)
		delete(visited)
		append(&circuit_sizes, len(circuit))
		for c in circuit {
			included[c] = struct{}{}
		}
		delete(circuit)
	}

	slice.reverse_sort(circuit_sizes[:])

	return circuit_sizes[0] * circuit_sizes[1] * circuit_sizes[2]
}

pp :: proc(boxes: []Junction_Box) -> string {
	bb := strings.builder_make_none()
	defer strings.builder_destroy(&bb)

	for b in boxes {
		fmt.sbprintf(&bb, "(%d,%d,%d)", b.x, b.y, b.z)
	}

	return strings.to_string(bb)
}

find_circuit :: proc(box: Junction_Box, visited: ^map[Coordinates]struct{}) -> []Junction_Box {
	visited := visited
	visited[box.coordinates] = struct{}{}
	
	circuit := make([dynamic]Junction_Box)
	append(&circuit, box)
	
	for c in box.connections {
		if c.coordinates not_in visited {
			add_circuit := find_circuit(c^, visited)
			append(&circuit, ..add_circuit)
			delete(add_circuit)
		}
	}

	return circuit[:]
}

@(require_results)
find_connected_box :: proc(source, target: ^Junction_Box, ignore: ^Junction_Box=nil) -> bool {
	for c in source.connections {
		if box_equals(c^, target^) {
			return true
		}
		// Don't loop back to where we just came from.
		if ignore != nil && box_equals(c^, ignore^) {
			continue
		}
		if find_connected_box(c, target, source) {
			return true
		}
	}
	return false
}

@(require_results)
distance :: proc(c1, c2: Coordinates) -> f32 {
	x_diff, y_diff, z_diff := c1.x - c2.x, c1.y - c2.y, c1.z - c2.z
	return math.sqrt(f32(x_diff * x_diff + y_diff * y_diff + z_diff * z_diff))
}
