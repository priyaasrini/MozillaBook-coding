using Javis

myvideo = Video(500,500)

#= One may wonder, "why is args... needed in the ground function?" 
Each user-defined function gets three arguments video, object, 
and frame provided by Javis. =#
function ground(args...) 
        background("white") # canvas background
        sethue("black") # pen color 
end 

function object(p=Point(0,0), color="black")
    sethue(color)
    circle(p, 25, :fill) # draw circle of radius 25 at 0,0 and fill it with 'color' 
    return p
end

# for orbit
function path!(points, pos, color)
    sethue(color)
    push!(points, pos) # add pos to points
    circle.(points, 2, :fill) # draws a circle for each point using broadcasting
end

# connector
function connector(p1, p2, color)
    sethue(color)
    line(p1,p2, :stroke)
end

# Drawing a cricle and rendering it

Background(1:70, ground)

#= The Object functionality gives us the option to define the frames 
it applies to. Here, it is applied to frames 1 to 70, 
a function and a starting position. =#
red_ball = Object(1:70, (args...) -> object(O, "red"), Point(100, 0))
blue_ball = Object(1:70, (args...) -> object(O, "blue"), Point(200,80))

path_of_red = Point[]
Object(1:70, (args...)->path!(path_of_red, pos(red_ball), "red"))

Object(1:70, (args...)->connector(pos(blue_ball), pos(red_ball), "brown"))

path_of_blue = Point[]
Object(1:70, (args...)->path!(path_of_blue, pos(blue_ball), "blue"))

act!(red_ball, Action(anim_rotate_around(2π, O))) # 0 = Point(0,0)
act!(blue_ball, Action(anim_rotate_around(2π, 0.0, red_ball)))


render(
    myvideo;
    pathname="./Javis/hellow-world.gif"
)
