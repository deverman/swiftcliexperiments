import Markdown
import ArgumentParser

@main
struct FigletTool: ParsableCommand {
    @Option(help: "specify the input")
    public var input: String

    public func run() throws {
        let document = Document(parsing: self.input)
        print(document.debugDescription())
    }
    
}

// swift run MyCLI --input 'Hello, world!'
