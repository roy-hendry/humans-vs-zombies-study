breed [ peoples people ]                    ; creating a population of people who will move around and attempt to avoid zombies or chase and fight them
breed [ zombies zombie ]                    ; creating a population of zombies who will move around and chase people

peoples-own [ speed_variation               ; creating a variable to determine people's speeds
  per_vis_rad per_vis_ang                   ; creating variables for personalised vision cones
  vis_rand people_health                    ; creating a variable to add some randomness for the vision and creating the people health variable
  bravery                                   ; creating a bravery variable to hold people's personalised bravery
  closest_zombie_in_vis_cone                ; creating a variable for the people to hold the closest zombie in it's vision cone
  zombies_near_me ]                         ; creating a variable for the zombies to hold all of the zombies near it

zombies-own [ closest_people                ; creating the variable which holds the closest person to the zombie
  people_around_me                          ; creating the variable which holds all of the people near the zombie
  zombie_health ]                            ; creating the variable which states if the zombie is alive or not

globals [ rad                               ; the block of code to set all of the global variables and this creates a global variable called rad
daytime starting_color current_color        ; creating global variables for the daytime, starting colour and current colour
color_adjust color_range                    ; creating global variables for the colour adjustments and the colour range
timer_reset ]                               ; creating global variable for the timer reset

to setup                                    ; this creates a function called setup which contains all of the settings which initially effect the world
  clear-all                                 ; this clears the world of any previous activities
  reset-ticks                               ; this resets the ticks counter
  set rad 5                                 ; this sets the global variable rad to 5
  set timer_reset 1000                      ; this makes the timer reset be 1000
  set daytime true                          ; initially the world will start in daytime
  set starting_color 85                     ; set's the starting color value to 85
  set current_color starting_color          ; set's the current colour to the starting colour
  set color_range 5                         ; setting the colour range to 5
  set color_adjust ( color_range / ( timer_reset + 10 ))   ; ----------------might remove


  create-zombies number_of_zombies [        ; the block of code for creating the zombies and the amount of zombies is based on the slider on the interface
    setxy random-xcor random-ycor           ; this sets the starting position of the zombie to a random location in the world
    set size 10                             ; this sets the size of the zombie to 10
    set shape "zombiev1"                    ; setting the shape of the zombie to the custom shape we made
    set zombie_health 100                   ; making it so that zombies are alive by default
  ]

  create-peoples number_of_people [                 ; the block of code for creating the people and the amount of people is based on the slider on the interface
    setxy random-xcor random-ycor                   ; this sets the starting position of the people to a random location in the world
    set color white                                 ; this sets the colour of the people to white
    set size 10                                     ; this sets the size of the people to 10
    set shape "personv1"                            ; this sets the shape of the people to a person
    set people_health 60 + random 40 + user_health  ; setting a base people health for the people plus a random value to show variety of health levels in people
    set vis_rand random 20                          ; setting a random size of the vision cone people have, this
    adjust_vision_cone                              ; this calls the adjust_vision_cone fuction to setup the vision cone
    set speed_variation random 10                   ; this sets the speed_variation variable to a random value up to 10. the higher the value the faster the human
    set bravery 10 + user_bravery + random 40       ; this creates a base amount of bravery to 10, adds that to the slider value of the bravery and then adds a random value of up to 40 to it
  ]
end

to make_people_move                                        ; this creates a function called make_people_move
  ask peoples [                                            ; this asks all of the people in the population to do what is in the brackets
    set people_health people_health                        ; setting people health to have it's value
    ifelse people_health > 0 [                                    ; provided people health is above 0...
      show_visualisations                                  ; calls the show_visualisations function made below
      ;set color white                                     ; this sets the color of each person to white
      let have_seen_zombie people_function                 ; creates a local variable and gives it the value from the people function
      right ( random pwr - ( pwr / 2))                     ; this turns the person right relative to its current heading by a random degree number using the range set within pwr NOTE: if negative it will turn left
      if ( have_seen_zombie = true and bravery >= 60 ) [   ; provided the person has seen the zombie and has a bravery greater than or equal to 60 then...
        set heading ( towards closest_zombie_in_vis_cone ) ; setting the people to head towards the closest zombie in their vision cone
        zombie_kill                                        ; calling the zombie kill function
      ]
      if (have_seen_zombie = true and bravery < 60) [      ; if the person has seen a zombie and their bravery is less than 60 then...
        right 180                                          ; turn right 180 degrees
      ]
      forward people_speed                                 ; move foward at people's speed decided by the slider
    ][                                                     ; because the people health is not greater than 0...
      convert_people                                       ; calls the convert people function
      die                                                  ; kills the people
    ]
  ]
