# draws simple perlin canvas using ffi-tk.
require 'ffi-tk'
Tk.init

require 'lib/perlin2.rb'
Noise = Perlin.new 123

require 'lib/perlin.rb'
Noise2 = PerlinNoise.new 123


@canvas = Tk::Canvas.new(Tk.root, width: 700, height: 200, background: 'black')
@perlin_poly = @canvas.create_polygon(0, 10, 10, 15)
@canvas.create_line(0, 200/2, 700, 200/2, fill: 'grey')
@perlin_poly.configure(fill: 'blue', joinstyle: :round) #, smooth: true)

@canvas2 = Tk::Canvas.new(Tk.root, width: 700, height: 200, background: 'black')
@perlin_poly2 = @canvas2.create_polygon(0, 10, 10, 15)
@canvas2.create_line(0, 200/2, 700, 200/2, fill: 'grey')
@perlin_poly2.configure(fill: 'yellow', joinstyle: :round) #, smooth: true)


def render_canvas
  time = Time.now
  mouseX, mouseY = 50, 13
  div = mouseY

  ys = [[],[]]
  700.times do |n|
    if n.even?
      y = Noise.run(n/div, mouseX/div)
      y *= 50
      y += 200/2
      ys[0] += [n, y]

      y = Noise2.noise(n/div, mouseX/div, 0)
      y += 200/4
      ys[1] += [n, y]
    end
  end
  @perlin_poly.coords(0, 200, *ys[0], 700, 200)
  @perlin_poly2.coords(0, 200, *ys[1], 700, 200)
  puts "canvas update takes %f seconds" % [Time.now - time]
  true
end


def update_canvas
  Noise.rand_seed
  Noise2.rand_seed
  render_canvas
end

def clear_canvas
  @perlin_poly.coords(0,0); @perlin_poly2.coords(0,0)
end


#Tk::Button.new(Tk.root, text: 'quit'){ Tk.exit }.pack
Tk::Button.new(Tk.root, text: 'clear'){ clear_canvas }.pack
Tk::Button.new(Tk.root, text: 'rand_seed'){ update_canvas }.pack
Tk.root.bind('<Control-q>') { Tk.exit }
Tk.root.bind('<Key-n>') { update_canvas }
Tk.root.bind('<Key-c>') { clear_canvas }

[@canvas, @canvas2].each(&:pack)


b = lambda { update_canvas; Tk::After.ms(9000, &b) }
Tk::After.ms(1000, &b)


Tk.mainloop

__END__
bi = lambda do
  inactive = Tk.root.tk_inactive
  if inactive > 6000
    update_canvas
    Tk.root.tk_inactive('reset')
    Tk::After.ms(2000, &bi)
  else
    Tk::After.ms(2000, &bi)
  end
end

