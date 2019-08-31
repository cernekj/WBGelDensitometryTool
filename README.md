#  Western Blot densitometry analysis - macro tool for ImageJ 1.x

## What is it good for?

This tool provides a quick and dirty way to measure images of not necessarily straight lines of Western Blot films, dot blots and other silimar bio-scientific images. It utilizes densitometry measurement of ImageJ and subtracts density of image background. Density of image background is measured the same way as bands, on the side of the film, so no rolling-ball, convolution, averages or other techniques are used.


## What is it not good for?

- We expect that blot bands are aligned almost horizontally with almost equal distance between them. This tool is not much suitable for other situations.
- It will not work properly with uneven, warped films / images or images with too small margins.


## Warning

- We utilize ImageJ "Overlays" so it will delete all your overlays!
- We overwrite files "<image_name><current_datetime>-ROI.zip" and "<image_name><current_datetime>.csv"


## Installation

- for single session use: menu Plugins > Macro > Install...
- for permanent use: copy script file "WBGelDensitometryTool.ijm" into %imagej_root%/macros/toolsets/


## Usage

ROI = Region Of Interest

1. Click the icon most to the right in the toolbar ">>" and select "WBGelDensitometryTool"
2. Right click on "WB Gel Bands Selection Tool" (the first one on additional palette) and setup WB parameters
3. Select the first tool "WB Gel Bands Selection Tool" and draw a line precisely selecting your bands.
4. Select the second tool "WB Gel Bands Create ROIs" to create ROIs (rectangles selecting blot bands).
5. Select the "Straight line tool" and move all ROIs as needed to avoid debris, scratches and other imperfections that could affect the measurement.
   The ROI called "background" will be used to subtract the film natural density automatically, so place it wisely.
6. Click on the third tool "WB Gel Bands Measure ROIs" to measure and save the results.
   It will save the results to a file with the same filename as your image with a CSV extension (+ datetime)
   plus another file containing all ROIs for later reference with "datetime-ROI.zip" suffix.
7. Evaluate the results in your favourite table / data analysis editor (OpenOffice, R, Excel, SPSS, SAS, ...)


## Densitometry Tips And Tricks

- Preferably, use a *calibrated* digitalization device (scanner, camera) with high DPI (>300)
- Use correct Gamma setting and ICC profile on the digitalization device, image file format and software (ImageJ)
- Prepare all images with the same setting of the digitalization device, gamma, ICC. Preferably acquire all images on the same device.
- Do no apply any image correction, such as as affine transformations (rotation, zoom), change in image pixel levels (contrast, brightness, etc.), or any painting, brushing, wiping, blurring, de-noise, focus, save or re-save in any loss compression.
  In the other words: Keep the image as it is! Use lossless compression. Use the maximum bit depth of your input device.


## Credits

- Cernek J. (2012 - 2019): original author
- Koledova Z. (2012 - 2019): bio-scientist and tester in real lab workflow
- ImageJ and FiJi authors: for a great Image analysis framework


## Recommended citation format

- Cernek J.: Western Blot densitometry analysis - macro tool for ImageJ 1.x [Online]. Available: https://github.com/cernekj/WBGelDensitometryTool, Accessed on: <date>.

## Contributions

- Use this repository on Github https://github.com/cernekj/WBGelDensitometryTool
- Improve and push change requests or fork and edit on your own


## Support, Warranty, Liability

- Not provided


## License

- GNU GPL

