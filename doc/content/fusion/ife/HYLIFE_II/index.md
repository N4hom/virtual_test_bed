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

!media media/fusion/ife/hylife_ii/hylife_ii_mesh.png
  id=fig:mesh
  caption=2D monoblock: (left) geometry and mesh; (right) temperature distribution.
  style=display:block;margin-left:auto;margin-right:auto;width:50%

The mesh was generated using the open-source tool Salome.

### Nomenclature of variables and physical parameters

!style halign=left
[tab:variables] lists the variables and physical parameters used in this example with their units.

!table id=tab:variables caption=Nomenclature of variables and physical parameters used in this example.
| Symbol | Variable or Physical Property | Unit |
| --- | --- | --- |
| $C_s$ | Concentration of solute (mobile) species | m$^{−3}$ |
| $C_t$ | Concentration of trapped species | m$^{−3}$ |
| $T$ | Temperature | K |
| $D$ | Diffusivity of solute (mobile) species | m$^{2}$ s$^{-1}$ |
| $K_s$ | Solubility of solute (mobile) species | m$^{−3}$ Pa$^{-1/2}$ |
| $C_{total}$ | Total concentration of species $C_{total}=C_s + C_t$ | m$^{−3}$ |
| $C_t^e$ | Concentration of empty trapping sites | m$^{−3}$ |
| $C_t^0$ | Concentration of trapping sites $C_t^e=C_t^0-C_t$ | m$^{−3}$ |
| $\alpha_t$ | Trapping rate coefficient, $2.75 \times 10^{11}$ | s$^{−1}$ |
| $\alpha_r$ | Release rate coefficient $\alpha_r=\alpha_{r0} \exp⁡((-E_{dt})/(k_b T))$ | s$^{−1}$ |
| $\alpha_{r0}$ | Pre-exponential factor, $8.40 \times 10^{12}$ | s$^{−1}$ |
| $E_{dt}$ | Detrapping energy | eV |
| $N$ | Atomic number density | m$^{−3}$ |
| $\rho$ | Density | g m$^{-3}$ |
| $c_p$ | Specific heat | J kg$^{-1}$ K$^{-1}$ |
| $k_T$ | Thermal conductivity | W m$^{-1}$ K$^{-1}$ |


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


!style halign=left
To simulate tritium and thermal transport, we define two sets of [!ac](PDEs).
First, the strong form of the mass conservation equation for solute (mobile) T atoms, $C_s$, is written as:

\begin{equation} \label{eq:concentration}
\frac{\partial C_s}{\partial t} + \nabla \cdot (-D \nabla C_s) + \alpha_t \frac{C_t^e}{N} C_s - \alpha_r C_t = 0.
\end{equation}

We use three sets of mass conservation equations to calculate the behaviors of solute T atoms in three different materials (i.e., W, Cu, CuCrZr).
Second, the strong form of the conservation of energy equation is written as:

\begin{equation} \label{eq:temperature}
\rho c_p \frac{\partial T}{\partial t} - \nabla \cdot (k_T \nabla T) = 0.
\end{equation}



Then, to solve for the [!ac](PDEs) and physical phenomena, we can select appropriate kernels and boundary conditions (BCs) from MOOSE’s extensive library. The following three subsections describe each kernel, BC, and numerical method utilized in the present work.

In the input file, the variables are defined as:

!listing fusion/mcf/divertor_monoblock/divertor_monoblock.i link=false block=Variables

Note the usage of `initial_condition` and `block` parameters in order to set initial conditions and material block applicability for each variable.


### Kernels

!style halign=left

