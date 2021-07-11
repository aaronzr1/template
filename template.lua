--[[

Basic Template for S4 Simulation:
 - define structure parameters
 - set up incident light wave
 - calculate reflection and transmission

]]

-- Create Simulation
S = S4.NewSimulation()
S:SetLattice({1,0},{0,1})
S:SetNumG(32) --adjusted for computation time and memory usage

-- Define materials in the structure (name of material + real/imaginary components of permittivity)
S:AddMaterial('Vacuum', {1.0,0})
S:AddMaterial('GaAs', {3.5^2,0})

-- Define the geometric parameters of the patterned layer and normalize based on a
a = 0.637 -- periodicity/lattice constant
r = 0.285/a -- radius of hole
t = 0.23/a -- thickness of layer

-- Define the layers of the structure (name of layer, thickness, material); 0 means infinite thickness
S:AddLayer('air_above', 0, 'Vacuum')
S:AddLayer('patterned_layer', t, 'GaAs')
S:AddLayer('substrate', 0 , 'Vacuum')

-- Define the patterning on the patterned layer
S:SetLayerPatternCircle('patterned_layer', 'Vacuum', {0,0}, r)

-- Define input light source
S:SetExcitationPlanewave(
	{0,0}, 	-- incident angles: phi (0, 180) and theta (0, 360)
	{1,0}, 	-- s-polarization amplitude and phase (in degrees)
	{0,90})	-- p-polarization amplitude and phase

-- Simulate transmission/reflection and output into a .txt file
wvl_start = 0.9
wvl_end = 1.1
wvl_step = 0.0001
outfile = io.open('output.txt', 'w')
outfile:write('wvl, freq, reflectance, transmission\n')

for wvl = wvl_start, wvl_end, wvl_step do
	freq = a/wvl
	S:SetFrequency(freq)

	-- we only care about -pyntbacktop (reflectance) and pyntfowbot (transmission)
	pyntfowtop, pyntbacktop = S:GetPoyntingFlux('air_above', 0)
	pyntfowbot, pyntbackbot = S:GetPoyntingFlux('substrate', 0)
	outfile:write(wvl .. ',' .. freq .. ',' .. -pyntbacktop .. ',' .. pyntfowbot .. '\n') -- record wvl, freq, reflectance, and transmission
	-- outfile:write(wvl .. ',' .. freq .. ',' .. 1-pyntfowbot .. ',' .. pyntfowbot ..  '\n') -- does same thing
end