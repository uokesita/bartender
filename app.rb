require 'rubygems'
require 'sinatra'
require 'yaml'
require 'wufoo'

# CONFIGURATION FILE FOR WUFOO
config = YAML::load(File.read('config/wufoo'))


helpers do
  def partial(page, options={})
    haml page, options.merge!(:layout => false)
  end
end


get '/' do
  haml :layout
end


post '/wufoo' do 
  
  client = Wufoo::Client.new(config['wufoo_url'], config['api_key'])
  submission = Wufoo::Submission.new(client, config['form_name'])

  response = submission.add_params({
    # ADD HERE FORM PARAMETERS. GO TO FORM API for VALUES
    '7'  => params[:nombre],
  }).process


  if response.success?
    
    #@mensaje = response.message
    @message = "Gracias por contactarnos. Te llamaremos dentro de 2 dias abiles o menos"
  else
    # Something was wrong with the request
    # (missing api key, invalid form, etc)
    if response.fail?
     @mensaje = response.error    
    end

    # validation errors
    unless response.valid?
      errors = response.errors.collect { |e| "#{e.field_id} (#{e.code}): #{e.message}" }    
      @mensaje = errors * "\n"
    end
  end
  
  haml :wufoo
  
end




