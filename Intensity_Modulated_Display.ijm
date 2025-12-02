// Improved Intensity Modulated Display (IMD) Macro
// Automatically creates ratio image from FRET and CFP, handles both stacks and single images
// Parameters can be saved to and loaded from a text file

// ============================================================
// PARAMETER SETTINGS
// ============================================================

// Get list of open images
imageList = getList("image.titles");
if (imageList.length < 2) {
    showMessage("Error", "Please open at least 2 images (FRET and CFP).");
    exit();
}

// Check if parameter file exists
paramFile = getDirectory("imagej") + "IMD_parameters.txt";
defaultRmax = 3;
defaultRmin = -1;
defaultDmax = 6000;
defaultDmin = 0;
defaultRollingBallRadius = 50;
defaultLUT = "physics";

// Load parameters from file if it exists
if (File.exists(paramFile)) {
    paramString = File.openAsString(paramFile);
    lines = split(paramString, "\n");
    for (i = 0; i < lines.length; i++) {
        if (startsWith(lines[i], "rmax=")) defaultRmax = parseFloat(substring(lines[i], 5));
        if (startsWith(lines[i], "rmin=")) defaultRmin = parseFloat(substring(lines[i], 5));
        if (startsWith(lines[i], "dmax=")) defaultDmax = parseFloat(substring(lines[i], 5));
        if (startsWith(lines[i], "dmin=")) defaultDmin = parseFloat(substring(lines[i], 5));
        if (startsWith(lines[i], "rolling_ball_radius=")) defaultRollingBallRadius = parseFloat(substring(lines[i], 20));
        if (startsWith(lines[i], "lut=")) defaultLUT = substring(lines[i], 4);
    }
}

// Create dialog for user input
Dialog.create("IMD - Image Selection and Parameters");
Dialog.addMessage("=== Image Selection ===");
Dialog.addChoice("FRET image:", imageList);
Dialog.addChoice("CFP (Donor) image:", imageList, imageList[Math.min(1, imageList.length-1)]);
Dialog.addMessage("\n=== Ratio Range ===");
Dialog.addNumber("Ratio max:", defaultRmax);
Dialog.addNumber("Ratio min:", defaultRmin);
Dialog.addMessage("\n=== Donor Intensity Range ===");
Dialog.addNumber("Donor max:", defaultDmax);
Dialog.addNumber("Donor min:", defaultDmin);
Dialog.addMessage("\n=== Display Options ===");
// Get all available LUTs from ImageJ
lutList = newArray();
// Try to get LUTs from luts folder
ijDir = getDirectory("imagej");
lutDir = ijDir + "luts" + File.separator;
if (File.exists(lutDir)) {
    lutFiles = getFileList(lutDir);
    for (i = 0; i < lutFiles.length; i++) {
        if (endsWith(lutFiles[i], ".lut")) {
            lutName = substring(lutFiles[i], 0, lengthOf(lutFiles[i])-4);
            lutList = Array.concat(lutList, lutName);
        }
    }
}
// Add commonly available built-in LUTs
builtInLuts = newArray("Grays", "Fire", "Ice", "Spectrum", "Red", "Green", "Blue", "Cyan", "Magenta", "Yellow", "Red/Green", 
                       "physics", "Jet", "Thermal", "Rainbow RGB", "Red Hot", "Green Fire Blue", "16 colors", "5 ramps", "6 shades");
lutOptions = Array.concat(builtInLuts, lutList);
// Sort and keep unique
lutOptions = Array.sort(lutOptions);

// Set default LUT (if not in the list, use the first one)
lutDefault = defaultLUT;
lutFound = false;
for (i = 0; i < lutOptions.length; i++) {
    if (lutOptions[i] == defaultLUT) {
        lutFound = true;
    }
}
if (!lutFound && lutOptions.length > 0) {
    lutDefault = lutOptions[0];
}
Dialog.addChoice("LUT:", lutOptions, lutDefault);
Dialog.addMessage("\n=== Options ===");
Dialog.addCheckbox("Test mode (process first frame only for stacks)", false);
Dialog.addCheckbox("Subtract background (Rolling ball)", false);
Dialog.addNumber("Rolling ball radius:", defaultRollingBallRadius);
Dialog.addCheckbox("Save parameters to file", true);
Dialog.addCheckbox("Use batch mode (hide intermediate images)", true);
Dialog.show();

