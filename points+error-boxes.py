#script to plot points and their errorboxes in blender


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

# When --help or no args are given, print this help
usage_text =  'Run blender in background mode with this script:'
usage_text += '  blender -b -P <skript_name> -- [options]'

parser = optparse.OptionParser(usage = usage_text)

parser.add_option('-i', '--input', dest='input', help='Input file containing the points and their errors.', type='string')
parser.add_option('-o', '--output', dest='output', help='Output file where the scene will be saved in. Suffix sets the format: Blender (.blend); DXF (.dxf); STL (.stl); Videoscape (.obj); VRML 1.0 (.wrl)', type='string')

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
matp.rgbCol = [0.2, 0.2, 0.2]          # change its color
matp.setAlpha(0.5)                     # mat.alpha = 0.2 -- almost transparent
matp.emit = 0.2                        # equivalent to mat.setEmit(0.8)
#matp.mode |= B.Material.Modes.VCOL_PAINT # turn on vertex colouring
matp.mode |= B.Material.Modes.ZTRANSP    # turn on Z-Buffer transparency

##material for the error box
matb = B.Material.New('p_mat')         
matb.rgbCol = [1, 0, 0]          # change its color
matb.setAlpha(0.5)                     # mat.alpha = 0.2 -- almost transparent
matb.emit = 0.2                        # equivalent to mat.setEmit(0.8)
#matb.mode |= B.Material.Modes.VCOL_PAINT # turn on vertex colouring
matb.mode |= B.Material.Modes.ZTRANSP    # turn on Z-Buffer transparency



w= B.World.Get('World') #assume there exists a world named "world"
w.hor = [1,1,1] #make the backgroung white

ln= sum([1 for line in in_file]) #get the amoutn of input lines for progress report
in_file.seek(0) #go back to the beginning of the file for the actual run


###create a sphere for a point and a cube for as an errorbox
sc= B.Scene.GetCurrent()          # get current scene

j= 0
while True:
   j+= 1

   in_line = in_file.readline()
   if not in_line:
      break

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

   index= dl[1]
   pos= dl[1:4]
   l_error= dl[4:7]
   h_error= dl[7:10]
   dx= [h-l for h, l in zip(h_error, l_error)] #errorbox edge lengths
   tx= [(h-l)/2 + l for h, l in zip(h_error, l_error)] #errorbox centre
   
   #print ".",
   #sys.stdout.write(".")
   print "\r[%3d%%]" % (j*100.0/ln),
   sys.stdout.flush()


   #icosphere for point position

   subdivisions=1
   diameter=20 #should be calculated as a percentage of the smallest error
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


