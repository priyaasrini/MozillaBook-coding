#-----------------------------------#
    # For directed wiring diagrams
#-----------------------------------#
using AlgebraicDynamics
using LabelledArrays
using Catlab.WiringDiagrams, Catlab.Programs, Catlab.Graphics

using PrettyTables

# Define the composition pattern
doorPerson_diagram = @relation (Door_state, Person_state) begin
    Door(Door_state) # box_name(junction_name)
    Connection(Door_state, Person_state)
    Person(Person_state)
end

to_graphviz(doorPerson_diagram, box_labels=:name, junction_labels=:variable)


#=
doorTransition(state, param, t) = begin 
   state=" "
 end


connectionTransition(state, param, t) = begin
    if(state[2] == "waiting" && state[1] == "closed")
        ["waiting","open"]
    elseif(state[2] == "passed" && state[1] == "closed")
        ["passed", "closed"]
    elseif(state[2] == "waiting" && state[1] == "open")
        ["passed", "open"]
    elseif(state[2] == "passed" && input[1] == "open")
        ["passed", "closed"]
    else 
        ["waiting","open"]
    end
end

personTransition(state, param, t) = begin
     state = " "
end =#

personTransition(state, param, t) = [0]

doorTransition(state, param, t) = [0]

# waiting = 1 ; passed through = 2
# closed = 1 ; open = 2
# state[1] is door
# state[2] is person 
connectionTransition(state, param, t) = begin
    if(state[2] == 1 && state[1] == 1)  # person is waiting and door is closed
        [2, 1] # door person
    elseif(state[2] == 2 && state[1] == 1) # person has pased and door is closed
        [1, 2] 
    elseif(state[2] == 1 && state[1] == 2) # person is waiting and door is open
        [2, 2]
    elseif(state[2] == 2 && input[1] == 2) # person has passed and door is open
        [1, 2]
    else 
        [1, 1]
    end
end

# 1 input, 1 state, 1 output, dynamics, time
Door = DiscreteResourceSharer{Int64}(1, 1, doorTransition,[1]) # DiscreteResourceSharer{T}(nports, nstates, f, portmap)
Connection = DiscreteResourceSharer{Int64}(2, 2, connectionTransition, [1,2])  
Person = DiscreteResourceSharer{Int64}(1, 1, personTransition, [1])

# Compose
automaticDoor = oapply(doorPerson_diagram, [Door, Connection, Person]) 

#possible initial states
openwaiting =[2, 1]
closedwaiting =[1, 1]
closedpassed =[1, 2]
openpassed = [2, 2]


initial_states = closedwaiting
tspan = (1, 10)


prob = DiscreteProblem(automaticDoor, initial_states, tspan, nothing) #p=nothing (no parameters)
sol = solve(prob, FunctionMap();)


map(sol) do u
    return (Door=u[1], Person=u[2])
end |> pretty_table