module Keystuff
export  GeneratePubPrivKeys, genKey,warmup_njit_functions

#https://chatgpt.com/share/6852a7cc-c250-8006-8f34-02822cfa0f74
using Random
using JSON
#SettingsDict = JSON.parsefile("../src/Settings.txt")

REALLY_BIG_NUBER = "FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A63A3620FFFFFFFFFFFFFFFF"
#SettingsDict["REALLY_BIG_NUBER"]
PRIME_NUMBER = 71
#SettingsDict["PRIME_NUMBER"]

G = BigInt(PRIME_NUMBER)#71
N = parse(BigInt, REALLY_BIG_NUBER, base=16)
function warmup_njit_functions()
    genKey("11","13")
    rand_bigint_range(BigInt(1),BigInt(7))
    return nothing
end
# === Key Generation ===
function GeneratePubPrivKeys()
    PrivateKey = rand_bigint_range(BigInt(1),N-BigInt(2))
    PublicKey = powermod(G, PrivateKey, N)
    return (string(PublicKey), string(PrivateKey))
end
function rand_bigint_range(low::BigInt, high::BigInt)
    if high < low
        throw(ArgumentError("high must be ≥ low"))
    end
    range = high - low + 1
    n_bits = length(string(range, base=2))  # how many bits needed
    n_bytes = cld(n_bits, 8)

    while true
        bytes = rand(RandomDevice(), UInt8, n_bytes)
        x = BigInt(0)
        for b in bytes
            x = (x << 8) | b
        end
        if x < range
            return low + x
        end
    end
end

function genKey(private_key:: String, public_key::String)
    key = powermod(parse(BigInt,private_key), parse(BigInt,public_key), N)
    return (reverse(string(key)))
end

end