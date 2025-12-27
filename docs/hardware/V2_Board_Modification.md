---
title: V2_Board_Modification
layout: default
nav_order: 5
has_children: false
description: Describes how to modify the original V2 Connector Board to fix a problem with the strobe not shutting off fully and/or quickly.
keywords: DIY golf hardware, launch monitor parts, raspberry pi golf components, PCB assembly golf, Connector Board, V2
og_image: /assets/images/hardware/v2_board_ball_exposure_candidates_before_mosfet_mod.png
last_modified_date: 2025-12-26
---

# Modifying the V2 Connector Board to Fix the Strobe Not Shutting Off

This document describes how to modify the original V2 Connector Board to fix a problem with the strobe not shutting off fully and/or quickly.  It's pretty hack-y, and involves a bit of small hand-soldering.  But, it does seem to work pretty well and is relatively inexpensive.

In order for the V2 board to work correctly, there is also a second modification that will be included in this document, even though the mod is not strictly related to the shut-off problem.  This second mod involves moving the resistor that is currently in the "R19" position to the previously-empty "R20" position.

## The Problem
The initial version of the V2 Connector Board had an issue where the strobe light would not turn off completely or quickly enough after each pulse. This could lead to unwanted light exposure between pulses, which in turn created smearing and poor focus/sharpness of the individual ball images. This problem would then degrade the accuracy of the launch monitor, especially in regard to sPin analysis.

A typical ball-exposure identification image when this problem happens looks like this:  ![Slow strobe cutoff problem]({{ '/assets/images/hardware/v2_board_ball_exposure_candidates_before_mosfet_mod.png' | relative_url }})

Note that there is a completely different potential problem that looks very similar.  This unrelated problem is caused by a missing or ineffective visible-light-cut filter on the ball-flight camera (cam 2).  That sort of problem will also create some smear, but in this case the smear is much less pronounced, and is actually caused by visible light, not the IR light from the strobe.  An example of this problem is shown here:  ![Missing visible-light-cut filter problem]({{ '/assets/images/hardware/v2_board_ball_exposure_candidates_missing_filter.png' | relative_url }}).  This second problem is usually a lot easier to solve and will not be addressed here.

## Solution(s)
As a preface, the ultimate solution for this problem will probably be to retroactively modify the design of the V2 Connector Board itself, probably to include a MOSFET-based switching circuit for the strobe light. Also, the V3 Connector Board is in the works, and has a different design that should also take care of the issue.

