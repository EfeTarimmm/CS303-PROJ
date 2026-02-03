CS303 – Electronic Battleship Game (FPGA)

This repository contains the term project for CS303: Logic & Digital System Design at Sabancı University. The project implements a two‑player electronic Battleship game on an FPGA board using Verilog, following a structured Algorithmic State Machine (ASM) design methodology.

⸻

Project Overview
	•	Game Type: Two‑player Battleship
	•	Platform: FPGA
	•	Language: Verilog
	•	Board Size: 4×4 grid per player
	•	Interface: Push buttons, switches, LEDs, and seven‑segment displays (SSDs)

The game allows two players (A and B) to place ships, take turns shooting, track scores, and determine a winner. All gameplay logic is implemented in hardware using finite‑state control.

⸻

Gameplay Flow
	1.	Reset State
	•	Game resets via reset button.
	•	SSDs display IDLE and predefined LEDs turn on.
	2.	Ship Placement Phase
	•	Players A and B sequentially enter ship coordinates using switches.
	•	Each player places four ships on a 4×4 grid.
	•	Invalid placements (overlapping ships) trigger an ERRO state.
	3.	Shooting Phase
	•	Players take turns selecting target coordinates.
	•	Live X/Y coordinates are shown on SSDs.
	•	Scores are updated and displayed using LEDs and SSDs.
	4.	Win Condition
	•	First player to sink four ships wins.
	•	Winner is displayed on SSDs and LEDs perform a blinking/dance pattern.

⸻

Design & Architecture
	•	Implemented using a Finite State Machine (FSM) derived from the provided ASM charts.
	•	Game phases (idle, input, validation, shooting, scoring, win) are mapped to distinct states.
	•	Button presses are synchronized and cleaned using a debouncer module.
	•	A clock divider generates a 50 Hz clock for stable gameplay timing.

Key Modules
	•	top.v – Top‑level module integrating all components
	•	battleship logic – Core FSM and gameplay control
	•	clk_divider.v – Clock division from 100 MHz to 50 Hz
	•	debouncer.v – Button edge detection
	•	ssd.v – Seven‑segment display driver

⸻

Inputs & Outputs

Inputs
	•	Buttons:
	•	BTN3 – Player A action
	•	BTN0 – Player B action
	•	BTN1 – Start
	•	BTN2 – Reset
	•	Switches:
	•	Switches [3:2] → X coordinate
	•	Switches [1:0] → Y coordinate

Outputs
	•	LEDs:
	•	Indicate turn, input count, score, and hit/miss feedback
	•	SSDs:
	•	Display coordinates, player turns, scores, errors, and winner

⸻

Verification & Demonstration
	•	Functionality verified through Verilog simulation using custom testbenches.
	•	Final design implemented and demonstrated on FPGA hardware.
	•	Edge cases such as invalid ship placement and repeated shots were handled explicitly.

⸻

How to Run
	1.	Load the provided Verilog files onto the FPGA project environment.
	2.	Ensure all module names and interfaces remain unchanged.
	3.	Synthesize and program the FPGA.
	4.	Use switches and buttons to interact with the game as described above.

⸻

Learning Outcomes
	•	Practical experience with FSM/ASM‑based digital design
	•	Hands‑on Verilog development and debugging
	•	Hardware‑level input/output handling
	•	FPGA implementation and real‑time testing

⸻

Notes
	•	Project follows strict academic integrity rules; all logic was implemented manually.
	•	Design decisions prioritize correctness, clarity, and hardware feasibility.

⸻

Course: CS303 – Logic & Digital System Design
Term: Fall 2024
