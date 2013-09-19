##script to plot points and their errorboxes in blender
#added colour option
#drawing a plane from #plane line
#added scaling factor to shrink values to fit in blender scene
#point size now proportional to smallest error
#05: set tmat on object not on mesh such that local translation along xy is possible
#06: read in first plane normal, then plane offset
#07: changed calculation of rot-mat to Euler axis and angle representation, centering not yet working
#08: added plotting of estimated iline
#09: added plotting of error-ellipsoid (error in p) and the elliptic error cone (EDC) (error in v)

import math
import sys,os,getopt
import optparse  # to parse options for us and print a nice help message

import bpy
import Blender as B 


# get the args passed to blender after "--", all of which are ignored by blender specifically
# so python may receive its own arguments
argv= sys.argv

if '--' not in argv:
   argv = [] # as if no args are passed
else:
   argv = argv[argv.index('--')+1: ]  # get all args after "--"

point_size= .3 # relative scaling to smallest error

# When --help or no args are given, print this help
usage_text =  'Run blender in background mode with this script:'
usage_text += '  blender -b -P <skript_name> -- [options]'

parser = optparse.OptionParser(usage = usage_text)

parser.add_option('-i', '--input', dest='input', help='Input file containing the points and their errors.', type='string')
parser.add_option('-o', '--output', dest='output', help='Output file where the scene will be saved in. Suffix sets the format: Blender (.blend); DXF (.dxf); STL (.stl); Videoscape (.obj); VRML 1.0 (.wrl)', type='string')
parser.add_option('-r', '--red', dest='r', help='Red colour for the points and their errorboxes.', type='float')
parser.add_option('-g', '--green', dest='g', help='Green colour for the points and their errorboxes.', type='float')
parser.add_option('-b', '--blue', dest='b', help='Blue colour for the points and their errorboxes.', type='float')
parser.add_option('-s', '--scale', dest='s', help='Scale factor to shrink extensions to blender scene (max 10000).', type='float')

options, args = parser.parse_args(argv)

if not argv:
   parser.print_help()
   sys.exit(1)

if not options.input:
   print 'Need an input file'
   parser.print_help()
   sys.exit(1)

if not options.output:
   print 'Need an output file'
   parser.print_help()
   sys.exit(1)


in_file = open(options.input, "r")
#out_file = open(options.output, "w")

####remove all objects fromt the default scene, could be made a start option
#scn = B.Scene.GetCurrent() #deprecated????
scn= bpy.data.scenes.active

# obs = scn.objects
# #ob = [ob for ob in obs if ob.name == 'Cube'][0] #get FIRST Cube !?!
# ob = [ob for ob in obs if ob.type == 'Mesh'][0]
# for ob in obs:
#     scn.objects.unlink(ob)
#     #print "Unlinking object: " + str(ob)
#     print "Unlinking object: ", ob
# obs = scn.objects


##material for the point
matp = B.Material.New('p_mat')         
matp.rgbCol = [options.r, options.g, options.b]          # change its color
matp.setAlpha(1.0)                     # mat.alpha = 0.2 -- almost transparent
matp.emit = 0.2                        # equivalent to mat.setEmit(0.8)
#matp.mode |= B.Material.Modes.VCOL_PAINT # turn on vertex colouring
matp.mode |= B.Material.Modes.ZTRANSP    # turn on Z-Buffer transparency

##material for the error box
matb = B.Material.New('p_mat')         
matb.rgbCol = [options.r, options.g, options.b]          # change its color
matb.setAlpha(0.5)                     # mat.alpha = 0.2 -- almost transparent
matb.emit = 0.2                        # equivalent to mat.setEmit(0.8)
#matb.mode |= B.Material.Modes.VCOL_PAINT # turn on vertex colouring
matb.mode |= B.Material.Modes.ZTRANSP    # turn on Z-Buffer transparency

##material for the fitted plane
matplane = B.Material.New('plane_mat')         
#matplane.rgbCol = [options.r, options.g, options.b]          # change its color
matplane.rgbCol = [0, 0, 1]          # change its color
matplane.setAlpha(.5)                     # mat.alpha = 0.2 -- almost transparent
matplane.emit = 0.8                        # equivalent to mat.setEmit(0.8)
#matb.mode |= B.Material.Modes.VCOL_PAINT # turn on vertex colouring
matplane.mode |= B.Material.Modes.ZTRANSP    # turn on Z-Buffer transparency

