require 'sinatra'
require 'json'
require 'fogbugz'
require './lib/foghub/parser'

class Foghub < Sinatra::Base
  attr_accessor :instance, :config

  def config
    @config ||= YAML.load_file('./config.yml')
  end

  def fogbugz
    unless @instance
      @instance ||= Fogbugz::Interface.new(config[:fogbugz])
      @instance.authenticate
    end

    @instance
  end

  #TODO Clean this mess
  post '/commit' do
    raise StandardError, "No payload!" unless params[:payload]
    # gsub because sometimes JSOn is just FUCKED
    hook = JSON.parse(params[:payload].gsub('\"', '"'))

    hook["commits"].each do |raw_commit|
      commit = CommitParser.new(raw_commit["message"])
      commit.aliases = config[:aliases]

      if commit.review? && commit.reviewers.length >= 1
        message = "#{raw_commit["message"]} #{raw_commit["url"]}"

        params = {
          :sPersonAssignedTo => commit.reviewer_ids.first,
          :sCategory => "Code Review",
          :sEvent => message
        }

        fogbugz.command(:new, params)
      end

      unless commit.cases.empty?
        commit.cases.each do |case_id|
          message = "#{raw_commit["message"]} #{raw_commit["url"]}"
          params = {:ixBug => case_id, :sEvent => message}

          fogbugz.command(:edit, params)
        end
      end
    end
    
    status 200
  end
end
