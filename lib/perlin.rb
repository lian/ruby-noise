# Perlin noise is a procedural texture primitive, used by visual
# effects artists to increase the appearance of realism in computer
# graphics. This is a type of gradient noise.
class PerlinNoise
  PERLIN_YWRAPB = 4
  PERLIN_YWRAP = 1 << PERLIN_YWRAPB;
  PERLIN_ZWRAPB = 8
  PERLIN_ZWRAP = 1 << PERLIN_ZWRAPB;
  PERLIN_SIZE = 4095
  PERLIN_MIN_AMPLITUDE = 0.001

  SC_PRECISION = 0.25
  Lut_DEG_TO_RAD = (Math::PI / 180.0) * SC_PRECISION
  Lut_RAD_TO_DEG = (180.0 / Math::PI) / SC_PRECISION

  SC_INV_PREC = 1.0 / SC_PRECISION
  SC_PERIOD = (360.0 * SC_INV_PREC).to_i
  SinLUT = (0..SC_PERIOD).map{|i| 0.0 }
  CosLUT = (0..SC_PERIOD).map{|i| 0.0 }

  SC_PERIOD.times do |i|
    SinLUT[i] = Math.sin(i * Lut_DEG_TO_RAD)
    CosLUT[i] = Math.cos(i * Lut_DEG_TO_RAD)
  end


  def initialize(_seed=100, _ampl=0.5, _falloff=0.5)
    @perlin_octaves = (1..4).to_a  # 0..3
    @amp_falloff, @ampl_t = _falloff, _ampl

    @p_TWO_PI = @p_PI = SC_PERIOD.to_i
    @p_PI = @p_PI >> 1;

    seed_noise _seed
  end

  def seed_noise(_what)
    srand _what
    @perlin = (0..PERLIN_SIZE+1).map{|i| (rand * 100).to_i }
    srand # reset seed again..
  end

  def noise_fsc(_f)
    #@cosTable = CosLUT;
    0.5 * (1.0 - CosLUT[_f * @p_PI  /  @p_TWO_PI])
  end

  def noiseuf(*args)
    (noise(*args) * 0.5) + 0.5
  end

  def noise(*args)
    case args.size
    when 1
      noise_x *args
    when 2
      noise_x_y *args
    when 3
      noise_x_y_z *args
    else
      raise ArgumentError
    end
  end

  def noise_x _x
    x  = _x.to_f
    x  = -x if x < 0
    xi = x.to_i
    xf = x - xi

    ampl = @ampl_t
    rxf, n1 = 0.to_f, 0.to_f
    result = 0.0

    @perlin_octaves.each do |i|
      of = xi
      rxf = noise_fsc(xf)

      n1 = @perlin[of & PERLIN_SIZE]
      n1 += rxf * (@perlin[of + 1] & PERLIN_SIZE - n1)

      of += PERLIN_ZWRAP

      result += n1 * ampl
      ampl *= @amp_falloff 

      break if ampl < PERLIN_MIN_AMPLITUDE

      xi = xi << 1
      xf = xf * 2

      (xi+=1 and xf-=1) if xf >= 1.0
      #p '%i => %i' % [ i, result ]
    end

    result
  end

  def noise_x_y(_x, _y)
    x, y  = _x.to_f, _y.to_f
    x  = -x if x < 0
    y  = -y if y < 0
    xi, yi = x.to_i, y.to_i

    xf, yf = (x - xi), (y -yi)

    ampl = @ampl_t
    rxf, ryf = 0.0, 0.0
    n1, n2, n3 = 0.0, 0.0, 0.0
    result = 0.0

    @perlin_octaves.each do |i|
      of = xi + (yi << PERLIN_YWRAPB)
      rxf = noise_fsc(xf)
      ryf = noise_fsc(yf)

      n1 = @perlin[of & PERLIN_SIZE];
      n1 += rxf * (@perlin[(of + 1) & PERLIN_SIZE] - n1);
      n2 = @perlin[(of + PERLIN_YWRAP) & PERLIN_SIZE];
      n2 += rxf * (@perlin[(of + PERLIN_YWRAP + 1) & PERLIN_SIZE] - n2);
      n1 += ryf * (n2 - n1);

      of += PERLIN_ZWRAP;
      n2 = @perlin[of & PERLIN_SIZE];
      n2 += rxf * (@perlin[(of + 1) & PERLIN_SIZE] - n2);
      n3 = @perlin[(of + PERLIN_YWRAP) & PERLIN_SIZE];
      n3 += rxf * (@perlin[(of + PERLIN_YWRAP + 1) & PERLIN_SIZE] - n3);
      n2 += ryf * (n3 - n2);

      result += n1 * ampl
      ampl *= @amp_falloff 

      break if ampl < PERLIN_MIN_AMPLITUDE

      xi = xi << 1
      xf = xf * 2

      yi = yi << 1
      yf = yf * 2

      (xi+=1 and xf-=1) if xf >= 1.0
      (yi+=1 and yf-=1) if yf >= 1.0
      #p '%i => %i' % [ i, result ]
    end

    result
  end

  def noise_x_y_z(_x, _y, _z)
    x, y, z  = _x.to_f, _y.to_f, _z.to_f
    x  = -x if x < 0
    y  = -y if y < 0
    z  = -z if z < 0
    xi, yi, zi = x.to_i, y.to_i, z.to_i

    xf, yf, zf = (x - xi), (y -yi), (z - zi)

    ampl = @ampl_t
    rxf, ryf = 0.0, 0.0
    n1, n2, n3 = 0.0, 0.0, 0.0
    result = 0.0

    @perlin_octaves.each do |i|
      of = xi + (yi << PERLIN_YWRAPB) + (zi << PERLIN_ZWRAPB)
      rxf = noise_fsc(xf)
      ryf = noise_fsc(yf)

      n1 = @perlin[of & PERLIN_SIZE];
      n1 += rxf * (@perlin[(of + 1) & PERLIN_SIZE] - n1);
      n2 = @perlin[(of + PERLIN_YWRAP) & PERLIN_SIZE];
      n2 += rxf * (@perlin[(of + PERLIN_YWRAP + 1) & PERLIN_SIZE] - n2);
      n1 += ryf * (n2 - n1);

      of += PERLIN_ZWRAP;
      n2 = @perlin[of & PERLIN_SIZE];
      n2 += rxf * (@perlin[(of + 1) & PERLIN_SIZE] - n2);
      n3 = @perlin[(of + PERLIN_YWRAP) & PERLIN_SIZE];
      n3 += rxf * (@perlin[(of + PERLIN_YWRAP + 1) & PERLIN_SIZE] - n3);
      n2 += ryf * (n3 - n2);

		  n1 += noise_fsc(zf) * (n2 - n1);

      result += n1 * ampl
      ampl *= @amp_falloff 

      break if ampl < PERLIN_MIN_AMPLITUDE

      xi = xi << 1
      xf = xf * 2

      yi = yi << 1
      yf = yf * 2

      zi = zi << 1
      zf = zf * 2

      (xi+=1 and xf-=1) if xf >= 1.0
      (yi+=1 and yf-=1) if yf >= 1.0
      (zi+=1 and zf-=1) if zf >= 1.0
      #p '%i => %i' % [ i, result ]
    end

    result
  end