##material for the fitted iline
mati= B.Material.New('iline_mat')       # normals and inside faces
mati.rgbCol = [0, 0, 0]          # change its color
mati.setAlpha(0.5)                     # mat.alpha = 0.2 -- almost transparent
mati.emit = 0.6                        # equivalent to mat.setEmit(0.8)
mati.spec = 0
mati.mode |= B.Material.Modes.WIRE # turn on vertex colouring
mati.mode |= B.Material.Modes.ZTRANSP    # turn on Z-Buffer transparency

##material for the error ellipsoid
mateell = B.Material.New('eell_mat')         
#matplane.rgbCol = [options.r, options.g, options.b]          # change its color
mateell.rgbCol = [1, 1, 0]          # change its color
mateell.setAlpha(.5)                     # mat.alpha = 0.2 -- almost transparent
mateell.emit = 0.8                        # equivalent to mat.setEmit(0.8)
#matb.mode |= B.Material.Modes.VCOL_PAINT # turn on vertex colouring
mateell.mode |= B.Material.Modes.ZTRANSP    # turn on Z-Buffer transparency

##material for the error EDC
mateEDC = B.Material.New('eell_mat')         
#matplane.rgbCol = [options.r, options.g, options.b]          # change its color
mateEDC.rgbCol = [1, 1, 0]          # change its color
mateEDC.setAlpha(.5)                     # mat.alpha = 0.2 -- almost transparent
mateEDC.emit = 0.8                        # equivalent to mat.setEmit(0.8)
#matb.mode |= B.Material.Modes.VCOL_PAINT # turn on vertex colouring
mateEDC.mode |= B.Material.Modes.ZTRANSP    # turn on Z-Buffer transparency


w= B.World.Get('World') #assume there exists a world named "world"
w.hor = [1,1,1] #make the backgroung white

ln= sum([1 for line in in_file]) #get the amoutn of input lines for progress report
in_file.seek(0) #go back to the beginning of the file for the actual run


print "Finding extend and smallest error..."
j= 0
mindx= []
pos_x= []
pos_y= []
pos_z= []

while True:
   j+= 1

   in_line = in_file.readline()
   if not in_line:
      break

   #print ".",
   #sys.stdout.write(".")
   print "\r[%3d%%]" % (j*100.0/ln),
   sys.stdout.flush()

   in_line = in_line[:-1] #drop last char '\n' ;-)
   if (len(in_line) == 0): #skip empty lines
      continue 

   if (in_line[0] == "#"): #skip comments
      continue 
   line= in_line.split() #split at white space
   if line:
      dl = map(float, line)
   # for i in range(0, len(sl)):
   #     dl[i]= float(sl[i])
   #print dl

   pos_x.append(dl[1]*options.s)
   pos_y.append(dl[2]*options.s)
   pos_z.append(dl[3]*options.s)
   #pos_tap.append([x*options.s for x in dl[1]])
   l_error= [x*options.s for x in dl[4:7]]
   h_error= [x*options.s for x in dl[7:10]]
   dxe= [h-l for h, l in zip(h_error, l_error)] #errorbox edge lengths
   mindx.append(min(dxe)) #smallest edge of a box

min_error=min(mindx)
min_pos=[min(pos_x), min(pos_y), min(pos_z)] #minimum x,y,z posistion
max_pos=[max(pos_x), max(pos_y), max(pos_z)]
print " done."
in_file.seek(0) #go back to the beginning of the file for the actual run

#print min_error
#print [y for y in pos_tap[][2]]
#print min_pos
#print max_pos



###create a sphere for a point and a cube for as an errorbox
sc= B.Scene.GetCurrent()          # get current scene

