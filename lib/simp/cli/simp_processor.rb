
module SimpProcessor
  
  def self.get_env(key)
    @@context.find(key)
  end
  
  def self.set_env(key, value)
    @@context ||= SimpContext.new
    @@context.define key, value
  end
  
  def self.evaluate(expression)
    # p [ 'Evalulating', expression ]
    
    # return @current_environment.find(expression) if expression.is_a? Symbol
    return expression unless expression.is_a? Array
    
    if expression[0] == :define
      return @current_environment.define expression[1], evaluate(expression[2])
    else # function call
      function = evaluate(expression[0]).to_s
      arguments = expression.slice(1, expression.length)
      scope = nil
      
      # Allows +param1 param2 calls
      ( function = $1; arguments.unshift($2) ) if function =~ /^([+?])([a-zA-Z0-9_]+)$/
      
      # Allow scope-function calls
      ( scope = $1; function = $2 ) if function =~ /^([a-zA-Z0-9_]+)-([a-zA-Z0-9_]+)$/
      
      ( scope = nil; function = 'ring'; arguments.unshift($1) ) if function =~ /^@([a-zA-Z0-9_]+)$/
      p [ 'Executing Function', "#{ scope ? scope + '-' : '' }#{function}", arguments ]
      
      # We are going to walk modules
      mod = SimpCLIFunctions
      mod = mod.class_eval(SimpHelper.camel_case(scope)) if scope
      
      # Check if function is available
      if mod.respond_to?(function)
        return mod.send(function, *arguments)
      else
        if scope
          raise "Unknown function: #{camel_case(scope)}::#{function}"
        else
          raise "Unknown function: #{function}"
        end
      end
    end
  end
end