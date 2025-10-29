**Description:**

The Basebox is the base of the PiTrac version 2 enclosure.  The Basebox consists of three parts - a Main Body, an End-Cap that fits into the body, and a Light Shield that fits into the other two parts.  The Basebox houses the Meanwell power supply unit and secures the tower that holds all of the electronics, cameras, and other parts. 
A [FreeCAD 1.0](https://www.freecad.org/downloads.php) compatible parameterized model is included here along with .stl files.
The current version of this Basebox is configured for mounting an LRS-75 Meanwell power supply inside.  The prior verions (pre-October 2025) were instead configured to house the larger LRS-154 power supply.  Ultimately, the smaller power supply is the current version.

**Printing Notes:**

PLA works well for this, but PETG probably would as well. The main body is printed standing on its closed end, which makes for a pretty high print.  You may need to make sure your printer won't have problems near the top of the print. For example, make sure the filament feed is centered and sufficiently high not to get pulled sideways too much.

Recommended print settings: 2 perimeter layers (3 for a little more strength), 15% infill, grid or rectilinear infill patterns, custom painted-on supports (see the Prusa Slicer .3mf file for where the supports are needed). The main body requires glue-stick glue on the printer bed and we recommend a 7mm brim assist because of the height and relatively small print base.  
The end-cap is a pretty easy print, and should not need glue or a brim.  Even with the "X" cross-bracing on the heat venting fins, this model is still susceptible to vibration-caused distortions if the print plate movement is too fast.  Slowing the print nearer the top may be necessary on some printers.

The Light Shield Body prints pretty well with any settings, but we use 2 perimeter layers, 15% infill, grid infill and no supports, brims, or glue. Even lower infills might work, too.

Note that a beginning of a sketch for an x-shaped leveling support base has been started in the model, but is not finished and not yet printable.

Note also that the "shank shield" is not designed for 3D printing.  The hope is that the .dxf file can be used to laser cut or mill that part out of acrylic or (better) polycarbonite.
**Assembly Notes:**

See the [main assembly instructions](https://github.com/jamespilgrim/PiTrac/blob/main/Documentation/PiTrac%20Version%202%20Assembly.md).