class Simplex
  # port of Ken Perlin's improved noise implementation
  # found at http://mrl.nyu.edu/~perlin/noise/ 

  def fastfloor(x)
    (x > 0 ? x : x-1).to_i
  end

  def noise(x, y, z)
    # find unit cube that contains point
    x_ = fastfloor(x) & 255
    y_ = fastfloor(y) & 255
    z_ = fastfloor(z) & 255

    # find relative x,y,z of point in cube
    #x -= fastfloor(x)
    #y -= fastfloor(y)
    #z -= fastfloor(z)

    # compute fade curves for each of x,y,z
    u, v, w = fade(x), fade(y), fade(z)

    # hash coordinates of the 8 cube corners
     a = PT[x_  ]+y_
    aa = PT[a]+z_
    ab = PT[a+1]+z_
     b = PT[x_+1]+y_
    ba = PT[b]+z_
    bb = PT[b+1]+z_

    # and add blended results from 8 corners of cube
    lerp(w, lerp(v, lerp(u, grad(PT[aa  ], x  , y  , z  ),
                            grad(PT[ba  ], x-1, y  , z  )),
                    lerp(u, grad(PT[ab  ], x  , y-1, z  ),
                            grad(PT[bb  ], x-1, y-1, z  ))),
            lerp(v, lerp(u, grad(PT[aa+1], x  , y  , z-1),
                            grad(PT[ba+1], x-1, y  , z-1)),
                    lerp(u, grad(PT[ab+1], x  , y-1, z-1),
                            grad(PT[bb+1], x-1, y-1, z-1)))  );
  end

  def fade(t); t * t * t * (t * (t * 6 - 15) + 10); end
  def lerp(t,a,b); a + t * (b - a); end
  def grad(_hash, x, y, z)
    h = _hash & 15
    u = h<8 ? x : y
    v = h<4 ? y : ((h==12 || h==14) ? x : y)
    ((h & 1) == 0  ? u : -u) + ((h & 2) == 0 ? v : -v)
  end

  PT_PERM =[ 151,160,137,91,90,15,
   131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
   190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
   88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
   77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
   102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
   135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
   5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
   223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
   129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
   251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
   49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
   138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180    ]
  PT = []; (0...256).each { |i| PT[256+i] = PT_PERM[i]; PT[i] = PT_PERM[i] }
end


require 'bacon';  Bacon.summary_on_exit

describe 'Simplex/Perlin noise' do
  it 'initializes' do
    @perlin = Simplex.new
    @perlin.should.not.nil?
  end
  it '#noise x, y, z' do
    (1..5).map{|i| @perlin.noise(i, 0, 0) }.should == [0, 0, -1026, 2940, 95620]
    (1..5).map{|i| @perlin.noise(0, i, 0) }.should == [0, 124, 1026, 5892, -106240]
    (1..5).map{|i| @perlin.noise(0, 0, i) }.should == [0, 0, 0, 0, 0]
    (1..5).map{|i| @perlin.noise(i, i, 0) }.should == [0, -6944, -1313280, -52002816, -2144698760]
    (1..5).map{|i| @perlin.noise(i, -i, 0) }.should == [32, -19072, -3013638, 156450680, -2497106240]
  end
end