end

to-report people_function                                                      ; the function to report if people have seen zombies
  let seen [false]                                                             ; making local variables to say if the person has seen a zombie
  set zombies_near_me other ( zombies in-cone per_vis_rad per_vis_ang )        ; set zombies near me to to report the zombies in the vision radius of the people
  set closest_zombie_in_vis_cone min-one-of zombies_near_me [distance myself]  ; set the closest zombie in the vision cone to be the one that has the least distance between the turtle and it's target
  ask zombies in-cone per_vis_rad per_vis_ang [                                ; if zombies are in the vision cone of the human then...
    set seen true                                                              ; set seen to true
  ]
  report seen                                                                  ; report if seen is true or false
end

to zombie_kill                                        ; creating the zombie kill function
  let hit [false]                                     ; making a local variable to say if the zombie has been hit
  let zombie_hit 0                                    ;

  ask zombies in-radius 1 [                           ; provided the zombies are in a radius of 1...
    set hit true                                      ; set hit to true
    set zombie_hit who                                ; set zombie hit to the individual human who hit him
  ]

  if (hit = true)[                                    ; if hit = true then...
    ask zombie zombie_hit [ set zombie_health zombie_health - (10 + random 50) ]  ; remove health from the zombie that was hit
  ]

end

to make_zombie_move                             ; making the make zombies move function
  ask zombies [                                 ; make zombies do the commands below
    ifelse zombie_health > 0 [                  ; if the zombie is alive...
      let can_smell_person zombie_hunt 30       ; make a local variable called can smell person that holds the value of zombie hunt when a radius of 30 is given as a parameter
      ifelse ( can_smell_person = true ) [      ; if a person is in a zombie's radius...
        set heading ( towards closest_people )  ; make the zombie head towards the closest person to it
      ][
      right ( random zwr - ( zwr / 2 ))         ; this turns the zombie right relative to its current heading by a random degree number using the range set within zwr
      ]
      forward zombie_speed                      ; go forward at the speed set by the slider
    ][
     die                                        ; if the zombie alive is false then kill the zombie
    ]
  ]
end

to-report zombie_hunt [radius]                                     ; making the function that reports back if a zombie is within the radius passed to it of detecting a human
  let hit [false]                                                  ; setting the local variable for hit to false
  let person_hit 0                                                 ; making the local variable for person hit empty for now
  set people_around_me other ( peoples in-radius radius )          ; setting people around me to be the people in the radius of the value it was given as a parameter
  set closest_people min-one-of people_around_me [distance myself] ; sets the closest person to be the one that has the least distance between the turtle and the humans within the radius near it
  let can_smell_people [false]                                     ; set the local variable for can smell people to false
  if (closest_people != nobody) [                                  ; if no people are in the radius then...
    set can_smell_people true                                      ; set can smell people to true
  ]

  ask peoples in-radius 3 [                                        ; ask people who are within a radius of 3 to the zombie to...
    set hit true                                                   ; set their variable of hit to true
    set person_hit who                                             ; set their person hit id to specifically be them
  ]

  if hit = true [                                                  ; if they are hit then...
    ask people person_hit [ set people_health people_health - (1 + random 10) ]        ; ask the person hit to remove health randomly up to 10 per hit
  ]

  report can_smell_people                                          ; report if people are in range or not
end

to convert_people             ; making the convert people to zombies function
  hatch-zombies 1 [           ; when it is called it will create one zombie whith these parameters
    set size 10               ; the zombie made will be size 10
    set shape "zombiev1"      ; setting the shape of the zombies
    set zombie_health 100 ]   ; setting zombies alive to be true because if it isn't the zombie will instantly die as soon as it was converted
end

to go                                       ; this creates a function called go
  reset_patch_colour                        ; this calls the reset_patch_colour function
  make_people_move                          ; this calls the make_people_move function
  make_zombie_move
  tick                                      ; this adds 1 to the tick counter
  day_night_change ;test function - it should go somewhere else
