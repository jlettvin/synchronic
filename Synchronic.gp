#!/usr/bin/env gnuplot

limit=10.0
inflection=5.0
delta=0.1
dz=limit/2
delta=1e-3

set xrange[-limit:+limit]
set yrange[-limit:+limit]
set zrange[-limit*3:limit**2]
set view 84,15
set term pngcairo size 600,800 enhanced crop

approx(a,b)          = (abs(a-b)<=delta)
radius(x,y)          = sqrt(x**2+y**2)
plane(x,y,z)         = z
paraboloid(r)        = (r<10                  ? r**2    : 1/0)
cylinder(x,y,z,r) = (approx(radius(x,y),r) ? z+limit**2: 1/0)
circle(x,y,z,r)      = (approx(radius(x,y),r) ? z       : 1/0)
circlefit(x,y,r)     = (approx(radius(x,y),r) ? r**2    : 1/0)

radius(x,y)=sqrt(x*x+y*y)
u(a,x0,y0,x,y)=radius(x-x0,y-y0)*pi/a
wave(i0,a,x0,y0,x,y)=sqrt(abs(i0))*2*besj1(u(a,x0,y0,x,y))/u(a,x0,y0,x,y)
Airy(i0,a,x0,y0,x,y)=wave(i0,a,x0,y0,x,y)**2
diff1(i0,a,x0,y0,x,y,delta)=1e3*\
  (Airy(i0,a,x0      ,y0      ,x,y)-\
  (Airy(i0,a,x0+delta,y0      ,x,y)+\
   Airy(i0,a,x0      ,y0+delta,x,y)+\
   Airy(i0,a,x0-delta,y0      ,x,y)+\
   Airy(i0,a,x0,      y0-delta,x,y))/4)
decay(i0,a,x0,y0,x,y)=tanh(-1e1*Airy(i0,a,x0,y0,x,y))
diff2(i0,a,x0,y0,x,y,delta)=1e5*tanh(1e2*\
  (decay(i0,a,x0      ,y0      ,x,y)-\
  (decay(i0,a,x0+delta,y0      ,x,y)+\
   decay(i0,a,x0      ,y0+delta,x,y)+\
   decay(i0,a,x0-delta,y0      ,x,y)+\
   decay(i0,a,x0,      y0-delta,x,y))/4))
signal(i0,a,x0,y0,x,y)=diff2(i0,a,x0,y0,x,y,delta)>30 ? 0 : 1/0

set isosamples 51

set nokey
set title  "\
Point source Airy pattern\n\
on photoreceptors(magenta)"
set output "Airy.png"
splot \
    -20+Airy(100,5,0,0,x,y) with lines lt rgb "magenta"

set nokey
set title  "\
Airy differences\n\
(red)"
set output "Differences.png"
splot \
    diff1(100,5,0,0,x,y,delta) with lines lt rgb "red"

set nokey
set title  "\
Airy signal\n\
(cyan)"
set output "Signal.png"
splot \
    signal(100,5,0,0,x,y) with lines lt rgb "cyan"

set nokey
set title  "\
Airy decay\n\
(cyan)"
set output "Decay.png"
splot \
    diff2(100,5,0,0,x,y,delta) with lines lt rgb "cyan"

set samples 21
set isosamples 21

set nokey
set title  "\
IPL Plane\n\
efferent-fed amacrines(green)"
set output "Plane.png"
splot \
    plane(x,y,inflection**2) with points  pt 7 ps 1 lt rgb "green"

set nokey
set title  "\
IPL Cylinder\n\
ascending bipolar sensor signals(blue)"
set output "Cylinder.png"
splot \
    for [z=0:limit**2:dz]                                 \
        -80+cylinder(x,y,z-inflection**2,inflection) \
        with points pt 7 ps 1 lt rgb "blue"

#set pm3d
set nokey
set title  "\
IPL Paraboloid\n\
descending bipolar convolution(red)"
set output "Paraboloid.png"
splot \
    paraboloid(radius(x,y)) with points pt 7 ps 1 lt rgb "red"

set arrow 1 from 0,0,0 to 0,0,-limit*3 lw 3 lt rgb "orange"
set nokey
set title  "\
IPL Synchronic (triple intersection)\n\
ascending bipolar sensor signals(blue)\n\
efferent-fed amacrines(green)\n\
descending bipolar convolution(red)\n\
intersection(yellow)\n\
hyperacute detection (orange)"
set output "Synchronic.png"
splot \
    paraboloid(radius(x,y))       with points lc rgb "red" pt 7 ps 1, \
    plane(x,y,inflection**2)      with points lc rgb "green" pt 7 ps 1, \
    for [z=0:limit**2:dz]                                 \
        -80+cylinder(x,y,z-inflection**2,inflection)      \
        with points pt 7 ps 1 lt rgb "blue",              \
    circlefit(x,y,inflection)     with points lc rgb "yellow" pt 7 ps 1
