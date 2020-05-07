mutable struct TreeLeaf
  key::Union{Symbol,AbstractString,Number}
  value::Any
end

mutable struct TreeNode
  key::Union{Symbol,AbstractString,Number}
  children::Vector{Union{TreeNode, TreeLeaf}}
end

mutable struct TreeList
  root::Union{TreeNode, Nothing}
  nodes::Vector{Union{TreeNode, TreeLeaf}}
end

function build_node!(tree_list::TreeList, cur_key::Union{Symbol,AbstractString,Number}, nestedDict::AbstractDict)
  cur_children = []
  for (cur_key, cur_value) in nestedDict
    tmp_node = build_node!(tree_list, cur_key, cur_value)
    push!(cur_children, tmp_node)
  end

  cur_node = TreeNode(cur_key, cur_children)
  push!(tree_list.nodes, cur_node)
  return cur_node
end

function build_node!(tree_list::TreeList, cur_key::Union{Symbol,AbstractString,Number}, cur_value)
  cur_node = TreeLeaf(cur_key, cur_value)
  push!(tree_list.nodes, cur_node)
  return cur_node
end

function build_tree(nested_dict::AbstractDict)
  tree_list = TreeList(nothing, [])
  tree_list.root = build_node!(tree_list, :root, nested_dict)

  return tree_list
end

function tree_to_dict(cur_node::TreeLeaf)
  return cur_node.value
end

function tree_to_dict(cur_node::TreeNode)
  cur_dict = OrderedDict()
  for sub_node in cur_node.children
    cur_dict[sub_node.key] = tree_to_dict(sub_node)
  end
  return cur_dict
end
