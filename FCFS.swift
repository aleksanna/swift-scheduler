//
//  FCFS.swift
//  OSScheduler

import Foundation

// class for the FCFS algorithm
final class FCFS {
	// private variables for this class
	private var fcfsQueue: Queue<Process>?
	private var fcfsProcesses: [Process]?
	private var currentTime: Int
	private var idleTime: Int
	
	// default constructor
	private init() {
		self.fcfsProcesses = [Process]()
		self.fcfsQueue = Queue<Process>()
		self.currentTime = 0
		self.idleTime = 0
	}
	
	// explicit value constructor
	public convenience init(_ filename: String) {
		self.init()
		self.load(filename)
	}
	
	private func startProcesses() {
		// add all processes to fcfs queue
		for p in self.fcfsProcesses! {
			self.fcfsQueue?.enqueue(p)
		}
		// clear fcfs array so it can be used for calculateTimes
		self.fcfsProcesses = [Process]()

		// call executeProcesses until there are no items left in our queue
		while !self.fcfsQueue!.isEmpty {
			self.executeProcesses()
		}
		// call function to determine response time, turnarount time, et cetera
		self.calculateTimes()
	}
	
	private func executeProcesses () {
		print("Current time: " + String(self.currentTime) + "\n")
		// dequeue first process in queue
		var executingProcess = (self.fcfsQueue?.dequeue())!
		// check for idle time
		if executingProcess.arrivalTime > self.currentTime {
			self.idleTime += executingProcess.arrivalTime - self.currentTime
			self.currentTime += executingProcess.arrivalTime - self.currentTime
		}
		// set currentBurst
		executingProcess.currentBurst = executingProcess.burstArray[executingProcess.burstIdx]
		// set response time
		if executingProcess.firstTimeExecution {
			executingProcess.response = self.currentTime
		}
		// set i/o time & current i/o if there is more i/o time available
		if executingProcess.ioIdx < executingProcess.ioTime.count {
			executingProcess.currentIO = executingProcess.ioTime[executingProcess.ioIdx]
			executingProcess.ioIdx = executingProcess.ioIdx + 1
		}
		print("Now running: " + "P" + String(executingProcess.id))
		print("..................................................")
		print("Ready Queue:\tProcess\tBurst")
		for p in self.fcfsQueue!.processes {
			if p.arrivalTime <= self.currentTime {
				if p.firstTimeExecution {
					print("\t\t\tP" + String(p.id) + "\t\t" + String(p.currentBurst))
				} else {
					print("\t\t\tP" + String(p.id) + "\t\t" + String(p.burstArray[p.burstIdx]))
				}
			}
		}
		print("Now in I/O:\tProcess\tRemaining I/O time")
		for p in self.fcfsQueue!.processes {
			if p.arrivalTime > self.currentTime {
				print("\t\t\tP" + String(p.id) + "\t\t" + String(p.arrivalTime - self.currentTime))
			}
		}
		// update firstTimeExecution
		executingProcess.firstTimeExecution = false
		// increment burst index and guard to make sure we are not accessing an index out of range
		executingProcess.burstIdx = executingProcess.burstIdx + 1
		guard executingProcess.burstIdx < executingProcess.burstArray.count else {
			executingProcess.done = true
			print("\n\n-------P" + String(executingProcess.id) + " has finished executing-------\n")
			// add to current time the process' last burst
			self.currentTime += executingProcess.currentBurst
			// set end time
			executingProcess.endTime = self.currentTime
			// add process to array of processes (not the queue - used for calculateTimes)
			fcfsProcesses!.append(executingProcess)
			return
		}
		// update current time
		self.currentTime += executingProcess.currentBurst
		// update arrival time with i/o time
		executingProcess.arrivalTime = self.currentTime + executingProcess.currentIO
		// enqueue process again
		self.fcfsQueue?.enqueue(executingProcess)
		// sort fcfs queue to reflect new addition (sorts based on arrival time and id)
		self.fcfsQueue?.setProcess(p: (self.fcfsQueue?.processes.sorted(by: {
			if (($0 as Process).arrivalTime == ($1 as Process).arrivalTime) {
				return ($0 as Process).id < ($1 as Process).id
			} else {
				return ($0 as Process).arrivalTime < ($1 as Process).arrivalTime
			}
		}))!)
		print("\n::::::::::::::::::::::::::::::::::::::::::::::::::\n\n")
	}

	// function used to find the turnaround, waiting, & response time, etc
	private func calculateTimes () {
		// sort array of processes by id
		self.fcfsProcesses?.sort { ($0 as Process).id < ($1 as Process).id }
		print("FCFS Simulation Results:\n")
		print("Total Time: " + String(self.currentTime) + "\n")
		print("..................................................\n")
		// find cpu utilization by subtracting idle time from total time and dividing by total time
		print("CPU Utilization: " + String(((Float(self.currentTime) - Float(self.idleTime))/Float(self.currentTime)) * 100.0) + "%\n")
		print("..................................................")
		print("\nWaiting times: \n")
		var burstSum: Int = 0
		var ioSum: Int = 0
		var waitingTime: Int = 0
		var waitingSum: Int = 0
		// adding up all of the bursts and io times
		for p in self.fcfsProcesses! {
			for burst in p.burstArray {
				burstSum += burst
			}

			for io in p.ioTime {
				ioSum += io
			}
			// find waiting time
			waitingTime = (p.endTime! - burstSum - ioSum)
			print("Process: P" + String(p.id) + "\tWaiting Time: " + String(waitingTime) + "\n")
			// add to sum of waiting time
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
		// find turn around sum by adding together all the processes' end times
		for p in self.fcfsProcesses! {
			print("Process: P" + String(p.id) + "\tTurnaround Time: " + String(p.endTime!) + "\n")
			turnAroundSum += p.endTime!
		}
		print("\nAverage Turnaround time: " + String(turnAroundSum/9) + "\n")
		print("..................................................")
		print("\nResponse times:\n")
		var responseSum: Int = 0
		// find response sum by adding together all the processes' response time
		for p in self.fcfsProcesses! {
			print("Process: P" + String(p.id) + "\tResponse Time: " + String(p.response!) + "\n")
			responseSum += p.response!
		}
		print("\nAverage Response time: " + String(responseSum/9) + "\n")
		print("..................................................\n")
	}
	
	// loads in all data from file into an array of processes
	private func load(_ fileName: String) {
		do {
			var bursts = [[String]]()
			// read contents of the file
			let dataString = try String(contentsOfFile: fileName)
			// separate each by new line
			let burstStrings = dataString.components(separatedBy: .newlines)
			// separate strings by commas
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
										   priority: nil,
										    endTime: 0,
										arrivalTime: 0)
				// set burst & ioTime array to equal the array created						
				process.burstArray = burstArray
				process.ioTime = ioTime
				// set current burst & io
				process.currentBurst = process.burstArray[process.burstIdx]
				process.currentIO = process.ioTime[process.ioIdx]
				// add process to array of processes
				self.fcfsProcesses?.append(process)
			}
		} catch _ {
			print("Error: File not found")
		}
		self.startProcesses()
	}
}