However, in order to support folks who have the *current* V2 boards (because we're all about supporting our community! :) ), a modification has been designed that adds a separate MOSFET module to the existing board. This module will provide better switching performance for the strobe light, ensuring it turns off fully and quickly after each pulse.

This solution uses the same module that was a component part of the V1 Connector Board.  In some countries, Amazon has that module on sale for around US$1 a piece.  For example, [here](https://www.amazon.com/ANMBEST-High-Power-Adjustment-Electronic-Brightness/dp/B09KGDDS37/ref=sr_1_4?crid=1AZQ3YCT8KRTG&dib=eyJ2IjoiMSJ9.n1lkNUx_DfKx9fgfmBkKbQ9RhhGFyOIPvrQq8mt8uRj8Vh7j1CTZ2Su22d74O93d8avW9g0AeIHY-MF5LYIUMY9N8BhxiUQIO1hJnthTflVk3GnAg8dyryXjHjaV0q4IHXitXr0U74ST5NJMS1CPUWXjdMCzc9IgwARLmiVoer5J4t96V2lIHT0SB9Sdu-8zTZ6OpvGJ77JaL1KEr-PZlm6gwHTs7porBf5_mil6SsE.ko_jT8L5O0nJWc6HcHww7vEEEXERhlGQb9eNsbexamI&dib_tag=se&keywords=dual%2Bmosfet%2Bmodule&qid=1766787908&sprefix=dual%2Bmosfet%2Bmodule%2Caps%2C146&sr=8-4&th=1).

![V2 Board Modification]({{ '/assets/images/hardware/Dual_MOSFET_Switching_Module.png' | relative_url }})

The solution described here essentially places a dual-MOSFET switching module in series with the existing strobe light output on the V2 Connector Board. The module is then triggered using a 5v signal that already exists on the V2 board.  When the new inline module's input signal drops back to 0, the module will shutdown the pulse strobe very quickly, as the module is essentially a second switch in line with the strobe.  When the module switches off, the power to the strobe will go off immediately even if the V2 board is still trying to push out some voltage.

The schematic for the modification is shown here:  ![V2 Board Modification Schematic]({{ '/assets/images/hardware/V2_Board_MOSFET_Module_Modification_Schematic.png' | relative_url }})

The completed modification will look like this:
![V2 Board Modification]({{ '/assets/images/hardware/V2_Connector_Board_MOSFET_module_addition.jpeg' | relative_url }}).  

Finally, an annotated image of the completed modification is shown here to help identify the various connections: ![V2 Board Modification Annotated]({{ '/assets/images/hardware/MOSFET_Module_Installation_Annotated.png' | relative_url }}).

When completed, the test V2 board that we modified produced this ball-exposure identification image:  ![Image from fixed V2 Connector Board]({{ '/assets/images/hardware/v2_board_ball_exposure_candidates_with_mosfet_mod.png' | relative_url }}).  Note how the smear is gone and the ball images are now sharp and well-defined.

The modification steps further below will guide you through the process of making this change.

Before detailing those steps, however, please note that it is also necessary to move the resistor from R19 to R20 on the board.  The results of this mod are shown in the image below:
![V2 Board Resistor R19/R20 Modification]({{ '/assets/images/hardware/Moving_R19_To_R20.png' | relative_url }}).
A few suggestions when moving the resistor:
	1. Using a knife-edge solder tip can make it easier to apply heat simultaneously to both of the terminals of the resistor when removing it. Just remember to have a good pair of tweezers handy to make sure the resistor doesn't end up stuck to and baking on the solder tip.   
	2. When soldering the resistor into its new position, use some flux first to make sure the pads will accept the solder readily.  It is often easier to flux just one pad, then apply a little blob of solder to that pad, and then use tweezers and the iron to get the resistor connected and positioned to just that first pad.  After that is done, flux and solder the other end to the other pad.
	3. If you lose or damage the resistor during its relocation, you may also be able to get things working by simply bridging a small piece of wire across the R20 terminal pads.


## Modification Steps for Fixing the Strobe Shutoff Problem

	1.  Attach trigger + and trigger ground wires to the MOSFET module:  
		a.  (This step is more easily done prior to mounting the MOSFET module onto your PiTrac.)
		b.  Cut and strip the ends of two small gauge wires (e.g., 22-24 AWG), preferably one black and the other not red.  Both should be long enough to easily reach where they will terminate on the Connector Board, around 15cm.  Strip about 7mm of insulation off the ends that will be soldered to the module so you can push them into their respective holes.  You'll want even less bare wire (5mm at the most) for the wire that will be soldered to Pin 2 of chip U9.  That solder joint will be very small in a crowded area, so you don't want too much excess.  You don't want to be trying to strip the second ends of these wires after the first ends have already been soldered to the module.
		c.  Solder the black wire to the pad labeled "GND" on the MOSFET module (your labelling might be different).  See the close-up image of the module here:  ![MOSFET Module Closeup]({{ '/assets/images/hardware/MOSFET_Module_Closeup.jpeg' | relative_url }}).
		d.  Solder the other wire to the pad labeled "TRIG" on the MOSFET module.  This is the positive trigger input.
	2.  Prepare the wires to the strobe LED:
		a.  Next, you'll need to modify the existing wiring from the V2 board to the strobe LED.  See the schematic above.  If you just had two wires from the -/+ posts on the V2 board that go straight to the LED, this will likely involve cutting those wires so that you end up with two short wires from the Connector Board and two longer wires to the Strobe.
		b.  Consider marking the wires before you cut them to ensure you can keep track of which is + and which is -.
		c.  NOTE: Try to keep the wire lengths here as short as possible.  The drive circuit is very sensitive to wiring length, and longer wires can cause ringing, interference and other issues.  Aim for less than 15cm total length if possible for each of the two paths.
		d.  Strip 6-8mm of insulation off the four ends of the wires that will connect to the MOSFET module. Try to avoid too much bare wire.
	3.  Mount the MOSFET module:  
		a.  We found that the easiest way to mount the MOSFET module is to use an M2 melt-in insert and an M2 bolt through one or more corners of the module's PCB.  The melt-in insert can be heated with a soldering iron and pressed into a small hole in the PiTrac tower, just above the Connector Board.  Pre-drilling a hole for the insert will help ensure that the insert doesn't end up with melted plastic where the bolt was otehrwise supposed to go (!). Make sure to position the module so that the wires you soldered in step 1 will easily reach their respective solder points on the V2 board.
		b.  You could also try using (non-conducting) double-sided foam tape or hot glue to securely attach the MOSFET module to the V2 Connector Board, ensuring it is stable and won't move
		c.  Make sure the module is mounted in a way that avoids the USB-C cable that powers the Raspberry Pi and also allows easy access to the terminal blocks for wiring.
	4.  Connect the strobe LED wires and Connector Board Outputs to the MOSFET Module
		a.  You'll have to open up (unscrew) the little screws in the 4 terminal blocks on the MOSFET module to insert the wires.  Tighten things down firmly, but remember the posts are not that robust.
		b.  Double-check the wiring order here using the schematic above and the markings on the module and/or it's documentation.
		c.  You want to ensure that the Connector Board's strobe + output goes to the MOSFET module's "IN +" terminal, and that the Board's - output goes to the module's "IN -" terminal.  Same with the module outputs to the strobe.
	5.  Connect the Module's Trigger Wires to the Connector Board
		a.  This is probably the trickiest part of the modification, as the area around chip U9 is quite crowded and it's difficult soldering even a small wire to the tiny Pin on the chip.
		b.  First, solder the  ground wire from the MOSFET module to any convenient ground point on the V2 Connector Board.  A good place may be to one of the ground Pins of the USB cable connectors, as they are relatively large and easy to access.  Just make sure that the connector's metal shell is actually connected to ground, however!
		c.  Next, solder the trigger wire from the MOSFET module to Pin 2 of chip U9 on the V2 Connector Board.  This is the Pin that provides the 5v trigger signal for the strobe.  You may need to use a magnifying glass or jeweler's loupe to see this area clearly.  
		d.  A trick here is to exploit the fact that Pin 1 is an unused Pin on the chip and is not electrically connected to anything (at least for the component we've been using).  So, you can solder the trigger wire to both Pins 1 and 2 (with the wire coming in from the right (edge) side of the board.  
		e.  Use a little external solder flux on Pins 1 and 2 (making sure none of it gets near Pin 3) and heat it up a bit with your soldering iron before adding some solder at least Pin 2, but also maybe between Pins 1 and 2 to have more material to work with.  Make sure you also put some flux on the trigger wire coming from the MOSFET module, and then heat up the blob on Pin 2 and insert the wire into the blob and then pull the iron out.
		f.  Lower-temperature solder (e.g., leaded solder) may help here to avoid damaging the chip with too much heat and just to make it easier generally.  HOWEVER, be very careful if you use leaded solder, as it's dangerously toxic and absolutely requires good ventilation and proper handling/disposal.  Lead-free solder is safer, but harder to work with.
		g.  Be very careful not to create any solder bridges to adjacent Pins on the chip.
		h.  For those with an oscilloscope, you can verify that the trigger wire is transferring the proper 5v signal when the strobe is supposed to be firing.  To do so, trigger on an upward edge and run the Pulse Test from the PiTrac UI.  

Here is the soldering close up for the U9 chip: 
![U9 Pin Soldering Closeup]({{ '/assets/images/hardware/Soldering_Trigger_Wire_To_U9.png' | relative_url }}).
You should see something like this if you look at the signal from the wire connected to U9 Pin 2:  
![Trigger Signal on Oscilloscope]({{ '/assets/images/hardware/U9_Chip_Trigger_Signal_From_Pin_2.jpeg' | relative_url }}).



