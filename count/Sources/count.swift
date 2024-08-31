import Markdown
import ArgumentParser
import Foundation


@main
struct Count: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Word counter.")
    
    @Option(name: [.short, .customLong("input")], help: "A file to read.")
    var inputFile: String

    @Option(name: [.short, .customLong("output")], help: "A file to save word counts to.")
    var outputFile: String

    @Flag(name: .shortAndLong, help: "Print status updates while counting.")
    var verbose = false

    mutating func run() throws {
        if verbose {
            print("""
                Counting words in '\(inputFile)' \
                and writing the result into '\(outputFile)'.
                """)
        }
 
        guard let input = try? String(contentsOfFile: inputFile) else {
            throw RuntimeError("Couldn't read from '\(inputFile)'!")
        }
        
        let words = input.components(separatedBy: .whitespacesAndNewlines)
            .map { word in
                word.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
                    .lowercased()
            }
            .compactMap { word in word.isEmpty ? nil : word }
        
        let counts = Dictionary(grouping: words, by: { $0 })
            .mapValues { $0.count }
            .sorted(by: { $0.value > $1.value })
        
        if verbose {
            print("Found \(counts.count) words.")
        }
        
        let output = counts.map { word, count in "\(word): \(count)" }
            .joined(separator: "\n")
        
        guard let _ = try? output.write(toFile: outputFile, atomically: true, encoding: .utf8) else {
            throw RuntimeError("Couldn't write to '\(outputFile)'!")
        }
    }
}

struct RuntimeError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}


// swift run MyCLI --input 'Hello, world!'
