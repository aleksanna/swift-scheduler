//
//  MLFQ.swift
//  SwiftScheduler

import Foundation

// class for the MLFQ algorithm
final class MLFQ {
	// private variables for this class
	fileprivate var rrQueue1: Queue<Process>?
	fileprivate var rrQueue2: Queue<Process>?
	fileprivate var fcfsQueue: Queue<Process>?
	fileprivate var mlfqProcesses: [Process]?
	fileprivate var currentTime: Int
	fileprivate var tq1: Int
	fileprivate var tq2: Int
	fileprivate var idleTime: Int
	
	// default constructor for MLFQ class
	private init() {
		self.currentTime = 0
		self.mlfqProcesses = [Process]()
		self.rrQueue1 = Queue<Process>()
		self.rrQueue2 = Queue<Process>()
		self.fcfsQueue = Queue<Process>()
		self.tq1 = 0
		self.tq2 = 0
		self.idleTime = 0
	}
	
	// explicit value constructor for MLFQ class
	public convenience init(_ filename: String, tq1: Int, tq2: Int) {
		self.init()
		self.tq1 = tq1
		self.tq2 = tq2
		self.load(filename)
	}
	
	private func startProcesses() {
		// add all processes to the first round robin queue
		for p in self.mlfqProcesses! {
			self.rrQueue1?.enqueue(p)
		}

		// clear array of processes so it can be used for the calculations
		self.mlfqProcesses = [Process]()
		
		// call executeProcesses until all of the queues are empty
		while !fcfsQueue!.isEmpty || !rrQueue1!.isEmpty || !rrQueue2!.isEmpty {
			self.executeProcesses()
		}
		
		// call calculateTimes to calculate response time, turnaround time, et cetera
		self.calculateTimes()
	}
	
	// sorting function to sort the first queue based on arrival time and process id
	private func sortRR1() {
		self.rrQueue1?.setProcess(p: (self.rrQueue1?.processes.sorted(by: {
			if (($0 as Process).arrivalTime == ($1 as Process).arrivalTime) {
				return ($0 as Process).id < ($1 as Process).id
			} else {
				return ($0 as Process).arrivalTime < ($1 as Process).arrivalTime
			}
		}))!)
	}
	
	// sorting function to sort the second queue based on arrival time and process id
	private func sortRR2() {
		self.rrQueue2?.setProcess(p: (self.rrQueue2?.processes.sorted(by: {
			if (($0 as Process).arrivalTime == ($1 as Process).arrivalTime) {
				return ($0 as Process).id < ($1 as Process).id
			} else {
				return ($0 as Process).arrivalTime < ($1 as Process).arrivalTime
			}
		}))!)
	}
	
	// sorting function to sort the third queue based on arrival time and process id
	private func sortFCFS() {
		self.fcfsQueue?.setProcess(p: (self.fcfsQueue?.processes.sorted(by: {
			if (($0 as Process).arrivalTime == ($1 as Process).arrivalTime) {
				return ($0 as Process).id < ($1 as Process).id
			} else {
				return ($0 as Process).arrivalTime < ($1 as Process).arrivalTime
			}
		}))!)
	}
	
