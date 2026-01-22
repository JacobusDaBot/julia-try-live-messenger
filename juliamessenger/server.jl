using Sockets

include("Encryption//Encrypt.jl")
include("Encryption//keystuff.jl")
# --- Receive a length-prefixed packet ---
function recv_packet(sock::TCPSocket)
    hdr = read(sock, 4)
    first4bytes=reinterpret(UInt32, hdr)
    #println(first4bytes)
    if length(first4bytes)>0
        len = first4bytes[1]
        rpacket = read(sock, len)   # already Vector{UInt8}
        return rpacket, len
    end
    return "null",0
end

# --- Send a length-prefixed packet ---
function send_packet(sock::TCPSocket, data::Vector{UInt8})
    len = UInt32(length(data))
    write(sock, reinterpret(UInt8, [len]))
    write(sock, data)
    flush(sock)
end

# --- Server ---
#try
    println("Server listening on port 4000...")
    for i in 0:5
        server = listen(4000)
        sock = accept(server)
        close(server)
        println("Opening connection to: ", Sockets.getsockname(sock))

        # Receive first packet
        messageUchar, len = recv_packet(sock)
        
        msg = String(messageUchar)        
        #println("\tServer got: ", msg)
        messageunits=codeunits(msg)
        if len<=5
            println("naa fuck you")
            close(sock)
            continue
        end
        if (codeunits("HREQ")==(messageunits)[1:4])
            println("handshake request granted")
            privkey,pubkey=Keystuff.GeneratePubPrivKeys()
            sharedkey=""
            try 
                clientpubkey=msg[5:len]               
                sharedkey=Keystuff.genKey(privkey,clientpubkey)
            catch
                println("naa fuck you--key issue")
                close(sock)
                continue
            end
            # Send handshake back
            handshake = Vector{UInt8}("HGR"*pubkey)
            send_packet(sock, handshake)
            println("Sent handshake grant to client")

            #get main message
            message_received, len = recv_packet(sock)
            msg = String(message_received)
            println("encrypted : ",msg)
            messageunits=codeunits(msg)
            Encrypt.Prep(Vector{UInt8}(sharedkey),false)
            decrypteddata=Encrypt.UnShuffel(messageunits,len)
            strdecrypted=String(decrypteddata)
            println("Server got: ",strdecrypted)
            if strdecrypted=="close"
                break
            end
        else
            #not a handshake request
            println(String(messageUchar))
        end
        println("Closing connection to: ",Sockets.getsockname(sock)) 
        
        close(sock)

    end
#=
catch err
    println("Error: ", err)
    if isdefined(Main, :sock) && isopen(sock)
        close(sock)
    end
    if isdefined(Main, :server) && isopen(server)
        close(server)
    end=#
#end