end




#__END__
require 'bacon'
Bacon.summary_on_exit


describe 'PerlinNoise' do
  it 'initializes' do
    @perlin = PerlinNoise.new 100  # seed of 100
    @perlin.instance_eval { @p_TWO_PI }.should == 1440
    @perlin.instance_eval { @p_PI }.should == 720
  end

  it '#noise takes 1-3 numbers (x, y, z)' do
    lambda { @perlin.noise }.should.raise ArgumentError
    lambda { @perlin.noise(0, 0, 0, 0) }.should.raise ArgumentError
  end

  it '#noise x' do
    (0..10).map { |n| @perlin.noise(n) }.should == [
      50.625, 24.8125, 27.6875, 62.0625, 14.0, 38.25, 41.875, 57.1875, 33.8125, 62.0625, 67.625
    ]
  end

  it '#noiseuf x' do
    (0..10).map { |n| @perlin.noiseuf(n) }.should == [
      25.8125, 12.90625, 14.34375, 31.53125, 7.5, 19.625, 21.4375, 29.09375, 17.40625, 31.53125, 34.3125
    ]
  end

  it '#noise x, y' do
    (0..10).map { |n| @perlin.noise(n, n) }.should == [
      50.625, 17.375, 19.1875, 73.25, 38.0625, 26.625, 60.8125, 52.125, 41.8125, 48.125, 25.4375
    ]
  end

  it '#noiseuf x, y' do
    (0..10).map { |n| @perlin.noiseuf(n, n) }.should == [
      25.8125, 9.1875, 10.09375, 37.125, 19.53125, 13.8125, 30.90625, 26.5625, 21.40625, 24.5625, 13.21875
    ]
  end

  it '#noise x, y, z' do
    (0..10).map { |n| @perlin.noise(n, n, n) }.should == [
      50.625, 75.4375, 66.3125, 58.125, 50.3125, 9.8125, 34.5625, 40.5625, 53.3125, 52.5625, 8.8125
    ]
  end

  it '#noiseuf x, y, z' do
    (0..10).map { |n| @perlin.noiseuf(n, n, n) }.should == [
      25.8125, 38.21875, 33.65625, 29.5625, 25.65625, 5.40625, 17.78125, 20.78125, 27.15625, 26.78125, 4.90625
    ]
  end

  it '#seed_noise seed' do
    @perlin.seed_noise 3  # whatever
    (0..10).map { |n| @perlin.noise(n) }.should == [
      51.5625, 53.6875, 37.5, 39.875, 51.625, 51.0, 30.4375, 35.875, 16.25, 40.875, 13.75
    ]
  end
end
