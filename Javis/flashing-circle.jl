using Javis

video = Video(500, 500)

function ground(args...)
    background("white")
    sethue("black")
end

anim_background = Background(1:10, ground)

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

frame=10

color_sequence = [
    "tomato"
 "gold1"
 "darkolivegreen1"
 "gold1"
 "white"
 "tomato"
 "gold1"
 "darkolivegreen1"
 "gold1"
 "white"
 "tomato"
 "white"
 "darkolivegreen1"
 "tomato"
 "darkolivegreen1" ]

radius = 15
total_frames = 10

for num in 1:10
Object( num:num, 
        (args...) ->
            electrode(
                Point(0,0),
                color_sequence[num],
                "black",
                :fill,
                radius,
            ),
    )
end

function info_box(video, object, frame)
    fontsize(12)
    Javis.box(140, -210, 170, 40, :stroke)
    text("10-20 EEG Array Readings", 140, -220, valign = :middle, halign = :center)
    text("t = $(frame)s", 140, -200, valign = :middle, halign = :center)
end
    
info = Object(info_box)
    


render(video, pathname = "./Javis/flashing-light.gif", framerate = 1)