end

to day_night_change
  if ticks > timer_reset [
    ifelse daytime = true [
      set daytime false
    ][
      set daytime true
    ]
    reset-ticks
  ]
end

to reset_patch_colour                       ; this creates a function called reset_patch_color
  ifelse daytime = true [
    set current_color current_color - color_adjust
  ][
    set current_color current_color + color_adjust
  ]
  ask patches [                             ; this asks all of the patches in the population to do what is in the brackets
    set pcolor current_color                        ; this sets the color of each patch to black
  ]
end

to show_visualisations                            ; this creates a function called show_visualisations
  if show_col_rad = true [                        ; this will switch on the visualisation of the collision radius if the switch is set to true
    ask patches in-radius rad [                   ; this sets up a radius around the human to the value of the global variable rad which we are using to display the size of the radius by changing the patch color
      set pcolor orange                           ; this sets the patch color to orange
    ]
  ]
  if show_vis_cone = true [                       ; this will switch on the visualisation of the vision cone if the switch is set to true
    ask patches in-cone per_vis_rad per_vis_ang [ ; this sets up a vision cone in front of the human to the value of the global variables per_vis_rad per_vis_ang which we are using to display the size of the radius by changing the patch color
      set pcolor red                              ; this sets the patch color to red
    ]
  ]
end

