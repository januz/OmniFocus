use AppleScript version "2.4"
use scripting additions
use O : script "omnifocus"
use framework "Foundation"


-- classes, constants, and enums used
property NSCaseInsensitiveSearch : a reference to 1
property NSRegularExpressionSearch : a reference to 1024
property NSCharacterSet : a reference to current application's NSCharacterSet
property NSString : a reference to current application's NSString

tell application "OmniFocus"
	set sel to selectedItems() of O
	repeat with _sel in sel
		repeat with paragraphCount from 1 to (count (paragraphs of note of _sel))
			set _paragraph to ((NSString's stringWithString:(paragraph paragraphCount of note of _sel))'s stringByTrimmingCharactersInSet:(NSCharacterSet's whitespaceAndNewlineCharacterSet())) as text
			if _paragraph starts with "Script:" then
				set shellScript to text 9 thru -1 of _paragraph
				set saveTID to AppleScript's text item delimiters
				set AppleScript's text item delimiters to {" "}
				set shellProgram to text item 1 of shellScript
				set shellArguments to (text items 2 thru -1 of shellScript as text)
				set finalShellArguments to (NSString's stringWithString:shellArguments)
				set shell to (finalShellArguments's stringByReplacingOccurrencesOfString:"~" withString:(POSIX path of (path to home folder)) options:NSCaseInsensitiveSearch range:{0, finalShellArguments's |length|()}) as text
				set AppleScript's text item delimiters to saveTID
				do shell script shellProgram & " " & quoted form of shell
			else if _paragraph starts with "Command:" then
				do shell script text 10 through -1 of _paragraph
			else if _paragraph starts with "Email:" then
				set the_content to text 8 thru -1 of _paragraph
				if the_content starts with "message://" then
					do shell script "open " & quoted form of the_content
				else
					do shell script "open mailto:" & quoted form of the_content
				end if
			else if _paragraph starts with "Tel:" then
				do shell script "open tel://" & quoted form of (text 5 thru -1 of _paragraph) & "?audio=yes"
			else if _paragraph contains "://" then
				do shell script "open " & quoted form of _paragraph
			else if _paragraph starts with "App:" then
				set target to "-a " & quoted form of (text 6 thru -1 of _paragraph)
				do shell script "open " & target
			else if _paragraph starts with "Notify:" then
				set target to (get text 8 through -1 of _paragraph)
				display notification target
			else if _paragraph starts with "Alert:" then
				set target to (get text 7 through -1 of _paragraph)
				display alert target
			else if length of (get file name of first file attachment of file attachments of note of first item of _sel) is not 0 then
				repeat with _attachment in file attachments of note of _sel
					set target to POSIX path of (get file name of _attachment)
					do shell script "open " & quoted form of target
				end repeat
			else if value of attribute named "link" of style of paragraph paragraphCount of note of _sel is not "" then
				set target to value of attribute named "link" of style of paragraph paragraphCount of note of _sel
				do shell script "open " & quoted form of target
			else
				display notification "Nothing to open."
			end if
		end repeat
	end repeat
	tell O to setComplete(sel, true)
end tell