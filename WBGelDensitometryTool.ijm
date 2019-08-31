/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *  Western Blot Gel densitometry analysis - macro tool for ImageJ 1.x   *
 *  quick and dirty way to analyse unstraight Gel lines                  *
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * @author  J. Cernek <devel.e8a4b1 at cernek.cz>
 * @link    http://pn.cernek.cz/OS15/WBGelDensitometryTool.ijm
 * @version r1908270148 (2019-08-26)
 * @license GNU GPL <http://www.gnu.org/licenses/gpl.html>
 *
 * WARNING:
 *     We utilise "Overlay" so it will delete all your overlays!
 *
 */

var bandsCount = 6, bandHeight = 100, ROIm;

  // This macro runs when the user clicks and drags on the image.
macro "WB Gel Bands Selection Tool - C037T0710WTa710BC00cL0cfcL090fL595fLa9afLf9ff" {

    bandsCount = parseInt(call("ij.Prefs.get", "WBGelDenT.bandsCount", bandsCount));
    bandHeight = parseInt(call("ij.Prefs.get", "WBGelDenT.bandHeight", bandHeight));

    getLine(lx1, ly1, lx2, ly2, lW);

    setOption("Show All", true);
    setOption("DisablePopupMenu", true);
    showStatus("Selecting WB Gel with " + bandsCount + " bands.");

    getCursorLoc(x, y, z, flags);

    xstart = x;
    ystart = y;
    x2 = x;
    y2 = y;
    tolerance = 15;
    editing1 = 0;
    editing2 = 0;

    if (lx1 >= x-tolerance && lx1 <= x+tolerance && ly1 >= y-tolerance && ly1 <= y+tolerance) {
        editing1 = 1;
        x2 = lx2;
        y2 = ly2;
    }
    if (lx2 >= x-tolerance && lx2 <= x+tolerance && ly2 >= y-tolerance && ly2 <= y+tolerance) {
        editing2 = 1;
        xstart = lx1;
        ystart = ly1;
    }

    while (true) {
        getCursorLoc(x, y, z, flags);
        if (flags&16==0) {
            exit;
        }
	if (editing1 == 1 && (xstart!=x || ystart!=y)) {
            makeLine(xstart, ystart, x2, y2);
            overlayBands(xstart, ystart, x2, y2);
        } else if (editing1 != 1 && (x!=x2 || y!=y2)) {
            makeLine(xstart, ystart, x, y);
            overlayBands(xstart, ystart, x, y);
        }
        if (editing1 == 1) {
            xstart=x; ystart=y;
        } else {
            x2=x; y2=y;
        }
        wait(10);
    };
}

macro "WB Gel Bands Create ROIs Action Tool - C037T0710WTa710BC00cT0f08RT6f08OTdf08I" {
    createBandROIs();
}

function overlayBands(xa,ya,xb,yb) {
    Overlay.remove;
    setColor('yellow');
    setLineWidth(0.5);
    xs = (xb-xa)/bandsCount;
    ys = (yb-ya)/bandsCount;
    for (i=0;i<bandsCount+1;i++) {
        Overlay.moveTo(xa+i*xs, ya+i*ys-bandHeight/2);
        Overlay.lineTo(xa+i*xs, ya+i*ys+bandHeight/2);
    }
    Overlay.show;
}

function createBandROIs() {
    getLine(x1, y1, x2, y2, lineWidth);
    if (x1==-1)
        exit("This macro requires a straight line selection");
    bandsCount = parseInt(call("ij.Prefs.get", "WBGelDenT.bandsCount", bandsCount));
    bandHeight = parseInt(call("ij.Prefs.get", "WBGelDenT.bandHeight", bandHeight));
    prefix = getString("Logical band name (identification)","");
    title = getTitle;
    name = prefix+"."+"line "+replace(title, ".tif", "");
    filename = replace(title, ".tif", "");

    run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
    run("Set Measurements...", "area integrated display redirect=None decimal=3");

    ROIm = roiManager("count");
    roiManager("Add");
    roiManager("Select", ROIm);
    roiManager("Rename", name);
    setOption("Show All", true);
    dx = abs(x2-x1)/bandsCount;
    dy = (y2-y1)/bandsCount;

    blankPosition = bandsCount+0.9;
    if (x1 > x2) { // reverse direction of the line
        x1 = x2;
        y1 = y2;
        dy=-dy;
        blankPosition = -1.9;
    }

    for (i=0; i<bandsCount; i++) {
        name = prefix+"."+(i+1)+ " " + filename;
        rectByLineDivison(x1, y1, dx, dy, i, bandHeight, ROIm+i+1, name);
    }
    name = prefix+"."+"background"+ " " + filename;
    rectByLineDivison(x1, y1, dx, dy, blankPosition, bandHeight, ROIm+bandsCount+1, name); // Blank one
}

