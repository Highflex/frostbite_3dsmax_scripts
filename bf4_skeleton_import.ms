-- By Dainius G. 21.08.2014
-- Edits by Highflex 27.09.15
--	-> Rewritten to support max 16
--	-> Cleaned up Structure
--	-> Bone count is now calculated before reading the file
--	-> Tested with MAX 2016

clearlistener();

--openfile dialog
fname = getOpenFileName \ 
	caption:"Import skeleton file" \ 
	types:"Skeleton data (*.txt)|*.txt" \ 
	historyCategory:"Skeleton data" 
		f = openfile fname
		b = openfile fname
		m =  openfile fname
		fbn = fopen fname "rb"
		
--initialize arrays		
boneposFloats_array=#()
hierarchy_array=#()
bonenames_array=#()
bone_array=#()
bnarr=#()

bcount_loop=0
dy_bonecount=0

--set scale for floats	
scaler =39

--skip to hierachy and get bone count
seek f 0
skiptostring f "Hierarchy::array"
skiptonextline f

while(bcount_loop != "LocalPose::array") do
(
	bcount_loop = trimleft (readLine f) " " as string
	dy_bonecount = dy_bonecount + 1
)

dy_bonecount = dy_bonecount - 2 -- subtract last and first line :V

--skip to hierachy again and read
seek f 0
skiptostring f "Hierarchy::array"
skiptonextline f

--read hierachy array
seek f 0
skiptostring f "Hierarchy::array"
skiptonextline f
skiptonextline f
for i = 1 to dy_bonecount do 
(
	h1	 = trimleft (readLine f) as string
	h2	= filterString h1 " "
	append hierarchy_array h2[2]
)	

--read bonenames and append them to the array
seek b 0	
skiptostring b "BoneNames::array"	
skiptonextline b
skiptonextline b

for k in hierarchy_array do 
(
	bn1 = trimleft (readLine b) as string
	bn2 = filterString bn1 " "
	append bonenames_array bn2[2]
)	

--skip first array because it apears it has some invalid data
skiptostring m "ModelPose::array"
bonesbool= false

--function to get the matrix3
for i = 1 to dy_bonecount do
(	
	BoneName = bonenames_array[i]
	skiptostring m ("member("+((i-1 as integer) as string)+")::LinearTransform")
	skiptonextline m
	skiptonextline m
	skiptonextline m
	skiptonextline m

	rw1x = filterString (readLine m) " "
	rw1y = filterString (readLine m) " "
	rw1z = filterString (readLine m) " "
	rw1xf = rw1x[2] as float*scaler
	rw1yf = rw1y[2] as float*scaler
	rw1zf = rw1z[2] as float*scaler
	
	skiptonextline m
	skiptonextline m
	
	rw2x = filterString (readLine m) " "
	rw2y = filterString (readLine m) " "
	rw2z = filterString (readLine m) " "
	rw2xf = rw2x[2] as float*scaler
	rw2yf = rw2y[2] as float*scaler
	rw2zf = rw2z[2] as float*scaler
	
	skiptonextline m
	skiptonextline m

	rw3x = filterString (readLine m) " "
	rw3y = filterString (readLine m) " "
	rw3z = filterString (readLine m) " "
	rw3xf = rw3x[2] as float*scaler
	rw3yf = rw3y[2] as float*scaler
	rw3zf = rw3z[2] as float*scaler
	
	skiptonextline m
	skiptonextline m
	
	rw4x = filterString (readLine m) " "
	rw4y = filterString (readLine m) " "
	rw4z = filterString (readLine m) " "
	rw4xf = rw4x[2] as float*scaler
	rw4yf = rw4y[2] as float*scaler
	rw4zf = rw4z[2] as float*scaler

	row1 = point3 (rw1xf)(rw1yf)(rw1zf)
	row2 = point3 (rw2xf)(rw2yf)(rw2zf)
	row3 = point3 (rw3xf)(rw3yf)(rw3zf)
	row4 = point3 (rw4xf)(rw4yf)(rw4zf)
	
	if (getNodeByName BoneName) != undefined do 
	(
		append BNArr (getNodeByName BoneName)
	)
	
	if (getNodeByName BoneName) == undefined do 
	(
		BoneParent = hierarchy_array[i]
		BP_ID = BoneParent as integer +1
		
		newBone = bonesys.createbone	\
				  row4	\
				  (row4 + 0.01 * (normalize row1)) \
				  (normalize row3)
		
		newBone.name = bonenames_array[i]--+"_Child_of_ID_"+(hierarchy_array[i])))-- bonenames_array[i]
		newBone.width  = 0.01
		newBone.height = 0.01
		--newBone.transform = inverse tfm
		newBone.setBoneEnable false 0
		newBone.wirecolor = white
		newbone.showlinks = true
		newBone.pos.controller      = TCB_position ()
		newBone.rotation.controller = TCB_rotation ()
		
			if (BP_ID!=0) then newBone.parent = BNarr[BP_ID]		  
				append BNArr newBone
	)	
	
	bonesbool = true
)

if bonesbool == true do
(
	-- create new layer
	layer = LayerManager.newLayer()
			
	-- set layer's name
	layer.setname (getfilenamefile fname)
			
	-- add nodes to layer from array
	for n in BNArr do layer.addnode n
		rotate $Reference (angleaxis 90 [1,0,0]))

fclose m
gc()
fclose f
fclose b



