[Postprocessors]
  [./cfl_dt]
    type = ADCFLTimeStepSize
    c_names = 'sound_speed'
    vel_names = 'speed'
    CFL = 0.01
    outputs = none 
  [../]

  [drag_jets_x]
    type = IntegralDirectedSurfaceForce
    vel_x = 0
    vel_y = 0
    mu = 0
    pressure = p
    principal_direction = '1 0 0'
    boundary = 'jets'
    # outputs = none # Outputs #idk
  []

  [drag_jets_y]
    type = IntegralDirectedSurfaceForce
    vel_x = 0
    vel_y = 0
    mu = 0
    pressure = p
    principal_direction = '0 1 0'
    boundary = 'jets'
    # outputs = none #  Outputs #idk
  []

 

  [drag_slabs_x]
    type = IntegralDirectedSurfaceForce
    vel_x = 0
    vel_y = 0
    mu = 0
    pressure = p
    principal_direction = '1 0 0'
    boundary = 'slabs'
    # outputs = none #  Outputs #idk
  []

  [drag_slabs_y]
    type = IntegralDirectedSurfaceForce
    vel_x = 0
    vel_y = 0
    mu = 0
    pressure = p
    principal_direction = '0 1 0'
    boundary = 'slabs'
    # outputs = none # Outputs #idk
  []

  [temperature_center]
    type = PointValue
    point = '0 0 0'
    variable = temperature
    #outputs = none 
  []

  [G_center]
    type = PointValue
    point = '0 0 0'
    variable = G
    # outputs = none 
  []

  [temperatureCheck]
    type = PointValue
    point = '0 0 0'
    variable = temperatureCheck
    # outputs = none 
  []

  [pressure_center]
    type = PointValue
    point = '0 0 0'
    variable = p
    # outputs = none 
  []

  [rho_E_center]
    type = PointValue
    point = '0 0 0'
    variable = rho_E
    # outputs = none 
  []

  # [radSource_center]
  #   type = PointValue
  #   point = '0 0 0'
  #   variable = rad_source
  #   # outputs = none 
  # []

  # [norm_G]
  #   type = ParsedPostprocessor
  #   pp_names = 'norm_T'
  #   expression = '(1.0 / norm_T)^4'
  #   execute_on = 'initial nonlinear'
  # []

  [residual_mass]
    type = ElementIntegralFunctorPostprocessor
    prefactor = inner_chamber_zone
    functor = rho
    # outputs = none 
  []


  [impSourceCoeff_center]
    type = PointValue
    point = '0 0 0'
    variable = implicitSourceCoeff
    # execute_on = 'initial'
    # outputs = none 
  []

  [impSource_center]
    type = PointValue
    point = '0 0 0'
    variable = implicitSource
    # execute_on = 'initial'
    # outputs = none 
  []

  [expSource_center]
    type = PointValue
    point = '0 0 0'
    variable = explicitSource
    # outputs = none 
  []

[]

[Outputs]
  [exodus]
    type = Exodus
    time_step_interval = 100
    file_base = 'postProcessing_rad/output'
  []
  [csv]
    type = CSV
    time_step_interval = 10
    file_base = 'postProcessing_rad/force'
  []  
[]


[Executioner]
    type = Transient
    end_time = 500e-6
    solve_type = LINEAR
    [TimeIntegrator]
      type = ActuallyExplicitEuler
    []
    # l_tol = 1e-3
    # petsc_options_iname = '-ksp_type  -pc_type -pc_factor_shift_type'
    # petsc_options_value = 'cg bjacobi NONZERO'
    # nl_abs_tol = 1e-6
    # nl_rel_tol = 1e-6
  
    [./TimeStepper]
      type = PostprocessorDT
      postprocessor = cfl_dt
    [../]

      dtmin = 1e-13
  []