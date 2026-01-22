cd(@__DIR__)
##make sothat when c1 is called there is a new console menue for choosing the specific file then c2 can be called
include("../src/keystuff.jl")
include("../src/Encryption.jl")
include("../src/NetworkingFuncts.jl")
include("../src/fileManager.jl")
using .NetworkingFuncts

function ConnectEncryptSend(ServerIp,port, data::Vector{UInt8};attempt=0,debugging=false)
    if attempt>0
        println("attempting again")
    end
    
    sock=establishConnectionToServer(ServerIp,port)
    println("Connected to server!")
    #gen key and load vars
    privkey,pubkey=Keystuff.GeneratePubPrivKeys()
    handshakedata=Vector{UInt8}("HREQ"*pubkey)

    #send HREQ and pub key
    WriteAndSendData(sock, handshakedata)
    if debugging println("sent: HREQ") end
    #get HGR and serverpubkey
    handsfromserver, lenreciev = recv_packet(sock)
    isvalid,sharedkey=isvalidKey(handsfromserver,lenreciev,privkey,"HGR",debugging=debugging)
    if (isvalid)
            #encrypt own message with shared key
            lensend=length(data)
            encrypteddata=Encryption.Encrypt(data,sharedkey)
            #send data
            WriteAndSendData(sock, encrypteddata)
            if debugging println("message sent") end
            valuefromrequest, lenreciev = recv_packet(sock)
            if debugging println("got respomse") end
            if lenreciev!=0
                decryptedval=Encryption.Decrypt(valuefromrequest,sharedkey)
                return recievecommands(decryptedval,data)
            end
    else
        #Expected HGR was null
        println("invalid hgr")
        ConnectEncryptSend(ServerIp,port,data;attempt=attempt+1)
        return
    end
end

function recievecommands(decryptedval,data)
    command=data[1:2]
    cmdstring=String(command)
    remaindata=data[3:length(data)]
    if (cmdstring=="C1")#command for getting file struct
        stringrecieved=String(decryptedval)
        println(stringrecieved)
    end
    if (cmdstring=="C2")#command for requesting file bytes
        remaindata=data[3:length(data)]
        remstring=String(remaindata)
        println(remstring)
        fileManager.save_file_bytes(remstring,decryptedval)
    end


end

println("ready")
while true
    stringin=readline()
    ConnectEncryptSend("0.0.0.0", 4000, Vector{UInt8}(stringin))
    #PTP_Project.send_packet("105.184.213.245", 5000, Vector{UInt8}(stringin))
end