The equations are solved using the HLLC flux scheme (ref). The HLLC kernel is applied to each component of the state vector $\textbf{U}$: [CNSFVMassHLLC](https://mooseframework.inl.gov/source/kernels/xxx.html), [CNSFVMomentumHLLC](https://mooseframework.inl.gov/source/kernels/xxx.html) and [CNSFVEnergyHLLC](https://mooseframework.inl.gov/source/kernels/xxx.html) for mass, momentum and energy equation. 

The P-1 model is solved using the diffusion kernel and the heat sink/source term

!listing fusion/mcf/divertor_monoblock/divertor_monoblock.i link=false block=Kernels

[NodalKernels](https://mooseframework.inl.gov/syntax/NodalKernels/index.html) are used for non-diffusive variables (trapped species).

!listing fusion/mcf/divertor_monoblock/divertor_monoblock.i link=false block=NodalKernels


### AuxVariables and AuxKernels

!style halign=left
[AuxVariables](https://mooseframework.inl.gov/syntax/AuxVariables/index.html) are used to track quantities that are not solved for by the [!ac](PDEs),
but are needed to compute materials properties,
or are desirable to obtain as outputs, such as the total concentration of tritium or flux values.
[AuxKernels](https://mooseframework.inl.gov/syntax/AuxKernels/index.html) provide the expressions that define the `AuxVariables`.

!listing fusion/mcf/divertor_monoblock/divertor_monoblock.i link=false block=AuxVariables

!listing fusion/mcf/divertor_monoblock/divertor_monoblock.i link=false block=AuxKernels


### Initial conditions

!style halign=left
For the mass conservation equation, we use [FunctionNeumannBC](https://mooseframework.inl.gov/source/bcs/FunctionNeumannBC.html) and [DirichletBC](https://mooseframework.inl.gov/source/bcs/DirichletBC.html) to solve the 2$^{\text{nd}}$ term of [eq:concentration_weak].
`FunctionNeumannBC` is used to treat the time-dependent plasma exposure at the top (plasma-exposed) surface,
and `DirichletBC` is used to set the BC of the solute T atom concentration to zero at the inner CuCrZr tube (at $r = 6$ mm).
For the energy conservation equation, we use `FunctionNeumannBC` and `DirichletBC` to solve the 2$^{\text{nd}}$ term of [eq:temperature_weak].
`FunctionNeumannBC` is used to treat the time-dependent heat flux at the top (plasma-exposed) surface,
and [FunctionDirichletBC](https://mooseframework.inl.gov/source/bcs/FunctionDirichletBC.html) is used to treat the temperature increase in the cooling tube.
`FunctionNeumannBC`, `FunctionDirichletBC`, `DirichletBC`, and `FunctionDirichletBC` are MOOSE objects commonly used to represent the BCs of the variables to be solved.

We simulate a 20,000-second plasma discharge, with each 1,600-second cycle consisting of a 100-second plasma ramp-up,
a 400-second steady-state plasma discharge, a 100-second plasma ramp-down, and a 1,000-second waiting phase.
Up to 50 cycles are simulated to achieve the total discharge.
[fig:tritium_temperature_history] shows the integrated (solute, total and trapped) tritium concentration profiles in the monoblock.
It shows that implantation fluxes and temperatures vary linearly up to (from) their steady-state values from (up to) their initial values during ramp-up (ramp-down).

!media media/fusion/mcf/divertor_monoblock/divertor_monoblock_history.png
  id=fig:tritium_temperature_history
  caption=Temperature profiles (orange) and integrated tritium concentration profiles (blue) during two 1,600-second-cycle plasma discharges. This corresponds to Fig. 2 in [!cite](Shimada2024114438).
  style=display:block;margin-left:auto;margin-right:auto;width:60%

During the steady-state plasma discharge, we set a heat flux of 10 MW$\cdot$m$^{-2}$ at the top of the 2D monoblock (at $y = 14.0$ mm)
and a cooling temperature of 552 K at the inner CuCrZr tube (at $r = 6.0$ mm).
We assume a 100% T plasma with a 5.0 $\times$ 10$^{23}$ m$^{-2}$$\cdot$s$^{-1}$ plasma particle flux
(which is half of the full 1.0 $\times$ 10$^{24}$ m$^{-2}$$\cdot$s$^{-1}$ DT plasma particle flux),
and only 0.1% of the incident plasma particle flux (5.0 $\times$ 10$^{20}$ m$^{-2}$$\cdot$s$^{-1}$)
entered the first layer of mesh at the exposed surface ($y = 14.0$ mm) as in [!cite](Shimada2024114438).
The solute T atom concentration is set to zero at the inner CuCrZr tube (at $r = 6.0$ mm).

We treated this plasma exposure by setting the flux BC of the
solute T atom concentration at the exposed surface ($y = 14.0$ mm)
as a simplification of the complex plasma implantation and recombination phenomena,
which would require a very fine mesh and increase computational costs.

!listing fusion/mcf/divertor_monoblock/divertor_monoblock.i link=false block=BCs



## Results

!style halign=left
The simulation results from this example are shown in [fig:results2D_a] and [fig:results2D_b].
For more results, information, and discussion about the results for this example case and
their significance, the reader is referred to [!cite](Shimada2024114438).

!media media/fusion/mcf/divertor_monoblock/divertor_monoblock_results_2D_a.png
  id=fig:results2D_a
  caption=Tritium concentration profile in W (left), Cu (center), and CuCrZr (right) after ten 1,600-second cycles ($t = 14912$ s). This corresponds to Fig. 4A in [!cite](Shimada2024114438).
  style=display:block;margin-left:auto;margin-right:auto;width:40%

!media media/fusion/mcf/divertor_monoblock/divertor_monoblock_results_2D_b.png
  id=fig:results2D_b
  caption=Tritium concentration profile in W (left), Cu (center), and CuCrZr (right) after fifty 1,600-second cycles ($t = 78912$ s). This corresponds to Fig. 4B in [!cite](Shimada2024114438).
  style=display:block;margin-left:auto;margin-right:auto;width:40%


## Complete input file

Below is the complete input file, which can be run reliably with approximately 4 processor cores. Note that this input file has not been optimized for computational costs.

!listing fusion/mcf/divertor_monoblock/divertor_monoblock.i

!bibtex bibliography
