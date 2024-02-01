#-----------------------------------#
    # For directed wiring diagrams
#-----------------------------------#
using AlgebraicDynamics.DWDDynam
using LabelledArrays
using Catlab.WiringDiagrams, Catlab.Programs, Catlab.Graphics
using OrdinaryDiffEq
using PrettyTables

# Define the composition pattern
trafficlight_blueprint = WiringDiagram([:Red, :Green, :Yellow], 
    [:Red, :Green, :Yellow])

controllerBox = Box(:Controller, [], [:Red, :Green, :Yellow])
RedBulb = Box(:Red, [:State], [:State])
GreenBulb = Box(:Green, [:State], [:State])
YellowBulb = Box(:Yellow, [:State], [:State])



#add four boxes
# add three boxes
Red_b = add_box!( trafficlight_blueprint, RedBulb)
Green_b = add_box!( trafficlight_blueprint, GreenBulb)
Yellow_b = add_box!( trafficlight_blueprint, YellowBulb)
Controller_b = add_box!( trafficlight_blueprint, controllerBox)

add_wires!(trafficlight_blueprint, Pair[
    (Red_b, 1)    => (output_id(trafficlight_blueprint), 1), # output of Box1 connected to 1st output of larger box
    (Green_b, 1)    => (output_id(trafficlight_blueprint), 2), # output of Box3 connected to 3rd output of larger box
    (Yellow_b, 1)    => (output_id(trafficlight_blueprint), 3), # output of Box2 connected to 2nd output of larger box
    (Controller_b, 1)    => (Red_b, 1), # output of Box1 connected to 1st input Box 2
    (Controller_b, 2)    => (Green_b, 1), # output of Box2 connected to 1st input Box 3
    (Controller_b, 3)    => (Yellow_b, 1), # output of Box3 connected to 1st input Box 1
])


draw(d::WiringDiagram; labels=true) = to_graphviz(d,
  orientation=LeftToRight,
  labels=labels, label_attr=:xlabel
)

draw(trafficlight_blueprint, labels=true)

BulbTransition(state, input, param, t) = [input[1]] 

ControllerTransition(state, input, param, t) = begin
    if(state[1] == true && state[2] == false && state[3] == false)  #Red is ON, the rest of OFF
        [false, true, false] 
    elseif(state[1] == false && state[2] == true && state[3] == false)  # Green is ON
        [false, false, true]
    elseif(state[1] == false && state[2] == false && state[3] == true)  # Yellow is ON, the rest is OFF
        [true, false, false]
    else #non-sense 
        [true, false, false]
    end
end

Readout(state, p, t) = state

# input, state, output, dynamics, time
Red_m = Green_m = Yellow_m = DiscreteMachine{Bool}(1,1,1, BulbTransition, Readout)
Controller_m = DiscreteMachine{Bool}(0,3,3, ControllerTransition, Readout)

# Compose
TrafficLight_m = oapply(trafficlight_blueprint, [Red_m, Green_m, Yellow_m, Controller_m]) 

#running the code
#first three states represent controller, last three states represent initial states of the light
initial_states = [true, false, false, false, false, false] # needs to be an array
inputs = [true, false, true]
tspan = (1, 10)


prob = DiscreteProblem(TrafficLight_m, initial_states, inputs, tspan, nothing) #p=nothing (no parameters)
sol = solve(prob, FunctionMap();) 


map(sol) do u
    return (Red=u[4], Green=u[5], Yellow=u[6])
end |> pretty_table