class StParseEvent
  @@history = Hash.new();
  attr_reader :to, :text, :event_type, :channel, :message
  @@default_channel = nil;
  @@filters = []
  def initialize (line)
    if (line.match(/^\#(.*?):/))
      (@channel, @message) = line.split(/\s*:\s*/, 2)
      @@default_channel = @channel;
    elsif (line.match(/^\.\w+/))
      @message = line
    else
      if ! @@default_channel.nil?
        @channel = @@default_channel
        @message = line
      end
    end
 
    if ! @@filters.nil?
      @@filters.each {|filter|
        rv = filter.call(@channel, @message);
        @channel = rv[0]
        @message = rv[1]
      }
    end

    if ! @channel.nil?
      if @@history[@channel].nil?
        @@history[@channel] = Array.new();
      end
      @@history[@channel].push("#{Time.now}: #{@message}");
      if @@history[@channel].size > 10
        @@history[@channel].shift
      end
    end
  end
  @@handlers = { 
    '.say' => lambda {|event| IRCConnection.output_push("PRIVMSG #{event.channel} : #{event.message}") },
    '.noop' => lambda {|event| },
  }
  @@callbacks = Hash.new();
  def process 
    handled = nil
    if ! @channel.nil?
      @@handlers['.say'].call(self)
      handled = 1
    end
    if @@handlers['command']
      @@handlers['command'].call(self)
      handled = 1
    end
    if !handled
      puts "No handler for event type #@event_type in #{self.class}"
    end
  end
  def StParseEvent.add_handler(message_id, proc=nil, &handler)
    if block_given?
      @@handlers[message_id] = handler
    elsif proc
      @@handlers[message_id] = proc
    end
  end
  def StParseEvent.add_filter(proc=nil, &filter)
    if block_given?
      @@filters.push(filter)
    elsif proc
      @@filters.push(proc)
    end
  end
  def StParseEvent.history(channel)
    return @@history[channel];
  end
  def StParseEvent.set_default_channel(channel)
    @@default_channel = channel
  end
end
