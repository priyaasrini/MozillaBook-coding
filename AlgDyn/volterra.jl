using AlgebraicDynamics
using Catlab.WiringDiagrams, Catlab.Programs, Catlab.Graphics

using LabelledArrays
using OrdinaryDiffEq, Plots, Plots.PlotMeasures

#----------------------------------------------#
    # Defining the Blueprint (syntax) #
#----------------------------------------------#

# Define the composition patternß
rf = @relation (rabbits,foxes) begin
    growth(rabbits) # box_name(junction_name)
    predation(rabbits,foxes)
    decline(foxes)
end

#Draw the undirected wiring diagram
to_graphviz(rf, box_labels=:name, junction_labels=:variable)

#----------------------------------------------#
    # Defining the building blocks (semantics) #
#----------------------------------------------#

# Define the primitive systems
dotr(u,p,t) = p.α*u # (has only one state) u is in the input which is the number of parameters , p is the list of parameters
dotrf(u,p,t) = [-p.β*u[1]*u[2], p.γ*u[1]*u[2]] # has two states -- number of rabbits and number of foxes, p is the list of parameters
dotf(u,p,t) = -p.δ*u

# Put a box around each of these dyanmics
rabbit_growth = ContinuousResourceSharer{Float64}(1, dotr)
rabbitfox_predation = ContinuousResourceSharer{Float64}(2, dotrf)
fox_decline = ContinuousResourceSharer{Float64}(1, dotf)

#--------------------------------------------------------#
  # Superposing the building blocks on the blue print #
#--------------------------------------------------------#
# Compose
rabbitfox_system = oapply(rf, [rabbit_growth, rabbitfox_predation, fox_decline])

#-------------------------------------------------------------#
  # Setting initial values of the system, setting parameters #
#-------------------------------------------------------------#
# Solve and plot
u0 = [10.0, 100.0] # 10 rabbits, 100 foxes
params = LVector(α=.3, β=0.015, γ=0.015, δ=0.7)
tspan = (0.0, 100.0)

#-------------------------------------------------------------------------------------#
  # The computer simulates the evolution of the system starting from initial values #
#-------------------------------------------------------------------------------------#
#solving differential equation 
prob = ODEProblem(rabbitfox_system, u0, tspan, params)
sol = solve(prob, Tsit5())

#---------------------------------------#
  # Visualize the system evolution #
#---------------------------------------#
# Visualizing the solution
plot(sol, rabbitfox_system,
    lw=2, title = "Lotka-Volterra Predator-Prey Model",
    xlabel = "time", ylabel = "population size"
)


#-----------------------------------#
    # For directed wiring diagrams
#-----------------------------------#
using AlgebraicDynamics.DWDDynam

# Define the composition pattern
rabbitfox_pattern = WiringDiagram([], [:rabbits, :foxes])
rabbit_box = add_box!(rabbitfox_pattern, Box(:rabbit, [:pop], [:pop]))
fox_box = add_box!(rabbitfox_pattern, Box(:fox, [:pop], [:pop]))

add_wires!(rabbitfox_pattern, Pair[
    (rabbit_box, 1) => (fox_box, 1),
    (fox_box, 1)    => (rabbit_box, 1),
    (rabbit_box, 1) => (output_id(rabbitfox_pattern), 1),
    (fox_box, 1)    => (output_id(rabbitfox_pattern), 2)
])

#Draw the undirected wiring diagram
#to_graphviz(rabbitfox_pattern, labels=true, label_attr=:xlabel)
draw(d::WiringDiagram; labels=true) = to_graphviz(d,
  orientation=LeftToRight,
  labels=labels, label_attr=:xlabel
)

draw(rabbitfox_pattern, labels=false)

# Define the primitive systems
# u[1] is the current rabbit population
# x[1] is the incoming fox population 
dotr(u, x, p, t) = [p.α*u[1] - p.β*u[1]*x[1]]

# u[1] is the current fox population
# x[1] is the current rabbit population
dotf(u, x, p, t) = [p.γ*u[1]*x[1] - p.δ*u[1]]

rabbit = ContinuousMachine{Float64}(1,1,1, dotr, (u, p, t) -> u)
fox    = ContinuousMachine{Float64}(1,1,1, dotf, (u, p, t) -> u)

# Compose
rabbitfox_system = oapply(rabbitfox_pattern, [rabbit, fox]) # 

# Solve and plot
u0 = [10.0, 100.0]
params = LVector(α=.3, β=0.015, γ=0.015, δ=0.7)
tspan = (0.0, 100.0)

prob = ODEProblem(rabbitfox_system, u0, tspan, params)
sol = solve(prob, Tsit5())

plot(sol, rabbitfox_system, params,
    lw=2, title = "Lotka-Volterra Predator-Prey Model",
    xlabel = "time", ylabel = "population size"
)