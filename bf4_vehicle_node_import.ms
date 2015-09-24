
clearlistener();
veh_bool = false	

	--openfile dialog
skel_file = getOpenFileName caption:"Import Skeleton File" types:"SkeletonFile (*.txt)|*.txt|All Files (*.*)|*.*"
	if skel_file != undefined then 
		sfile=openfile skel_file mode:"r+"
		
scaler =39 -- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<WARNING this might offset the readouts use caution!!!!

-- 	
-- component_name_array=#()
Vehicle_BoneNodes_array=#()
PartNames_array=#()
PartIndex_Array=#()	
PID = 0

while not eof sfile do
(
	rl = readline sfile 
	
	if  matchPattern rl pattern:"*Transform::LinearTransform" do 
	(	
		PID += 1
	)							
)
	
seek sfile 0 
-- 	--function to get the matrix3
for i = 1 to PID do
(
	skiptostring sfile "Transform::LinearTransform"
	skiptonextline sfile
	skiptonextline sfile
	--read floats from 3 lines under "right::Vec3"
	rw1xf =( (trimLeft (readLine sfile) " xyz") as float)*scaler
	rw1yf =( (trimLeft (readLine sfile) " xyz") as float)*scaler
	rw1zf =( (trimLeft (readLine sfile) " xyz") as float)*scaler
	--read floats from 3 lines under "up::Vec3"
			skiptonextline sfile
	rw2xf =( (trimLeft (readLine sfile) " xyz") as float)*scaler
	rw2yf =( (trimLeft (readLine sfile) " xyz") as float)*scaler
	rw2zf =( (trimLeft (readLine sfile) " xyz") as float)*scaler
	--read floats from 3 lines under "forward::Vec3"
			skiptonextline sfile
	rw3xf =( (trimLeft (readLine sfile) " xyz") as float)*scaler
	rw3yf =( (trimLeft (readLine sfile) " xyz") as float)*scaler
	rw3zf =( (trimLeft (readLine sfile) " xyz") as float)*scaler
	--read floats from 3 lines under "trans::Vec3"
			skiptonextline sfile
	rw4xf =( (trimLeft (readLine sfile) " xyz") as float)*scaler
	rw4yf =( (trimLeft (readLine sfile) " xyz") as float)*scaler
	rw4zf =( (trimLeft (readLine sfile) " xyz") as float)*scaler
	
	row1 = point3 (rw1xf)(rw1yf)(rw1zf)
	row2 = point3 (rw2xf)(rw2yf)(rw2zf)
	row3 = point3 (rw3xf)(rw3yf)(rw3zf)
	row4 = point3 (rw4xf)(rw4yf)(rw4zf)
	
	newBone = bonesys.createbone	\
				  row4	\
				  (row4 + 0.01 * (normalize row1)) \
				  (normalize row3)
-- 			newBone.name = ("ID_"+((hierarchy_array[i+1])as string)+" "+bonenames_array[i]+"_Child_of_ID_"+(hierarchy_array[i])))
			newBone.width  = 0.01
			newBone.height = 0.01
-- 			newBone.transform = inverse tfm
			newBone.setBoneEnable false 0
			newBone.wirecolor = white
			newbone.showlinks = true
			newBone.pos.controller      = TCB_position ()
			newBone.rotation.controller = TCB_rotation ()
					  		  
	append Vehicle_BoneNodes_array newBone
	veh_bool=true

 )

if veh_bool=true do
(
	-- create new layer
	layer = LayerManager.newLayer()
	
	-- set layer's name
	layer.setname "Bones"
	
	-- add nodes to layer from array
	for n in Vehicle_BoneNodes_array do layer.addnode n
)

gc()
fclose sfile