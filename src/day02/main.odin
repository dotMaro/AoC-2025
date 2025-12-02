package main

import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
	input :: #load("../../inputs/day02.txt", string)

	two_repeated_sequences_sum: u64
	any_repeated_sequences_sum: u64
	for range in strings.split(input, ",") {
		parts := strings.split_n(range, "-", 2)
		assert(len(parts) == 2)

		lower, lower_ok := strconv.parse_u64(parts[0])
		assert(lower_ok)
		upper, upper_ok := strconv.parse_u64(parts[1])
		assert(upper_ok)

		for id in lower..=upper {
			buffer: [20]u8
			id_str := strconv.write_uint(buffer[:], id, 10)

			if is_two_repeated_sequences(id_str) {
				two_repeated_sequences_sum += id
			}
			if has_any_repeating_sequence(id_str) {
				any_repeated_sequences_sum += id			
			}
		}
	}

	fmt.printf("Part 1. %d\n", two_repeated_sequences_sum)
	fmt.printf("Part 2. %d\n", any_repeated_sequences_sum)
}

is_two_repeated_sequences :: proc(id: string) -> bool {
	middle := len(id) / 2
	return id[:middle] == id[middle:]
}

has_any_repeating_sequence :: proc(id: string) -> bool {
	for i in 1..=len(id)/2 {
		sequence := id[:i]
		reconstructed := strings.repeat(sequence, len(id)/i)
		if reconstructed == id {
			return true
		}
	}
	return false
}
