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
    return (BulbState = if (u[1]) "ON" else "OFF" end)
end |> pretty_table

result = map(sol) do u
    return if(u[1]) "gold" else "gray" end
end

#------ Javis code ----------#

using Javis

video = Video(500, 500)

function ground(args...)
    background("white")
    sethue("black")
end

anim_background = Background(1:10, ground) # same as tspan

function electrode(
    p = O,
    fill_color = "white",
    outline_color = "black",
    action = :fill,
    radius = 25,
)
    sethue(fill_color)
    circle(p, radius, :fill)
    sethue(outline_color)
    circle(p, radius, :stroke)
end

radius = 25
Object(
        (args...) ->
            electrode.(
                Point(0,0),
                map(sol) do u
                    return if(u[1]) "gold" else "lightgray" end
                end,
                "black",
                :fill,
                radius,
            ),
    )

function info_box(video, object, frame)
    fontsize(12)
    box(140, -210, 170, 40, :stroke)
    text("10-20 EEG Array Readings", 140, -220, valign = :middle, halign = :center)
    text("t = $(frame)s", 140, -200, valign = :middle, halign = :center)
end
    
info = Object(info_box)
    


render(video, pathname = "flashing-light.gif", framerate = 1)