	private func executeProcesses() {
		var executingProcess: Process
		// check if this is the first time the process is executing
		if !self.rrQueue1!.isEmpty && self.rrQueue1!.peek()!.firstTimeExecution {
			// dequeue first process
			executingProcess = (rrQueue1?.dequeue())!
			// set response time
			executingProcess.response = self.currentTime
			print("Now running: " + "P" + String(executingProcess.id))
			print("..................................................")
			print("Ready Queue:\tProcess\tBurst\t\tQueue")
			for p in self.rrQueue1!.processes {
				if p.arrivalTime <= self.currentTime {
					print("\t\t\tP" + String(p.id) + "\t\t" + String(p.burstArray[p.burstIdx]) + "\t\tQ1")
				}
			}
			for p in self.rrQueue2!.processes {
				if p.arrivalTime <= self.currentTime {
					print("\t\t\tP" + String(p.id) + "\t\t" + String(p.burstArray[p.burstIdx]) + "\t\tQ2")
				}
			}
			for p in self.fcfsQueue!.processes {
				if p.arrivalTime <= self.currentTime {
					print("\t\t\tP" + String(p.id) + "\t\t" + String(p.burstArray[p.burstIdx]) + "\t\tQ3e")
				}
			}
			print("Now in I/O:\tProcess\tRemaining I/O time")
			for p in self.rrQueue1!.processes {
				if p.arrivalTime > self.currentTime {
					print("\t\t\tP" + String(p.id) + "\t\t" + String(p.arrivalTime - self.currentTime))
				}
			}
			for p in self.rrQueue2!.processes {
				if p.arrivalTime > self.currentTime {
					print("\t\t\tP" + String(p.id) + "\t\t" + String(p.arrivalTime - self.currentTime))
				}
			}
			for p in self.fcfsQueue!.processes {
				if p.arrivalTime > self.currentTime {
					print("\t\t\tP" + String(p.id) + "\t\t" + String(p.arrivalTime - self.currentTime))
				}
			}
			// update firstTimeExecution to be false
			executingProcess.firstTimeExecution = false
			// set current burst
			executingProcess.currentBurst = executingProcess.burstArray[executingProcess.burstIdx]
			// check if current burst is less than or equal to time quantum
			if executingProcess.currentBurst <= self.tq1 {
				// update current time
				self.currentTime += executingProcess.currentBurst
				// update i/o time and current i/o only if there are more values available
				if executingProcess.ioIdx < executingProcess.ioTime.count {
					executingProcess.currentIO = executingProcess.ioTime[executingProcess.ioIdx]
					executingProcess.ioIdx = executingProcess.ioIdx + 1
					// update arrival time
					executingProcess.arrivalTime = self.currentTime + executingProcess.currentIO
				} else {
					// update arrival time
					executingProcess.arrivalTime = self.currentTime
				}
				// update burst index and guard to make sure we are not accessing an index out of range
				executingProcess.burstIdx = executingProcess.burstIdx + 1
				guard executingProcess.burstIdx < executingProcess.burstArray.count else {
					print("\n\nCurrent time: " + String(self.currentTime))
					executingProcess.done = true
					print("\n\n-------P" + String(executingProcess.id) + " has finished executing-------\n")
					// set end time to equal current time
					executingProcess.endTime = self.currentTime
					// add finished process to array of processes
					mlfqProcesses!.append(executingProcess)
					return
				}
				// enqueue process back onto first queue
				self.rrQueue1?.enqueue(executingProcess)
				// set priority to equal one
				executingProcess.priority! = 1
				self.sortRR1()
				print("\n\nCurrent time: " + String(self.currentTime))
			} else {
				// otherwise, currentBurst is larger than tq1...
				// update current time, arrival time, and burst array
				self.currentTime += self.tq1
				executingProcess.arrivalTime = self.currentTime
				executingProcess.burstArray[executingProcess.burstIdx] -= self.tq1
				// downgrade process to Q2, enqueue it
				self.rrQueue2?.enqueue(executingProcess)
				// reset priority to 2
				executingProcess.priority! = 2
				self.sortRR2()
				print("\n\nCurrent time: " + String(self.currentTime))
			}
			
		} else {
			// if you are here, it means that this is not a first-time execution
			var executingProcess: Process
			// checks if there are any processes that can be executed from Q1
			if !self.rrQueue1!.isEmpty && self.rrQueue1!.peek()!.arrivalTime <= self.currentTime {
				// dequeue first process
				executingProcess = (self.rrQueue1?.dequeue())!
				print("Now running: " + "P" + String(executingProcess.id))
				print("..................................................")
				print("Ready Queue:\tProcess\tBurst\t\tQueue")
				for p in self.rrQueue1!.processes {
					if p.arrivalTime <= self.currentTime {
						print("\t\t\tP" + String(p.id) + "\t\t" + String(p.burstArray[p.burstIdx]) + "\t\tQ1")
					}
				}
				for p in self.rrQueue2!.processes {
					if p.arrivalTime <= self.currentTime {
						print("\t\t\tP" + String(p.id) + "\t\t" + String(p.burstArray[p.burstIdx]) + "\t\tQ2")
					}
				}
				for p in self.fcfsQueue!.processes {
					if p.arrivalTime <= self.currentTime {
						print("\t\t\tP" + String(p.id) + "\t\t" + String(p.burstArray[p.burstIdx]) + "\t\tQ3")
					}
				}
				print("Now in I/O:\tProcess\tRemaining I/O time")
				for p in self.rrQueue1!.processes {
					if p.arrivalTime > self.currentTime {
						print("\t\t\tP" + String(p.id) + "\t\t" + String(p.arrivalTime - self.currentTime))
					}
				}
				// sets current burst
				executingProcess.currentBurst = executingProcess.burstArray[executingProcess.burstIdx]
				// checks if the current burst is less than or equal to the time quantum
				if executingProcess.currentBurst <= self.tq1 {
					// updates current time
					self.currentTime += executingProcess.currentBurst
					// updates i/o time and current i/o if there are any more values
					if executingProcess.ioIdx < executingProcess.ioTime.count {
						executingProcess.currentIO = executingProcess.ioTime[executingProcess.ioIdx]
						executingProcess.ioIdx = executingProcess.ioIdx + 1
						// update arrival time
						executingProcess.arrivalTime = self.currentTime + executingProcess.currentIO
					} else {
						// update arrival time
						executingProcess.arrivalTime = self.currentTime
					}
					// update burst index, and then guard against segmentation fault [index out of range]
					executingProcess.burstIdx = executingProcess.burstIdx + 1
					guard executingProcess.burstIdx < executingProcess.burstArray.count else {
						print("\n\nCurrent time: " + String(self.currentTime))
						executingProcess.done = true
						print("\n\n-------P" + String(executingProcess.id) + " has finished executing-------\n")
						// set end time to equal current time
						executingProcess.endTime = self.currentTime
						// add process to process array
						mlfqProcesses!.append(executingProcess)
						return
					}
					// enqueue process back onto first queue
					self.rrQueue1?.enqueue(executingProcess)
					// set priority
					executingProcess.priority! = 1
					self.sortRR1()
					print("\n\nCurrent time: " + String(self.currentTime))
				} else {
					// else, the process is too large for the time quantum
					// update current time
					self.currentTime += self.tq1
					// update arrival time
					executingProcess.arrivalTime = self.currentTime
					// update burst array
					executingProcess.burstArray[executingProcess.burstIdx] -= self.tq1
					// downgrade process to Q2, and enqueue onto Q2
					self.rrQueue2?.enqueue(executingProcess)
					// update priority
					executingProcess.priority! = 2
					self.sortRR2()
					print("\n\nCurrent time: " + String(self.currentTime))
				}
			} else if !self.rrQueue2!.isEmpty && self.rrQueue2!.peek()!.arrivalTime <= self.currentTime {
				// no available processes in Q1, but there are in Q2
				// dequeue first process
				executingProcess = (self.rrQueue2?.dequeue())!
				print("Now running: " + "P" + String(executingProcess.id))
				print("..................................................")
				print("Ready Queue:\tProcess\tBurst\t\tQueue")
				for p in self.rrQueue1!.processes {
					if p.arrivalTime <= self.currentTime {
						print("\t\t\tP" + String(p.id) + "\t\t" + String(p.burstArray[p.burstIdx]) + "\t\tQ1")
					}
				}
				for p in self.rrQueue2!.processes {
					if p.arrivalTime <= self.currentTime {
						print("\t\t\tP" + String(p.id) + "\t\t" + String(p.burstArray[p.burstIdx]) + "\t\tQ2")
					}
				}
				for p in self.fcfsQueue!.processes {
					if p.arrivalTime <= self.currentTime {
						print("\t\t\tP" + String(p.id) + "\t\t" + String(p.burstArray[p.burstIdx]) + "\t\tQ3e")
					}
				}
				print("Now in I/O:\tProcess\tRemaining I/O time")
				for p in self.rrQueue1!.processes {
					if p.arrivalTime > self.currentTime {
						print("\t\t\tP" + String(p.id) + "\t\t" + String(p.arrivalTime - self.currentTime))
					}
				}
				// update current burst
				executingProcess.currentBurst = executingProcess.burstArray[executingProcess.burstIdx]
				// check for the case of preemption from Q1
				if !self.rrQueue1!.isEmpty && self.rrQueue1!.peek()!.arrivalTime < self.currentTime + min(self.tq2, executingProcess.currentBurst) {
					// find the amount of time before preemption
					let preempt = self.rrQueue1!.peek()!.arrivalTime - self.currentTime
					// update current time
					self.currentTime += preempt
					// update burst array
					executingProcess.burstArray[executingProcess.burstIdx] -= preempt
					// update arrival time
					executingProcess.arrivalTime = self.currentTime
					// enqueue process back onto the second round robin queue
					self.rrQueue2?.enqueue(executingProcess)
					// set priority
					executingProcess.priority! = 2
					self.sortRR2()
					print("\n\nCurrent time: " + String(self.currentTime))
					// check if the current burst is less than the time quantum
				} else if executingProcess.currentBurst <= self.tq2 {
					// update current time
					self.currentTime += executingProcess.currentBurst
					// update i/o time and current i/o if there are more values
					if executingProcess.ioIdx < executingProcess.ioTime.count {
						executingProcess.currentIO = executingProcess.ioTime[executingProcess.ioIdx]
						executingProcess.ioIdx = executingProcess.ioIdx + 1
						// update arrival time
						executingProcess.arrivalTime = self.currentTime + executingProcess.currentIO
					} else {
						// update arrival time
						executingProcess.arrivalTime = self.currentTime
					}
					// update burst index and then guard against segmentation fault
					executingProcess.burstIdx = executingProcess.burstIdx + 1
					guard executingProcess.burstIdx < executingProcess.burstArray.count else {
						print("\n\nCurrent time: " + String(self.currentTime))
						executingProcess.done = true
						print("\n\n-------P" + String(executingProcess.id) + " has finished executing-------\n")
						// set end time of process
						executingProcess.endTime = self.currentTime
						// add process to array of processes
						mlfqProcesses!.append(executingProcess)
						return
					}
					// enqueue process back onto round robin queue
					self.rrQueue2?.enqueue(executingProcess)
					// set priority
					executingProcess.priority! = 2
					self.sortRR2()
					print("\n\nCurrent time: " + String(self.currentTime))
				} else {
					// else, could not finish burst in time quantum
					// update current time
					self.currentTime += self.tq2
					// update arrival time
					executingProcess.arrivalTime = self.currentTime
					// update burst array
					executingProcess.burstArray[executingProcess.burstIdx] -= self.tq2
					// downgrade process priority, enqueue onto Q3
					self.fcfsQueue?.enqueue(executingProcess)
					// update priority
					executingProcess.priority! = 3
					self.sortFCFS()
					print("\n\nCurrent time: " + String(self.currentTime))
				}
				// check if the fcfs queue has any available processes if Q1 & Q2 don't
			} else if !self.fcfsQueue!.isEmpty && self.fcfsQueue!.peek()!.arrivalTime <= self.currentTime {
				// dequeue first process
				executingProcess = (self.fcfsQueue?.dequeue())!
				print("Now running: " + "P" + String(executingProcess.id))
				print("..................................................")
				print("Ready Queue:\tProcess\tBurst\t\tQueue")
				for p in self.rrQueue1!.processes {
					if p.arrivalTime <= self.currentTime {
						print("\t\t\tP" + String(p.id) + "\t\t" + String(p.burstArray[p.burstIdx]) + "\t\tQ1")
					}
				}
				for p in self.rrQueue2!.processes {
					if p.arrivalTime <= self.currentTime {
						print("\t\t\tP" + String(p.id) + "\t\t" + String(p.burstArray[p.burstIdx]) + "\t\tQ2")
					}
				}
				for p in self.fcfsQueue!.processes {
					if p.arrivalTime <= self.currentTime {
						print("\t\t\tP" + String(p.id) + "\t\t" + String(p.burstArray[p.burstIdx]) + "\t\tQ3e")
					}
				}
				print("Now in I/O:\tProcess\tRemaining I/O time")
				for p in self.rrQueue1!.processes {
					if p.arrivalTime > self.currentTime {
						print("\t\t\tP" + String(p.id) + "\t\t" + String(p.arrivalTime - self.currentTime))
					}
				}
				print("P" + String(executingProcess.id) + " leaves the queue.")
				// update burst array
				executingProcess.currentBurst = executingProcess.burstArray[executingProcess.burstIdx]
				// check for preemption with Q1
				if !self.rrQueue1!.isEmpty && self.rrQueue1!.peek()!.arrivalTime < self.currentTime + executingProcess.currentBurst {
					// find at what time unit preemption occurs
					let preempt = self.rrQueue1!.peek()!.arrivalTime - self.currentTime
					// update current time
					self.currentTime += preempt
					// update burst array
					executingProcess.burstArray[executingProcess.burstIdx] -= preempt
					// update arrival time
					executingProcess.arrivalTime = self.currentTime
					// enqueue back onto fcfs queue
					self.fcfsQueue?.enqueue(executingProcess)
					// set priority
					executingProcess.priority! = 3
					self.sortFCFS()
					print("\n\nCurrent time: " + String(self.currentTime))
					// check for preemption with Q2
				} else if !self.rrQueue2!.isEmpty && self.rrQueue2!.peek()!.arrivalTime < self.currentTime + executingProcess.currentBurst {
					// find at what time unit preemption occurs
					let preempt = self.rrQueue2!.peek()!.arrivalTime - self.currentTime
					// update current time
					self.currentTime += preempt
					// update burst array
					executingProcess.burstArray[executingProcess.burstIdx] -= preempt
					// update arrival time
					executingProcess.arrivalTime = self.currentTime
					// enqueue process back onto fcfs queue
					self.fcfsQueue?.enqueue(executingProcess)
					// set priority
					executingProcess.priority! = 3
					self.sortFCFS()
					print("\n\nCurrent time: " + String(self.currentTime))
				} else {
					// if no preemption occurs....
					// update current time
					self.currentTime += executingProcess.currentBurst
					// update i/o and current i/o if there are any more
					if executingProcess.ioIdx < executingProcess.ioTime.count {
						executingProcess.currentIO = executingProcess.ioTime[executingProcess.ioIdx]
						executingProcess.ioIdx = executingProcess.ioIdx + 1
						// update arrival time
						executingProcess.arrivalTime = self.currentTime + executingProcess.currentIO
					} else {
						// update arrival time
						executingProcess.arrivalTime = self.currentTime
					}
					// update burst index and then guard against segmentation fault
					executingProcess.burstIdx = executingProcess.burstIdx + 1
					guard executingProcess.burstIdx < executingProcess.burstArray.count else {
						print("\n\nCurrent time: " + String(self.currentTime))
						executingProcess.done = true
						print("\n\n-------P" + String(executingProcess.id) + " has finished executing-------\n")
						// set end time to equal current time
						executingProcess.endTime = self.currentTime
						// add process to array of processes
						mlfqProcesses!.append(executingProcess)
						return
					}
					// enqueue process back onto fcfs queue
					self.fcfsQueue?.enqueue(executingProcess)
					// set priority
					executingProcess.priority! = 3
					self.sortFCFS()
					print("\n\nCurrent time: " + String(self.currentTime))
				}
			} else {
				// if you are here, we are in an idle state.
				// next available arrival times of each queue
				let minRR1 = rrQueue1?.peek()?.arrivalTime ?? Int(INT_MAX)
				let minRR2 = rrQueue2?.peek()?.arrivalTime ?? Int(INT_MAX)
				let minFCFS = fcfsQueue?.peek()?.arrivalTime ?? Int(INT_MAX)
				// add the minimum value of idle time to the idle time variable
				self.idleTime += (min(minRR1, minRR2, minFCFS) - self.currentTime)
				// update current time to be out of the idle state
				self.currentTime = min(minRR1, minRR2, minFCFS)
			}
		}
	}
	
