#-----------------------------------#
    # For Traffic Intersection without a memory
#-----------------------------------#
using AlgebraicDynamics.DWDDynam
using LabelledArrays
using Catlab.WiringDiagrams, Catlab.Programs, Catlab.Graphics
using OrdinaryDiffEq
using PrettyTables

# Define the composition pattern
blueprint = WiringDiagram([], [:LRed, :LGreen, :LYellow, :RRed, :RGreen, :RYellow])

#controller has six inputs and 3 outputs
controllerBox = Box(:Controller, [:Red_n, :Green_n, :Yellow_n], [:Red, :Green, :Yellow])
RedBulb = Box(:RedBulb, [:State], [:State])
GreenBulb = Box(:GreenBulb, [:State], [:State])
YellowBulb = Box(:YellowBulb, [:State], [:State])


#add eight boxes -- four on left and right and right
LRed_b = add_box!( blueprint, RedBulb)
LGreen_b = add_box!( blueprint, GreenBulb)
LYellow_b = add_box!( blueprint, YellowBulb)
LController_b = add_box!( blueprint, controllerBox)
RRed_b = add_box!( blueprint, RedBulb)
RGreen_b = add_box!( blueprint, GreenBulb)
RYellow_b = add_box!( blueprint, YellowBulb)
RController_b = add_box!( blueprint, controllerBox)

add_wires!(blueprint, Pair[
    (LController_b, 1)    => (LRed_b, 1), #1st output of left controller connected to Left red input
    (LController_b, 2)    => (LGreen_b, 1), 
    (LController_b, 3)    => (LYellow_b, 1), 
    (RController_b, 1)    => (RRed_b, 1), #1st output of right controller connected to right red input
    (RController_b, 2)    => (RGreen_b, 1), 
    (RController_b, 3)    => (RYellow_b, 1), 
    (LRed_b, 1)    => (output_id(blueprint), 1), # output of Box1 connected to 1st output of larger box
    (LGreen_b, 1)    => (output_id(blueprint), 2), # output of Box3 connected to 3rd output of larger box
    (LYellow_b, 1)    => (output_id(blueprint), 3), # output of Box2 connected to 2nd output of larger box
    (RRed_b, 1)    => (output_id(blueprint), 4), 
    (RGreen_b, 1)    => (output_id(blueprint), 5), 
    (RYellow_b, 1)    => (output_id(blueprint), 6),
    (RRed_b, 1)    => (LController_b, 1), 
    (RGreen_b, 1)    => (LController_b, 2), 
    (RYellow_b, 1)    => (LController_b, 3),
    (LRed_b, 1)    => (RController_b, 1), 
    (LGreen_b, 1)    => (RController_b, 2), 
    (LYellow_b, 1)    => (RController_b, 3)
])

#=


    (LRed_b, 1)    => (input_id(blueprint), 4), # output of Box1 connected to input of right controller
    (LGreen_b, 1)    => (input_id(blueprint), 5), # output of Box1 connected to input of right controller
    (LYellow_b, 1)    => (input_id(blueprint), 6), # output of Box1 connected to input of right controller

    =#


draw(d::WiringDiagram; labels=true) = to_graphviz(d,
  orientation=LeftToRight,
  labels=labels, label_attr=:xlabel
)

draw(blueprint, labels=true)


BulbTransition(state, input, param, t) = [input[1]] 


TwinControllerTransition_L(state, input, param, t) = begin
    if(state[1] == false && state[2] == true && state[3] == false )  # if your state is green, go to yellow
        [false, false, true, false] 
    elseif(state[1] == false && state[2] == false && state[3] == true ) # if your state is yellow, go to red
        [true, false, false, false]
    #If current state = red
    elseif(state[1] == true && state[2] == false && state[3] == false ) 
        if(input[1] == true &&  input[2]== false && input[3] == false ) # if input is red
            if( state[4] == true) #  If you ready to go green
                [false, true, false, false ] # go green 
            else 
                state # wait in current state
            end
        elseif(input[1] == false &&  input[2]== false && input[3] == true ) # if input is yellow
            [state[1], state[2], state[3], true] # flip the ready to change switch, maintain the red color
        else #if input is green
            state # wait in current state
        end
    else # always start in red and ready to change
        [true, false, false, true] 
    end
end

TwinControllerTransition_R(state, input, param, t) = begin
    println("stater = ", state)
    println("inputr =", input)
    if(state[1] == false && state[2] == true && state[3] == false )  # if your state is green, go to yellow
        [false, false, true, false] 
    elseif(state[1] == false && state[2] == false && state[3] == true ) # if your state is yellow, go to red
        [true, false, false, false]
    #If current state = red
    elseif(state[1] == true && state[2] == false && state[3] == false ) 
        if(input[1] == true &&  input[2]== false && input[3] == false ) # if input is red
            if( state[4] == true) #  If you ready to go green
                [false, true, false, false ] # go green 
            else 
                state # wait in current state
            end
        elseif(input[1] == false &&  input[2]== false && input[3] == true ) # if input is yellow
            [state[1], state[2], state[3], true] # flip the ready to change switch, maintain the red color
        else #if input is green
            state # wait in current state
        end
    else # always start in red and not ready to change
        [true, false, false, false] 
    end
end

MemoryTransition(state, input, param, t) = input


Readout(state, p, t) = state

# input, state, output, dynamics, time
LRed_m = LGreen_m = LYellow_m =RRed_m = RGreen_m = RYellow_m = DiscreteMachine{Bool}(1,1,1, BulbTransition, Readout)
LController_m = DiscreteMachine{Bool}(3,4,3, TwinControllerTransition_L, Readout)
RController_m  = DiscreteMachine{Bool}(3,4,3, TwinControllerTransition_R, Readout)

# Compose
TwinTrafficLight_m = oapply(blueprint, [LRed_m, LGreen_m, LYellow_m, LController_m, RRed_m, RGreen_m, RYellow_m, RController_m ]) 

#running the code
# States 1 - 3 for L bulbs
# States 4 - 6 for L controller
# States 7 - 9 for R bulbs
# states 10 - 12 for R controller
#IS - Initital States
LLights_IS = [true, false, false] #currently red
LController_IS = [true, false, false, true] # keep red but ready to change

RLights_IS = [false, true, false] # currently green
RController_IS = [false, false, true, false] # make yellow and not ready to change

initial_states = append!(LLights_IS,LController_IS, RLights_IS, RController_IS)
# All the inputs have red light on
inputs = [] 
tspan = (1, 25)


prob = DiscreteProblem(TwinTrafficLight_m, initial_states, inputs, tspan, nothing) #p=nothing (no parameters)
sol = solve(prob, FunctionMap();) 


#=
#checking if left memory works correctly
map(sol) do u
    return (
    B_Red_2=u[7], B_Green_2=u[8], B_Yellow_2=u[9],
    M_Red_1 = u[13], M_Green_1 = u[14], M_Yellow_1 = u[15])
end |> pretty_table

#checking if right memory works correctly
map(sol) do u
    return (B_Red_1=u[1], B_Green_1=u[2], B_Yellow_1=u[3], 
    M_Red_2 = u[16], M_Green_2 = u[17], M_Yellow_2 = u[18])
end |> pretty_table
=#

#seeing only Traffic light 1 transition
map(sol) do u
    return (Light1=(u[1],u[2],u[3]), 
    Controller1 = (u[4], u[5], u[6], u[7]),
    Light2=(u[8],u[9],u[10]),
    Controller2 = (u[11], u[12], u[13], u[4]),
    )
end |> pretty_table