# Introduction
excellent-watir (herein called 'xlwatir') was a prototype ruby/watir testing framework, with test steps defined in Excel spreadsheets.

xlwatir was designed to speed up automated testing of Web applications. It allows testers to rapidly build test scripts and test suites in a structured way. xlwatir provides all the power of the popular “watir” tool but without the overhead of learning the Ruby language. xlwatir may be used by testers of all skill levels. Test scripts may range from a simple single file, to a suite of complex tests with custom functionality. 

## Prerequisites
Ruby, watir, Excel

# Using xlwatir
## Making a xlwatir Script
The easiest way is to build upon ‘template.xls’ included in this repo. However xlwatir allows other file types such as .csv or .xlsx, using Excel to read in the data. The following steps describe a script built on template.xls. 

## IE Developer Tools
Open IE and press [F12] to show the developer toolbar. The tool “Select Element by Click” helps to identify page elements for your test script to use. Activate “Select Element by Click” then click an element on the web page to reveal its attributes.
 
## Entering a xlwatir Command
* Open template.xls
* Leave row 1 as is -- the ‘import’ command is needed to define the valid Watir commands.
* On the next row, click on the leftmost cell (the “Command cell”), and choose a command from the dropdown list. A good one to start with is ‘goto_url’.
 
Most commands also require a parameter. After making a selection, the worksheet will automatically populate the row with the parameters expected. The “goto_url” command requires a URL. For this example, enter “google.co.nz”. 
 
## Identify page elements
Using the IE Developer Toolbar, examine the attributes of the Google input field. Note that attribute “name” has a value of “q”.  
* To find commands to input text into the field, scroll through the dropdown list in the next Command cell. The appropriate xlwatir command is “input_text_by_name”. 
* Command “input_text_by_name” requires two parameters, as detailed in the adjacent cells (Fig. 5). For this example, replace “name parameter” with the value “q”, and replace “text parameter” with some search text, for example “apteryx australis”

## Add Further Commands and Test Cases
Some other commands available are
* click_button_by_name
* click_link_by_url
* comment
* go_back
* select_list_item_by_name
* set_checkbox_by_name
* set_radio_by_name
* start_new_script
* submit_form
* verify_text_on_page
 
(See the “Command Reference” section for a full list of commands and descriptions.)

This is an example of a completed script:

| command	| param_1	| param_2 | 
| ------ | ------ | ------ | 
| import	| BaseCommandsWatir.rb	| BaseCommandsWatir | 
| pause_message	| This is a sample message to pause the script. Hit OK to continue.|	| 
| comment	| "xlwatir" Scripting Template + Example |	| 
| goto_url	| google.co.nz |	|
| input_text_by_name	| q	| apteryx australis |
| click_button_by_name	| btnG |	|
| verify_text_on_page	| South Island Kiwi |	|
| verify_text_on_page	| Apteryx Australis |	|
| comment | Finished googly example. |	|
 

## Running / Testing the Script
Save the Excel script you have created, with a name such as “example.xls”. xlwatir expects to find your script in the same location as the ruby files.

### Run from Command Line
Open a Command shell (Start > Run > cmd), go to the directory where your script resides and enter the command :

    ruby Main.rb example.xls

(replace <example.xls> with your script name)
The script takes a few seconds to start up because it loads new instances of Ruby, Excel, and IE

### Observe Output / Log File
* Wait for the script to finish navigating the IE session
* A log file is also created in the same directory, with a filename: log.<timestamp>.txt
* Check the results are as expected, and adjust your xlwatir script accordingly.

 
# Building a Test Suite
## Structure
A test suite comprises one parent script which starts one or more child scripts. The following two tables show two simple scripts. 

Parent script “demo.xls” uses command “start_new_script” to call “demo_W3_search.xls” and pass parameters to it. 

## Passing Parameters
The first time it is called, child script “demo_W3_search.xls” replaces %1% with the first parameter “w3.org” and replaces %2% with “bubblegum”. This makes IE navigate to w3.org and search for the phrase “bubblegum”.
The second time it is called, “demo_W3_search.xls” replaces %1% with “w3.org” and replaces %2% with “extensible markup language”. This makes IE navigate to w3.org and search for the phrase “extensible markup language”.

### demo.xls

    import	baseCommandsWatir.rb	BaseCommandsWatir	
    comment	Demo of "xlwatir"		
    start_new_script	demo_W3_search.xls	w3.org	bubblegum
    start_new_script	demo_W3_search.xls	w3.org	extensible markup language
    #ignore_this	example: it can handle incorrect command		
    pause_message	Script Complete! Hit OK to exit.		

### demo_W3_search.xls

    goto_url	%1%	
    verify_text_on_page	World Wide Web Consortium (W3C)	
    click_link_by_text	New Visitors	
    go_back		
    input_text_by_id	inputField	%2%
    click_button_by_id	goButton	
    verify_text_on_page	from www.w3.org	
    comment	finished search	

# Architecture of xlwatir 
 
The classes are defined in Ruby source files:
* Main.rb contains classes TestRunner and ScriptRunner. Main.rb is the main xlwatir executable file.
* BaseCommands.rb contains classes BaseCommands and LogResults.
* BaseCommandsWatir.rb contains extensions for the BaseCommands class.