	// function used to find turnaround time, response time, et cetera
	private func calculateTimes () {
		// sort array of processes by id
		self.mlfqProcesses?.sort { ($0 as Process).id < ($1 as Process).id }
		print("MLFQ Simulation Results:\n")
		print("Total Time: " + String(self.currentTime) + "\n")
		print("..................................................\n")
		// find cpu utilization time by subtracting current time by idle time and then dividing by current time
		print("CPU Utilization: " +  String((Float(self.currentTime) - Float(self.idleTime)) / Float(self.currentTime) * 100) + "%\n")
		print("..................................................")
		print("\nWaiting times: \n")
		var burstSum: Int = 0
		var ioSum: Int = 0
		var waitingTime: Int = 0
		var waitingSum: Int = 0
		// adding up all the burst and io times
		for p in self.mlfqProcesses! {
			for burst in p.burstArray {
				burstSum += burst
			}
			
			for io in p.ioTime {
				ioSum += io
			}
			// find waiting time
			waitingTime = (p.endTime! - burstSum - ioSum)
			print("Process: P" + String(p.id) + "\tWaiting Time: " + String(waitingTime) + "\n")
			// add waiting time to sum of waiting time
			waitingSum += waitingTime
			// clear values for next iteration
			ioSum = 0
			burstSum = ioSum
			waitingTime = 0
		}
		print("\nAverage Waiting time: " + String(waitingSum/9) + "\n")
		print("..................................................")
		print("\nTurnaround Times: \n")
		var turnAroundSum: Int = 0
		// find the sum of turnaround times by adding together all the processes' end times
		for p in self.mlfqProcesses! {
			print("Process: P" + String(p.id) + "\tTurnaround Time: " + String(p.endTime!) + "\n")
			turnAroundSum += p.endTime!
		}
		print("\nAverage Turnaround time: " + String(turnAroundSum/9) + "\n")
		print("..................................................")
		print("\nResponse times:\n")
		var responseSum: Int = 0
		// find the sum of response times by adding together all the processes' response times
		for p in self.mlfqProcesses! {
			print("Process: P" + String(p.id) + "\tResponse Time: " + String(p.response!) + "\n")
			responseSum += p.response!
		}
		print("\nAverage Response time: " + String(responseSum/9) + "\n")
		print("..................................................\n")
	}

	
	private func load(_ fileName: String) {
		do {
			var bursts = [[String]]()
			// read contents of file
			let dataString = try String(contentsOfFile: fileName)
			// separate by new line
			let burstStrings = dataString.components(separatedBy: .newlines)
			// separate by commas
			for s in burstStrings {
				let a = s.components(separatedBy: ",")
				bursts.append(a)
			}
			// traverse 2d array of bursts & io and separate them into different arrays
			for processArray in bursts {
				var burstArray = [Int]()
				var ioTime = [Int]()
				for i in 1..<processArray.count {
					if i % 2 == 0 {
						ioTime.append(Int(processArray[i])!)
					} else {
						burstArray.append(Int(processArray[i])!)
					}
				}
				// create a process and initialize with its default values
				var process: Process = Process(done: false,
				                               firstTimeExecution: true,
				                               id: processArray[0][1],
				                               waiting: nil,
				                               burstArray: [Int](),
				                               burstIdx: 0,
				                               currentBurst: 0,
				                               currentIO: 0,
				                               ioTime: [Int](),
				                               ioIdx: 0,
				                               response: nil,
				                               priority: 1,
				                               endTime: 0,
				                               arrivalTime: 0)
				// set burst & ioTime array to equal the array created
				process.burstArray = burstArray
				process.ioTime = ioTime
				// set current burst & io
				process.currentBurst = process.burstArray[process.burstIdx]
				process.currentBurst = process.ioTime[process.ioIdx]
				// add process to array of processes
				self.mlfqProcesses?.append(process)
			}
		} catch _ {
			print("Error: File not found")
		}
		self.startProcesses()
	}
}
