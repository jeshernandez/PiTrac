**PiTrac \- DIY LM  Parts Lists**

**Computing Hardware:**

| Quantity | Hardware | Purpose |
| :---- | :---- | :---- |
| 1 | [Raspberry Pi 5](https://www.raspberrypi.com/products/raspberry-pi-5/) and power supply, 4 GB minimum, 8 FB recommended. | Getting a bundled kit with the Pi and power supply and some other things can be economical if you don’t have any Pi-related stuff yet. |
| 1 | [Raspberry Pi 4 Model B](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) and power supply, 4 GB minimum.  It may also make sense for a little more money just to get a second Pi 5\. |  |
| 1 | [Pimoroni NVMe Base for Raspberry Pi 5 \- PIM699](https://www.adafruit.com/product/5845) ((optional, but recommended for speed and longevity).   [This board](https://www.amazon.com/gp/product/B0CQ4D2C9S/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1) works well, too. | For the Pi 5, this allows use of an NVMe memory drive instead of an MicroSD card. |
| 1 | An [NVMe solid state (SSD) memory drive](https://www.amazon.com/gp/product/B0BGFRZDTB/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1) (optional, but recommended for speed and longevity) | Typically with an M.2 M key edge connector, in the 2230 and 2242 form factors.  Should probably get at least 256 GB capacity. |
| 2 | Micro SD cards (to bootstrap the Pi’s). | We recommend 64GB size |
| 1 | An Active Cooler fan for the Pi 5 (optional) | The Pi 5 can get pretty hot if you’re doing a lot of big compiles on it.  If so, having a cooler seems like decent insurance. |

**Hardware \- Bolts and Nuts:[^1]**

| Quantity | Hardware | Purpose |
| :---- | :---- | :---- |
| 4 | M4 x 12 screws | LED Power supply hold-downs |
|  |  |  |
| 4 | 2.5M x 12mm bolt | Pi 1 Board Bolt-down |
| 4 | 2.5 Hex Nuts | Pi 1 Board Bolt-down |
| 3 | 2.5M x 10mm bolt | Pi 2 Board Bolt-down |
| 1 | 2.5M x 12mm bolt (odd one\!) | Pi 2 Board Bolt-down |
|  |  |  |
| 2 x 4 | 2.5M x 16mm 2.5 Hex Nuts | Pi Camera Attachment Bolts (to back plate) |
| 3 x 2 3 x 2 | M4 x 12mm  M4 Hex Nuts  | Pi Cam Gimbal Attachment Hinge (2 cameras and strobe gimbal) |
| 2 x 1 2 x 1 | M5 x 12 M5 Hex Nut | Pi Cam (Pan) Swivel Mount (on bottom of mount) |
|  |  |  |
| 3 x 2 | M3 | Horizontal Center-Side Body Attachment |
| 4 | 2.5 x 10 or 12 | Connector Board Bolt-down |
| 3 x 6 \= 18 | M3 x 10mm | Floor hold-down screws |
|  |  |  |
| 2 x 4 | 2.5M x 12mm bolt | Connector Board Mounting Bolts |
| 2 x 4 | 2.5 Hex Nuts | Connector Board Mounting Bolts |
| 8 | M3 x 10mm | LED and LED Lens Hold-down screws |
|  |  |  |
| 2 2 | M3 x 12mm M3 Nuts | Half-Join bolts and nuts for ceiling level walls |
| 2 2 | M3 x 16mm M3 Nuts | Half-Join bolts and nuts for base and middle level walls |
| 5 x 4 | M3 x 10mm self-tapping screws | These screws secure the five “floor” components to their respective “wall” components and/or other floor components |

**Camera and Lighting Hardware:**

| 2  | [Raspberry Pi Global Shutter Camera – CS Lens Mount](https://www.adafruit.com/product/5702) | The cameras currently used by the LM.  They do not come with lenses (see below) |
| :---- | :---- | :---- |
| 1 | [Raspberry Pi 5 FPC Camera Cable \- 22-pin 0.5mm to 15-pin 1mm \- 300mm long](https://www.adafruit.com/product/5819) | The current Pi Cameras have a CSI cable that needs a conversion to fit into the smaller CSI ports on the Pi 5\.  The 200mm should probably work as well. |
|  | [200 mm Flex Cable for Pi 4](https://www.adafruit.com/product/2087) | This likely comes with most Pi Cameras, so may not be necessary |
| 2 | [6mm 3MP Wide Angle Lens for Raspberry Pi HQ Camera \- 3MP](https://www.adafruit.com/product/4563) | Wide angle lens for the Pi GS cameras (which come without a lens) |
| 1 | [1" x 1", Optical Cast Plastic IR Longpass Filter](https://www.edmundoptics.com/p/1quot-x-1quot-optical-cast-plastic-ir-longpass-filter/5421/) (1.5mm nominal thickness) | Blocks visible light from entering the Camera 2 sensor |
|  |  |  |
| 1 | [60 / 120 Degree LED Lens Optical Glass 44mm \+ Reflector Collimator \+ Fixed Bracket for 20W 30W 50W 100W COB High Power Chip (60Degree 100W len kit)](https://www.amazon.com/dp/B09XK7QTV5?ref=ppx_yo2ov_dt_b_fed_asin_title)  | The lens helps focus the infrared IR light.  NOTE \- this device can get very hot if left constantly on for even a few seconds.  PiTrac just uses it in short pulses. |
| 1 | [Aclorol USB COB LED Strip Lights for TV 5V USB Powered LED Tape Lights Daylight White 6.56FT 320Leds/M 6000K COB Flexible Light Strip TV Led Backlight for Bedroom Under Cabinet Kitchen DIY](https://www.amazon.com/Aclorol-Powered-Daylight-Flexible-Backlight/dp/B0D1FYV3LM/ref=asc_df_B0D1FYV3LM?mcid=70db06b6e26231f3961ef52c9615b991&hvocijid=2003913134214569652-B0D1FYV3LM-&hvexpln=73&tag=hyprod-20&linkCode=df0&hvadid=721245378154&hvpos=&hvnetw=g&hvrand=2003913134214569652&hvpone=&hvptwo=&hvqmt=&hvdev=c&hvdvcmdl=&hvlocint=&hvlocphy=9028778&hvtargid=pla-2281435177378&psc=1) | LED strip for lighting the teed-up ball- long enough to double it for more light. |

**Power-Related Parts:**

| 1  | LED Driver, 12-26V, Output Current DC 3600mA, such as: https://www.aliexpress.us/item/2251832563139779.html | Driver for LED strobe array. Because of the short pulses that are used in the LM, a much smaller (and cheaper) driver may also work, possibly even a non-constant-current driver. |
| :---- | :---- | :---- |
| 1 | A 5V USB-B power supply with a male micro USB connector  | This is currently necessary to run the Connectro Board.  The supply is used as an isolated, independent (downstream of a transformer) power plane to try to keep the Pi’s and the Pi Camera safe. |
|  |  |  |

**Connector Board Parts:**

| Item | Qty | Reference(s) | Value | LibPart | Footprint / Details |  |
| :---- | :---- | :---- | :---- | :---- | :---- | ----- |
| 1 | 1 | J3 | \~ | [USB B Micro Female Pinboard](https://www.amazon.com/Pinboard-MELIFE-Interface-Adapter-Breakout/dp/B07W6T97HZ/ref=sr_1_1?crid=1KITM9DEDEQMA&dib=eyJ2IjoiMSJ9.fGuXBUJw1cZvJFMJklJhkSh4wNEQKdwHnb94uj1k7QTRfzEl71vaSvgkvNQ0aqipm8Ua3bK7zTYznxLIBgNAD4XJGFw08Mivt69vXxTpzaH_qrzlbYL8n7s_uwWCz7OMd4BUwKb8m4OW2InoWsrjHJH9RNJImM2AJTL0pbrro1OPdtfIv6AMsSSx1s9T9YNZyzrvz_o5B1rXAK7BsCBoX6edEQggz2toWMxzcdXa3PJ-cSoZUAo8mb6lIgYGhKnPElFTuXkOqoh-kAGtKJSqudp3cwFBwl2wzeDo9ioWl7U.VxdrpEbIBjzibUhD8wjWdpWVrk3AT8vYemC8ZQVRUQA&dib_tag=se&keywords=10pcs+Female+Micro+USB+to+DIP+5-Pin+Pinboard%2C+2.54mm+Micro+USB+Type+Interface+Power+Adapter+Board+5V+Breakout+Module&qid=1732903628&s=electronics&sprefix=10pcs+female+micro+usb+to+dip+5-pin+pinboard%2C+2.54mm+micro+usb+type+interface+power+adapter+board+5v+breakout+module%2Celectronics%2C173&sr=1-1) | The included Pin headers can be used for the parts below |  |
| 2 | 2 | R1, R4 | 330 ohm R | Resistor A decent assortment kit is [here](https://www.amazon.com/gp/product/B003UC4FSS/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1) | Resistor\_THT:R\_Axial\_DIN0207\_L6.3mm\_D2.5mm\_P10.16mm\_Horizontal |  |
| 3 | 2 | R2, R3 | 270 ohm R | Resistor | Resistor\_THT:R\_Axial\_DIN0207\_L6.3mm\_D2.5mm\_P10.16mm\_Horizontal |  |
| 5 | 1 | Sys1\_Conn1 | \~ | 4 Pin Header | Connector\_PinHeader\_2.54mm:PinHeader\_1x04\_P2.54mm\_Vertical |  |
| 6 | 1 | Sys2\_Conn1 | \~ | 3 Pin Header | Connector\_PinHeader\_2.54mm:PinHeader\_1x03\_P2.54mm\_Vertical |  |
| 7 | 2 | U2, U3 | H11L1 | [Isolator:H11L1](https://www.amazon.com/dp/B09KM2BJCF?ref_=pe_386300_442618370_TE_sc_as_ri_0) | Package\_DIP:DIP-6\_W7.62mm |  |
| 8 | 1 | U4 | 74HC04 | 74xx:74HC04 | Package\_DIP:DIP-14\_W7.62mm\_Socket |  |
| 9 | 1 | U5 | \~ | [Dual\_Mos\_Driver\_Module](https://www.amazon.com/Anmbest-High-Power-Adjustment-Electronic-Brightness/dp/B07NWD8W26/ref=sims_dp_d_dex_ai_speed_loc_mtl_v5_t1_d_sccl_2_1/132-9837543-1351009?pd_rd_w=xeol9&content-id=amzn1.sym.281550a9-05fa-4fa0-a033-b1923adca8ef&pf_rd_p=281550a9-05fa-4fa0-a033-b1923adca8ef&pf_rd_r=WXGFBGSTH336WSAYW2XQ&pd_rd_wg=SokZb&pd_rd_r=2d219084-db5a-41cc-b5d7-b01ed55844ec&pd_rd_i=B07NWD8W26&th=1) | Verdant\_Custom\_Footprint\_Library:PCB Dual MOS Driver Module |  |
|  | 1 | 2.5M Bolt 2.5M Nut |  |  | These help mechanically tie down the USB-B power connector to the board |  |
|  |  | \<Optional\> |  |  |  |  |
|  | 2 | 6 \- pin DIP socket |  | A decent assortment kit is [here](https://www.amazon.com/dp/B01GOLSUAU?ref=ppx_yo2ov_dt_b_fed_asin_title) | The opto-isolators and the hex inverter chip are probably the most likely to be blown up or injured by solder over-temps.  So best to put them in sockets |  |
|  | 1 | 14 \- pin DIP socket |  | A decent assortment kit is [here](https://www.amazon.com/dp/B01GOLSUAU?ref=ppx_yo2ov_dt_b_fed_asin_title) |  |  |

**Miscellaneous Parts/Supplies:**

| Quantity | Hardware | Purpose / Notes |
| :---- | :---- | :---- |
| 2 |  [Ideal Industries 30-102 Power Plug](https://www.amazon.com/Ideal-Industries-30-102-Power-72427/dp/B01LYF1WV9/ref=sr_1_10?crid=35QTOVMFFT8MM&dib=eyJ2IjoiMSJ9.E2lbqLFKVG_hmleCqoMKymmILpx7xHQqbjKLlS_O8biic815YLA-1NACjC7tLtjM1exKso1Yz_65dH1SEbMni2IVp4idBpijPJhdQ_dqc_jCaEmkTbkPx0xoOe5u_wFYZDU-708_oXsrAmTNBXO-a2iAVH3lMZzeo9MZ6zFEO29IgxN_2m_0GrCkWTMORn0iifYao1peHnHenuPGSKCOTzvpolrumaoD-CkeZ5nvs29wAsiRDyq-Yq2K7tfmSzrQslG_ZpLzrx5-9GZQe55ktJDEK1bqKpEjHi-F_Lg1tuk.lAcQi1tp-upRzLoq8eleSXFSf1Vet_Xild25OSMBkYI&dib_tag=se&keywords=ideal+power+plug&qid=1732650183&sprefix=ideal+power+plug%2Caps%2C174&sr=8-10). | Enables easy connect/disconnects |
| N/A | 3 and 4-pin ribbon cables For example, [here](https://www.amazon.com/Kidisoii-Dupont-Connector-Pre-Crimped-5P-10CM/dp/B0CCV1HVM9/ref=sr_1_2_sspa?crid=82PRY332YY24&dib=eyJ2IjoiMSJ9.QGbaFF62mgZ1Tf0J7CajkKXRwTNzXfW_5IJDpp-KFNMSPxr3NJETCkY5IC0OIC6NydeuYNxh2IMnpu14CuIxCxLVt4T4kUKlsGMMPk0uwwu7oKUnh2qI2YGvPNmbGfKPCZE6EYSST4_MDqKRP2VMQDk5slq7dKh0rdLvqEMAjboPrVlVx0sd3ShyQsdiUN9ljqd6q-bfi_ZVY2jKoBiwVuMgkZs-BkA3jRBQvkzWpos.aLN0QbPnnKDjbELWeYKRE5SrUWDe-Ivk47o6BkYfL04&dib_tag=se&keywords=ribbon+cable+with+female+connectors&qid=1733175902&sprefix=ribbon+cable+with+femaleconnectors%2Caps%2C143&sr=8-2-spons&sp_csd=d2lkZ2V0TmFtZT1zcF9hdGY&psc=1). | These are used for the wiring harness connects between the various GPIO pins and the Connector Board |
| 1 | 15.5cm x 24cm plexiglass anti-ball-strike protective window | Protects the cameras and strobe **NOTE:**  Ensure the plexi is not IR-blocking\!  Most hardware stores can cut plexi in this size for a few US$ |
| 1 | Power Strip | A relatively short power strip that is compact enough to fit into the enclosure. 10” or less, and with some type of power filtering to protect the rest of the components |

[^1]:  Stainless Steel seems to be stronger than black carbon steel, though both can work.  Especially in the stiffer PLA material, stainless is preferable because black carbon can break if torqued too much..  For parts supply example see [HanTof 525 Pcs 304 Stainless Steel M2 M3 M4 Phillips Pan Head Self Tapping Wood screws Assortment Kit](https://www.googleadservices.com/pagead/aclk?sa=L&ai=DChcSEwiLuLi4w9eJAxW8Ka0GHe7XF-QYABALGgJwdg&co=1&ase=2&gclid=Cj0KCQiAlsy5BhDeARIsABRc6ZvLmaSF7SMXMVEWsWj3rp8S5qOvISkRMdr9czJDXK6-_GcV_X18lyoaApxdEALw_wcB&ohost=www.google.com&cid=CAESVeD2Qt_A3T4eLbWpcXoKb1T4jyPt8OTe6U2I9Uze-kjy3MAArJhoS9pYvi39aDroogjezyRvCcOJ56x4hYKkL8BaTouv69VFkW3lUm7VcRcYOp8m49s&sig=AOD64_3FizAX65usODanOujaKxqh5_gQbg&ctype=5&q=&nis=4&ved=2ahUKEwj92Kq4w9eJAxU1JzQIHakTKO8Q9aACKAB6BAgEEAw&adurl=)., 