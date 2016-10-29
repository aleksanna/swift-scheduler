//
//  Queue.swift
//  OSScheduler

import Foundation

/*
First-in first-out queue (FIFO)

New elements are added to the end of the queue. Dequeuing pulls elements from
the front of the queue.

Enqueuing is an O(1) operation, dequeuing is O(n). Note: If the queue had been
implemented with a linked list, then both would be O(1).
*/

public struct Queue<Process> {
	// variables for this structure
	fileprivate var array = [Process]()
	fileprivate var tq: Int?
	
	// returns how many elements there are in your queue
	public var count: Int {
		return array.count
	}
	
	// returns the time quantum if any
	public var timeQ: Int {
		return (tq ?? nil)!
	}
	
	// returns true if  the array is empty and vice versa
	public var isEmpty: Bool {
		return array.isEmpty
	}
	
	// accessor function to get the array of processes
	public var processes: [Process] {
		return array
	}
	
	// change the value of the queue to another array of processes
	public mutating func setProcess(p: [Process]) {
		array = p
	}
	
	// adds new item to the back of the queue structure
	public mutating func enqueue(_ element: Process) {
		array.append(element)
	}
	
	// removes the first element of the queue unless it is empty
	public mutating func dequeue() -> Process? {
		if isEmpty {
			return nil
		} else {
			return array.removeFirst()
		}
	}
	
	// gives you access to the first element in your queue
	public func peek() -> Process? {
		return array.first
	}
}
