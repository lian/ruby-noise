class Perlin
  # simple perlin noise, pure ruby.
  # Invented in 1985 by Ken Perlin. http://mrl.nyu.edu/~perlin/
  # port of c extension: github.com/boj/ruby-perlin

  attr_reader :seed
  def initialize(seed, presistence=1.0, octave=1)
    @seed = seed || rand
    @p, @o = presistence, octave
  end

  def rand_seed
    @seed = (rand * 10000).to_i
  end

  def interpolate(a, b, x)
    ft = x * Math::PI;  f = (1-Math.cos(ft)) * 0.5
    a * (1 - f) + b * f
  end

  def noise(x, y)
    n = x + y * 57;  n = (n << 13) ^ n
    1.0 - ((n * (n * n * 0x3d73*seed + 0xc0ae5*seed) + 0x5208dd0d*seed) & 0x7fffffff) / (0x40000000).to_f
  end

  def smooth_noise(x, y)
    corners = (noise(x-1, y-1) + noise(x+1, y-1) + noise(x-1, y+1) + noise(x+1, y+1)) / 16
    sides   = (noise(x-1, y)   + noise(x+1, y)   + noise(x, y-1)   + noise(x, y+1)  ) / 8
    corners + sides + (noise(x,y) / 4)
  end

  def interpolated_noise(x, y)
    ix = x.to_i
    iy = y.to_i
    fractional_x = x - ix
    fractional_y = y - iy

    v1 = smooth_noise(ix, iy)
    v2 = smooth_noise(ix+1, iy)
    v3 = smooth_noise(ix, iy+1)
    v4 = smooth_noise(ix+1, iy+1)

    interpolate(
      interpolate(v1, v2, fractional_x),
      interpolate(v3, v4, fractional_x),
      fractional_y
    )
  end

  def run(x, y, _presistence=@p, _octave=@o)
   total, frequency, amplitude = 0.0, 1.0, 1.0
   _octave.times do
     total += interpolated_noise(x.to_i * frequency, y.to_i * frequency) * amplitude
     frequency *= 2;  amplitude *= _presistence
   end
   total
  end

  def run_ascii(w,h)
    self.class.run_ascii(seed, @p, @o, w, h, self)
  end

  def self.run_ascii(seed, p, o, h, w, kl=nil)
    perlin, res = (kl || new(seed, p, o)), ''
    (1..h).each do |y|
      (1..w).each do |x|
        n = perlin.run(x, y)
        if n >= 0.9
          res += '^'
        elsif n < 0.9 and n > 0.7
          res += '%'
        elsif n < 0.7 and n > 0.5
          res += '*'
        elsif n < 0.5 and n > 0.3
          res += '#'
        elsif n < 0.3 and n > 0.1
          res += '.'
        elsif n < 0.1 and n > -0.1
          res += ','
        else
          res += ' '
        end
      end; res += "\n"
    end
    res
  end
end



require 'bacon';  Bacon.summary_on_exit

describe 'Perlin noise' do
  it 'initiailizes' do
    @perlin = Perlin.new(123, 1.0, 1)
    @perlin.seed.should == 123
    @perlin.instance_eval{ @p }.should == 1.0
    @perlin.instance_eval{ @o }.should == 1
  end

  it '#run interpolates noise' do
    perlin = Perlin.new(210, 0.5, 2)
    (0...3).map{|i| (perlin.run(i,i)*1000).to_i }.should === [-97, -122, -220 ]
    (0...3).map{|i| (@perlin.run(i,i)*1000).to_i }.should === [ -211, -341, -564 ]
  end

  it '#run_ascii' do
    p1 = @perlin.run_ascii(16, 32)
    p1.size.should == 16 + (16 * 32)

    p2 = Perlin.run_ascii(123, 1.0, 1, 16, 32)
    p1.should == p2
  end
end

