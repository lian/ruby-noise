# Simplex noise is a method for constructing an n-dimensional noise
# function comparable to Perlin noise ("classic" noise) Ken Perlin
# designed the algorithm in 2001 to address the limitations of his
# classic noise function, especially in higher dimensions.
# Invented in 2001 by Ken Perlin. http://mrl.nyu.edu/~perlin/
class SimplexNoise
  SIMPLEX_SQRT3 = 1.73205080756888
  SIMPLEX_SQRT5 = 2.23606797749979

  SIMPLEX_F2 = 0.36602540378444
  SIMPLEX_G2 = 0.211325
  SIMPLEX_G22 = -0.57735

  SIMPLEX_F3 = 0.33333333333333
  SIMPLEX_G3 = 0.16666666666667

  SIMPLEX_F4  = 0.309017
  SIMPLEX_G4  = 0.138197
  SIMPLEX_G42 = 0.276393
  SIMPLEX_G43 = 0.41459
  SIMPLEX_G44 = -0.447214

  Grad3 = [
    [1,1,0],[-1,1,0],[1,-1,0],[-1,-1,0 ],[1,0,1],[-1,0,1],
    [1,0,-1],[-1,0,-1],[0,1,1],[0,-1,1],[0,1,-1],[0,-1,-1]
  ]

  P = [ 151, 160, 137, 91, 90, 15, 131, 13, 201,
    95, 96, 53, 194, 233, 7, 225, 140, 36, 103, 30, 69, 142, 8, 99, 37,
    240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 0, 26, 197, 62,
    94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 56,
    87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139,
    48, 27, 166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133,
    230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54, 65, 25,
    63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169, 200,
    196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3,
    64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255,
    82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42,
    223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153,
    101, 155, 167, 43, 172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79,
    113, 224, 232, 178, 185, 112, 104, 218, 246, 97, 228, 251, 34, 242,
    193, 238, 210, 144, 12, 191, 179, 162, 241, 81, 51, 145, 235, 249,
    14, 239, 107, 49, 192, 214, 31, 181, 199, 106, 157, 184, 84, 204,
    176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93, 222,
    114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156,180
  ]

  attr_reader :perm
  def initialize
    @perm = (0..512).map{|i| P[i & 255] }
  end

  def noise(x, y)
    x, y = x.to_f, y.to_f
    n0, n1, n2 = 0, 0, 0

    s = (x + y) * SIMPLEX_F2
    i = fastfloor(x + s).to_i
    j = fastfloor(y + s).to_i
	  t = (i + j) * SIMPLEX_G2
	  x0 = x - (i - t)
	  y0 = y - (j - t)

    i1, j1 = 0, 0
    (x0 > y0) ? (i1, j1 = 1, 0) : (i1, j1 = 0, 1)

    x1 = x0 - i1 + SIMPLEX_G2
    y1 = y0 - j1 + SIMPLEX_G2
    x2 = x0 + SIMPLEX_G22
    y2 = y0 + SIMPLEX_G22

    ii = i.to_i & 255
    jj = j.to_i & 255

	  t0 = 0.5 - (x0 * x0) - (y0 * y0)
    if t0 > 0
      t0 *= t0
      gi0 = @perm[ii + @perm[jj]] / 12
      n0 = t0 * t0 * dot(Grad3[gi0], x0, y0)
    end

	  t1 = 0.5 - x1 * x1 - y1 * y1
    if t1 > 0
      t1 *= t1
      gi1 = @perm[ii + i1 + @perm[jj + j1]] / 12
      n1 = t1 * t1 * dot(Grad3[gi1], x1, y1)
      t
    end

    t2 = 0.5 - x2 * x2 - y2 * y2;
    if t2 > 0
      t2 *= t2
      gi2 = @perm[ii + 1 + @perm[jj + 1]] / 12
      n2 = t2 * t2 * dot(Grad3[gi2], x2, y2)
    end

    # result
    #70.0 * (n0 + n1 + n2)
    (n0 + n1 + n2)
  end

  def dot(g, x, y)
    g = [0,0,0] unless g
    #g = [1,1,1] unless g
    g[0].to_i * x  +  g[1].to_i * y 
  end

  def fastfloor(x)
    x > 0 ? x : x-1
  end
end


#__END__
require 'bacon'
Bacon.summary_on_exit

describe SimplexNoise do
  it 'initiailes' do
    SimplexNoise::P.size.should == 256
    SimplexNoise::P[0..5   ].should == [151, 160, 137, 91, 90, 15]
    SimplexNoise::P[250..260].should == [78, 66, 215, 61, 156, 180]

    @simplex = SimplexNoise.new
    @simplex.perm.size == 512
    @simplex.perm[0..5    ].should == [151, 160, 137, 91, 90, 15]
    @simplex.perm[250..260].should == [78, 66, 215, 61, 156, 180, 151, 160, 137, 91, 90]
    @simplex.perm[510..-1 ].should == [156, 180, 151]
  end

  it '#noise x, y' do
    # hrm, not sure if this is right. not quite how to use simplex yet, had no reason.

    #@simplex.noise(0.2, 1.2).to_s.should === '0.00622229067169459'
    @simplex.noise(1, 2).to_s.should === '0.00336096381024259'

    (@simplex.noise(1, 2) * 10000).to_i.should == 33
    (@simplex.noise(10, 22) * 10000).to_i.should == 2
    (@simplex.noise(10, 100) * 10000).to_i.should == -1
    (@simplex.noise(300, 240) * 10000).to_i.should == 62
    (@simplex.noise(10, 720) * 10000).to_i.should == 0
    (@simplex.noise(10, 720) * 1000000000000000000).to_s.should ==  '1.53567974087673'
    #("%i" % [@simplex.noise(10, 720)]).should == ''
  end
end

