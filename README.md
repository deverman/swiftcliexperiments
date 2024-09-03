# Swift CLI Experiments
Scratchpad to play around with Swift command line tools before breaking them out.

Most of these are based on the [Swift command line tutorial](https://www.swift.org/getting-started/cli-swiftpm/).

## count

Counts the total number of instances in each file. Takes an input file and outputs a file sorted by most occurrences of a word to least occurrences.

## markdownchecklist

Takes markdown as input on the command line and outputs the debug info of the markdown library

## MyCLI

Takes a phrase as input and draws the text in the terminal using ascii art. This is the demo from the tutorial above.

## ReminderProcessor

Proof of concept to see if it was possible to query the Reminders database from the command line and then run an AI prompt on the item using ollama with the Facebook training model. It tries to estimate and prioritize the reminders and then output them as taskpaper. Think the taskpaper part is not quite right yet. (This was co developed with Claude.ai)

You should be able run them by just running them with the following command line. Refer to the tutorial above if you are a complete newbie like me.

```swift run <PackageName>
