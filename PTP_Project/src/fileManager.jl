module fileManager
#need to complete tree stuff to make it send and use trees instead of list_directory
#
include("naryTree.jl") 
using .naryTree
export  list_directory,get_folder_bytes,save_file_bytes
    function list_directory(dir_path, indent="")
        root=populate_directory_tree(dir_path)
        return tostring(root)
    end
    #=
    function list_directory(dir_path, indent="")
        items = readdir(dir_path)
        thisstr=""
        for item in items
            full_path = joinpath(dir_path, item)
            #println(indent * item)
            thisstr*="\n"*indent * item
            if isdir(full_path)
                thisstr*=list_directory(full_path, full_path * "\\") # Increase indent for subdirectories
            end
        end
        return thisstr
    end=#
    
function populate_directory_tree(dir_path; root=nothing, depth::Int=-1)
    if depth == 0
        return root
    end
    
    # Create root node with directory name if not provided
    if root === nothing
        root = node(basename(dir_path))
    end
    
    items = readdir(dir_path)
    
    for item in items
        full_path = joinpath(dir_path, item)
        
        # Create child node and add to root
        child_node = node(item)
        push!(root.children, child_node)
        
        if isdir(full_path)
            # Recursively populate THIS child node with its contents
            populate_directory_tree(full_path, root=child_node, depth=depth-1)
        end
        # If it's a file, we leave it as a leaf node (no children)
    end
    return root
end
    function get_file_bytes(file_path)
        if (!isdir(file_path))
            bytes = read(file_path)
            return bytes
        else 
            return "that is not a file, that is a folder"
        end
    end

    function save_file_bytes(file_name,bytes)    
        downloads_path = joinpath(homedir(), "Downloads")*"\\"*file_name
        println(downloads_path)
        open(downloads_path, "w") do f
            write(f, bytes)
        end
        println("saved bytes to: "*downloads_path)
    end

    function parse_tree_from_string(tree_string::String)
    lines = split(strip(tree_string), '\n')
    isempty(lines) && return node("")
    
    root = node("root")  # Default root name
    stack = [(root, -1)]  # Start with negative indent for root
    
    for line in lines
        if isempty(strip(line))
            continue
        end
        
        # Parse indentation and content
        indent_match = match(r"^(\s*)(.*)$", line)
        indent = length(indent_match.captures[1])
        name = strip(indent_match.captures[2])
        
        # Find the correct parent
        while !isempty(stack) && stack[end][2] >= indent
            pop!(stack)
        end
        
        parent_node, _ = stack[end]
        new_node = node(name)
        push!(parent_node.children, new_node)
        push!(stack, (new_node, indent))
    end
    
    return root

end
    treestr=list_directory(".","")
    tree=parse_tree_from_string(treestr)
    println(tostring(tree,3))
end