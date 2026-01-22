using Sockets
cd(@__DIR__)
include("../src/keystuff.jl")
include("../src/Encryption.jl")
include("../src/NetworkingFuncts.jl")
include("../src/fileManager.jl")
using .NetworkingFuncts 

# --- Receive a length-prefixed packet ---

function ProcessUser(sock)
    privkey,pubkey=Keystuff.GeneratePubPrivKeys()
    println("Opening connection to: ", Sockets.getsockname(sock))
    # Receive first packet
    handsReq, lenreciev = recv_packet(sock)   
    isvalid,sharedkey=isvalidKey(handsReq,lenreciev,privkey,"HREQ")
    if (isvalid)
        #println("handshake request granted")
        # Send HGR and pub key
        handshake = Vector{UInt8}("HGR"*pubkey)
        WriteAndSendData(sock, handshake)
        println("sent: HGR")
        #get main message
        message_received, len = recv_packet(sock)
        msg = String(message_received)
        println("encrypted : ",msg)
        messageunits=Vector{UInt8}(msg)
        #println(messageunits)
        decrypteddata=Encryption.Decrypt(messageunits,sharedkey)
        strdecrypted=String(decrypteddata)
        println("Server got: ",strdecrypted)
        retvalue,retsize = (processCommands(strdecrypted))
        println(retvalue)
        println(retsize)
        retdata=Encryption.Encrypt(retvalue,sharedkey)
        println(retdata)
        println("emcrypted retval")
        WriteAndSendData(sock,retdata)
        println("sent:"*retvalue)
    else
        print("Invalid hreq")
    end
    println("Closing connection to: ",Sockets.getsockname(sock)) 
    
    close(sock)
end

function processCommands(strcommand)
    if strcommand=="C1"#command for getting file struct
        println("listing files")
        filess=(fileManager.list_directory("."))
        println(filess)
        retfiles=codeunits(filess)
        return retfiles,size(retfiles)[1]
    end
    if strcommand[1:2]=="C2"#command for requesting file bytes
        println("getting bytes")
        bytes=fileManager.get_file_bytes(strcommand[3:length(strcommand)])
        println(bytes)
        return bytes,size(bytes)[1]
    end
end

println("Server listening on port 4000...")

server = listen(4000)
while true
    sock = accept(server)
    @async ProcessUser(sock)
end
close(server)
