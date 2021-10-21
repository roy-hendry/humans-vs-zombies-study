# humans-vs-zombies-study
 
This is a netlogo program to see the interaction between humans and zombies.
This is the simulation from Roy Hendry and Harry Davis to show how we expect humans and zombies to interact based off our variables we deem important and our thought process of the most important factors.

What rules the agents use to create the overall behaviour of the model:
If the bravery of the human is below 60: The people will run around and if they see a zombie in their vision cone then they will turn around and try to avoid it.
If the bravery of the human is 60+ they will go towards a zombie and try to kill it
The zombies will try to attack a human if they come within a certain radius of it causing up to 10 units of health loss per strike
If a human gets killed by a zombie then the human will become a zombie

The factors considered are:
Number of people
People random turn rate
People speed
People bravery

Number of zombies
Zombie random turn rate
Zombie speed

Vision radius
Vision cone angle