macro "WB Gel Bands Measure ROIs Action Tool -C037T0710WTa710BC00cT0f08CT7f08STdf08V" {
    title = getTitle;
    filename=replace(title, ".tif", "");
    dir = getDirectory("Image");

    /*
    if (File.exists(dir+filename+"-ROI.zip")) {
        waitForUser("ERROR:\n    File '" + dir+filename+"-ROI.zip" + "' exists.\n    Couldn't save results, move/delete the file and re-run measurement!");
        exit;
    }
    */

    bandsCount = parseInt(call("ij.Prefs.get", "WBGelDenT.bandsCount", bandsCount));
    ROIi = roiManager("index");
    ROIn = call("ij.plugin.frame.RoiManager.getName", ROIi);

    if (!matches(ROIn, ".*\.line "+filename+"")) {
    	waitForUser("Select correct ROI in ROI Manager with name like 'mybandname.line "+filename+"'");
    	exit;
    }
    for (i=0; i<(bandsCount+1); i++) {
        roiManager("Select", ROIi+1+i);
        run("Measure");
    }
    roiManager("Save", dir+filename+"-"+dateTimeISO()+"-ROI.zip");
    saveAs("Measurements", dir+filename+"-"+dateTimeISO()+".csv");
}

function dateTimeISO() {
     getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
     TimeString = ""+year;
     if (month<9) {TimeString = TimeString+"0";}
     TimeString = TimeString+month+1;
     if (dayOfMonth<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+dayOfMonth+"T";
     if (hour<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+hour;
     if (minute<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+minute;
     if (second<10) {TimeString = TimeString+"0";}
     TimeString = TimeString+second;
     return TimeString;
}

function rectByLineDivison(x1, y1, dx, dy, i, h, ROImi, name) {
    makeRectangle((x1+i*dx), (y1-h/2+dy*i+dy/2), dx, h);
    roiManager("Add");
    roiManager("Select", ROImi);
    roiManager("Rename", name);
}

  // This macro runs when the user double clicks on the tool
  // icon or selects "MultiCursor Tool Options" from the
  // Plugins>Macros menu.
  // The name of this macro must be the same as the name of the
  // tool (without the hex icon description) followed by " Options".
macro "WB Gel Bands Selection Tool Options" {
    bandsCount = parseInt(call("ij.Prefs.get", "WBGelDenT.bandsCount", bandsCount));
    bandHeight = parseInt(call("ij.Prefs.get", "WBGelDenT.bandHeight", bandHeight));

    Dialog.create("Choose Settings");
    Dialog.addMessage ("Wester Blot Gel image parameters:");
    Dialog.addNumber("Band's count", bandsCount, 0, 3, "");
    Dialog.addNumber("Height of a band", bandHeight, 0, 3, "");
    Dialog.show();

    bandsCount = Dialog.getNumber();
    bandHeight= Dialog.getNumber();
    if (isNaN(parseInt(bandsCount)) || isNaN(parseInt(bandHeight)) || bandsCount<1 || bandsCount>100 || bandHeight<10 || bandHeight>1000) {
        waitForUser("WARNING:\n    Some value is out of reasonable range.\n    Limits: count 1-100, height 10-1000\n \n    Setting was not changed!");
        exit;
    }

    call("ij.Prefs.set", "WBGelDenT.bandsCount", bandsCount);
    call("ij.Prefs.set", "WBGelDenT.bandHeight", bandHeight);
}

