#-----------------------------------#
    # For directed wiring diagrams
#-----------------------------------#
using AlgebraicDynamics.DWDDynam
using LabelledArrays
using Catlab.WiringDiagrams, Catlab.Programs, Catlab.Graphics

using OrdinaryDiffEq, Plots, Plots.PlotMeasures

# Define the composition pattern
mood_pattern = WiringDiagram([], [:mood_level])
person_box = add_box!(mood_pattern, Box(:KeeKee, [], [:mood_level]))

add_wires!(mood_pattern, Pair[
    (person_box, 1) => (output_id(mood_pattern), 1)
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
# A person's mood level is a number in the interval [-5, 5] 
# -5 is uber grumpy
# +5 is uber excited 
#  0 is neutral

# Each person has a susceptability_factor [0,1] caputring the susceptibility of other person's mood during an interaction
# Each person has a calmDown_factor [0,1] capturing the rate at which they approach the neutral state if by themselves (no interaction) 
# When each person has reached their maximum grumpiness or maximum excitment, the external connection breaks, Lets call this mood_tolerance 

# change_in_mood = external_mood * susceptability - mood * calmdown_rate (if mood > gumpiness_tolerance and mood < excitement_tolreance)
# This model has a major flaw, suppose the tolerance limit is reached, then the connection is broken only for the person whose tolerance limit 
# has been reached. The other person is still affected by and the connection is not broken at his/her end. This makes no sense. The connection 
# must be treated as a shared resource which is either available to both or unavailable to both simultaneously. 
#------------------------------#

dotmood(mood, input, param, t) = [-(mood[1] * param.calmdown_rate[1]) ]

# 1 input, 1 state, 1 output, dynamics, readout
KeeKee_m = ContinuousMachine{Float64}(0,1,1, dotmood, (mood_level, p, t) -> mood_level)

# Compose
mood_system = oapply(mood_pattern, [KeeKee_m]) 

initial_moods = [4.5]
params = LVector(calmdown_rate=[.05, .03])
tspan = (0.0, 100.0)

prob = ODEProblem(mood_system, initial_moods, tspan, params)
sol = solve(prob, Tsit5())


plot(sol, mood_system, params,
    lw=2, title = "Mood",
    xlabel = "Time in Hours", ylabel = "Mood level"
)