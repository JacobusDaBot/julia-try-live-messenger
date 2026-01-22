module naryTree
export addchildtree, node, displaytree, print_tree, tostring

mutable struct node
    data::String
    children::Vector{node}
    function node(data)
        new(data, Vector{node}())  # start with empty children
    end
end

function addchildtree(root, childdata)
    push!(root.children, node(childdata))
end

function print_tree(n::node, depth::Int=-1, indent::Int=0)
    if depth == 0
        return 
    end
    println(" "^indent * string(n.data))
    for child in n.children
        print_tree(child, depth-1, indent + 2)
    end
end

function tostring(n::node, depth::Int=-1, indent::Int=0)
    if depth == 0
        return ""
    end
    strret = " "^indent * string(n.data) * "\n"
    for child in n.children
        strret *= tostring(child, depth-1, indent + 2)  # Fixed: append children after parent
    end
    return strret
end

end