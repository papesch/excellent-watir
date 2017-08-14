#---------------------------------------------------------
# excellent-watir -- An EXPERIMENTAL Watir Automation Framework 
#---------------------------------------------------------
#if __FILE__ == $0
  # TODO Generated stub
#end

class BaseCommands
  #Collection of common commands 
  #Extended at runtime with domain-specific commands from other files

  def start_new_script(params)
    #TODO check file exists
    #if not found, look in current working directory
    #TODO if still not found, exit
    if params.class.name == "Array"
      path2file = Dir.pwd + "/" + params[0].to_s  #get first param value
    else  
      path2file = Dir.pwd + "/" + params.to_s  #use all of it as the field name...
    end

    #Run the Script
    #branch to a new ScriptRunner instance
    
    if params.class.name == "Array"
      scriptRunner = ScriptRunner.new(path2file, params)
      #reformat array for nicer log output
      p_delimited = ""
      params.each do |p|
        p_delimited = p_delimited + p + "; " 
      end
      $log.debug("passing parameters via array [#{p_delimited}]")
    else  
      scriptRunner = ScriptRunner.new(path2file,[params.to_s])
      $log.debug("passing parameters from string #{params.to_s}")
    end
    scriptRunner.runScript
    #(note, session is tidied up by scriptRunner so my work is done)
  end
  
  def comment(params)
    $log.add(" ------------ ") #the comment is already logged by ScriptRunner, this text is just a separator for emphasis
  end
  
  def pause_message(params)
    #Calls method in BaseCommands
    message_box([params[0].to_s, "excellent-watir Paused", 0, 48])
  end
  
  def message_box(params)
    txt=params[0]
    title=params[1]
    buttons=params[2]
    icon=params[3]
    user32 = DL.dlopen('user32')
    msgbox = user32['MessageBoxA', 'ILSSI']
    r = msgbox.call(0, txt, title, buttons+icon)
    return r
    #### button/icon constants
    #~ BUTTONS_OK = 0                 #~ BUTTONS_OKCANCEL = 1       #~ BUTTONS_ABORTRETRYIGNORE = 2   #~ BUTTONS_YESNO = 4
    #~ ICON_HAND = 16                 #~ ICON_QUESTION = 32         #~ ICON_EXCLAMATION = 48          #~ ICON_ASTERISK = 64
    #### return code constants
    #~ CLICKED_OK = 1                 #~ CLICKED_CANCEL = 2         #~ CLICKED_ABORT = 3              #~ CLICKED_RETRY = 4
    #~ CLICKED_IGNORE = 5             #~ CLICKED_YES = 6            #~ CLICKED_NO = 7
  end
  
  #def get_input(prompt='', title='')
    # This little thing pops up an input box to get around the CAPTCHA 
    # Requires MS Excel to be installed as it calls an Excel object
  #  excel = WIN32OLE.new('Excel.Application')
  #  response = excel.InputBox(prompt, title)
  #  excel.Quit
  #  excel = nil
  #  return response
  #end
  
  #debug code...
  def this_method
     caller[0] =~ /`([^']*)'/ and $1
  end
end

class LogResults 
  def initialize
    logtime = Time.now.strftime "%Y%m%d.%H%M%S"
    logfile = "log." + logtime + ".txt"   #filename
    fullpath = Dir.pwd + "/" + logfile    #just put it in current directory for now.
    #log = REXML.Document.new File.new(logpath)  #log file is a new XML object
    @log = File.new fullpath,"a" 
    #start counters
    @error = 0
    @fail = 0
    @pass = 0
  end
  def add(logmsg)
    #write Log logmsg to logfile + console
    logEntry = "#{Time.now.strftime '%Y%m%d.%H%M%S'} #{logmsg}\n"
    @log.write(logEntry)
    puts logEntry
  end
  def error(logmsg)
    #write Error logmsg to logfile + console
    @error+=1
    logEntry = "#{Time.now.strftime '%Y%m%d.%H%M%S'} ERROR: #{logmsg}"
    @log.write(logEntry)
    $stderr.puts logEntry
  end
  def fail(logmsg,expect="",actual="")
    @fail+=1
    if expect.to_s.length>0 or actual.to_s.length >0
      logEntry = "FAILURE: #{logmsg}, expected: #{expect} found: #{actual}"
    else
      logEntry = "FAILURE: #{logmsg}"  
    end
    self.add(logEntry)
  end
  def pass(logmsg)
    @pass+=1
    logEntry = "PASS: #{logmsg}"
    self.add(logEntry)
  end
  def debug(logmsg)
    if $debug 
      self.add("DEBUG: #{logmsg}")
    end
  end

  def close
    logEntry = "RESULTS: == Pass: #{@pass}  Fail: #{@fail}  Error: #{@error} ==\n"
    self.add(logEntry)
    @log.close
  end
end
