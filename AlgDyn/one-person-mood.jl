#-----------------------------------#
    # For directed wiring diagrams
#-----------------------------------#
using AlgebraicDynamics.DWDDynam
using LabelledArrays
using Catlab.WiringDiagrams, Catlab.Programs, Catlab.Graphics

using OrdinaryDiffEq, Plots, Plots.PlotMeasures

# Define the composition pattern
mood_pattern = WiringDiagram([], [:Person_mood])
Person_b = add_box!(mood_pattern, Box(:Person, [], [:Person_mood]))


add_wires!(mood_pattern, Pair[
    (Person_b, 1) => (output_id(mood_pattern), 1),
])

#Draw the undirected wiring diagram
#to_graphviz(rabbitfox_pattern, labels=true, label_attr=:xlabel)
draw(d::WiringDiagram; labels=true) = to_graphviz(d,
  orientation=LeftToRight,
  labels=labels, label_attr=:xlabel
)

draw(mood_pattern, labels=true)


#------------------------------#
# Define the primitive systems #
# Each person's mood level is a number in the interval [-5, 5] 
# -5 is uber grumpy
# +5 is uber excited 
#  0 is neutral

# Each person has a calmDown_factor [0,1] capturing the rate at which they approach the neutral state if by themselves (no interaction) 

# change_in_mood =  - mood * calmdown_rate 
#------------------------------#

dotmood(mood, input, param, t) = [ - (mood[1] * param.calmdown_rate[1]) ] # pay attention to the negative sign in the front; here, change in mood is the amount by which the mood moves towards zero

# 1 input, 1 state, 1 output, dynamics, readout
Person_m = ContinuousMachine{Float64}(0,1,1, dotmood, (mood_level, p, t) -> mood_level)

# Compose
single_person_mood_system = oapply(mood_pattern, [Person_m]) # 

initial_moods = [4.5]
params = LVector(susceptability=[0.2], calmdown_rate=[.05], grumpiness_tolerance=[-4], excitement_tolerance=[4.5])
tspan = (0.0, 100.0)

prob = ODEProblem(single_person_mood_system, initial_moods, tspan, params)
sol = solve(prob, Tsit5())

plot(sol, single_person_mood_system, params,
    lw=2, title = "Mood shifting",
    xlabel = "Time in Minutes", ylabel = "Mood level", ylims=(-5,5)
)