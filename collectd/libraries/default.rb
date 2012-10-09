
def format_option(option)
  return option if option.instance_of?(Fixnum) || option == true || option == false
  "\"#{option}\""
end

