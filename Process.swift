//
//  Process.swift
//  OSScheduler

import Foundation

// this is the process structure for our queues
struct Process {
	// boolean value that determines whether a process has finished or not
	var done: Bool
	// boolean value that determines whether this is the first time this
	// process is executing
	var firstTimeExecution: Bool
	// id number of the process
	let id: Character
	// variable that keeps track of the waiting time for the process
	var waiting: Int?
	// array of CPU bursts
	var burstArray: [Int]
	// index of CPU burst the queue is currently at
	var burstIdx: Int
	// the value of the current burst that the CPU is processing
	var currentBurst: Int
	// the value of the current io time for a process
	var currentIO: Int
	// array of io times
	var ioTime: [Int]
	// index of io time the queue is currently at
	var ioIdx: Int
	// variable that holds the value of the response time
	var response: Int?
	// optional value, stores the priority of the process (which queue)
	var priority: Int?
	// time the process is completely done executing
	var endTime: Int?
	// arrival time of process into the queue
	var arrivalTime: Int
}
