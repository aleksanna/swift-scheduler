//
//  main.swift
//  OSScheduler
//
//  Created by sphota on 10/2/16.
//  Copyright © 2016 Intellex. All rights reserved.
//

import Foundation

// runs FCFS
print("Now running FCFS.....\n\n")
let fcfs = FCFS("test1.txt")
// runs MLFQ
print("Now running MLFQ.....\n\n")
let mlfq = MLFQ("test1.txt", tq1: 7, tq2: 14)
