require 'IRC'
require 'StParseEvent'
require 'socket'


botnick = "RBot"
server  = "irc.freenode.net"
port    = "6667"
channels = ["\#ruby-irc"]
#options = {:use_ssl => 1}
options = {}

class RBot < IRC
  def initialize (nick, server, port, channels, options) 

    super(nick, server, port, "RBOT", options)
    @bot = self
    
    # This makes us listen to STDIN. It's handy sometimes
    IRCConnection.add_IO_socket(STDIN) {|sock| StParseEvent.new(sock.readline.chomp) }
    # Callbakcs for the connection.
    IRCEvent.add_callback('endofmotd'){ |event| channels.each do |chan| @bot.add_channel(chan); end }
    IRCEvent.add_callback('nicknameinuse') {|event| bot.ch_nick("RubyBot") }
    IRCEvent.add_callback('privmsg') {|event| parse(event) }
    StParseEvent.add_handler('command') {|event| parse(event) }
    IRCEvent.add_callback('join') {|event| 
      if @autoops.include?(event.from)
        @bot.op(event.channel, event.from)
      end
    }
    IRCEvent.add_callback('mode') { |event|
      # Gotta Break up the mode events.
      switch = 'add'
      i = 5
      event.mode.scan(/[\+-ovh]/) { |mode| 
        case mode
        when '-'
          switch = 'sub'
        when '+'
          switch = 'add'
        when 'o'
          target = event.stats[i]
          if @autoops.include?(event.from) && ! @autoops.include?(target) && switch == 'add'
            @autoops.add(target)
            @autoops.write()
          else @autoops.include?(event.from) && switch == 'sub' && @autoops.include?(target)
            @autoops.remove(target)
            @autoops.write()
          end
          i += 1
        else
          i += 1
        end
      }
    }
    return
  end

  def parse (event)
    if @command.nil?
      init_command_handler()
    end
    
    line = event.message;
    
    parts = line.scan(/^\.\w+/)
    com = parts[0];

    if (com.nil? )
      return
    end
    
    if @command.nil? 
      puts "Gonna die soon, still nil here for some reason"
    end

    if @command[com]
      @command[com].call(self, event)
    end
  end
  
  def init_command_handler
    @command = Hash.new();
    @command = { 
      '.test'  => lambda {|bot, event| bot.send_message(event.channel, "Hello World") },
      '.join'  => lambda {|bot, event| event.message.scan(/\#\w+/) { |channel| @bot.join(channel) } },
      '.part'  => lambda {|bot, event| event.message.scan(/\#\w+/) { |channel| @bot.part(channel) } },
      '.addop' => lambda {|bot, event| event.message.scan(/\s\w+/) { |user| @autoops.add(user.gsub(/\s/,'')) }},
      '.remop' => lambda {|bot, event| event.message.scan(/\s\w+/) { |user| @autoops.remove(user.gsub(/\s/, '')) }},
      '.saveop' => lambda {|bot, event| @autoops.write },
      '.version' => lambda {|bot, event| bot.send_message(event.channel, "Currently running on ruby version #{RUBY_VERSION}")},
      '.listop' => lambda {|bot, event| bot.send_message(event.channel, "OPS: #{@autoops.inspect}"); @autoops.each() {|op| bot.send_message(event.channel, "OP: #{op.to_s}")}},
      '.alert'  => lambda {|bot, event| 
        event.message.scan(/\s\d+/) { |time| 
          bot.send_message(event.channel, "setting alert for #{time} seconds")
          sleep time.to_f
          bot.send_message(event.channel, "This is your #{time} second alarm" ) 
        } 
      }, 
      '.quit'   => lambda {|bot, event| @bot.send_quit; IRCConnection.quit },
      '.waitup' => lambda {|bot, event| sleep 10; bot.send_message(event.channel, "OK, I waited up for you")},
      '.newdefault' => lambda {|bot, event|  },
      '.rotatelog'  => lambda {|bot, event|  }, 
      '.history'    => lambda {|bot, event| 
        event.message.scan(/\#\w+/) {|channel|
          history = StParseEvent.history(channel)
          history.each {|line| 
            bot.send_message(event.from, "#{line}")
          }
        }
      }
        

    }
  end
  
end



RBot.new(botnick, server, port, channels, options).connect

