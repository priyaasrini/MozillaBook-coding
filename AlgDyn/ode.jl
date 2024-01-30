using DifferentialEquations
f(u, p, t) = 0.18 * u[1] * (1 - u[1]* (2.0*10^(-9)) )
u0 = 0.5 * 10^9
tspan = (0.0, 0.1)
prob = ODEProblem(f, u0, tspan)
sol = solve(prob, Tsit5(), reltol = 1e-8, abstol = 1e-8)

using Plots
plot(sol, linewidth = 5, title = "Solution to the linear ODE with a thick line",
    xaxis = "Time (t)", yaxis = "u(t) (in μm)", label = "My Thick Line!") # legend=false
