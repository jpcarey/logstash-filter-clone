# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require "logstash/event"

# The clone filter is for duplicating events.
# A clone will be made for each type in the clone list.
# The original event is left unchanged.
class LogStash::Filters::Clone < LogStash::Filters::Base

  config_name "clone"

  # A new clone will be created with the given type for each type in this list.
  config :clones, :validate => :array, :default => []
  config :meta, :validate => :boolean, :default => true

  public
  def register
    # Nothing to do
  end

  public
  def filter(event)
    @clones.each do |type|
      if @meta
        clone = LogStash::Event.new(event.to_hash_with_metadata)
      else
        clone = event.clone
      end
      clone["type"] = type
      filter_matched(clone)
      @logger.debug("Cloned event", :clone => clone, :event => event)

      # Push this new event onto the stack at the LogStash::FilterWorker
      yield clone
    end
  end

end # class LogStash::Filters::Clone
