# Radiation parameters
sigma = 5.670374419e-8
opacity = 100
c_v = 1784.5

radius_zone_interest = 0.4

[Functions]
  [inner_chamber]
    type = ParsedFunction
    expression = 'if((x*x + y*y)<${fparse radius_zone_interest * radius_zone_interest }, 1, 0)'
    execute_on = 'TIMESTEP_END'
  []
[]

[FluidProperties]
    [./fp]
      type = IdealGasFluidProperties
      molar_mass = 0.007
      gamma = 1.667 # Monoatomic gas (ionized Flibe)
      #allow_imperfect_jacobians = true
    [../]
[]


[Materials]
    [./var_mat]
      type = ConservedVarValuesMaterial
      rho = rho
      rhou = rho_u
      rhov = rho_v
      # rhow = rho_w
      rho_et = rho_E
      fp = fp
    [../]
    [./sound_speed]
      type = SoundspeedMat
      fp = fp
    [../]

    [temperature_mat]
        type = ADParsedMaterial
        property_name = 'temperature_mat'
        coupled_variables = 'rho rho_u rho_v rho_E'
        expression = '(rho_E - 0.5 * (rho_u^2 + rho_v^2) / rho) / ${c_v}'
        # outputs = none
    []
    # [radiation_source]
    #   type = ADParsedFunctorMaterial
    #   property_name = 'rad_source'
    #   functor_names = 'temperature'
    #   functor_symbols = 'T'
    #   expression = '${sigma} * T^4'
    #   outputs = none
    # []


[]

[Variables]
    [./rho]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    [../]
    [./rho_u]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    [../]
    [./rho_v]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    [../]
    # [./rho_w]
    #   order = CONSTANT
    #   family = MONOMIAL
    #   fv = true
    # [../]
    [./rho_E]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    [../]

[]

[AuxVariables]
    [./Ma]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    [../]

    [./p]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    [../]

    [./v_norm]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    [../]

    [./temperature]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    [../]

    [./temperatureCheck]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    [../]

    [explicitSource]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    []

    [implicitSourceCoeff]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    []

    [implicitSource]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    []

    [./internal_energy]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    [../]

    [G]
      order = CONSTANT
      family = MONOMIAL
      fv = true
    [../]


    [inner_chamber_zone]
    []

[]

[AuxKernels]
    [./Ma_aux]
      type = NSMachAux
      variable = Ma
      fluid_properties = fp
      use_material_properties = true
    [../]

    [./p_aux]
      type = ADMaterialRealAux
      variable = p
      property = pressure
    [../]

    [./v_norm_aux]
      type = ADMaterialRealAux
      variable = v_norm
      property = speed
    [../]

    [./temperature_aux]
      type = ADMaterialRealAux
      variable = temperature
      property = T_fluid
    [../]

    [./temperatureCheck_aux]
      type = ADMaterialRealAux
      variable = temperatureCheck
      property = temperature_mat
    [../]

    [./internal_energy_aux]
      type = InternalEnergyAux
      variable = internal_energy
      density = rho
      pressure = p
      fp = fp
    [../]

    [inner_chamber]
      type = FunctionAux
      variable = inner_chamber_zone
      function = inner_chamber
    []

    [populate_explicitSource]
      type = ParsedAux
      variable = explicitSource
      coupled_variables = 'temperature G v_norm'
      expression = '${opacity} * (abs(G) + G/(G+1) * ${sigma} * temperature^3 / ${c_v} * 0.5 * v_norm^2)'
      # execute_on = 'LINEAR'
    []

    [populate_implicitSourceCoeff]
      type = ParsedAux
      variable = implicitSourceCoeff
      coupled_variables = 'rho temperature G'
      expression = 'G/(G+1) * ${opacity} * ${sigma} * temperature^3 / ${c_v}/ rho'
      # bexecute_on = 'LINEAR'
    []
    [populate_implicitSource] # For postprocessing only
      type = ParsedAux
      variable = implicitSource
      coupled_variables = 'rho temperature rho_E G'
      expression = 'G/(G+1) * ${opacity} * ${sigma} * temperature^3 / ${c_v}/ rho * rho_E'
      # execute_on = 'LINEAR'
    []

    # [populate_implicitSourceCoeff]
    #   type = ParsedAux
    #   variable = implicitSourceCoeff
    #   coupled_variables = 'rho temperature'
    #   expression = '0 * ${opacity} * ${sigma} * temperature^3 / ${c_v}/ rho'
    #   execute_on = 'INITIAL LINEAR'
    # []

    # [populate_explicitSource]
    #   type = ParsedAux
    #   variable = explicitSource
    #   coupled_variables = 'temperature G v_norm'
    #   expression = '${opacity} * (G - G/(G+1) * ${sigma} * temperature^4)'
    #   execute_on = 'INITIAL LINEAR'
    # []

    # [populate_implicitSource] # For postprocessing only
    #   type = ParsedAux
    #   variable = implicitSource
    #   coupled_variables = 'rho temperature rho_E'
    #   expression = '0 * ${opacity} * ${sigma} * temperature^3 / ${c_v}/ rho * rho_E'
    #   execute_on = 'INITIAL LINEAR'
    # []

