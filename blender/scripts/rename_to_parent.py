
import bpy
from mathutils import *
from math import *

C = bpy.context

print(dir(C.selected_objects[0].data))
for obj in C.selected_objects:
    prefix = obj.data.name.split('.')[0]
    obj.data.name = prefix + '.' + obj.name
