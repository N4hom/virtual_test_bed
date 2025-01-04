# [Mesh]
#     [mesh]
#       type = FileMeshGenerator
#       file = 'HYLIFE_II_2D_medium.unv'
#     []
#     # When MOOSE reads the gmsh file it converts the boundaries into blocks (subdomains)
#     # that are essentially groups of faces that should be boundary. 
#     #  SideSetsAroundSubdomainGenerator converts the groups of faces into sideSets (boundaries)
#     # [merge]
#     #   type = RenameBlockGenerator
#     #   input = mesh
#     #   old_block = 'Solid_1 Solid_2'
#     #   new_block = '0 0'
#     # []

#     # construct_side_list_from_node_list=true
# []


[Mesh]
  #Serial number should match corresponding Executioner parameter
  file = multiApp_out_cp/114412
  #This method of restart is only supported on serial meshes
  # distribution = serial
[]

[Problem]
  #Note that the suffix is left off in the parameter below.
  restart_file_base = multiApp_out_cp/114412  # You may also use a specific number here
[]