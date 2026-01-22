
module NetworkingFuncts
export recv_packet,WriteAndSendData,establishConnectionToServer,isvalidKey
using Sockets
include("Encryption.jl")
include("keystuff.jl")

chunk_size=10_000_000
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
function WriteAndSendData(sock,data)
    total = UInt32(length(data))
    write(sock, reinterpret(UInt8, [total]))
    sent = 0
    while sent < total
        chunk_end = min(sent + chunk_size, total)
        write(sock, @view data[sent+1:chunk_end])
        sent = chunk_end
    end
    flush(sock) 
end
function isvalidKey(handsfromserver,lenreciev,privkey,typehand;debugging=false)
    #println("checking validity")
    lentype=length(typehand)
    if lenreciev > lentype+1
        msg=String(handsfromserver)
        #println("Client got handshake: ", (msg))
        if ((msg)[1:lentype]==typehand)
            if debugging println("recieved:"*typehand) end
            sharedkey=""
            try 
                #read serverpub key and generate shared key
                serverpubkey=msg[lentype+1:lenreciev]
                sharedkey=Keystuff.genKey(privkey,serverpubkey)
            catch
                    #somethign wrong with pubkey from server  
                    println("naa fuck you--key issue")          
                    #ConnectEncryptSend(clientip,port,data;attempt=attempt+1)
                    return false,""
            end
            return true,sharedkey
        else
            println("not "*typehand)
        end
    end
    return false,""
end
function establishConnectionToServer(ServerIp,port)
    err=1
    sock = Nothing
    #repeat try connect
    while err!=0
        try 
            err=0
            sock = connect(ServerIp,port)
        catch error
            err=error
            sleep(0.5)
            println("try connect")
        end
    end
    return sock
end




end