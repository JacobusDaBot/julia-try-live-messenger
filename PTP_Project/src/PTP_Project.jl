module PTP_Project

using Sockets
include("Encryption.jl")
include("keystuff.jl")


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

function send_packet(clientip,port, data::Vector{UInt8})
    sock = Nothing
    err=1
    while err!=0
        try 
            err=0
            sock = connect(clientip,port)
        catch error
            err=error
            sleep(0.5)
            println("try connect")
        end
    end
    println("Connected to server!")
    privkey,pubkey=Keystuff.GeneratePubPrivKeys()
    handshakedata=Vector{UInt8}("HREQ"*pubkey)
    msg=""
    lenreciev=0
    handsfromserver="null"
    while lenreciev<=0
        println("send attempt to connect")
        len = UInt32(length(handshakedata))
        write(sock, reinterpret(UInt8, [len]))
        write(sock, handshakedata)
        flush(sock)        
        handsfromserver, lenreciev = recv_packet(sock)
        if lenreciev >0 
            break
        else
            err=1
            while err!=0
                try 
                    err=0
                    sock = connect(clientip,port)
                catch error
                    err=error
                end
            end
        end
    end
    msg=String(handsfromserver)
    #println("Client got handshake: ", (msg))
    if ((msg)[1:3]=="HGR")
        println("handshake grant recieved")
        sharedkey=""
        try 
            serverpubkey=msg[4:lenreciev]
            sharedkey=Keystuff.genKey(privkey,serverpubkey)
        catch
                println("naa fuck you--key issue")          
                #try again      
                send_packet(clientip,port,data)
                return
        end
        len = UInt32(length(data))
        encrypteddata=Encryption.Encrypt(data,sharedkey)
        write(sock, reinterpret(UInt8, [len]))
        write(sock, encrypteddata)
        flush(sock)
        println("message sent")
    else
        println("rejected")
    end
end



end