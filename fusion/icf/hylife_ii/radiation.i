# I don't know if I'm using the same mesh or if this is a copy.
# This is likely a copy. Not an issue for a small case like this 
# but a different way must be found in 3D problems 

!include mesh.i



# Define constants for the P1 model
P1_sigma_scattering = 0
opacity = 100
wall_temperature = 909
[AuxVariables]
    # Define variable holder to transfer from Euler solver
    [T_radiation]
        family = MONOMIAL
        order = CONSTANT
        fv = true
        # initial_condition = 5e4
      []
    
    # Scaled temperature to be used in the P1 solver 
    [T_radiation_scaled]
        family = MONOMIAL
        order = CONSTANT
        fv = true
    []

    # Variable that holds the non-normalized radiation intensity to be given back to the Euler solver
    [G]
        family = MONOMIAL
        order = CONSTANT
        fv = true
    []


[]

[Variables]
    # Normalized radiation intensity that holds the solution
    [G_scaled]
        family = MONOMIAL
        order = CONSTANT
        fv = true
        # initial_condition = 1e2
    []
[]

[Postprocessors]
    # To check if transfer occurs properly
    [T_radiation_center]
        type = PointValue
        point = '0 0 0'
        variable = T_radiation
        execute_on = 'initial nonlinear'
        # outputs = none 
    []
    

    [T_radiation_center_scaled]
        type = PointValue
        point = '0 0 0'
        variable = T_radiation_scaled
        execute_on = 'initial nonlinear'
        #outputs = none 
    []

    [average_T]
        type = ElementAverageValue
        variable = T_radiation
        execute_on = 'initial nonlinear'
        outputs = none 
    []

    [norm_T]
        type = ParsedPostprocessor
        pp_names = 'T_radiation_center'
        expression = 'abs(1.0 / 1e3)'
        execute_on = 'initial nonlinear'
        outputs = none 
    []
    [norm_G]
        type = ParsedPostprocessor
        pp_names = 'norm_T'
        expression = '(1.0 / norm_T^4)'
        execute_on = 'initial nonlinear'
        outputs = none 
    []
    
    # Check is P1 is solved
    [G_scaled_radiation_center]
        type = PointValue
        point = '0 0 0'
        variable = G_scaled
        # outputs = none 
    []

    [G_radiation_center]
        type = PointValue
        point = '0 0 0'
        variable = G
        # outputs = none 
    []
[]

[FVKernels]
    # The equation solves for the scaled radiation intensity
    [G_diff]
        type = FVDiffusion
        coeff = 1
        variable = G_scaled
    []
    [source_and_sink]
        type = FVThermalRadiationSourceSink
        variable = G_scaled
        temperature_radiation = 'T_radiation_scaled'
        opacity = ${opacity}
      []
[]


[FVBCs]
    [boundaries_bc]
      type = FVMarshakRadiativeBC
      boundary = 'slabs jets wall'
      variable = G_scaled
      temperature_radiation = ${fparse wall_temperature * 1e-3}
      coeff_diffusion = 'diff_coef_AD'
      boundary_emissivity = 1
    []
  []


[Materials]
    [diff_coef_AD]
      type = ADRadiativeP1DiffusionCoefficientMaterial
      opacity = ${opacity}
      sigma_scat_eff = ${P1_sigma_scattering}
      P1_diff_coef_name = 'diff_coef_AD'
    []
  
  []

[AuxKernels]
    [compute_T_radiation_scaled]
      type = FunctorAux
      variable = T_radiation_scaled
      functor = T_radiation
      factor = 'norm_T'
      execute_on = 'INITIAL TIMESTEP_BEGIN TIMESTEP_END'
    []
    [compute_G]
      type = FunctorAux
      variable = G
      functor = G_scaled
      factor = 'norm_G'
      execute_on = 'TIMESTEP_END'
    []
  []

[Executioner]
    type = Steady
    solve_type = NEWTON
    petsc_options_iname = '-pc_type -pc_factor_shift_type'
    petsc_options_value = 'lu NONZERO'
    nl_abs_tol = 1e-9
    nl_rel_tol = 1e-9
[]

[Outputs]
    [exodus]
        type = Exodus
        time_step_interval = 1
        file_base = 'postProcessing/radiation_out'
    []
    [csv]
        type = CSV
        file_base = 'postProcessing/radiation_out'
    []
[]



  