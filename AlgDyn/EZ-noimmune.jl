using AlgebraicDynamics
using Catlab.WiringDiagrams, Catlab.Programs, Catlab.Graphics

using LabelledArrays
using OrdinaryDiffEq, Plots, Plots.PlotMeasures

#----------------------------------------------#
    # Defining the Blueprint (syntax) #
#----------------------------------------------#

# Define the composition patternß
blueprint = @relation (Effectors,Zombies) begin
    Effector(Effectors) # box_name(junction_name)
    WarZone(Effectors,Zombies)
    Zombie(Zombies)
end

#Draw the undirected wiring diagram
to_graphviz(blueprint, box_labels=:name, junction_labels=:variable)

#----------------------------------------------#
    # Defining the building blocks (semantics) #
#----------------------------------------------#

# Define the primitive systems
dotE(u,p,t) = p.e_production - p.e_decline*u[1] 
dotET(u,p,t) = [(p.p1*u[1]*u[2])/(p.g1+u[2])- p.m*u[1]*u[2], -p.t_killing*u[1]*u[2]]
dotT(u,p,t) = p.t_production * u[1] # * (1 - u[1]*p.envCapacity) 

# Put a box around each of these dyanmics
effectors = ContinuousResourceSharer{Float64}(1, dotE)
warzone = ContinuousResourceSharer{Float64}(2, dotET)
zombies = ContinuousResourceSharer{Float64}(1, dotT)

#--------------------------------------------------------#
  # Superposing the building blocks on the blue print #
#--------------------------------------------------------#
# Compose
defense_system = oapply(blueprint, [effectors, warzone, zombies])

#-------------------------------------------------------------#
  # Setting initial values of the system, setting parameters #
#-------------------------------------------------------------#
# Solve and plot

#= 1. Stable set of parameters =#

#  try changing production rate in the range 0.5 to 2
#  try changing effector decline rate 0.07 - 0.37 .. None of these changes
#  what if zombies can never kill the effectors

#=
u0 = [1, 1]  # try setting initial zombies to 0.1
 #1.131
params = LVector(e_production=0.5,  
    p1=1.131, 
    g1=20.19,  
    m=  0.00311, # 0.00311% of every possible pair of E-Z manages to deactivate effector
    e_decline=0.37,  # 37% of effectors die
    t_killing= 0.22, # 22% of every possible pair of E-Z manages to lethally hit the zombie
    t_production=1.2, # 1.636 times the current population; the population more than doubles
    envCapacity=2.0*10^(-3))  # the environment supports 500
=# 

u0 = [1, 100]  # try setting initial zombies to 0.1
    #1.131
    params = LVector(e_production=0.5,  
    p1=1.131, 
    g1=20.19,  
    m=  0.00311, # 0.00311% of every possible pair of E-Z manages to deactivate effector
    e_decline=0.37,  # 37% of effectors die
    t_killing= 0.22, # 22% of every possible pair of E-Z manages to lethally hit the zombie
    t_production=1.2, # 1.636 times the current population; the population more than doubles
    envCapacity=2.0*10^(-3))  # the environment supports 500


# can the zombies be killed forever? No! 

# What if the receving help is set to zero? If p1 is set to zero, then the zombies win in to no time

# What if the city manufactures 100% of effectors? 

# What if the city manages to manufacture effectors with better battery? 

# what if we start 0.1 Zombie? Then strangely the least value increases
# The more zombies, the effectors kill them effectively

tspan = (0.0, 365.0) # need to understand what this is!



#-------------------------------------------------------------------------------------#
  # The computer simulates the evolution of the system starting from initial values #
#-------------------------------------------------------------------------------------#
#solving differential equation 
prob = ODEProblem(defense_system, u0, tspan,params)
sol = solve(prob, Tsit5())

#---------------------------------------#
  # Visualize the system evolution #
#---------------------------------------#
# Visualizing the solution
days = length(sol)
x=range(1, days,length= days)
y = first(map(last,sol),length(x))
plot(x,y, ylabel="Cells population", xlabel="days", label="tumor", xticks = 0:10:length(x))


z = first(map(first,sol),length(x))
plot!(x,z, ylabel="Cell population", xlabel="days", label="effector")