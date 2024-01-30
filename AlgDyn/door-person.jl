#-----------------------------------#
    # For directed wiring diagrams
#-----------------------------------#
using AlgebraicDynamics.DWDDynam
using LabelledArrays
using Catlab.WiringDiagrams, Catlab.Programs, Catlab.Graphics
using OrdinaryDiffEq
using PrettyTables

# Define the composition pattern
autoDoor_blueprint = WiringDiagram([], [:Door_state, :Person_state])
Door_box = add_box!( autoDoor_blueprint, Box(:Door, [:Person_state], [:Door_state]))
Person_box = add_box!( autoDoor_blueprint, Box(:Person, [:Door_state], [:Person_state]))

add_wires!(autoDoor_blueprint, Pair[
    (Door_box, 1) => (Person_box, 1),
    (Person_box, 1)    => (Door_box, 1),
    (Door_box, 1) => (output_id(autoDoor_blueprint), 1),
    (Person_box, 1)    => (output_id(autoDoor_blueprint), 2)
])

#Draw the undirected wiring diagram
#to_graphviz(rabbitfox_pattern, labels=true, label_attr=:xlabel)
draw(d::WiringDiagram; labels=true) = to_graphviz(d,
  orientation=LeftToRight,
  labels=labels, label_attr=:xlabel
)

@enum personState begin
    waiting = 1
    passed = 2
end

@enum doorState begin
    open = 1
    closed = 2
end


draw(autoDoor_blueprint, labels=true)

# waiting : true
# passed : false 
# closed : true
# open : false
#=
doorTransition(state, input, param, t) = begin 
    if(input[1] == personStates::waiting) 
       doorStates::open
     else # (inputp[1] == "passed")
       doorStates::closed
    end
end
=#

doorTransition(state, input, param, t) = begin 
 if(input[1] == true) 
    false
  else # (inputp[1] == "passed")
    true
 end
end


# waiting : true
# passed : false 
# closed : true
# open : false
personTransition(state, input, param, t) = begin
    if(state[1] == true && input[1] == false)
        false
    elseif(state[1] == false && input[1] == false)
        false
    elseif(state[1] ==  true && input[1] == true)
        true
    elseif(state[1] == false && input[1] == true)
        false
    else 
        true
    end
end

readOut(state, p, t) = state

# 1 input, 1 state, 1 output, dynamics, time
Door = DiscreteMachine{Bool}(1,1,1, doorTransition, readOut)
Person = DiscreteMachine{Bool}(1,1,1, personTransition, readOut)

# Compose
automaticDoor = oapply(autoDoor_blueprint, [Door, Person]) 

#possible initial states
openwaiting = [open, waiting] #["open","waiting"]
closedwaiting = [closed, waiting] #["closed","waiting"]
closedpassed = [closed, passed] #["closed","passed"]
openpassed = [open, passed] #["open","passed"]


initial_states = [ true, true]
tspan = (1, 10)


prob = DiscreteProblem(automaticDoor, initial_states, tspan, nothing) #p=nothing (no parameters)
sol = solve(prob, FunctionMap();)


map(sol) do u
    return (Door=u[1], Person=u[2])
end |> pretty_table