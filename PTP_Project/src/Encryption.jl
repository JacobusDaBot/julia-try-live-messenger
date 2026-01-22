module Encryption
export Encrypt,Decrypt

function pack_uint32(bytes)
    return sum(UInt32(bytes[i]) << (8*(4-i)) for i in 1:length(bytes))
end
function unpack_uint32(x)
    return [UInt8((x >> (8*(4-i))) & 0xff) for i in 1:4]
end

function pack_uint128(bytes)
    return sum(UInt128(bytes[i]) << (8*(16-i)) for i in 1:length(bytes))
end
function unpack_uint128(x)
    return [UInt8((x >> (8*(16-i))) & 0xff) for i in 1:16]
end
function pack_uBigInt(bytes,len)
    return sum(BigInt(bytes[i]) << (8*(len-i)) for i in 1:len)
end
function unpack_uBigInt(x,len)
    return [UInt8((x >> (8*(len-i))) & 0xff) for i in 1:len]
end
function GenerateStructure(vectorsmg,keyvector)#array of uint128
    bits=div(128,8)
    lenin=length(vectorsmg)
    lenout=Int(ceil(lenin/bits))#16 to get 128 bits in each row
    matrixData=zeros(UInt8,(lenout,bits))
    count=1
    for row in 1:lenout
        start_idx = (row-1)*bits + 1
        end_idx = min(row*bits, lenin)
        if start_idx <= lenin
            chunk_length = end_idx - start_idx + 1
            matrixData[row, 1:chunk_length] .= vectorsmg[start_idx:end_idx]
        end
    end
    lenkey=length(keyvector)
    packedkey=zeros(UInt32,div(lenkey,4)+1)
    icount=1
    for i in 1:4:lenkey-1
        packedkey[icount]=pack_uint32(keyvector[i:min(i+3,lenkey)])
        icount+=1
    end
    return matrixData,lenout,packedkey
end
function DeGenerateStructure(matrixData)
    return vec(transpose(matrixData))
end

function getSbox()
    AES_SBOX = UInt8[
        0x63, 0x7c, 0x77, 0x7b, 0xf2, 0x6b, 0x6f, 0xc5, 0x30, 0x01, 0x67, 0x2b, 0xfe, 0xd7, 0xab, 0x76,
        0xca, 0x82, 0xc9, 0x7d, 0xfa, 0x59, 0x47, 0xf0, 0xad, 0xd4, 0xa2, 0xaf, 0x9c, 0xa4, 0x72, 0xc0,
        0xb7, 0xfd, 0x93, 0x26, 0x36, 0x3f, 0xf7, 0xcc, 0x34, 0xa5, 0xe5, 0xf1, 0x71, 0xd8, 0x31, 0x15,
        0x04, 0xc7, 0x23, 0xc3, 0x18, 0x96, 0x05, 0x9a, 0x07, 0x12, 0x80, 0xe2, 0xeb, 0x27, 0xb2, 0x75,
        0x09, 0x83, 0x2c, 0x1a, 0x1b, 0x6e, 0x5a, 0xa0, 0x52, 0x3b, 0xd6, 0xb3, 0x29, 0xe3, 0x2f, 0x84,
        0x53, 0xd1, 0x00, 0xed, 0x20, 0xfc, 0xb1, 0x5b, 0x6a, 0xcb, 0xbe, 0x39, 0x4a, 0x4c, 0x58, 0xcf,
        0xd0, 0xef, 0xaa, 0xfb, 0x43, 0x4d, 0x33, 0x85, 0x45, 0xf9, 0x02, 0x7f, 0x50, 0x3c, 0x9f, 0xa8,
        0x51, 0xa3, 0x40, 0x8f, 0x92, 0x9d, 0x38, 0xf5, 0xbc, 0xb6, 0xda, 0x21, 0x10, 0xff, 0xf3, 0xd2,
        0xcd, 0x0c, 0x13, 0xec, 0x5f, 0x97, 0x44, 0x17, 0xc4, 0xa7, 0x7e, 0x3d, 0x64, 0x5d, 0x19, 0x73,
        0x60, 0x81, 0x4f, 0xdc, 0x22, 0x2a, 0x90, 0x88, 0x46, 0xee, 0xb8, 0x14, 0xde, 0x5e, 0x0b, 0xdb,
        0xe0, 0x32, 0x3a, 0x0a, 0x49, 0x06, 0x24, 0x5c, 0xc2, 0xd3, 0xac, 0x62, 0x91, 0x95, 0xe4, 0x79,
        0xe7, 0xc8, 0x37, 0x6d, 0x8d, 0xd5, 0x4e, 0xa9, 0x6c, 0x56, 0xf4, 0xea, 0x65, 0x7a, 0xae, 0x08,
        0xba, 0x78, 0x25, 0x2e, 0x1c, 0xa6, 0xb4, 0xc6, 0xe8, 0xdd, 0x74, 0x1f, 0x4b, 0xbd, 0x8b, 0x8a,
        0x70, 0x3e, 0xb5, 0x66, 0x48, 0x03, 0xf6, 0x0e, 0x61, 0x35, 0x57, 0xb9, 0x86, 0xc1, 0x1d, 0x9e,
        0xe1, 0xf8, 0x98, 0x11, 0x69, 0xd9, 0x8e, 0x94, 0x9b, 0x1e, 0x87, 0xe9, 0xce, 0x55, 0x28, 0xdf,
        0x8c, 0xa1, 0x89, 0x0d, 0xbf, 0xe6, 0x42, 0x68, 0x41, 0x99, 0x2d, 0x0f, 0xb0, 0x54, 0xbb, 0x16
    ]
        AES_INV_SBOX = zeros(UInt8, 256)
        for i in 0x00:0xff
            original_byte = UInt8(i)
            substituted_byte = AES_SBOX[original_byte+1]
            AES_INV_SBOX[substituted_byte + 1] = original_byte
        end
       
    return AES_SBOX,AES_INV_SBOX