// Get user input
fretName = Dialog.getChoice();
cfpName = Dialog.getChoice();
rmax = Dialog.getNumber();
rmin = Dialog.getNumber();
dmax = Dialog.getNumber();
dmin = Dialog.getNumber();
lutChoice = Dialog.getChoice();
testMode = Dialog.getCheckbox();
subtractBG = Dialog.getCheckbox();
rollingBallRadius = Dialog.getNumber();
saveParams = Dialog.getCheckbox();
useBatchMode = Dialog.getCheckbox();

// Validate image selection
if (fretName == cfpName) {
    showMessage("Error", "Please select different images for FRET and CFP.");
    exit();
}

// Calculate ranges
rrange = rmax - rmin;
drange = dmax - dmin;

// Save parameters if requested
if (saveParams) {
    paramContent = "rmax=" + rmax + "\n" +
                   "rmin=" + rmin + "\n" +
                   "dmax=" + dmax + "\n" +
                   "dmin=" + dmin + "\n" +
                   "rolling_ball_radius=" + rollingBallRadius + "\n" +
                   "lut=" + lutChoice + "\n";
    File.saveString(paramContent, paramFile);
    print("Parameters saved to: " + paramFile);
}

// ============================================================
// IMAGE PROCESSING
// ============================================================

// Check if images are stacks or single images
selectWindow(fretName);
fretSlices = nSlices;
selectWindow(cfpName);
cfpSlices = nSlices;

if (fretSlices != cfpSlices) {
    showMessage("Error", "FRET and CFP images must have the same number of slices.");
    exit();
}

isStack = (fretSlices > 1);
stackOption = "";
if (isStack) {
    stackOption = " stack";
}

// Test mode: Extract first frame only for stacks
if (testMode && isStack) {
    print("\n*** TEST MODE: Processing first frame only ***");
    
    // Extract first frame from FRET
    selectWindow(fretName);
    run("Duplicate...", "title=FRET_test duplicate frames=1-1");
    fretName = "FRET_test";
    
    // Extract first frame from CFP
    selectWindow(cfpName);
    run("Duplicate...", "title=CFP_test duplicate frames=1-1");
    cfpName = "CFP_test";
    
    // Update variables for single image processing
    fretSlices = 1;
    cfpSlices = 1;
    isStack = false;
    stackOption = "";
}

print("\n=== IMD Processing Started ===");
print("FRET image: " + fretName + " (" + fretSlices + " slice(s))");
print("CFP image: " + cfpName + " (" + cfpSlices + " slice(s))");
if (isStack) {
    print("Image type: Stack");
} else {
    print("Image type: Single image");
}
print("Ratio range: " + rmin + " to " + rmax);
print("Donor range: " + dmin + " to " + dmax);
print("LUT: " + lutChoice);

// Enable batch mode to hide intermediate images
if (useBatchMode) {
    setBatchMode(true);
    print("Batch mode: Enabled");
} else {
    print("Batch mode: Disabled");
}

if (subtractBG) {
    print("Background subtraction: Enabled (Rolling ball radius = " + rollingBallRadius + ")");
} else {
    print("Background subtraction: Disabled");
}

// Create ratio image using Image Calculator
selectWindow(fretName);
if (isStack) {
    run("Duplicate...", "title=FRET_copy duplicate");
} else {
    run("Duplicate...", "title=FRET_copy");
}

// Subtract background from FRET copy if requested
if (subtractBG) {
    selectWindow("FRET_copy");
    if (isStack) {
        run("Subtract Background...", "rolling=" + rollingBallRadius + " stack");
    } else {
        run("Subtract Background...", "rolling=" + rollingBallRadius);
    }
}

selectWindow(cfpName);
if (isStack) {
    run("Duplicate...", "title=CFP_copy duplicate");
} else {
    run("Duplicate...", "title=CFP_copy");
}

// Subtract background from CFP copy if requested
if (subtractBG) {
    selectWindow("CFP_copy");
    if (isStack) {
        run("Subtract Background...", "rolling=" + rollingBallRadius + " stack");
    } else {
        run("Subtract Background...", "rolling=" + rollingBallRadius);
    }
}

if (isStack) {
    imageCalculator("Divide create stack", "FRET_copy", "CFP_copy");
} else {
    imageCalculator("Divide create", "FRET_copy", "CFP_copy");
}
rename("Ratio_FRET_CFP");
rname = "Ratio_FRET_CFP";

