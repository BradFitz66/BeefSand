# BeefSand
Falling sand simulation made using Beef Language and Atma.Framework.

The point of this is to create a falling sand simulation with a scalable world with good performance. 
A lot of optimizations that are going into this are from the GDC talk for Noita.


## Todo

- [ ] Add multi-threading. This can be done via updating the world chunks in a checkerboard pattern as described in Noita's GDC talk. Will probably be done last
- [x] Chunk the world. Split world into chunks that are updated individually. COMPLETED
- [x] Dirty rect. Have each chunk contain a dirty rect which is the area that needs updating. This limits the amount of particles we iterate over each chunk. COMPLETED*
- [x] Particle sleeping. Particles that haven't moved in a while have a flag set that makes them get ignored by the update loop until the flag is unset. COMPLETED*
- [ ] Box2D. Using the method described in the GDC talk, implement Box2D physics that can interact with the falling sand simulation (currently no ports of Box2D for Beef AFAIK)  

*dirty rect is currently very buggy. Particles can get stuck on chunk borders etc. Needs to be fixed before continuing.

*Particle sleeping is mostly made redundant by dirty rects
