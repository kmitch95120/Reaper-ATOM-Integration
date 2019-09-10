#!/bin/bash

./sendmidi dev ATOM ch 1 cc 86 0

./sendmidi dev ATOM ch 1 cc 85 0

./sendmidi dev ATOM ch 1 cc 31 0

./sendmidi dev ATOM ch 1 cc 30 0

./sendmidi dev ATOM ch 1 cc 29 0

# Preset +/-
./sendmidi dev ATOM ch 1 cc 27 0
./sendmidi dev ATOM ch 2 cc 27 0
./sendmidi dev ATOM ch 3 cc 27 0
./sendmidi dev ATOM ch 4 cc 27 0

# Bank
./sendmidi dev ATOM ch 1 cc 26 0
./sendmidi dev ATOM ch 2 cc 26 0
./sendmidi dev ATOM ch 3 cc 26 0
./sendmidi dev ATOM ch 4 cc 26 0

./sendmidi dev ATOM ch 1 cc 25 0

./sendmidi dev ATOM ch 1 cc 24 0

./sendmidi dev ATOM ch 1 cc 32 0

./sendmidi dev ATOM ch 1 cc 105 0

./sendmidi dev ATOM ch 1 cc 107 0

# Play
./sendmidi dev ATOM ch 1 cc 109 0
./sendmidi dev ATOM ch 2 cc 109 0
./sendmidi dev ATOM ch 3 cc 109 0
./sendmidi dev ATOM ch 4 cc 109 0

./sendmidi dev ATOM ch 1 cc 111 0
