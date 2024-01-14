# Copyright (c) 2020 Roman Smolka
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

try
    tell application "Finder"
        activate
        set targetFolder to the target of the front window as alias
        set newFileName to my getAvailableFilename(targetFolder)
        set newFile to make new file at targetFolder with properties {name: newFileName}
        select newFile
    end tell
    
    delay 0.4
    
    tell application "System Events"
        tell process "Finder"
            keystroke return
        end tell
    end tell
    
on error theError number errorNumber
    tell me to activate
    if errorNumber is 1002 then
        displayAccessibilityPromptDialog()
    else
        display dialog "Error: " & (errorNumber as text) & return & return & theError Â
            buttons {"OK"} Â
            default button 1 Â
            with icon stop Â
            with title "New File Applet"
    end if
end try

on getAvailableFilename(folderAlias)
    set found to false
    set fileCount to 1
    set appendix to ""

    repeat while found is false
        tell application "Finder"
            if exists file (folderAlias as text & "untitled file" & appendix) then
                set fileCount to (fileCount + 1)
                set appendix to (" " & fileCount as string)
            else
                return "untitled file" & appendix
            end if
        end tell
    end repeat

end getAvailableFilename

on displayAccessibilityPromptDialog()
    set systemVersion to system version of (system info)

    considering numeric strings
        set hasNewSettingsApp to systemVersion ³ "11"
    end considering

    if hasNewSettingsApp
        set accessibilitySettingPath to "System Settings ? Privacy & Security ? Accessibility"
    else
        set accessibilitySettingPath to "System Preferences ? Security & Privacy ? Privacy ? Accessibility"
    end if

    set theResponse to display dialog "Please allow the New File app in:" & return & return & accessibilitySettingPath Â
        buttons {"Open Privacy Settings", "OK"} Â
        default button 1 Â
        with icon caution Â
        with title "New File Applet"

    if (button returned of theResponse is "Open Privacy Settings") then
        if hasNewSettingsApp then
            set securityPaneId to "com.apple.settings.PrivacySecurity.extension"
            tell application "System Settings"
                activate
                delay 0.5
                set the current pane to pane id securityPaneId
                get the name of every anchor of pane id securityPaneId
                delay 0.5
                reveal anchor "Privacy_Accessibility" of pane id securityPaneId
            end tell
        else
            set securityPaneId to "com.apple.preference.security"
            tell application "System Preferences"
                activate
                delay 0.5
                set the current pane to pane id securityPaneId
                get the name of every anchor of pane id securityPaneId
                delay 0.5
                reveal anchor "Privacy_Accessibility" of pane id securityPaneId
            end tell
        end if
    end if

end displayAccessibilityPromptDialog
