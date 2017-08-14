#---------------------------------------------------------
# excellent-watir -- An EXPERIMENTAL Watir Automation Framework 
#---------------------------------------------------------
#
require 'BaseCommands'
require 'win32ole'  # for parsing Excel
require 'dl'        # for message_box in BaseCommands   
require 'watir'


class TestRunner

  def initialize
    $commands = BaseCommands.new    #TODO Try to avoid using global object   
    $ie = Watir::IE.new
    #$ie.set_fast_speed              #comment this out to slow things down
    $log = LogResults.new
    $debug = false                  #debug switch
  end

  def run_suite
    begin
      $log.add "Started test run"
      arg0 = ARGV[0].to_s.downcase   #read parameter in from cmdline
      #if arg0="" then turn debug switch ON and default to "testSuite.xls" (when run from IDE)
      #if arg0=DEBUG then turn debug switch ON and read in specified file (to debug via cmdline)
      case arg0
        when ""         
          # when running from IDE nothing is passed so use defaults
          # default debug mode and run dev script
          $debug = true ; arg0 = "example_template.xls"  
        when "debug"    
          # next parameter should be the spreadsheet (if not, catch it later)
          $debug = true ; arg0 = ARGV[1].to_s
        else
          # just assume arg0 is the spreadsheet ...
      end
    
      $commands.start_new_script(arg0) 
    rescue
      $log.error("Unable to process #{arg0}. Expected an excellent-watir script file.")
      $log.error("Please check the filename and path, or the syntax of the startup command.")
      $log.error("Syntax Example: 'ruby main.rb [DEBUG] demo.xls'")
    end

    $ie.close if defined? $ie and not $debug #~ This closes IE automatically. TODO add as switch option for scripter
    $log.add "Finished test run"
    $log.close
  end
end


class ScriptRunner 
  
  def initialize(fileName,args=[])
    #create an Excel object 
    @xlApp = WIN32OLE.new('Excel.Application')
    #@xlApp.Application.Visible = true         #TODO add Excel.visible as a switch option for scripter
    @args = args
    #get Excel to load the CSV for runScript to access
    begin
      $log.add("Open Excel Workbook #{fileName}")
      @xlApp.Workbooks.Open(fileName)
      $log.add("Workbook opened successfully!")
    rescue=>e 
      #catch problem opening file
      $log.error("#{e.message} #{e.backtrace}") 
      self.teardown
    end
  end
  
  def teardown
    #tidy up
    $log.add("Closing Excel Workbook #{@xlApp.ActiveWorkbook.name}")
    begin
      @xlApp.ActiveWorkbook.Close(false)
    rescue =>e
      $log.error("Error closing sheet #{e.message} #{e.backtrace}") 
    end
    @xlApp.Quit
    @xlApp = nil
  end

  def runScript
    #Parse "Command" spreadsheet and call relevant methods

    #get cell A1
    xl_command_cell = @xlApp.activeSheet.range("A1")

    #process each row until we reach an empty row
    while xl_command_cell.Value.to_s.length > 0 

      currentCommand = xl_command_cell.Value      #take the left most 'cell' as the command

      #--build parameter array--#
      parameters = []      
      xl_parameter_cell = xl_command_cell.Offset(0,1)         #go across to parameter cell

      while xl_parameter_cell.Value.to_s.length > 0           #loop across nonempty cells
        currentParameter = xl_parameter_cell.Value.to_s

      #TODO -- Turn this into "replace_script_var" method!
      #TODO
        #swap any %1%, %2% type variables with their assigned values
        #scriptReplaceText = currentParameter.scan(/%[0-9]+%/)
        begin
          for i in (0..(@args.length-1))
              currentParameter = currentParameter.gsub(("%"+i.to_s+"%"),@args[i])        
          end
        rescue =>e
          $log.error("Parameter substitution error - #{e.message} #{e.backtrace}") 
        end
      
        parameters.push(currentParameter)         #push cell data into parameter array
        xl_parameter_cell = xl_parameter_cell.Offset(0,1)     #go across to next parameter cell
      end 
      #--finished building parameter array---#
      
      
      #--Run the current Command--#
      #reformat param array for nicer log output
      p_delimited = ""
      parameters.each do |p|
        p_delimited = p_delimited + p + "; " 
      end
      $log.add "#{currentCommand} [#{p_delimited}]"
      
      #TODO -- Turn this into "import_commands" method!
      #TODO
      if currentCommand.downcase == 'import'
        #Read in defs, add to $commands object 
        begin
          data = ''
          f = File.open(parameters[0], "r") 
          f.each_line do |line|
            data += line
          end
          $commands.instance_eval data
        rescue =>e
          $log.error("Error importing commands #{e.message} #{e.backtrace}") 
        end


      elsif $commands.respond_to? currentCommand
        #Do standard commands 
        begin
          $commands.send(currentCommand, parameters)
        rescue=>e 
          $log.error "Error while processing command #{currentCommand} \nError: #{e.message} \nBacktrace: #{e.backtrace}"
        end

      else
        #flag error but continue anyway
        $log.error "Command #{currentCommand} is not supported."
      end
      #--finished Command execution--#
        
       #go down to next command row 
      xl_command_cell = xl_command_cell.Offset(1,0)
    end
   
    $log.add("Reached end of script (#{@xlApp.ActiveWorkbook.name})")
    self.teardown()
  end
end

#if __FILE__ == $0
testrunner = TestRunner.new
testrunner.run_suite
#end

