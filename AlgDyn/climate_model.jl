#-----------------------------------#
    # For directed wiring diagrams
#-----------------------------------#
using AlgebraicDynamics.DWDDynam
using LabelledArrays
using Catlab.WiringDiagrams, Catlab.Programs, Catlab.Graphics

using OrdinaryDiffEq, Plots, Plots.PlotMeasures

# Define the composition pattern
climate_pattern = WiringDiagram([:emission_rate], [:average_global_surface_temperature, :CO2_concentration])
atmosphere_box = add_box!(climate_pattern, Box(:Atmosphere_CO2, [:emission_rate], [:CO2_concentration]))
earth_box = add_box!(climate_pattern, Box(:Earth_temperature, [:curr_CO2, :prev_CO2_concentration], [:surface_temperature]))
memory_box = add_box!(climate_pattern, Box(:Memory, [:CO2_concentration], [:CO2_concentration]))

add_wires!(climate_pattern, Pair[
    (atmosphere_box, 1) => (memory_box, 1)
    , (memory_box, 1) => (earth_box, 2)
    , (atmosphere_box, 1) => (earth_box, 1)
    , (input_id(climate_pattern), 1) => (atmosphere_box, 1)
    , (earth_box, 1)    => (output_id(climate_pattern), 1)
    , (memory_box, 1)    => (output_id(climate_pattern), 2)
])

#Draw the undirected wiring diagram
draw(d::WiringDiagram; labels=true) = to_graphviz(d,
  orientation=LeftToRight,
  labels=labels, label_attr=:xlabel
)

draw(climate_pattern, labels=true)

#------------------------------#
# Define the primitive systems #
#------------------------------#

dotCO2(state, input, param, t) = [(0.995 * state[1])  +  (0.55 * input[1] / 2.3 * 5)]
dotTemp(state, input, param, t) = [state[1] + param.climate_sensitivity * log(input[1]/input[2])]
dotMemory(state, input, param, t) = [input[1]]


# 1 input, 1 state, 1 output, dynamics, time
atmosphere = DiscreteMachine{Float64}(1,1,1, dotCO2, (state, p, t) -> state)
earth = DiscreteMachine{Float64}(2,1,1, dotTemp, (state, p, t) -> state)
memory = DiscreteMachine{Float64}(1,1,1, dotMemory, (state, p, t) -> state)

# Compose
climate_model = oapply(climate_pattern, [atmosphere, earth, memory]) # 

initial_states = [ 399.4 , 14.65, 399.4] # CO2 concentration, global surface temperature, CO2 concentration prev
params = LVector(climate_sensitivity=3) # degrees
inputs = [10.5] #10.5 GigC carbon as emission rate
tspan = (1, 18)


prob = DiscreteProblem(climate_model, initial_states, inputs, tspan, params) #p=nothing (no parameters)
sol = solve(prob, FunctionMap();)

year = 2010
map(sol) do u
   global year = year + 5
    return (year, temperature=u[2], co2_concentration=u[3])
end |> pretty_table

plot(sol, climate_model, params,
    lw=2, title = "A very simple climate model",
    xlabel = "year", ylabel = "temperature in degrees celsius"
) 

#=
plot(
    [
        PlotlyJS.scatter(x=2015:5:2100, y=13.5:0.5:18, name="Temperature in celsius"),
        PlotlyJS.scatter(x=2015:5:2100, y=300:50:800, name="yaxis2 data", yaxis="CO2 concentration in ppm")
    ],
    Layout(
        title_text="A very simple climate model",
        xaxis_title_text="Year",
        yaxis_title_text="Temperature in celsius",
        yaxis2=PlotlyJS.attr(
            title="CO2 concentration in ppm",
            overlaying="y",
            side="right"
        )
    )
)
=#
#=
# Define the composition pattern
climate_pattern = WiringDiagram([:climate_sensitivity, :emission_rate], [:average_global_surface_temperature])
atmosphere_box = add_box!(climate_pattern, Box(:Atmosphere_CO2, [:CO2_concentration, :emission_rate], [:CO2_concentration]))
earth_box = add_box!(climate_pattern, Box(:Earth_temperature, [:surface_temperature, :climate_sensitivity, :CO2_concentration], [:surface_temperature]))

add_wires!(climate_pattern, Pair[
    (atmosphere_box, 1) => (atmosphere_box, 1),
    (atmosphere_box, 1) => (earth_box, 3),
    (input_id(climate_pattern), 2)    => (atmosphere_box, 2),
    (input_id(climate_pattern), 1) => (earth_box, 2),
    (earth_box, 1)    => (earth_box, 1),
    (earth_box, 1)    => (output_id(climate_pattern), 1)
])

#Draw the undirected wiring diagram
#to_graphviz(rabbitfox_pattern, labels=true, label_attr=:xlabel)
draw(d::WiringDiagram; labels=true) = to_graphviz(d,
  orientation=LeftToRight,
  labels=labels, label_attr=:xlabel
)

draw(climate_pattern, labels=true)

=#