// Close temporary copies
selectWindow("FRET_copy");
close();
selectWindow("CFP_copy");
close();

// Use CFP as donor image
dname = cfpName;

// ============================================================
// IMD PROCESSING (Original Algorithm)
// ============================================================

run("Conversions...", " ");

// Create mask from donor image
selectWindow(dname);
if (isStack) {
    run("Duplicate...", "title=mask duplicate");
} else {
    run("Duplicate...", "title=mask");
}
run("32-bit");
run("Subtract...", "value=&dmin" + stackOption);
run("Divide...", "value=&drange" + stackOption);
run("Min...", "value=0" + stackOption);
run("Max...", "value=1" + stackOption);

// Process ratio image
selectWindow(rname);
if (isStack) {
    run("Duplicate...", "title=tempratio duplicate");
} else {
    run("Duplicate...", "title=tempratio");
}
run("32-bit");
changeValues(NaN, NaN, 0);
run("Subtract...", "value=&rmin" + stackOption);
run("Divide...", "value=&rrange" + stackOption);
run("Min...", "value=0" + stackOption);
run("Max...", "value=1" + stackOption);
run("Multiply...", "value=255" + stackOption);
run("8-bit");
run(lutChoice);
run("RGB Color");

// Handle stack vs single image
if (isStack) {
    run("RGB Stack");
}

// Split and process RGB channels
selectWindow("tempratio");
run("Split Channels");

// Channel names differ between stacks and single images
// Stack: C1-tempratio, C2-tempratio, C3-tempratio
// Single: tempratio (red), tempratio (green), tempratio (blue)
if (isStack) {
    redChannel = "C1-tempratio";
    greenChannel = "C2-tempratio";
    blueChannel = "C3-tempratio";
    print("Channel naming: Stack format (C1-, C2-, C3-)");
} else {
    redChannel = "tempratio (red)";
    greenChannel = "tempratio (green)";
    blueChannel = "tempratio (blue)";
    print("Channel naming: Single image format ((red), (green), (blue))");
}

// Convert channels to 32-bit
selectWindow(redChannel);
run("32-bit");
selectWindow(greenChannel);
run("32-bit");
selectWindow(blueChannel);
run("32-bit");

// Multiply each channel by mask
if (isStack) {
    imageCalculator("Multiply stack", redChannel, "mask");
} else {
    imageCalculator("Multiply", redChannel, "mask");
}
selectWindow(redChannel);
rename("red");
run("8-bit");

if (isStack) {
    imageCalculator("Multiply stack", greenChannel, "mask");
} else {
    imageCalculator("Multiply", greenChannel, "mask");
}
selectWindow(greenChannel);
rename("green");
run("8-bit");

if (isStack) {
    imageCalculator("Multiply stack", blueChannel, "mask");
} else {
    imageCalculator("Multiply", blueChannel, "mask");
}
selectWindow(blueChannel);
rename("blue");
run("8-bit");

// Merge channels
if (isStack) {
    run("Merge Channels...", "c1=red c2=green c3=blue create");
} else {
    run("Merge Channels...", "c1=red c2=green c3=blue");
}

// Convert to RGB Color (ensure final output is RGB)
run("RGB Color");
run("Conversions...", "scale");
finalName = "IMD-Rmax" + rmax + "-Rmin" + rmin + "-Dmax" + dmax + "-Dmin" + dmin + "-" + lutChoice;
rename(finalName);

// Clean up before exiting batch mode
selectWindow("mask");
close();
selectWindow(rname);
close();

// Clean up test mode temporary images
if (testMode) {
    if (isImageOpen("FRET_test")) {
        selectWindow("FRET_test");
        close();
    }
    if (isImageOpen("CFP_test")) {
        selectWindow("CFP_test");
        close();
    }
}

// Disable batch mode and show only the final result
if (useBatchMode) {
    selectWindow(finalName);
    setBatchMode("exit and display");
}

print("=== Processing Complete ===");
print("Output: " + finalName);
if (testMode) {
    print("*** TEST MODE: Only first frame was processed ***");
    print("*** Uncheck 'Test mode' to process all frames ***");
}
print("==============================\n");

// Helper function to check if image window is open
function isImageOpen(imageName) {
    list = getList("image.titles");
    for (i = 0; i < list.length; i++) {
        if (list[i] == imageName) {
            return true;
        }
    }
    return false;
}
