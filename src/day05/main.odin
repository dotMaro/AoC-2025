package main

import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:slice"

main :: proc() {
	input :: #load("../../inputs/day05.txt", string)

	ranges: [dynamic]Range
	available_ingredients: [dynamic]u64
	defer {
		delete(ranges)
		delete(available_ingredients)
	}
	parse_ranges := true
	for line in strings.split_lines(input) {
		if line == "" {
			parse_ranges = false
			continue
		}

		if parse_ranges {
			append(&ranges, parse_range(line))
		} else {
			ingredient, ok := strconv.parse_u64(line)
			assert(ok)
			append(&available_ingredients, ingredient)
		}
	}

	fresh_count: uint
	for ingredient in available_ingredients {
		for range in ranges {
			if ingredient >= range.lower && ingredient <= range.upper {
				fresh_count += 1
				break
			}			
		}
	}

	fmt.println("Part 1.", fresh_count)

	// Merge all overlapping ranges.
	// Let's start by sorting all ranges by their lower bound.
	slice.sort_by(ranges[:], proc(i, j: Range) -> bool {return i.lower < j.lower})

	// Now check each range's lower bound to see which ranges we can merge.
	skip: uint
	merged_ranges: [dynamic]Range
	defer delete(merged_ranges)
	for &r1, i in ranges {
		// Skip any merged ranges as they are accounted for.
		if skip > 0 {
			skip -= 1
			continue
		}
		merged_range: Range = r1
		added := false
		if i+1 < len(ranges) {
			for r2 in ranges[i+1:] {
				if r2.lower > merged_range.upper+1 { // If they're only separated by one they can get merged anyway.
					append(&merged_ranges, merged_range)
					added = true
					break
				}
				// Merge possible.
				// Continue until we find a range that can't be merged.
				merged_range = Range{r1.lower, max(merged_range.upper, r2.upper)}
				skip += 1
			}
		}
		if !added {
			// This happens when it's able to merge to the last range.
			append(&merged_ranges, merged_range)
			break
		}
	}

	sum: u64
	for range in merged_ranges {
		sum += range.upper - range.lower + 1
	}

	fmt.println("Part 2.", sum)
}

Range :: struct {
	lower, upper: u64
}

parse_range :: proc(s: string) -> Range {
	parts, err := strings.split_n(s, "-", 2)
	assert(err == nil)
	assert(len(parts) == 2)

	lower, upper: u64
	ok: bool
	lower, ok = strconv.parse_u64(parts[0])
	assert(ok)
	upper, ok = strconv.parse_u64(parts[1])
	assert(ok)
	
	return Range{lower,	upper}
}