j= 0
while True:
   j+= 1

   in_line = in_file.readline()
   if not in_line:
      break

   #print ".",
   #sys.stdout.write(".")
   print "\r[%3d%%]" % (j*100.0/ln),
   sys.stdout.flush()

   in_line = in_line[:-1] #drop last char '\n' ;-)
   if (len(in_line) == 0): #skip empty lines
      continue 
   if (in_line[0:2] == "##"): #skip lines starting with double ##
      print "Caught comment: ", in_line
      continue 
   if ("#fplane" in in_line): #draw the plane
      line= in_line.split() #split at white space
      if line:
         print "Caught: ", line
         dl = map(float, line[1:]) #skip '#plane'
         index= dl[0]
         n= [x*options.s for x in dl[1:4]]
         pos= [x*options.s for x in dl[4:7]]
           
         ## Euler axis and angle representation
         N= B.Mathutils.Vector(n)
         print N*N
         N.normalize()
         print N*N
         
         P= B.Mathutils.Vector([0,0,1])
         P.normalize()
         #theta= N*P #angle in rad!!!
         theta= B.Mathutils.AngleBetweenVecs(N,P) #angle in deg!!!
         print theta
         e= N.cross(P)
         
         ## Euler axis/angle -> rot-mat (Rodrigues' rotation: http://en.wikipedia.org/wiki/Rotation_formalisms_in_three_dimensions#Rotation_matrix_.E2.86.94_Euler_axis.2Fangle )
         # E= B.Mathutils.Matrix([0, -e[2], e[1]], [e[2], 0, -e[0]], [-e[1], e[0], 0]);
         # rot= B.Mathutils.Matrix().identity()*math.cos(theta)+(1-math.cos(theta))*e*e.transpose()+E*math.sin(theta)
         
         ##or with quats
         # quat= B.Mathutils.Quaternion(e, theta)
         # rot= quat.toMatrix()

         ##or get matrix straight away ;-)
         rot= B.Mathutils.RotationMatrix(theta, 4, 'r', e) #angle in deg!!!
         print rot
         
         min_ext= B.Mathutils.Vector(min_pos)
         max_ext= B.Mathutils.Vector(max_pos)
         diagonal= max_ext - min_ext
         centre= (max_ext + min_ext) / 2
         
         #print diagonal, centre

         cmat= B.Mathutils.TranslationMatrix(B.Mathutils.Vector(centre.x, -centre.y, 0))
         xmat= B.Mathutils.ScaleMatrix(diagonal.x,4,B.Mathutils.Vector(1,0,0))
         ymat= B.Mathutils.ScaleMatrix(diagonal.y,4,B.Mathutils.Vector(0,1,0))
         #zmat= B.Mathutils.ScaleMatrix(dx[2],4,B.Mathutils.Vector(0,0,1))

         #tmat= rot.invert() #####Order matters!!! Has to be rotZ*rotY*rotX!!!!
         tmat= xmat*ymat*rot.invert() #####Order matters!!! Has to be rotZ*rotY*rotX!!!!

         edge_len=1
         mplane= B.Mesh.Primitives.Plane(edge_len) #create a plane with edge length 1 in xy-plane
         mplane.materials= [matplane]

         #me= ob.getData(mesh=1) #blender shows the obj. according to its matrix
         #me.transform(tmat)#but does not apply it on the obj verts
         #mplane.transform(tmat)
         obn= "plane_%0.4d" % index
         ob= sc.objects.new(mplane, obn) # add a new mesh-type object to the scene
         #ob.setMatrix(ob.matrix.identity())#set identity to avoid double effect
         ob.setMatrix(tmat)#set identity to avoid double effect
         #print centre*B.Mathutils.Vector(n)
         #print (centre*B.Mathutils.Vector(n))*B.Mathutils.Vector(n)
         #ob.setLocation(B.Mathutils.Vector(pos) + centre - ((centre*B.Mathutils.Vector(n))*B.Mathutils.Vector(n)))#transl obj only not the mesh
         ob.setLocation(pos[0], pos[1], pos[2])#transl obj only not the mesh
         ob.drawMode |= B.Object.DrawModes.TRANSP
      continue 
        
   if ("#iline" in in_line): #draw the iline
      line= in_line.split() #split at white space
      if line:
         print "Caught: ", line
         dl = map(float, line[1:]) #skip '#iline'
         index= dl[0]

         obn= "iline_%0.4d" % index

         n= [x*options.s for x in dl[1:4]]
         pos= [x*options.s for x in dl[4:7]]
         
         n_mesh = bpy.data.meshes.new(obn)#create a new mesh, len(name) <= 20!

         ##create rotated mesh
         # c= B.Mathutils.Vector(pos)
         # v= B.Mathutils.Vector(n)

         # n_mesh.verts.extend(c) #add centre vertex
         # n_mesh.verts.extend(c + v) #add direction vertex
         # n_mesh.edges.extend(n_mesh.verts[-2], n_mesh.verts[-1])#create a line between the last two added verts

         ##better rotate object:
         ##create mesh (not rotated)
         n_mesh.verts.extend(B.Mathutils.Vector([0,0,0])) #add centre vertex
         n_mesh.verts.extend(B.Mathutils.Vector([0,0,1])) #add direction vertex
         n_mesh.edges.extend(n_mesh.verts[-2], n_mesh.verts[-1])#create a line between t


         ## Euler axis and angle representation
         N= B.Mathutils.Vector(n)
         print N*N
         N.normalize()
         print N*N
         
         P= B.Mathutils.Vector([0,0,1])
         P.normalize()
         #theta= N*P #angle in rad!!!
         theta= B.Mathutils.AngleBetweenVecs(N,P) #angle in deg!!!
         print theta
         e= N.cross(P)
         
         ##or get matrix straight away ;-)
         rot= B.Mathutils.RotationMatrix(theta, 4, 'r', e) #angle in deg!!!
         print rot


         tmat= rot.invert() #####Order matters!!! Has to be rotZ*rotY*rotX!!!!


         n_mesh.materials= [mati]
         ob= scn.objects.new(n_mesh, obn)

         ##rotate object:
         ob.setMatrix(tmat)#set identity to avoid double effect
         ob.setLocation(pos[0], pos[1], pos[2])#transl obj only not the mesh
      continue 

   if ("#eell" in in_line): #create the error-ellipsoid (error in p)
      line= in_line.split() #split at white space
      if line:
         print "Caught: ", line
         dl = map(float, line[1:]) #skip '#eell'
         index= dl[0]
         abc= [x*options.s for x in dl[1:4]]
         rot= [x*options.s for x in dl[4:13]]
         pos= [x*options.s for x in dl[13:16]]
         
         #print rot[0:3]
         rmat= B.Mathutils.Matrix([rot[0], rot[1], rot[2], 0], [rot[3], rot[4], rot[5], 0], [rot[6], rot[7], rot[8], 0], [0,0,0,1])         

         xmat= B.Mathutils.ScaleMatrix(abc[0],4,B.Mathutils.Vector(1,0,0))
         ymat= B.Mathutils.ScaleMatrix(abc[1],4,B.Mathutils.Vector(0,1,0))
         zmat= B.Mathutils.ScaleMatrix(abc[2],4,B.Mathutils.Vector(0,0,1))
         
         tmat= (xmat*ymat*zmat)*rmat


         segments=32
         rings=32
         diameter=1.0 #expecting ell-axes to be full width!!!

         me= B.Mesh.Primitives.UVsphere(segments, rings, diameter)
         me.materials= [mateell]
         
         obn= "Eellipsoid_%0.4d" % index
         ob= sc.objects.new(me, obn) # add a new mesh-type object to the scene

         ob.setMatrix(tmat)#set identity to avoid double effect
         ob.setLocation(pos[0], pos[1], pos[2])#transl obj only not the mesh
         ob.drawMode |= B.Object.DrawModes.TRANSP
      continue 

   if ("#eEDC" in in_line): #create the EDC (error in v)
      line= in_line.split() #split at white space
      if line:
         print "Caught: ", line
         dl = map(float, line[1:]) #skip '#eEDC'
         index= dl[0]
         ab=  [x*options.s for x in dl[1:3]]
         rot= [x*options.s for x in dl[3:12]]
         pos= [x*options.s for x in dl[12:15]]
         
         #print rot[0:3]
         rrmat= B.Mathutils.Matrix([rot[0], rot[1], rot[2], 0], [rot[3], rot[4], rot[5], 0], [rot[6], rot[7], rot[8], 0], [0,0,0,1])         

         #rmat= B.Mathutils.RotationMatrix(90, 4, 'y') ##rot in deg not rad!!! 90/180*math.pi
         #rmat= B.Mathutils.RotationMatrix(90, 4, 'y').invert() * rrmat
         #rmat= rrmat * B.Mathutils.RotationMatrix(90, 4, 'y')
         #rmat= rrmat + B.Mathutils.RotationMatrix(90, 4, 'y')##strangly this works...
         rmat= rrmat ##doing local rot manually in blender
         xmat= B.Mathutils.ScaleMatrix(ab[0],4,B.Mathutils.Vector(1,0,0))
         ymat= B.Mathutils.ScaleMatrix(ab[1],4,B.Mathutils.Vector(0,1,0))
         zmat= B.Mathutils.Matrix().identity()
         
         tmat= (xmat*ymat*zmat)*rmat

         ##Cone points in z, centre @ hight/2 
         me= B.Mesh.Primitives.Cone(32, 1.0, 1.0) ##segments, radius, height
         me.materials= [mateEDC]
         
         obn= "EEDC_%0.4d" % index
         ob= sc.objects.new(me, obn) # add a new mesh-type object to the scene

         ob.setMatrix(tmat)
         #ob.setMatrix(tmat.invert()*B.Mathutils.RotationMatrix(90, 4, 'y')*tmat)
         #ob.setMatrix(tmat.rotationPart().invert()*B.Mathutils.RotationMatrix(90, 3, 'y')*tmat.rotationPart())
         ob.setLocation(pos[0], pos[1], pos[2])#transl obj only not the mesh
         ob.drawMode |= B.Object.DrawModes.TRANSP
      continue 

   if (in_line[0] == "#"): #skip comments
      continue 
   line= in_line.split() #split at white space
   if line:
      dl = map(float, line)
   # for i in range(0, len(sl)):
   #     dl[i]= float(sl[i])
   #print dl

   index= dl[1]
   pos= [x*options.s for x in dl[1:4]]
   l_error= [x*options.s for x in dl[4:7]]
   h_error= [x*options.s for x in dl[7:10]]
   dx= [h-l for h, l in zip(h_error, l_error)] #errorbox edge lengths
   tx= [(h-l)/2 + l for h, l in zip(h_error, l_error)] #errorbox centre
   
   #icosphere for point position

   subdivisions=1
   diameter=point_size*min_error*options.s  #should be calculated as a percentage of the smallest error
   mpoint= B.Mesh.Primitives.Icosphere(subdivisions, diameter)
   mpoint.materials= [matp]
   #http://www.blender.org/documentation/246PythonDoc/Object-module.html
   obn= "point_%0.4d" % index
   ob= sc.objects.new(mpoint, obn) # add a new mesh-type object to the scene
   ob.setMatrix(ob.matrix.identity())#set identity to avoid double effect
   ob.setLocation(pos[0], pos[1], pos[2])#transl obj only not the mesh


   #cube for errorbox

   edge_len=1.0
   mbox= B.Mesh.Primitives.Cube(edge_len) #create a cube with edge length 1
   mbox.materials= [matb]

   cmat= B.Mathutils.TranslationMatrix(B.Mathutils.Vector(tx))
   xmat= B.Mathutils.ScaleMatrix(dx[0],4,B.Mathutils.Vector(1,0,0))
   ymat= B.Mathutils.ScaleMatrix(dx[1],4,B.Mathutils.Vector(0,1,0))
   zmat= B.Mathutils.ScaleMatrix(dx[2],4,B.Mathutils.Vector(0,0,1))

   tmat= (xmat*ymat*zmat)*cmat
   #me= ob.getData(mesh=1) #blender shows the obj. according to its matrix
   #me.transform(tmat)#but does not apply it on the obj verts
   mbox.transform(tmat)
   obn= "errorbox_%0.4d" % index
   ob= sc.objects.new(mbox, obn) # add a new mesh-type object to the scene
   ob.setMatrix(ob.matrix.identity())#set identity to avoid double effect
   ob.setLocation(pos[0], pos[1], pos[2])#transl obj only not the mesh
   ob.drawMode |= B.Object.DrawModes.TRANSP


in_file.close()


#scn.objects.selected = [] # select none
scn.objects.selected = scn.objects # select all for STL export
B.Window.RedrawAll()               # update windows

#B.Save(options.ellout + ".blend", 1) #save as .blend anyway
#B.Save(options.ellout + ".wrl", 1) #DXF, STL and Videoscape export only selected meshes.
B.Save(options.output, 1)
scn.objects.selected = [] # select none


