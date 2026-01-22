# toyhash from before
using LoopVectorization
using Base.Threads
using JSON
function generate_salt(n::Int=128)
    return rand(UInt8, n)  # cryptographically strong random bytes
end
function passthesalt(longerpass,salt,arraysizes)
    lensalt = length(salt)
    longersalt = zeros(UInt8, arraysizes)
    
    @inbounds for i in eachindex(longerpass)#mod only used for circular array
        # Use XOR and addition only - no modulus!
        idx1 = ((i ⊻ salt[i % lensalt + 1]) % lensalt) + 1
        idx2 = ((i + salt[(i + 17) % lensalt + 1]) % arraysizes) + 1
        
        longerpass[i] = salt[idx1] ⊻ longerpass[idx2] ⊻ UInt8(i & 0xff)
        longersalt[i] = salt[(i * 17 + salt[i % lensalt + 1]) % lensalt + 1]
    end
    return longerpass, longersalt
end
@inline @inbounds function mixthepot!(in1,in2,h)
    for i in eachindex(in1)
        h = (h ⊻ in1[i]) + in2[i]
        h = (h << 13) | (h >> (64-13))  # Proper rotation
        h = h ⊻ 0x9e3779b9  # Golden ratio constant
        # Cross-mix arrays
        in1[i] = in1[i] ⊻ UInt8(h & 0xff)
        in2[i] = in2[i] ⊻ UInt8((h >> 8) & 0xff)
    end
    return h
end

function finalize_hash(h::UInt128, in1, in2, n)
    # Mix all array elements into final hash
    bigh=BigInt(h)
    finalsize=256
    for i in 1:(n)  # Sample 1024 elements
        bigh = bigh ⊻ (BigInt(in1[i]) << (i % 64))
        bigh = bigh ⊻ (BigInt(in2[i]) << ((i + 32) % 64))
        bigh = (bigh << in2[i]) | (bigh >> (finalsize-in2[i]))  # Rotate
        bigh%=(BigInt(2)^finalsize)#to limit the size of h
    end
    return bigh% (BigInt(2)^finalsize)
end
@inline function jHash(pass,salt,weight::Int=12)    
    arraysizes=16384  
    bitsize=128       #output length of h
    n=div(bitsize,2)
    mask = UInt128(2)^bitsize - 1
    lpass=Vector{UInt8}(pass)#vcat(Vector{UInt8}(pass),salt[1:length(pass)],Vector{UInt8}(pass),salt)[1:128]
    passleng=length(lpass)
    lensalt=length(salt)
    longerpass = Vector{UInt8}(undef, arraysizes)
    k=UInt(0)
    @inbounds for i in eachindex(lpass)
        k=lpass[i]⊻salt[(UInt8(lpass[i] & 0x80)+1)]+k#mod only used for circular array
    end
    
    longerpass[1] =UInt8(k & 0xFF)
    @inbounds for i in 2:arraysizes
        k = (k ⊻ lpass[(i % passleng) + 1]) * 0x9e3779b9 + salt[(i % lensalt) + 1]* lpass[(i % passleng) + 1]#mod only used for circular array
        longerpass[i] = UInt8(k & 0xff)
    end
    saltedpass,longersalt=passthesalt(longerpass,salt,arraysizes)
    hashval= mask
    begin
        @inbounds for x in 1:2^weight
        if x%2==0
            hashval=mixthepot!(longersalt,saltedpass,hashval) 
        else
            hashval=mixthepot!(saltedpass,longersalt,hashval) 
        end
        hashval=hashval ⊻ saltedpass[((x%arraysizes) +1)]
        nshift=saltedpass[((x%arraysizes) +1)]
        hashval=((hashval << nshift) | (hashval >> (bitsize-nshift))) 
    end   
end     
    return finalize_hash(hashval,saltedpass,longersalt,arraysizes)
end

pass = ("aa")
salt=[0xf8, 0xb8, 0xc6, 0x11, 0x56, 0x02, 0x33, 0x64, 0xcf, 0x8f, 0x41, 0xae, 0x0f, 0x24, 0x23, 0xf2, 0xb1, 0x7d, 0xf4, 0x53, 0x03, 0x29, 0xf5, 0x25, 0x76, 0x97, 0x97, 0x86, 0x25, 0x5a, 0x41, 0xb3, 0x6e, 0x31, 0x0f, 0x4c, 0x31, 0x0e, 0x5c, 0x44, 0xe4, 0x09, 0x8b, 0x25, 0x30, 0x84, 0xee, 0x96, 0x2e, 0xf2, 0x48, 0xf0, 0xdf, 0x11, 0x38, 0x91, 0x1a, 0xeb, 0x2f, 0x21, 0x4a, 0x01, 0x7b, 0xdc,0xf8, 0xb8, 0xc6, 0x11, 0x56, 0x02, 0x33, 0x64, 0xcf, 0x8f, 0x41, 0xae, 0x0f, 0x24, 0x23, 0xf2, 0xb1, 0x7d, 0xf4, 0x53, 0x03, 0x29, 0xf5, 0x25, 0x76, 0x97, 0x97, 0x86, 0x25, 0x5a, 0x41, 0xb3, 0x6e, 0x31, 0x0f, 0x4c, 0x31, 0x0e, 0x5c, 0x44, 0xe4, 0x09, 0x8b, 0x25, 0x30, 0x84, 0xee, 0x96, 0x2e, 0xf2, 0x48, 0xf0, 0xdf, 0x11, 0x38, 0x91, 0x1a, 0xeb, 0x2f, 0x21, 0x4a, 0x01, 0x7b, 0xdc] 
println(pass)
#jHash("a",salt,1)
println("-------------------------")
function test_avalanche_effect()
    salt = generate_salt(128)
    
    # Test with consistent 128-bit output
    original = jHash("aaab", salt, 12)
    modified = jHash("aaabc", salt, 12)  # Change one character
    
    # Convert BigInt to UInt128 for proper bit count
    println(length(codeunits(original)))
    bits_changed = count_ones(original ⊻ modified)
    println("Proper bits changed: $bits_changed/256")
    return bits_changed
end
test_avalanche_effect()
#@time modified = jHash("aaabc", salt, 12)  