end
function ShiftRows!(matrix,key,keylen,keyoffset,matrixlen)
    icount=keyoffset
    for i in (eachrow(matrix))
        packi=pack_uint128(i)
        shiftamount=key[(icount)%keylen + 1]%128
        i[1:16]=unpack_uint128((packi>>shiftamount)| (packi<< (128-shiftamount)) )
        icount+=1
    end
        icount=keyoffset
    matrixlen8=matrixlen*8
    for i in eachcol(matrix)
        packi=pack_uBigInt(i,matrixlen)
        shiftamount=key[(icount)%keylen + 1]%(matrixlen8)
        newcol=(packi<<shiftamount)| (packi>> (matrixlen8-shiftamount)) 
        i[1:matrixlen]=unpack_uBigInt(newcol,matrixlen)
        icount+=1
    end
end
function UnShiftRows!(matrix,key,keylen,keyoffset,matrixlen)
    icount=keyoffset
    matrixlen8=matrixlen*8
    for i in eachcol(matrix)
        packi=pack_uBigInt(i,matrixlen)
        shiftamount=key[(icount)%keylen + 1]%(matrixlen8)
        newcol=(packi>>shiftamount)| (packi<< (matrixlen8-shiftamount)) 
        i[1:matrixlen]=unpack_uBigInt(newcol,matrixlen)
        icount+=1
    end
        icount=keyoffset
    for i in (eachrow(matrix))
        packi=pack_uint128(i)
        shiftamount=key[(icount)%keylen + 1]%128
        i[1:16]=unpack_uint128((packi<<shiftamount)| (packi>> (128-shiftamount)) )
        icount+=1
    end
end
function gf_multiply(a::UInt8, b::UInt8)
    result = UInt8(0)
    for i in 0:7
        if (b >> i) & 1 != 0
            result ⊻= a
        end
        # Multiply a by x (left shift)
        carry = a & 0x80
        a = a << 1
        if carry != 0
            a ⊻= 0x1B  # XOR with irreducible polynomial
        end
    end
    return result
end
function MixColumns!(matrix::Matrix{UInt8})
    rows, cols = size(matrix)
    
    # Process in groups of 4 columns
    for col_start in 1:4:cols
        col_end = min(col_start + 3, cols)
        
        # For each row, process the 4-byte block
        for row_start in 1:4:rows
            row_end = min(row_start + 3, rows)
            
            # Extract 4x4 block (pad with zeros if needed)
            block = zeros(UInt8, 4, 4)
            for r in row_start:row_end, c in col_start:col_end
                block[r-row_start+1, c-col_start+1] = matrix[r, c]
            end
            
            # Apply MixColumns to this 4x4 block
            mix_4x4_block!(block)
            
            # Copy back
            for r in row_start:row_end, c in col_start:col_end
                matrix[r, c] = block[r-row_start+1, c-col_start+1]
            end
        end
    end
