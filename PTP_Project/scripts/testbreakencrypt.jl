include("../src/Encryption.jl")
include("../src/keystuff.jl")


pubkey,privkey=Keystuff.GeneratePubPrivKeys()
sharedkey=Keystuff.genKey(privkey,pubkey)
msg="oiquerghqerioguheoirgh"
vmsg=Vector{UInt8}(msg)
@time encr= Encryption.Encrypt(vmsg,sharedkey)
println(String(encr))
@time decr= Encryption.Decrypt(encr,sharedkey)
println(String(decr))