to adjust_vision_cone                              ; this creates a function called adjust_vision_cone
  if ((vis_rad + random 20)*(0.5)) > 0 [           ; if the calculation if greater than 0 then...
    set per_vis_rad ((vis_rad + vis_rand)*(0.5))  ; set the personal vision radius to factor in some randomness and health (less health = less vision)
  ]
  if ((vis_ang + random 20)*(0.5)) > 0 [           ; if the calculation if greater than 0 then...
    set per_vis_ang ((vis_ang + vis_rand)*(0.5))  ; set the personal vision angle to factor in some randomness and health (less health = less vision)
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
820
621
-1
-1
2.0
1
10
1
1
1
0
1
1
1
-150
150
-150
150
1
1
1
ticks
30.0

SLIDER
25
100
197
133
number_of_people
number_of_people
0
100
64.0
1
1
NIL
HORIZONTAL

SLIDER
25
138
197
171
pwr
pwr
10
200
10.0
1
1
NIL
HORIZONTAL

SLIDER
25
175
197
208
people_speed
people_speed
0
100
1.0
1
1
NIL
HORIZONTAL

BUTTON
22
17
85
50
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
103
17
203
50
go (forever)
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
214
687
386
720
vis_rad
vis_rad
0
50
40.0
1
1
NIL
HORIZONTAL

SWITCH
418
628
558
661
show_vis_cone
show_vis_cone
0
1
-1000

SLIDER
403
687
575
720
vis_ang
vis_ang
0
200
152.0
1
1
NIL
HORIZONTAL

SWITCH
223
632
363
665
show_col_rad
show_col_rad
0
1
-1000

SLIDER
20
320
192
353
number_of_zombies
number_of_zombies
0
20
1.0
1
1
NIL
HORIZONTAL

TEXTBOX
20
81
211
109
------------- People controls -------------
11
0.0
1

TEXTBOX
12
295
215
323
------------- Zombie controls -------------
11
0.0
1

SLIDER
20
360
192
393
zwr
zwr
10
200
10.0
1
1
NIL
HORIZONTAL

SLIDER
20
399
192
432
zombie_speed
zombie_speed
1
100
6.0
1
1
NIL
HORIZONTAL

PLOT
4
486
204
636
Model stats
Time
Quantity
0.0
500.0
0.0
10.0
true
true
"" ""
PENS
"People" 1.0 0 -15390905 true "" "plot count peoples"
"Zombies" 1.0 0 -15575016 true "" "plot count zombies"

MONITOR
61
706
151
751
NIL
count peoples
17
1
11

MONITOR
62
760
154
805
NIL
count zombies
17
1
11

SLIDER
25
214
197
247
user_bravery
user_bravery
0
50
0.0
1
1
NIL
HORIZONTAL

SLIDER
873
242
1045
275
user_health
user_health
0
200
100.0
10
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

roy big nerd

This is the simulation from Roy Hendry and Harry Davis to show how we expect humans and zombies to interact based off our variables we deem important and our thought process of the most important factors.

## HOW IT WORKS

(what rules the agents use to create the overall behaviour of the model)

 - If the bravery of the human is below 60: The people will run around and if they see a zombie in their vision cone then they will turn around and try to avoid it.
 - If the bravery of the human is 60+ they will go towards a zombie and try to kill it
 - The zombies will try to attack a human if they come within a certain radius of it causing up to 10 units of health loss per strike
 - If a human gets killed by a zombie then the human will become a zombie


## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

Buttons:
 - The "setup" button will make a brand-new set up of the world with all of the values that are random being remade and all of the values that are based on the sliders unchanged.
 - The "go (forever)" button will continue running the simulation forever


Sliders:
People controls:
 - "number_of_people" slider will decide the amount of people who are spawned on initial setup
 - "pwr" is the random turn rate of the people, the higher this is the more frequently the people will alter their direction
 - "people_speed" is the speed value that the people which decides how fast they are so the higher the value, the faster the people are
 - "user_bravery" is the braveness of the people added onto what they have had randomly given to them
 - "vis_rad" is used to alter the radius (length) of the vision cone that the people have
 - "vis_ang" is used to alter the angle of the vision cone that the people have

Zombie controls:
 - "number_of_zombies" will decide the number of zombies who are spawned on initial setup
 - The "zwr" is the random turn rate of the zombies, the higher this is the more frequently the zombies will alter their direction
 - "zombies_speed" is the speed value that the zombies which decides how fast they are so the higher the value, the faster the zombies are


Switches:
 - "show_col_rad" if this is enabled then the user will be able to see the collision radius of the people
 - "show_vis_cone" if this is enabled then the user will be able to see the vision cone of the people


Stats:
Plot:
 - The "Model stats" plot shows the number of people and the number of zombies - this will help you see how dramatically the values of one effect the other

Monitors:
 - The "count people" shows the amount of people at any one time
 - The "count zombies" shows the number of zombies at any one time


## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

As the amount of zombies and people spike and change watch the effect it has on the other type of turtle

Some settings when set to their maximum become too unstable, why do you think that this is, and would it be rational to use those scenarios to see how they could effect a simulation?

Are the humans that are brave enough to fight back generally the ones that survive the longest?

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

 - How do the varying numbers of people or zombies effect the rate of zombies or people overcoming the other?
 - Does having people who are more brave necessarily mean more people survive?
 - How much does the vision radius and angle help the humans?
 - Would the humans benefit by having faster people even if they aren't brave? Would they survive longer?
 - If the zombies are fast but the humans are brave will the zombies still win?

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

In real life humans often stay together for protection and for support, that could be a great thing that could be implemented into the project.

If we were to add a food system for the humans so that they relied on food then that could be more realistic as 

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

personv1
false
0
Polygon -7500403 true true 75 90 225 90 225 120 195 120 195 195 105 195 105 120 75 120 75 90
Rectangle -7500403 true true 105 0 195 90
Polygon -7500403 true true 105 195 90 270 105 285 135 285 150 195 105 195
Polygon -7500403 true true 195 195 210 270 195 285 165 285 150 195 165 195
Rectangle -16777216 true false 165 30 180 45
Rectangle -16777216 true false 120 30 135 45
Polygon -7500403 true true 75 105 60 150 60 180 90 180 105 120 90 120
Polygon -7500403 true true 225 105 240 150 240 180 210 180 195 120 210 120

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

zombiev1
false
0
Polygon -13791810 true false 75 90 225 90 225 120 195 120 195 195 105 195 105 120 75 120 75 90
Rectangle -10899396 true false 105 0 195 90
Polygon -13345367 true false 105 195 90 270 105 285 135 285 150 195 105 195
Polygon -13345367 true false 195 195 210 270 195 285 165 285 150 195 165 195
Rectangle -16777216 true false 165 30 180 45
Rectangle -16777216 true false 120 30 135 45
Polygon -10899396 true false 75 105 60 150 60 180 90 180 105 120 90 120
Polygon -10899396 true false 225 105 240 150 240 180 210 180 195 120 210 120
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