## Ruby Main
From the windows command line or an IDE, a command is passed to Ruby, such as the following:

    ruby Main.rb example.xls

Ruby then runs Main.rb, passing “example.xls” as a string argument.
Main.rb initializes a new TestRunner, then calls its run_suite() method.

## TestRunner
TestRunner sets up new instances of Internet Explorer, LogResults, and BaseCommands. The new instances are assigned global variables $ie, $log, $commands.

A test run begins with the run_suite() method, which parses the command line (such as above) and calls BaseCommands.start_new_script(), passing through the script name (such as “demo.xls”).

## LogResults
Each TestRunner creates a LogResults object. LogResults initializes by creating a new File object called “@log”, with a file name of log.<timestamp>.txt in the current directory. Also counters for @error, @fail, @pass are set to 0. 
* add() logs text {timestamp + logmsg}, and echoes it to stdout
* error() increments @error, logs text {timestamp + “ERROR” + logmsg}, and echoes it to stderr
* fail() increments @fail, logs {timestamp + “FAIL” + expected + actual result}, and echoes it to stdout
* pass() increments @pass, logs text {timestamp + “PASS”}, and echoes it to stdout
* debug() logs text {timestamp + “DEBUG” + logmsg}, and echoes it to stdout
* close() prints final results for the test run {@pass, @fail, @error} and closes the File object

These methods are globally available. ScriptRunner logs its main actions, some “verify” methods in BaseCommands log their results, and the log optionally includes debug information.

## ScriptRunner
Each ScriptRunner instance corresponds to a particular xlwatir script file. ScriptRunner sets up a new instance of Excel and loads the specified workbook. The runScript() method iterates down the spreadsheet, parsing each row and calling the requisite xlwatir command and its parameters. 

Some intelligent logic is applied so runScript() will also:
* Replace internal script variables such as %1%, %2% with values from an array called “args” (args is optionally passed in with the runScript() call)
* Extend BaseCommands by mixing in further Ruby or Watir code from another source file, such as BaseCommandsWatir or a domain-specific collection of commands 


## BaseCommands
BaseCommands is the collection of xlwatir commands (methods). There are four basic methods
* start_new_script() starts a new instance of ScriptRunner with the script file name. This method enables the tester to build a suite of scripts initiated from one main script.
* message_box() is a method to pop up a Windows message box, with various formatting options
* pause_message() is a simplified wrapper for the message_box() method
* comment() adds a simple entry to the log file 

This list of valid commands is extended at runtime when ScriptRunner imports the file “BaseCommandsWatir.rb”. This file is the gateway to WATiR functionality. It includes many methods for interacting with the $ie object, such as
* goto_url()
* go_back()
* submit_form()
* bypass_cert()
* :click_button_by_id()
* verify_text_on_page()
* verify_page_title()
* verify_text_by_xpath()
(and many more … for full descriptions see the “Command Reference” section in the Appendix)

 
# Appendix: xlwatir Command Reference

    Command	Parameter 1	Parameter 2	Parameter 3	Parameter 4	Description
    bypass_cert					Dismiss annoying IE warning
    clear_text_by_name	name parameter				Clear text from input field
    clear_radio_by_name	name parameter				Clear selected radio button
    clear_checkbox_by_name	name parameter				Clear selected checkbox
    clear_list_by_name	name parameter				Clear dropdown list selection
    click_button_by_id	id parameter				Click button
    click_button_by_name	name parameter				Click button
    click_element_by_xpath	xpath parameter				Click ANY element
    click_label_text	text parameter				Click label
    click_link_by_text	text parameter				Click link
    click_link_by_url	URL parameter				Click link
    comment	your comments go here… parameter				Log a Comment
    find_text_by_xpath	xpath parameter				Locate item within the page structure
    goto_url	URL parameter				Navigate to a new website
    go_back					Browser back() function
    input_text_by_id	id parameter	text parameter			Enter text to input field
    input_text_by_name	name parameter	text parameter			Enter text to input field
    message_box	message text parameter	title parameter	buttons parameter	icon parameter	Show a customised Windows message box
    pause_message	message text parameter				Show a simple Windows message box
    select_list_item_by_id	list_id parameter	item_text parameter			Select item from dropdown list
    select_list_item_by_name	list_name parameter	item_text parameter			Select item from dropdown list
    set_checkbox_by_index	index parameter				Set a checkbox
    set_checkbox_by_name	name parameter				Set a checkbox
    set_radio_by_id	id parameter				Set a radio button
    set_radio_by_index	index parameter				Set a radio button
    set_radio_by_name	name parameter				Set a radio button
    start_new_script	filename parameter	parameter1 parameter	parameter2 parameter		Branch to a new xlwatir script
    submit_form					Test default form action
    verify_page_title	title parameter				Test Title attribute
    verify_table_entry_by_id	table_id parameter	rownum parameter	colnum parameter	expected parameter	Test data in HTML table
    erify_text_by_xpath	xpath parameter	text parameter	 parameter		Test text by specific location in DOM
    verify_text_on_page	text parameter				Test that text is somewhere on the page

