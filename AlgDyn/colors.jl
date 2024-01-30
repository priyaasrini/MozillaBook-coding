using AlgebraicDynamics
using Catlab.WiringDiagrams, Catlab.Programs, Catlab.Graphics
using AlgebraicDynamics.DWDDynam

using LabelledArrays
using SciMLBase
using OrdinaryDiffEq

color_pattern = WiringDiagram([:yesno], [:color])
change_state = add_box!(color_pattern, Box(:colorbox, [:yesno], [:color]))

add_wires!(color_pattern, Pair[
    (input_id(color_pattern), 1)    => (change_state, 1)
    ,(change_state, 1) => (output_id(color_pattern), 1)
])

draw(d::WiringDiagram; labels=true) = to_graphviz(d,
  orientation=LeftToRight,
  labels=labels, label_attr=:xlabel
)

draw(color_pattern, labels=true)

#---------------------------------#
   # Creating building blocks #
#---------------------------------#

transition_table = Dict(
     (true, 1) => 2
    ,(false, 1) => 1
    ,(true, 2) => 2
    ,(false, 2) => 3
    ,(true, 3) => 4
    ,(false, 3) => 4
    ,(true, 4) => 1
    ,(false, 4) => 4
    )

update_f(current_state, input, p, n) = [transition_table[(input[1], current_state[1])]]
readout_f(state, p, n) = begin
    if state == 1
        print("blue")
        return ["blue"]
    elseif state == 2
        print("red")
        return ["red"]
    elseif state == 3
        print("green")
        return ["green"] 
    elseif state == 4 
        print("blue")
        return ["blue"] 
    end
end

color_machine = DiscreteMachine{Bool}(1, 1, 1, update_f, readout_f) #DiscreteMachine{T}(ninputs, nstates, noutputs, f, r)

# ------------------------------------ #
    # Applying the machine to the BP 
# ------------------------------------ #
color_system = oapply(color_pattern, [color_machine]) 

# ------------------------------------ #
# Running the evolution in a computer #
# -------------------------------------#

initial_state=[2]
input_vec = [false] 
steps = (1,5)

prob = DiscreteProblem(color_system, initial_state, input_vec, steps, nothing) #p=nothing (no parameters)
sol = solve(prob, FunctionMap())

# @Sophie: 
# how to provide a stream on inputs?
# how to print the readout?
# What does sol usually have?