end
function InvMixColumns!(matrix::Matrix{UInt8})
    rows, cols = size(matrix)
    
    # Process in groups of 4 columns (same pattern as encryption)
    for col_start in 1:4:cols
        col_end = min(col_start + 3, cols)
        
        # For each row, process the 4-byte block
        for row_start in 1:4:rows
            row_end = min(row_start + 3, rows)
            
            # Extract 4x4 block (pad with zeros if needed)
            block = zeros(UInt8, 4, 4)
            for r in row_start:row_end, c in col_start:col_end
                block[r-row_start+1, c-col_start+1] = matrix[r, c]
            end
            
            # Apply INVERSE MixColumns to this 4x4 block
            inv_mix_4x4_block!(block)
            
            # Copy back
            for r in row_start:row_end, c in col_start:col_end
                matrix[r, c] = block[r-row_start+1, c-col_start+1]
            end
        end
    end
end
function mix_4x4_block!(state::Matrix{UInt8})
    for col in 1:4
        s0, s1, s2, s3 = state[:, col]
        
        # Matrix multiplication in GF(2^8)
        state[1, col] = gf_multiply(0x02, s0) ⊻ gf_multiply(0x03, s1) ⊻ s2 ⊻ s3
        state[2, col] = s0 ⊻ gf_multiply(0x02, s1) ⊻ gf_multiply(0x03, s2) ⊻ s3
        state[3, col] = s0 ⊻ s1 ⊻ gf_multiply(0x02, s2) ⊻ gf_multiply(0x03, s3)
        state[4, col] = gf_multiply(0x03, s0) ⊻ s1 ⊻ s2 ⊻ gf_multiply(0x02, s3)
    end
end
function inv_mix_4x4_block!(block::Matrix{UInt8})
    # Inverse MixColumns for a 4x4 block
    for col in 1:4
        s0, s1, s2, s3 = block[1, col], block[2, col], block[3, col], block[4, col]
        
        # Inverse matrix multiplication
        block[1, col] = gf_multiply(0x0E, s0) ⊻ gf_multiply(0x0B, s1) ⊻ gf_multiply(0x0D, s2) ⊻ gf_multiply(0x09, s3)
        block[2, col] = gf_multiply(0x09, s0) ⊻ gf_multiply(0x0E, s1) ⊻ gf_multiply(0x0B, s2) ⊻ gf_multiply(0x0D, s3)
        block[3, col] = gf_multiply(0x0D, s0) ⊻ gf_multiply(0x09, s1) ⊻ gf_multiply(0x0E, s2) ⊻ gf_multiply(0x0B, s3)
        block[4, col] = gf_multiply(0x0B, s0) ⊻ gf_multiply(0x0D, s1) ⊻ gf_multiply(0x09, s2) ⊻ gf_multiply(0x0E, s3)
    end
end
function AddRoundKey!(matrix,keyvector,lenmatrix,keylen)
    for i in 1:lenmatrix
        matrix[i%lenmatrix + 1]=xor(matrix[i%lenmatrix + 1],(keyvector[((i%keylen) +1)]))
    end
end
function UnAddRoundKey!(matrix,keyvector,lenmatrix,keylen)
    for i in 1:lenmatrix
        matrix[i%lenmatrix + 1]=xor(matrix[i%lenmatrix + 1],(keyvector[((i%keylen) +1)]))
    end
end
function Avalanche!(matrix)
    token=UInt32(3014610819)
    for i in eachrow(matrix)
        packarray=zeros(UInt32,4)
        ic=1
        for x in 1:4:16
            packarray[ic]=pack_uint32(i[x:x+3])
            ic+=1
        end
        packarray[1]=xor(token,packarray[1])
        for x in 2:4
            packarray[x]=xor(packarray[x-1],packarray[x])
        end
        ic=1
        for x in 1:4:16
            i[x:x+3]=unpack_uint32(packarray[ic])
            ic+=1
        end
    end
end
function UnAvalanche!(matrix)
    token=UInt32(3014610819)
    for i in eachrow(matrix)
        packarray=zeros(UInt32,4)
        ic=1
        for x in 1:4:16
            packarray[ic]=pack_uint32(i[x:x+3])
            ic+=1
        end
        
        for x in 4:-1:2
            packarray[x]=xor(packarray[x-1],packarray[x])
        end
        packarray[1]=xor(token,packarray[1])
        ic=1
        for x in 1:4:16
            i[x:x+3]=unpack_uint32(packarray[ic])
            ic+=1
        end
    end
end

