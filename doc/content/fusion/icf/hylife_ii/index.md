# Divertor Monoblock During Pulsed Operation

*Contact: Nahom Habtemariam (nahom.habtemariam.at.tamu.edu), Pierre-Clement Simon (pierreclement.simon.at.inl.gov), Mauricio Tano Retamales (), Carlo Fiorina ()*

*Model link: [HYLIFE II]()*

!tag name=HYLIFE II
     image=https://mooseframework.inl.gov/virtual_test_bed/media/fusion/mcf/divertor_monoblock/divertor_monoblock_mesh.png
     description=Gas venting in HYLIFE II chamber
     pairs=reactor_type:fusion_ICF
                       reactor:HYLIFE II
                       geometry:chamber
                       simulation_type:fluid dynamics
                       transient:pulse
                       V_and_V:demonstration
                       codes_used:navier-stokes module
                       computing_needs:Workstation
                       fiscal_year:2024
                       sponsor:DOE_FES
                       institution:INL

The finite volume capabilities in MOOSE are used to represent a gas venting scenario in a thick wall inertial fusion chamber. This example reproduces the results presented in [!cite](ifeMOOSE).

## General description of the simulation case and corresponding input file

### Introduction

!style halign=left

One of the most critical challenges in fusion energy systems is the protection of the first wall from intense radiation pulses, a problem that arises in both inertial and magnetic confinement approaches. For some inertial fusion energy (IFE) systems, the first wall is shielded by a thick layer of molten salt or liquid metal. However, when the fusion target emits high-energy x-rays, they rapidly heat a thin surface layer of the liquid, causing explosive ablation and the subsequent formation of a gaseous phase. This newly formed gas implodes into the reactor chamber, presenting engineering and challenges. It is important to understand the behavior of the gas because: (1) it will exert a force on the remaining liquid, and possibly disrupt the original configuration; and (2) the chamber is to be cleaned up by condensation onto droplets, therefore it is essential to know where to place condensing surfaces.

If the interested reader has more questions about this example case and how to modify this input file to adapt it to a different case, feel free to reach out to the MOOSE development team on the [MOOSE GitHub discussion page](https://github.com/idaholab/moose/discussions).


### HYLIFE-II chamber geometry and mesh

!style halign=left
[fig:mesh] shows the geometry, mesh, and temperature distribution of the 2D monoblock employed in [!cite](Shimada2024114438) and in the present example.
The 2D monoblock consisted of three materials:

!media media/fusion/icf/hylife_ii/2DmeshBase.png
  id=fig:mesh
  caption=2D mesh representative of the HYLIFE-II chamber
  style=display:block;margin-left:auto;margin-right:auto;width:50%

The mesh was generated using the open-source tool Salome.

### Nomenclature of variables and physical parameters

!style halign=left


### Variables and governing equations

!style halign=left
We make use of the compressible formulation of the Navier-Stokes equations in the Navier Stokes module of MOOSE (Euler equations).
The Euler equations are commonly presented in the conservative form:
\begin{equation} \label{euler}
    \frac{\partial \textbf{U} }{\partial t} + \nabla \cdot \textbf{F}  = 0
\end{equation}

\noindent$\textbf{U}$ holds the state vector of the conserved variables (density, momentum densities and energy density) and $\textbf{F}$ the corresponding fluxes:
\begin{equation} \label{eq:U}
    \textbf{U} =    \begin{bmatrix}
                    \rho & \rho \textbf{u} & \rho E 
                    \end{bmatrix}^T
\end{equation}
\begin{equation} \label{eq:Flux}
    \textbf{F} =    \begin{bmatrix}
                    \rho \textbf{u} & \rho \textbf{u} \otimes  \textbf{u} + p & (\rho E + p) \textbf{u}
                    \end{bmatrix}^T
\end{equation}
$\rho$ is the density, $\rho\textbf{u}$ is the momentum density and $\rho E$ is the total energy density. The specific total energy $E$ is the sum of the specific internal and kinetic energy of the gas.
\begin{equation} \label{eq:total_energy}
    E = e + \frac{1}{2}|\textbf{u}|^2
\end{equation}

The system of equations is closed by an equation of state.


In the input file, the variables are defined as:
!listing fusion/icf/hylife_ii/problem.i link=false block=Variables


### Kernels

!style halign=left

The equations are solved using the HLLC flux scheme (ref). The HLLC kernel is applied to each component of the state vector $\textbf{U}$: [CNSFVMassHLLC](https://mooseframework.inl.gov/source/fvkernels/CNSFVMassHLLC.html), [CNSFVMomentumHLLC](https://mooseframework.inl.gov/source/fvkernels/CNSFVMomentumHLLC.html) and [CNSFVFluidEnergyHLLC](https://mooseframework.inl.gov/source/fvkernels/CNSFVFluidEnergyHLLC.html) for mass, momentum and energy equation. 

The P-1 model is solved using the diffusion kernel [FVDiffusion](https://mooseframework.inl.gov/source/fvkernels/FVDiffusion.html) and the heat sink/source term [FVThermalRadiationSourceSink](https://mooseframework.inl.gov/source/fvkernels/FVThermalRadiationSourceSink.html).

!listing fusion/icf/hylife_ii/problem.i link=false block=FVKernels

[NodalKernels](https://mooseframework.inl.gov/syntax/NodalKernels/index.html) are used for non-diffusive variables (trapped species).

!listing fusion/icf/hylife_ii/radiation.i link=false block=FVKernels


### AuxVariables and AuxKernels

!style halign=left
[AuxVariables](https://mooseframework.inl.gov/syntax/AuxVariables/index.html) are used to track quantities that are not solved for by the [!ac](PDEs),
but are needed to compute materials properties. Some of these properties such as pressure and temperature are used by the equations in the system.
[AuxKernels](https://mooseframework.inl.gov/syntax/AuxKernels/index.html) provide the expressions that define the `AuxVariables`.

!listing fusion/icf/hylife_ii/problem.i link=false block=AuxVariables



### Initial conditions

!style halign=left

The simulation starts as the gas rebounds back from the center of the chamber. The initial conditions are extracted from previous results in the open literature since modeling liquid wall ablation is beyond the current capabilities of the MOOSE framework.

!media media/fusion/icf/hylife_ii/ICs.png
  id=fig:tritium_temperature_history
  caption=Initial conditions of the gas at $60 \mu s$ after liquid wall ablation [!cite](glenn) [!cite](tsunami).
  style=display:block;margin-left:auto;margin-right:auto;width:60%


!listing fusion/icf/hylife_ii/initial.i link=false block=BCs


## Results

!style halign=left
The simulation results from this example are shown in [fig:results2D_a] and [fig:results2D_b].
For more results, information, and discussion about the results for this example case and
their significance, the reader is referred to [!cite](Shimada2024114438).

!media media/fusion/icf/hylife_ii/impulse_base_vs_radiation.png
  id=fig:impulse_base_vs_radiation
  caption=Impulse delivered to the liquid wall as a function of time with and without radiative heat transfer effects, for two different yields.
  style=display:block;margin-left:auto;margin-right:auto;width:40%


!bibtex bibliography
