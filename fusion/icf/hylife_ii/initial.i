# # for ease of readability
# # r = sqrt(x^2 + y^2)
# # cosTheta = x/r
# # sinTheta = y/r

# #gamma = 1.667 # ideal monoatomic gas

# #invGammaM1 = ${fparse 1 / (1.667 - 1)}
# u_max = 2.2e3
# rho_max = 12
# rho0 = 1
# p_max = 1e8
# #rhoek_max = ${0.5 * ${rho_max} * ${u_max}^2}
# #rhoe_max = ${fparse p_max/(1.667 - 1)}
# #rhoE_max = ${fparse rhoe_max + rhoek_max }
# #p_undisturbed = 1e4
# #rhoE_undisturbed = ${fparse 1e4 / ${invGammaM1}}

# [Functions]
#   [./rho_ic]
#     type = ParsedFunction
#     expression = 'if ((x^2+y^2)^0.5 < 0.42 & (x^2+y^2)^0.5 > 0.3 , ${rho_max}, ${rho0})'
#   [../]
#   [./rhoU_ic]
#     type = ParsedFunction
#     expression = 'if ((x^2+y^2)^0.5 < 0.3 , ${rho0} * ${u_max} * x/0.3, if ((x^2+y^2)^0.5 < 0.42 , ${rho_max} * ${u_max} * x / (x^2+y^2)^0.5 , 0))'
#   [../]
#   [./rhoV_ic]
#     type = ParsedFunction
#     expression = 'if ((x^2+y^2)^0.5 < 0.3 , ${rho0} * ${u_max} * y/0.3, if ((x^2+y^2)^0.5 < 0.42 , ${rho_max} * ${u_max} * y / (x^2+y^2)^0.5 , 0))'
#   [../]
#   [./rhoE_ic]
#     type = ParsedFunction
#     expression = 'if ((x^2+y^2)^0.5 < 0.3 , ${p_max}/(1.6667-1) + ${fparse 0.5 * ${rho_max} * ${u_max}^2} * ((x^2 + y^2)^0.5/0.3) , if ((x^2+y^2)^0.5 < 0.42 , ${p_max}/(1.6667-1) + ${fparse 0.5 * ${rho_max} * ${u_max}^2} , ${fparse 1 / (1.667 - 1)}))'
#   [../]
#   #if ((x^2+y^2)^0.5 < 0.42 , ${p_max}/(1.6667-1) + ${fparse 0.5 * ${rho_max} * ${u_max}^2}  , ${fparse {p_undisturbed} / ${invGammaM1}})
#   # [./rhoE_ic]
#   #   type = ParsedFunction
#   #   expression = 'if ((x^2+y^2)^0.5 < 0.3 , ${p_max}/(1.6667-1) + ${fparse 0.5 * ${rho_max} * ${u_max}^2} * (x^2 + y^2)^0.5 , if ((x^2+y^2)^0.5 < 0.42 , ${p_max}/(1.6667-1) + ${fparse 0.5 * ${rho_max} * ${u_max}^2}  , ${fparse {p_undisturbed} / ${invGammaM1}}))'
#   # [../]
# []
# [ICs]
#   [./rho_ic]
#     type = FunctionIC
#     variable = rho
#     function = rho_ic
#   [../]
#   [./rho_u_ic]
#     type = FunctionIC
#     variable = rho_u
#     function = rhoU_ic
#   [../]
#   [./rho_v_ic]
#     type = FunctionIC
#     variable = rho_v
#     function = rhoV_ic
#   [../]
#   [./rho_E_ic]
#     type = FunctionIC
#     variable = rho_E
#     function = rhoE_ic
#   [../]
# []