import Foundation
import EventKit
import ArgumentParser
import PromptManager

@main
struct ReminderProcessor: AsyncParsableCommand {
	@Option(name: .shortAndLong, help: "Prompt to use for processing reminders")
	var promptName: String = "comprehensive"
	
	@Flag(name: .long, help: "update reminders with AI-generated information")
	var updateReminders = false
	
	@Option(name: .long, help: "Output file path for TaskPaper format")
	var outputFile: String?
		
	func run() async throws {
		let eventStore = EKEventStore()
	
		let granted = await requestAccess(for: eventStore)
		if granted {
			 await processReminders(store: eventStore)	
		} else {
			print("Access to reminders was denied.")
			Foundation.exit(1)
		}
	}
	
	func requestAccess(for store: EKEventStore) async -> Bool {
		await withCheckedContinuation { continuation in 
			store.requestAccess(to: .reminder) { granted, _ in
				continuation.resume(returning: granted)
			}
		}
	}
	
	func processReminders(store: EKEventStore) async {
		let predicate = store.predicateForIncompleteReminders(withDueDateStarting: nil,
																ending: nil,
																calendars: nil)

		let reminders = await fetchReminders(matching: predicate, in: store)
				
		guard !reminders.isEmpty else {
			print("No incomplete reminders found.")
			Foundation.exit(0)
		}
			
		var taskPaperOutput = "Reminders:\n"
			
		for reminder in reminders {
			print("Processing reminder: \(reminder.title ?? "Untitled") - Completed: \(reminder.isCompleted)")
			
			let prompt = await PromptManager.shared.getPrompt(name: self.promptName, reminder: reminder.title ?? "")
			let processedText = await self.processWithLlama(text: prompt)
			print("Processed result:\n\(processedText)\n")
			
			taskPaperOutput += self.formatTaskPaper(reminder: reminder, analysis: processedText)
			
			if self.updateReminders {
				await self.updateReminder(reminder: reminder, analysis: processedText, store: store)
			}
		}
			
		if let outputFile = self.outputFile {
			do {
				try taskPaperOutput.write(toFile: outputFile, atomically: true, encoding: .utf8)
			} catch {
				print("Error writing to file: \(error)")
			}
		} else {
			print("\nTaskPaper Output:\n\(taskPaperOutput)")
		}
		
		Foundation.exit(0)
	}

	func fetchReminders(matching predicate: NSPredicate, in store: EKEventStore) async -> [EKReminder] {
		await withCheckedContinuation { continuation in	
			store.fetchReminders(matching: predicate) { fetchedReminders in
				let copiedReminders = fetchedReminders?.map { $0.copy() as! EKReminder } ?? []
				continuation.resume(returning: copiedReminders)
			}
		}
	}	

	func processWithLlama(text: String) async -> String {
		let task = Process()
		task.executableURL = URL(fileURLWithPath: "/usr/local/bin/ollama")
		task.arguments = ["run", "llama3.1", text]
		
		let outputPipe = Pipe()
		task.standardOutput = outputPipe
		
		do {
			try task.run()
			task.waitUntilExit()
		} catch {
			print("Error running Ollama: \(error)")
			return ""
		}
		
		let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
		let output = String(data: outputData, encoding: .utf8) ?? ""
		
		return output.trimmingCharacters(in: .whitespacesAndNewlines)
	}
	
	func updateReminder(reminder: EKReminder, analysis: String, store: EKEventStore) async {
		let lines = analysis.components(separatedBy: .newlines)
		
		for line in lines {
			if line.starts(with: "Estimated Time:") {
				reminder.notes = (reminder.notes ?? "") + "\n" + line
			} else if line.starts(with: "Estimated Completion Date:") {
				if reminder.dueDateComponents == nil {
					let dateString = line.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
					let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd"
					if let date = dateFormatter.date(from: dateString) {
						reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
					}
				}
			} else if line.starts(with: "Priority:") {
			reminder.priority = self.priorityFromString(line.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
			}
		}
	
		do {
			try store.save(reminder, commit: true)
			print("Reminder updated successfully.")
		} catch {
			print("Failed to update reminder: \(error)")
		}
	}
	
	func priorityFromString(_ priority: String) -> Int {
		switch priority.lowercased() {
		case "high":
			return 1
		case "medium":
			return 5
		case "low":
			return 9
		default:
			return 5
		}
	}
	
	func formatTaskPaper(reminder: EKReminder, analysis: String) -> String {
		var output = "- \(reminder.title ?? "Untitled")\n"
		
		let lines = analysis.components(separatedBy: .newlines)
		for line in lines {
			if line.contains(":") {
				let components = line.components(separatedBy: ":")
				if components.count >= 2 {
					let key = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
					let value = components[1...].joined(separator: ":").trimmingCharacters(in: .whitespacesAndNewlines)
					output += "    @\(key.lowercased().replacingOccurrences(of: " ", with: "_")) \(value)\n"
				}
			}
		}
		
		if let dueDate = reminder.dueDateComponents {
			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "yyyy-MM-dd"
			if let date = Calendar.current.date(from: dueDate) {
				output += "    @due \(dateFormatter.string(from: date))\n"
			}
		}
		
		output += "\n"
		return output
	}
}