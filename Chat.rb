require 'socket'

class ChatServerRuby

  def initialize(port)
    @Container_array = Array::new
    @sockServer = TCPServer.new("", port)
    @sockServer.setsockopt(Socket::SOL_SOCKET , Socket::SO_REUSEADDR,true)
    @Container_array.push(@sockServer)
    puts "ChatServer started at port: #{port}"
  end

  def runtime
    while 1
      res = select(@Container_array , nil , nil ,nil)
      if res != nil then
        for sock in res[0]
          if sock == @sockServer
            accept_connection

          elsif sock.eof? then
              str = sprintf("Client left #{sock.peeraddr[2]} : #{sock.peeraddr[1]}\n");
              send_message(str,sock)
              sock.close
              @Container_array.delete(sock)

            else
              str = sprintf("[#{sock.peeraddr[2]} | #{sock.peeraddr[1]}] : #{sock.gets()}")
              send_message(str , sock)
          end
        end
      end
    end

  end

  def accept_connection
    new_sock = @sockServer.accept
    @Container_array.push(new_sock)
    new_sock.write("Accepted into Ruby ChatServer! \n")
    str = sprintf("Client Joined %s:%s\n",new_sock.peeraddr[2], new_sock.peeraddr[1])
    send_message(str , new_sock)
  end

  def send_message(str , omit_sock)
    @Container_array.each do |client_sock|
      if client_sock != @sockServer && client_sock != omit_sock
        client_sock.write(str)
      end
    end
  end
end

  rubychatserver = ChatServerRuby.new(2000)
  rubychatserver.runtime
