# Copyright (c) 2019 Winston Yallow.
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
#, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# Original script from https://gist.github.com/winston-yallow/41b2bab5bd71dc7711ecc4a761a3632c
# Further modified and converted into an add-on by David Herman

import bpy
import os
from mathutils import *
from math import *

bl_info = {
    "name": "Godot Curve Exporter",
    "version": (1, 0),
    "blender": (2, 83, 0),
    "category": "Import-Export",
}

_export_template = """[gd_resource type="Curve3D" format=2]

[resource]
_data = {{
"points": PoolVector3Array( {points_str} ),
"tilts": PoolRealArray( {tilts_str} )
}}
"""

def _add_bezpoint_to(origin, points, tilts, bezpoint):
    point = bezpoint.co + origin
    handle_l = bezpoint.handle_left - bezpoint.co
    handle_r = bezpoint.handle_right - bezpoint.co

    # Convert z up -> y up, since that's what Godot expects
    points += [
        handle_l.x, handle_l.z, -handle_l.y,
        handle_r.x, handle_r.z, -handle_r.y,
        point.x, point.z, -point.y
    ]
    tilts.append(bezpoint.tilt)

def _export_curve(origin, curve, precision, name, template=_export_template):
    print("EXPORT:", name)
    
    points = []
    tilts = []
    
    if curve.bezier_points:
        for bezpoint in curve.bezier_points:
            _add_bezpoint_to(origin, points, tilts, bezpoint)
            
        if curve.use_cyclic_u:
            _add_bezpoint_to(origin, points, tilts, curve.bezier_points[0])

        # round everything to prevent errors in godot:
        points = [round(i, precision) for i in points]
        tilts = [round(i, precision) for i in tilts]
        
    file_content = template.format(
        points_str=", ".join(str(i) for i in points),
        tilts_str=", ".join(str(0) for i in tilts)
    )
    
    with open(name, "w") as f:
        print(file_content)
        f.write(file_content)


class GodotCurveExporter(bpy.types.Operator):
    
    """Export all bezier curves into a format (.tres) that Godot can recognize"""
    bl_idname = "export.godot_curves"
    bl_label = "Export Curves For Godot"
    bl_options = {'REGISTER'}
    
    # moved assignment from execute() to the body of the class...
    precision: bpy.props.IntProperty(name="Precision", default=4, min=1, max=10)
    directory: bpy.props.StringProperty(subtype="DIR_PATH")

    def invoke(self, context, event):
        context.window_manager.fileselect_add(self)
        return {'RUNNING_MODAL'}
    
    def execute(self, context):
        if self.directory == "":
            return {'CANCELLED'}    
        
        for obj in context.scene.objects:
            if obj.type == "CURVE":
                if len(obj.data.splines) == 1:
                    export_file_name = self.directory + (obj.name + ".tres")
                    _export_curve(
                        obj.location,
                        obj.data.splines[0],
                        self.precision,
                        export_file_name
                    )
                else:
                    i = 0
                    for subcurve in obj.data.splines:
                        export_file_name = self.directory + (obj.name + "_" + str(i) + ".tres")
                        _export_curve(
                            obj.location,
                            subcurve,
                            self.precision,
                            export_file_name
                        )
                        i += 1

        return {'FINISHED'}


def register():
    bpy.utils.register_class(GodotCurveExporter)


def unregister():
    bpy.utils.unregister_class(GodotCurveExporter)


if __name__ == "__main__":
    register()