[]

[FVKernels]
    [./mass_time]
        type = FVTimeKernel
        variable = rho
    [../]

    [./mass_advection]
        fp = fp
        type = CNSFVMassHLLC
        variable = rho
    [../]

    [./momentum_x_time]
        type = FVTimeKernel
        variable = rho_u
    [../]

    [./momentum_x_advection]
        fp = fp
        type = CNSFVMomentumHLLC
        variable = rho_u
        momentum_component = x
    [../]

    [./momentum_y_time]
        type = FVTimeKernel
        variable = rho_v
    [../]

    [./momentum_y_advection]
        fp = fp
        type = CNSFVMomentumHLLC
        variable = rho_v
        momentum_component = y
    [../]

    # [./momentum_z_time]
    #     type = FVTimeKernel
    #     variable = rho_w
    # [../]

    # [./momentum_z_advection]
    #     type = CNSFVMomentumHLLC
    #     fp = fp
    #     variable = rho_w
    #     momentum_component = z
    # [../]

    [./fluid_energy_time]
        type = FVTimeKernel
        variable = rho_E
    [../]

    [./fluid_energy_advection]
        fp = fp
        type = CNSFVFluidEnergyHLLC
        variable = rho_E
    [../]

      # [radiation_absorption]
      #   type = FVCoupledForce
      #   variable = rho_E
      #   v = G #G
      #   coef = ${opacity}
      # []
      # [radiation_emmision_exp]
      #   type = FVCoupledForce
      #   variable = rho_E
      #   v = rad_source
      #   coef = ${fparse -opacity}
      # []
      # [radiation_emmision_imp]
      #   type = FVCoupledForce
      #   variable = rho_E
      #   v = 'explicitSource'
      # []
      [radiation_emmision_imp]
        type = FVNonUniformReaction
        variable = rho_E
        rateFunctor = 'implicitSourceCoeff'
      []
      [radiation_emmision_exp]
        type = FVNonUniformBodyForce
        variable = rho_E
        functor = 'explicitSource'
      []


[]

[FVBCs]
    [./mom_x_pressure]
        type = CNSFVMomImplicitPressureBC
        variable = rho_u
        momentum_component = x
        boundary = 'symmetry_xz symmetry_yz slabs jets'
    [../]

    [./mom_y_pressure]
        type = CNSFVMomImplicitPressureBC
        variable = rho_v
        momentum_component = y
        boundary = 'symmetry_xz symmetry_yz slabs jets'
    [../]

    # [./mom_z_pressure]
    #     type = CNSFVMomImplicitPressureBC
    #     variable = rho_w
    #     momentum_component = z
    #     boundary = 'symmetry_xz symmetry_yz top slabs_surface jets_surface'
    # [../]
[]



