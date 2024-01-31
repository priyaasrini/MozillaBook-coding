#-----------------------------------#
    # For directed wiring diagrams
#-----------------------------------#
using AlgebraicDynamics.DWDDynam
using LabelledArrays
using Catlab.WiringDiagrams, Catlab.Programs, Catlab.Graphics
using OrdinaryDiffEq
using PrettyTables

# Define the composition pattern
loopedBulb_blueprint = WiringDiagram([], [:Bulb1_state, :Bulb2_state, :Bulb3_state])

BulbBox = Box(:Bulb, [:Neighbor_state], [:My_state])

# add three boxes
Box1 = add_box!( loopedBulb_blueprint, BulbBox)
Box2 = add_box!( loopedBulb_blueprint, BulbBox)
Box3 = add_box!( loopedBulb_blueprint, BulbBox)


add_wires!(loopedBulb_blueprint, Pair[
    (Box1, 1)    => (output_id(loopedBulb_blueprint), 1), # output of Box1 connected to 1st output of larger box
    (Box2, 1)    => (output_id(loopedBulb_blueprint), 2), # output of Box2 connected to 2nd output of larger box
    (Box3, 1)    => (output_id(loopedBulb_blueprint), 3), # output of Box3 connected to 3rd output of larger box
    (Box1, 1)    => (Box2, 1), # output of Box1 connected to 1st input Box 2
    (Box2, 1)    => (Box3, 1), # output of Box2 connected to 1st input Box 3
    (Box3, 1)    => (Box1, 1), # output of Box3 connected to 1st input Box 1
])

#Draw the undirected wiring diagram
#to_graphviz(rabbitfox_pattern, labels=true, label_attr=:xlabel)
draw(d::WiringDiagram; labels=true) = to_graphviz(d,
  orientation=LeftToRight,
  labels=labels, label_attr=:xlabel
)

draw(loopedBulb_blueprint, labels=true)

@enum BulbState begin
    BULB_ON = true
    BULB_OFF = false
end

Transition(state, input, param, t) = [input[1]] 

Readout(state, p, t) = state

# 1 input, 1 state, 1 output, dynamics, time
Bulb1 = Bulb2 = Bulb3 = DiscreteMachine{Bool}(1,1,1, Transition, Readout)

# Compose
Looped_bulbs = oapply(loopedBulb_blueprint, [Bulb1, Bulb2, Bulb3]) 

initial_state = [Bool(BULB_ON), Bool(BULB_OFF), Bool(BULB_OFF)] # needs to be an array
tspan = (1, 10)


prob = DiscreteProblem(Looped_bulbs, initial_state, tspan, nothing) #p=nothing (no parameters)
sol = solve(prob, FunctionMap();)


map(sol) do u
    return (Bulb_1=u[1], Bulb_2=u[2], Bulb_3=u[3])
end |> pretty_table