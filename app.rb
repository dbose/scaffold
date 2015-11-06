require 'rubygems'
require 'sinatra'
require 'pry'

require 'mandrill'
require 'mandrill_template/client'
require 'mandrill_template/template'

require 'handlebars'
require 'nokogiri'
require 'cgi'

require 'sinatra/flash'

def get_or_post(path, opts={}, &block)
  get(path, opts, &block)
  post(path, opts, &block)
end

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end

  def h(html)
    CGI.escapeHTML html
  end
end

get '/' do
  @remote_templates = remote_templates
  generate_local_templates @remote_templates
  erb :home
end

get_or_post '/templates/sync' do
  generate_local_templates_unsafe remote_templates
  redirect '/'
end

get_or_post '/templates/:slug/sync' do
  template = MandrillClient.client.templates.info(params[:slug])
  generate_local_template_unsafe template
  redirect '/'
end

post '/code/*' do
  File.open("views/#{params['splat'].first}.erb", "w") do |f|
    f.write params[:code]
  end
  "OK"
end

get '/templates/:slug/render' do
  template = erb(:template_layout,
                :locals => {
                    :slug => params["slug"],
                    :render_for_upload => false },
                :layout => false)

  merge_vars =  JSON.parse(File.read("views/params.json.erb")) rescue []
  handlebars = Handlebars::Context.new
  h_template = handlebars.compile(template)
  h_template.call(localize_merge_vars(merge_vars))
end

post '/templates/:slug/draft' do
  upload_template params[:slug]
  flash[:notice] = "#{params[:slug]} has been drafted successfully !"
  redirect "/"
end

post '/templates/draft' do
  local_templates.each do |local_template|
    slug = local_template.split(".").first
    puts "Uploading #{slug}..."
    upload_template slug
  end
  flash[:notice] = "All templates have been drafted successfully !"
  redirect "/"
end

post '/templates/:slug/publish' do
  puts MandrillClient.client.templates.publish(params[:slug]).to_yaml
  flash[:notice] = "#{params[:slug]} has been published successfully !"
  redirect "/"
end

post '/templates/publish' do
  local_templates.each do |local_template|
    slug = local_template.split(".").first
    puts MandrillClient.client.templates.publish(slug).to_yaml
  end

  flash[:notice] = "All templates have been published successfully !"
  redirect "/"
end

def generate_local_templates(remote_templates, path = "views/templates/")
  if Dir["#{path}*"].empty?
    generate_local_templates_unsafe(remote_templates, path)
  end
end

def generate_local_templates_unsafe(remote_templates, path = "views/templates/")
  remote_templates.each do |template|
    generate_local_template_unsafe template, path
  end
end

def generate_local_template_unsafe(template, path = "views/templates/")
  File.open "#{path}#{template['slug']}.erb", "w+"  do |file|
    file.write(extract_content_from_template(template))
  end
end

def remote_templates
  @remote_templates ||= MandrillClient.client.templates.list.select{|t| !t['labels'].include?('layout') }
end

def local_templates
  @local_templates ||= Dir['views/templates/*']
end

def localize_merge_vars(merge_vars)
  h = {}
  merge_vars.each {|kv| h[kv["name"]] = kv["content"] }
  h
end

def extract_content_from_template(template, content_selector = 'div#body-content')
  begin
    template_code = template['code']
    slug = template['slug']

    return nil if template_code.nil?
    parser = Nokogiri::HTML.fragment(template_code)

    # Need to delete <style> , <meta> tags etc.
    ['title', 'style', 'meta'].each do |tag|
      tag_parser = parser.css(tag) rescue []
      tag_parser.remove unless tag_parser.empty?
    end

    #binding.pry if slug == 'advertiser-sale-agent-signup-paid'

    parsed = parser.css(content_selector) rescue []
    return template_code if parsed.empty?

    begin
      parsed.try(:inner_html)
    rescue => e
      puts e.backtrace
      parsed.to_a.first.inner_html
    end
  rescue => e
    puts e.backtrace
  end
end

def remote_template_exists?(name)
  begin
    MandrillClient.client.templates.info(name)
    true
  rescue Mandrill::UnknownTemplateError
    false
  end
end

def upload_template(slug)
  if remote_template_exists?(slug)
    method = :update
  else
    method = :add
  end

  templated_content = erb(:template_layout,
                          :locals => { :slug => slug, :render_for_upload => true },
                          :layout => false)

  # TODO: Ensure not to override un-used fields
  #
  result = MandrillClient.client.templates.send(method,
                                                slug,
                                                nil,
                                                nil,
                                                nil,
                                                templated_content,
                                                nil,
                                                false) # publish
  puts result.to_yaml
end