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

electrodes_list = [
    (name = "Cz", position = O),
    (name = "C3", position = Point(-70, 0)),
    (name = "C4", position = Point(70, 0)),
    (name = "T3", position = Point(-140, 0)),
    (name = "T4", position = Point(140, 0)),
    (name = "Pz", position = Point(0, 70)),
    (name = "P3", position = Point(-50, 70)),
    (name = "P4", position = Point(50, 70)),
    (name = "Fz", position = Point(0, -70)),
    (name = "F3", position = Point(-50, -70)),
    (name = "F4", position = Point(50, -70)),
    (name = "F8", position = Point(115, -80)),
    (name = "F7", position = Point(-115, -80)),
    (name = "T6", position = Point(115, 80)),
    (name = "T5", position = Point(-115, 80)),
    (name = "Fp2", position = Point(40, -135)),
    (name = "Fp1", position = Point(-40, -135)),
    (name = "A1", position = Point(-190, -10)),
    (name = "A2", position = Point(190, -10)),
    (name = "O1", position = Point(-40, 135)),
    (name = "O2", position = Point(40, 135)),
]

indicators = ["white", "gold1"]
sequence = ["White", "gold1", "white", "gold1", "white", "gold1", "white", "gold1", "black", "black" ]

radius = 25
Object(
        (args...) ->
            electrode.(
                Point(0,0),
                sequence,
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
    


render(video, pathname = "./Javis/flashing-light.gif", framerate = 1)
