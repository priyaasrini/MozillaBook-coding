#-----------------------------------#
    # For directed wiring diagrams
#-----------------------------------#
using AlgebraicDynamics.DWDDynam
using LabelledArrays
using Catlab.WiringDiagrams, Catlab.Programs, Catlab.Graphics
using OrdinaryDiffEq
using PrettyTables

# Define the composition pattern
flashingBulb_blueprint = WiringDiagram([], [:Bulb_state])
Bulb_box = add_box!( flashingBulb_blueprint, Box(:Bulb, [], [:Bulb_state]))

add_wires!(flashingBulb_blueprint, Pair[
    (Bulb_box, 1)    => (output_id(flashingBulb_blueprint), 1)
])

#Draw the undirected wiring diagram
#to_graphviz(rabbitfox_pattern, labels=true, label_attr=:xlabel)
draw(d::WiringDiagram; labels=true) = to_graphviz(d,
  orientation=LeftToRight,
  labels=labels, label_attr=:xlabel
)

draw(flashingBulb_blueprint, labels=true)

@enum BulbState begin
    BULB_ON = true
    BULB_OFF = false
end

Transition(state, input, param, t) = [xor(state[1], Bool(BULB_ON))] # toggle bulb state

Readout(state, p, t) = state

# 1 input, 1 state, 1 output, dynamics, time
Bulb = DiscreteMachine{Bool}(0,1,1, Transition, Readout)

# Compose
FlashingBub = oapply(flashingBulb_blueprint, [Bulb]) 

#possible initial states
on  = Bool(BULB_ON)
off = Bool(BULB_OFF)


initial_state = [on] # needs to be an array
tspan = (1, 10)


prob = DiscreteProblem(Bulb, initial_state, tspan, nothing) #p=nothing (no parameters)
sol = solve(prob, FunctionMap();)


map(sol) do u
    return (BulbState=u[1])
end |> pretty_table