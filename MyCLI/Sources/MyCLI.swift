import Figlet
import ArgumentParser

@main
struct FigletTool: ParsableCommand {
    @Option(help: "specify the input")
    public var input: String

    public func run() throws {
        Figlet.say(self.input)
    }
    
}

// swift run MyCLI --input 'Hello, world!'
