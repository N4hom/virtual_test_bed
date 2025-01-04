
[MultiApps]
  [radiation_problem]
    type = FullSolveMultiApp
    input_files = 'testRadiation.i'
    execute_on = 'TIMESTEP_END' # Options:FORWARD, ADJOINT, HOMOGENEOUS_FORWARD, ADJOINT_TIMESTEP_BEGIN, ADJOINT_TIMESTEP_END, NONE, INITIAL, LINEAR, NONLINEAR, POSTCHECK, TIMESTEP_END, TIMESTEP_BEGIN, MULTIAPP_FIXED_POINT_END, MULTIAPP_FIXED_POINT_BEGIN, FINAL, CUSTOM
  []
[]

[Transfers]
    [get_G]
      type = MultiAppCopyTransfer
      from_multi_app = radiation_problem
      source_variable = 'G'
      variable = 'G'
      #execute_on = 'TIMESTEP_END'
    []
    [send_T]
      type = MultiAppCopyTransfer
      to_multi_app = radiation_problem
      source_variable = 'temperature'
      variable = 'T_radiation'
      #execute_on = 'TIMESTEP_END'
    []
[]

[Debug]
  # show_execution_order = ALWAYS
  # show_actions = true
  # show_var_residual_norms = true
[]