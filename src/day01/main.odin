package main

import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
	input :: #load("../../inputs/day01.txt", string)

	position := 50
	landed_at_zero_between_instructions_count := 0
	zero_clicks := 0
	for line in strings.split_lines(input) {
		if line == "" {
			continue
		}

		rotations, ok := strconv.parse_int(line[1:])
		if !ok {
			fmt.panicf("could not parse int %d", line[1:])
		}
		switch line[0] {
		case 'L':
			if position == 0 {
				// Since one will be counted twice, decrement by one.
				zero_clicks -= 1
			}
			position -= rotations
			for position < 0 {
				zero_clicks += 1
				position += 100
			}
			if position == 0 {
				zero_clicks += 1
			}
		case 'R':
			position += rotations
			zero_clicks += position/100 // This will also catch if position ends up at zero.
			position %= 100
		case:
			fmt.panicf("invalid character %d", line[0])
		}

		if position == 0 {
			landed_at_zero_between_instructions_count += 1
		}
	}
	fmt.printf("Step 1. %d\n", landed_at_zero_between_instructions_count)
	fmt.printf("Step 2. %d\n", zero_clicks)
}


