#Collection of commands 
#Separated out to a new file 'BaseCommandsWatir.rb' 
#   Ref: http://wiki.seleniumhq.org/display/WTR/Cheat+Sheet
#   Ref: http://www.w3schools.com/html/html_forms.asp
#   ref: http://pettichord.com/watirtutorial/docs/watir_cheat_sheet/WTR/Methods%20supported%20by%20Element.html

  # --- Browser/Form functions ---
  def goto_url(params)
    $ie.goto(params[0])
  end

  def go_back(params)
    $ie.back()
  end

  def submit_form(params)
    #test default form action
    $ie.form(:action, "submit")
  end
  
  def bypass_cert(params)
    # Dismiss annoying IE warning
    if $ie.text.include?("There is a problem with this website's security certificate.")  
      $log.add("bypassing TA certificate error")
      $ie.link(:name, "overridelink").click      
    end
  end
  
  # --- Normal Buttons ---
  def click_button_by_id(params)
    $ie.button(:id, params[0]).click
  end

  def click_button_by_name(params)
    $ie.button(:name, params[0]).click
  end

  # --- Text & Labels ---
  def click_label_text(params)
    $ie.label(:text, params[0]).click
  end

  def verify_text_on_page(params)
    if ($ie.pageContainsText(params[0]))
      $log.pass("Page contains text: #{params[0]}")
    else
      $log.fail("Page does not contain text: #{params[0]}")
    end
  end
  
  def verify_page_title(params)
    if ($ie.title = params[0])
      $log.pass("Found expected page title: #{params[0]}")
    else
      $log.fail("Did not find expected page title: #{params[0]}, Actual was: #{$ie.title}")
    end
  end
  
  def verify_table_entry_by_id(params)
    #example: first row, third column of table "customers"
    # $ie.table(:id, "customers")[1][3].text = "bob@example.com"
    table_id = params[0]
    rownum = params[1]
    colnum = params[2]
    expected = params[3]
    
    $log.add("Checking text in Table[table_id,row,col] => [#{table_id},#{rownum},#{colnum}]")
    actual_data = $ie.table(:id, table_id)[rownum][colnum].text
    
    if (actual_data == expected)
      $log.pass("Found expected table data: #{expected}")
    else
      $log.fail("Did not find expected table data: #{expected}, Actual was: #{actual_data}")
    end
  end

  # --- Interact via XPath ---
  def click_element_by_xpath(params)
    #use an XPath expression to find ANY element and click it!
    #eg: $ie.element_by_xpath("//area[contains(@href , 'signup.htm')]").click()
    # Requires latest WATiR gem (won't work with 1.4.1!)
    $ie.element_by_xpath(params[0]).click()
  end
  
  def find_text_by_xpath(params)
    #use an XPath expression to find some text  
    #eg: $ie.element_by_xpath("//h2[contains(text(),'Now you')]").innerText
    if ie.element_by_xpath(params[0]).nil?
      $log.fail "Nothing found via XPath expression: #{params[0]}"
    else
      $log.pass "The text is existent, it is: #{$ie.element_by_xpath(params[0]).innerText}"
    end 
  end

  def verify_text_by_xpath(params)
    #use an XPath expression to find some text, then verify it  
    #eg: $ie.element_by_xpath("//h2[contains(text(),'Now you')]").innerText
    actual_data = $ie.element_by_xpath(params[0]).innerText
    expected = params[1]
    if actual_data == expected 
      $log.pass("Found expected data: #{expected}")
    else
      $log.fail("Did not find expected data: #{expected}, Actual was: #{actual_data}")
    end 
  end

  # --- Input Fields ---
  def input_text_by_name(params)
    $ie.text_field(:name, params[0]).set params[1]
  end

  def input_text_by_id(params)
    $ie.text_field(:id, params[0]).set params[1]
  end

  def clear_text_by_name(params)
    $ie.text_field(:name, params[0]).clear
  end
  
  # --- Radio Buttons ---
  def set_radio_by_id(params) 
    $ie.radio(:id, params[0]).set
  end

  def set_radio_by_name(params) 
    $ie.radio(:name, params[0]).set
  end

  def set_radio_by_index(params)
    $ie.radio(:index, params[0]).set
  end

  def clear_radio_by_name(params)
    $ie.radio(:name, params[0]).clear
  end
  
  # --- CheckBoxes ---
  def set_checkbox_by_name(params)
    $ie.checkbox(:name, params[0]).set
  end

  def set_checkbox_by_index(params)
    $ie.checkbox(:index, params[0]).set
  end

  def clear_checkbox_by_name(params)
    $ie.checkbox(:name, params[0]).clear
  end
  
  # --- Dropdown List ---
  def select_list_item_by_name(params)
    #param[0]=overall list name
    #param[1]=item text
    $ie.select_list(:name, params[0]).select(params[1])
  end
  
  def select_list_item_by_id(params)
    #param[0]=overall list name
    #param[1]=item text
    $ie.select_list(:id, params[0]).select(params[1])
  end

  def clear_list_by_name(params)
    $ie.select_list(:name, params[0]).clearSelection
  end
  
  # --- Links ---
  def click_link_by_url(params)
    #TODO Any element can be 'flashed'. Make flashing an option for scripter 
    $ie.link(:href, params[0]).flash
    $ie.link(:href, params[0]).click
  end
  
  def click_link_by_text(params)
    $ie.link(:text, params[0]).flash
    $ie.link(:text, params[0]).click
  end
  

#if __FILE__ == $0
#TODO Generated stub
#end