function displaymatrix(matrix)
    println(repeat("_",64))
    for i in eachrow(matrix)
        print(|)
        for x in eachindex(i)
            print(i[x])
            if (i[x]<=99)
            print(" ")
            end
            if (i[x]<9)
            print(" ")
            end
            print(" ")
        end
        println(|)
    end
    println(repeat("-",64))
end
function MixXbox(AES_SBOX, keyvector, longlenkey, round=0)
    # Create a copy to work with
    mixed_sbox = copy(AES_SBOX)
    
    # Generate a unique permutation for this round/key combination
    permutation = Vector{UInt8}(0x00:0xff)
    
    # Fisher-Yates shuffle using key bytes as randomness source
    for i in 256:-1:2
        # Get key-based random index (ensure good distribution)
        key_pos = (round * 32 + i) % longlenkey + 1
        key_byte = keyvector[key_pos]
        j = (key_byte % i) + 1  # j in range [1, i]
        
        # Swap elements to shuffle
        permutation[i], permutation[j] = permutation[j], permutation[i]
    end
    
    # Apply the permutation to create mixed S-box
    temp_sbox = copy(mixed_sbox)
    for i in 1:256
        mixed_sbox[i] = temp_sbox[permutation[i] + 1]
    end
    
    # Verify it's still a permutation (optional but good for debugging)
    verify_sbox_bijection(mixed_sbox)
    
    # Generate the inverse S-box
    mixed_inv_sbox = zeros(UInt8, 256)
    for i in 0x00:0xff
        original_byte = UInt8(i)
        substituted_byte = mixed_sbox[original_byte + 1]
        mixed_inv_sbox[substituted_byte + 1] = original_byte
    end
    
    return mixed_sbox, mixed_inv_sbox
end

function MixXbox(AES_SBOX, keyvector, longlenkey, round=0)
    mixed_sbox = copy(AES_SBOX)
    
    # Generate mixing value from key
    mix_val = UInt8(0)
    for i in 1:min(8, longlenkey)
        key_idx = (round * 8 + i) % longlenkey + 1
        mix_val ⊻= keyvector[key_idx]
    end
    
    # Apply XOR mixing (this preserves the permutation property)
    for i in 1:256
        mixed_sbox[i] ⊻= mix_val
    end
    
    # Generate inverse S-box
    mixed_inv_sbox = zeros(UInt8, 256)
    for i in 0x00:0xff
        mixed_inv_sbox[mixed_sbox[i + 1] + 1] = UInt8(i)
    end
    
    return mixed_sbox, mixed_inv_sbox
end
function remove_trailing_zeros(arr)
    idx = findlast(x -> x != 0x00, arr)
    return idx === nothing ? UInt8[] : arr[1:idx]
end
function Encrypt(vectorsmg,keystr)
    keyvector=Vector{UInt8}(keystr)
    AES_SBOX,AES_INV_SBOX=getSbox()
    matrix,lenmatrix,packedkey=GenerateStructure(vectorsmg,keyvector)
    keylen=length(packedkey)
    longlenkey=length(keyvector)
    for i in 1:1000
        AES_SBOX,AES_INV_SBOX=MixXbox(AES_SBOX,keyvector,longlenkey,i)
        matrix.=AES_SBOX[matrix .+ 1]
        ShiftRows!(matrix,keyvector,longlenkey,i,lenmatrix)
        AddRoundKey!(matrix,keyvector,lenmatrix,longlenkey)
        Avalanche!(matrix)
    end
    vectorout=DeGenerateStructure(matrix)
    return vectorout
end

function Decrypt(vectorsmg,keystr)
    
    keyvector=Vector{UInt8}(keystr)
    AES_SBOX,AES_INV_SBOX=getSbox()
        matrix,lenmatrix,packedkey=GenerateStructure(vectorsmg,keyvector)
        keylen=length(packedkey)
        longlenkey=length(keyvector)
        arrAES_INV_SBOX=[]
        
        for i in 1:1000
            AES_SBOX,AES_INV_SBOX=MixXbox(AES_SBOX,keyvector,longlenkey,i)
            push!(arrAES_INV_SBOX, copy(AES_INV_SBOX))
        end
        for i in 1000:-1:1
            UnAvalanche!(matrix)
            UnAddRoundKey!(matrix,keyvector,lenmatrix,longlenkey)
            UnShiftRows!(matrix,keyvector,longlenkey,i,lenmatrix)
            matrix.=arrAES_INV_SBOX[i][matrix .+ 1]
        end
        vectorout=remove_trailing_zeros(DeGenerateStructure(matrix))
    return vectorout
end
end