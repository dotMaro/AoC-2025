package main

import "core:fmt"
import "core:strings"

/*
	This can probably be done more intelligently by looking for the largest digit that's next within the bank size - remaining battery count. But I got the bruteforcing fast enough so I'll leave it as it is.
*/

main :: proc() {
	input :: #load("../../inputs/day03.txt", string)

	output_joltage_2_batteries: u64
	output_joltage_12_batteries: u64
	for bank in strings.split_lines(input) {
		output_joltage_2_batteries += largest_joltage_combination_n_batteries(bank, 2)
		joltage := largest_joltage_combination_n_batteries(bank, 12)
		fmt.println(bank, joltage)
		output_joltage_12_batteries += joltage
	}
	fmt.printf("Part 1. %d\n", output_joltage_2_batteries)
	fmt.printf("Part 2. %d\n", output_joltage_12_batteries)
}

largest_joltage_combination_n_batteries :: proc(bank: string, n: int) -> u64 {
	return find_largest_joltage_combination_n_batteries(bank, 0, n, 0)
}

find_largest_joltage_combination_n_batteries :: proc(bank: string, combination: u64, n, current: int) -> u64 {
	if current == n || bank == "" {
		return combination
	}
	
	largest_joltage: u64
	largest_joltage_battery: rune
	for battery, i in bank {
		if battery <= largest_joltage_battery {
			// It was over before it began.
			continue
		}
 		joltage := find_largest_joltage_combination_n_batteries(bank[i+1:], combination*10 + u64(battery) - '0', n, current+1)
		if joltage > largest_joltage {
			largest_joltage = joltage
			largest_joltage_battery = battery
		}
	}

	return largest_joltage
}

