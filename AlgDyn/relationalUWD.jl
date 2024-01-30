using AlgebraicDynamics
using Catlab.WiringDiagrams, Catlab.Programs, Catlab.Graphics

using LabelledArrays
using OrdinaryDiffEq, Plots, Plots.PlotMeasures

#----------------------------------------------#
    # Defining the Blueprint (syntax) #
#----------------------------------------------#

# Define the composition patternß
rf = @relation (x,y) begin
    R1(x, y, z) # box_name(junction_name)
    R2(z)
end

#Draw the undirected wiring diagram
to_graphviz(rf, box_labels=:name, junction_labels=:variable)
