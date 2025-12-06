package main

import "core:fmt"
import "core:strings"
import "core:strconv"

main :: proc() {
	input :: #load("../../inputs/day06.txt", string)

	fmt.println("Part 1.", parse_horizontally_and_calculate_sum_of_answers(input))
	fmt.println("Part 2.", parse_vertically_and_calculate_sum_of_answers(input))
}

parse_vertically_and_calculate_sum_of_answers :: proc(input: string) -> uint {
	operand_rows: [dynamic]string
	defer delete(operand_rows)
	operation_row: string
	
	lines, err := strings.split_lines(input)
	assert(err == nil)
	defer delete(lines)
	for line, line_number in lines {
		if line[0] == '+' || line[0] == '*' {
			// Operations.
			operation_row = line
		} else {
			// Operands.
			append(&operand_rows, line)
		}
	}

	// Sanity check.
	for operand_row in operand_rows[1:] {
		assert(len(operand_row) == len(operand_rows[0]))
	}

	operands: [dynamic]uint
	defer delete(operands)
	sum: uint
	for i := len(operand_rows[0])-1; i >= 0; i -= 1 {
		operand: uint
		for row in operand_rows {
			if row[i] != ' ' {
				operand = 10 * operand + uint(row[i] - '0')
			}
		}
		if operand == 0 {
			// Getting a zero operand means all operand rows had a space, i.e. we're between problems.
			continue
		}
		append(&operands, operand)

		operation := operation_row[i]
		if operation != ' ' {
			switch operation {
			case '+':
				for operand in operands {
					sum += operand
				}
			case '*':
				answer: uint = 1
				for operand in operands {
					answer *= operand
				}
				sum += answer
			}
			clear(&operands)
		}
	}

	return sum
}

parse_horizontally_and_calculate_sum_of_answers :: proc(input: string) -> uint {
	operands: [dynamic][dynamic]uint
	operations: [dynamic]u8
	defer {
		delete(operands)
		delete(operations)
	}
	operand_part := true
	lines, err := strings.split_lines(input)
	assert(err == nil)
	defer delete(lines)
	for line, line_number in lines {
		if line[0] == '+' || line[0] == '*' {
			operand_part = false
		} else {
			append(&operands, make([dynamic]uint))
		}
		for match in strings.split(line, " ") {
			if len(match) == 0 {
				continue
			}

			if operand_part {
				value, ok := strconv.parse_uint(match, 10)
				assert(ok, "parse operand")
				append(&operands[line_number], value)
			} else {
				assert(len(match) == 1, match)
				append(&operations, match[0])
			}
		}
	}

	// Sanity check that all operands and operations are equal in size.
	assert(len(operands[0]) == len(operands[1]))
	assert(len(operands[0]) == len(operands[2]))
	assert(len(operands[0]) == len(operations))

	sum: uint
	for operation, i in operations {
		answer: uint
		switch operation {
		case '+':
			for operand_column in operands {
				answer += operand_column[i]
			}
		case '*':
			answer = 1
			for operand_column in operands {
				answer *= operand_column[i]
			}
		case:
			fmt.panicf("illegal operation %q", operation)
		}
		sum += answer
	}

	return sum
}
