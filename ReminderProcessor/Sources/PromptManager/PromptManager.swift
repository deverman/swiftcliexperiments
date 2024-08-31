import Foundation

struct Prompt {
	public let template: String
	public let name: String
	
	public init(template: String, name: String) {
		self.template = template
		self.name = name
	}
}


public actor PromptManager {
	public static let shared = PromptManager()
	
	private var prompts: [Prompt] = [
	Prompt(template: """
		Analyze the following reminder:
		"{reminder}"
		
		Provide a comprehensive analysis in the following format:
		
		1. Category: [Categorize the reminder (e.g., Work Project, Personal Task, Shopping, etc.)]
		2. Estimated Time: [Provide an estimate in hours, use decimals for partial hours]
		3. Estimated Completion Date: [If no deadline is specified, suggest a reasonable completion date based on the task and estimated time]
		4. Priority: [Assign a priority: High, Medium, or Low]
		5. Project Breakdown: [If the task seems large or complex, suggest a breakdown into smaller subtasks, max 5 subtasks]
		6. Next Steps: [Provide 1-2 immediate next steps to make progress on this remidner]
		
		Provide your analysis in a concise, easy-to-read format.
		""", name: "comprehensive"),
		
	Prompt(template: """
		Estimate the time required to complete the following task:
		"{reminder}"
		
		Provide your estimate in the following format:
		Estimated Time: [X] hours
		Reasoning: [Brief explanation for your estimate]
		
		Consider the complexity and scope of the task when making your estimate.
		""", name: "estimate"),
		
	Prompt(template: """
		Break down the following task into smaller, manageable subtasks:
		"{reminder}"
		
		Provide a list of 3-5 subtasks in the following format:
		1. [Subtask 1]
		2. [Subtask 2]
		3. [Subtask 3]
		...
		
		Ensure that the subtasks are concrete, actionable items that contribute to completing the main task.
		""", name: "breakdown"),
		
	Prompt(template: """
		Determine the priority of the following task:
		"{reminder}"
		
		Assign a priority level (High, Medium, or Low) and provide a brief explanation:
		Priority: [High/Medium/Low]
		Reasoning: [Brief explanation for the assigned priority]
		
		Consider factors such aas urgency, importance, and potential impact when determining the priority.
		""", name: "priority")
	]
	
	private init() {}
	
	public func getPrompt(name: String, reminder: String) -> String {
		guard let prompt = prompts.first(where: { $0.name == name }) else {
			return "Error: Prompt not found"
		}
		return prompt.template.replacingOccurrences(of: "{reminder}", with: reminder)
	}
	
	public func addPrompt(template: String, name: String) {
		prompts.append(Prompt(template: template, name: name))
	}
}
