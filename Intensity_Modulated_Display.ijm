// Intensity Modulated Display (IMD) Macro
// Version 2.0.1
// Creates an intensity-modulated FRET ratio display normalized by donor (CFP) intensity.
//
// Input modes:
//   - Two separate images: pick FRET and CFP images independently
//   - Single multi-channel stack: pick one image, specify acceptor/donor channels
//
// Background subtraction uses the "Subtract Background Plus" plugin (Sliding paraboloid
// by default). Install it from: https://github.com/yugo8849/subtract-background-plus
// Handles both stacks and single images. Parameters persist in IMD_parameters.txt.

// ============================================================
// PARAMETER DEFAULTS (loaded from file if present)
// ============================================================

paramFile = getDirectory("imagej") + "IMD_parameters.txt";
defaultRmax = 3;
defaultRmin = -1;
defaultDmax = 6000;
defaultDmin = 0;
defaultRadius = 50;
defaultSmoothing = 2;
defaultLUT = "physics";
defaultAccCh = 1;
defaultDonCh = 2;

if (File.exists(paramFile)) {
    paramString = File.openAsString(paramFile);
    lines = split(paramString, "\n");
    for (i = 0; i < lines.length; i++) {
        if (startsWith(lines[i], "rmax=")) defaultRmax = parseFloat(substring(lines[i], 5));
        if (startsWith(lines[i], "rmin=")) defaultRmin = parseFloat(substring(lines[i], 5));
        if (startsWith(lines[i], "dmax=")) defaultDmax = parseFloat(substring(lines[i], 5));
        if (startsWith(lines[i], "dmin=")) defaultDmin = parseFloat(substring(lines[i], 5));
        if (startsWith(lines[i], "radius=")) defaultRadius = parseFloat(substring(lines[i], 7));
        if (startsWith(lines[i], "smoothing=")) defaultSmoothing = parseFloat(substring(lines[i], 10));
        if (startsWith(lines[i], "lut=")) defaultLUT = substring(lines[i], 4);
        if (startsWith(lines[i], "acceptor_channel=")) defaultAccCh = parseInt(substring(lines[i], 17));
        if (startsWith(lines[i], "donor_channel=")) defaultDonCh = parseInt(substring(lines[i], 14));
    }
}

// ============================================================
// STEP 1: SELECT INPUT MODE
// ============================================================

Dialog.create("IMD - Input Mode");
Dialog.addMessage("How are your FRET (acceptor) and donor data arranged?");
Dialog.addChoice("Input mode:", newArray("Two separate images", "Single multi-channel stack"), "Two separate images");
Dialog.show();
inputMode = Dialog.getChoice();
isMultiChannel = (inputMode == "Single multi-channel stack");

// ============================================================
// STEP 2: BUILD LUT LIST (all LUTs available in ImageJ)
// ============================================================

lutList = newArray();
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
builtInLuts = newArray("Grays", "Fire", "Ice", "Spectrum", "Red", "Green", "Blue", "Cyan", "Magenta", "Yellow", "Red/Green",
                       "physics", "Jet", "Thermal", "Rainbow RGB", "Red Hot", "Green Fire Blue", "16 colors", "5 ramps", "6 shades");
lutOptions = Array.concat(builtInLuts, lutList);
lutOptions = Array.sort(lutOptions);

lutDefault = defaultLUT;
lutFound = false;
for (i = 0; i < lutOptions.length; i++) {
    if (lutOptions[i] == defaultLUT) lutFound = true;
}
if (!lutFound && lutOptions.length > 0) lutDefault = lutOptions[0];

// Background methods (labels must match Subtract Background Plus exactly)
bgMethods = newArray("Sliding paraboloid (separable, fast)", "Rolling ball (full resolution)", "Morphological opening (flat disk)");

// ============================================================
// STEP 3: MAIN PARAMETER DIALOG
// ============================================================

if (isMultiChannel) {
    imageList = getList("image.titles");
    if (imageList.length < 1) {
        showMessage("Error", "Please open a multi-channel stack.");
        exit();
    }

    Dialog.create("IMD - Multi-channel Stack");
    Dialog.addMessage("=== Image / Channel Selection ===");
    Dialog.addChoice("Multi-channel image:", imageList);
    Dialog.addNumber("Acceptor (FRET) channel:", defaultAccCh);
    Dialog.addNumber("Donor (CFP) channel:", defaultDonCh);
    addCommonParams(defaultRmax, defaultRmin, defaultDmax, defaultDmin, lutOptions, lutDefault, bgMethods, defaultRadius, defaultSmoothing);
    Dialog.show();

    multiName = Dialog.getChoice();
    acceptorCh = Dialog.getNumber();
    donorCh = Dialog.getNumber();
    rmax = Dialog.getNumber();
    rmin = Dialog.getNumber();
    dmax = Dialog.getNumber();
    dmin = Dialog.getNumber();
    lutChoice = Dialog.getChoice();
    testMode = Dialog.getCheckbox();
    subtractBG = Dialog.getCheckbox();
    bgMethod = Dialog.getChoice();
    radius = Dialog.getNumber();
    smoothing = Dialog.getNumber();
    saveParams = Dialog.getCheckbox();
    useBatchMode = Dialog.getCheckbox();

    // Validate channels
    selectWindow(multiName);
    getDimensions(w, h, channels, slices, frames);
    if (channels < 2) {
        showMessage("Error", "Selected image has only " + channels + " channel(s). Need at least 2.");
        exit();
    }
    if (acceptorCh < 1 || acceptorCh > channels || donorCh < 1 || donorCh > channels) {
        showMessage("Error", "Channel numbers must be between 1 and " + channels + ".");
        exit();
    }
    if (acceptorCh == donorCh) {
        showMessage("Error", "Acceptor and Donor channels must be different.");
        exit();
    }

    // Extract the two channels into separate images
    selectWindow(multiName);
    run("Duplicate...", "title=FRET_src duplicate channels=" + acceptorCh);
    fretName = "FRET_src";

    selectWindow(multiName);
    run("Duplicate...", "title=CFP_src duplicate channels=" + donorCh);
    cfpName = "CFP_src";

} else {
    imageList = getList("image.titles");
    if (imageList.length < 2) {
        showMessage("Error", "Please open at least 2 images (FRET and CFP).");
        exit();
    }

    Dialog.create("IMD - Two Images");
    Dialog.addMessage("=== Image Selection ===");
    Dialog.addChoice("FRET (Acceptor) image:", imageList);
    Dialog.addChoice("CFP (Donor) image:", imageList, imageList[minOf(1, imageList.length-1)]);
    addCommonParams(defaultRmax, defaultRmin, defaultDmax, defaultDmin, lutOptions, lutDefault, bgMethods, defaultRadius, defaultSmoothing);
    Dialog.show();

    fretName = Dialog.getChoice();
    cfpName = Dialog.getChoice();
    rmax = Dialog.getNumber();
    rmin = Dialog.getNumber();
    dmax = Dialog.getNumber();
    dmin = Dialog.getNumber();
    lutChoice = Dialog.getChoice();
    testMode = Dialog.getCheckbox();
    subtractBG = Dialog.getCheckbox();
    bgMethod = Dialog.getChoice();
    radius = Dialog.getNumber();
    smoothing = Dialog.getNumber();
    saveParams = Dialog.getCheckbox();
    useBatchMode = Dialog.getCheckbox();

    if (fretName == cfpName) {
        showMessage("Error", "Please select different images for FRET and CFP.");
        exit();
    }
}

rrange = rmax - rmin;
drange = dmax - dmin;

// ============================================================
// SAVE PARAMETERS
// ============================================================

if (saveParams) {
    paramContent = "rmax=" + rmax + "\n" +
                   "rmin=" + rmin + "\n" +
                   "dmax=" + dmax + "\n" +
                   "dmin=" + dmin + "\n" +
                   "radius=" + radius + "\n" +
                   "smoothing=" + smoothing + "\n" +
                   "lut=" + lutChoice + "\n";
    if (isMultiChannel) {
        paramContent = paramContent + "acceptor_channel=" + acceptorCh + "\n" +
                       "donor_channel=" + donorCh + "\n";
    }
    File.saveString(paramContent, paramFile);
    print("Parameters saved to: " + paramFile);
}

// ============================================================
// IMAGE PROCESSING
// ============================================================

selectWindow(fretName);
fretSlices = nSlices;
selectWindow(cfpName);
cfpSlices = nSlices;

if (fretSlices != cfpSlices) {
    showMessage("Error", "FRET and CFP must have the same number of slices (got " + fretSlices + " vs " + cfpSlices + ").");
    exit();
}

isStack = (fretSlices > 1);
stackOption = "";
if (isStack) stackOption = " stack";

// Test mode: extract first slice/frame only
if (testMode && isStack) {
    print("\n*** TEST MODE: Processing first frame only ***");

    selectWindow(fretName);
    setSlice(1);
    run("Duplicate...", "title=FRET_test");
    fretName = "FRET_test";

    selectWindow(cfpName);
    setSlice(1);
    run("Duplicate...", "title=CFP_test");
    cfpName = "CFP_test";

    fretSlices = nSlices;
    cfpSlices = fretSlices;
    isStack = (fretSlices > 1);
    stackOption = "";
    if (isStack) stackOption = " stack";
}

print("\n=== IMD Processing Started ===");
print("Input mode: " + inputMode);
print("FRET image: " + fretName + " (" + fretSlices + " slice(s))");
print("CFP image: " + cfpName + " (" + cfpSlices + " slice(s))");
if (isStack) print("Image type: Stack"); else print("Image type: Single image");
print("Ratio range: " + rmin + " to " + rmax);
print("Donor range: " + dmin + " to " + dmax);
print("LUT: " + lutChoice);

if (useBatchMode) {
    setBatchMode(true);
    print("Batch mode: Enabled");
} else {
    print("Batch mode: Disabled");
}

if (subtractBG) {
    print("Background subtraction: " + bgMethod + " (radius=" + radius + ", smoothing=" + smoothing + ")");
} else {
    print("Background subtraction: Disabled");
}

// Duplicate FRET, then background-subtract
selectWindow(fretName);
if (isStack) run("Duplicate...", "title=FRET_copy duplicate");
else run("Duplicate...", "title=FRET_copy");
if (subtractBG) subtractBackgroundPlus("FRET_copy", bgMethod, radius, smoothing, stackOption);

// Duplicate CFP, then background-subtract
selectWindow(cfpName);
if (isStack) run("Duplicate...", "title=CFP_copy duplicate");
else run("Duplicate...", "title=CFP_copy");
if (subtractBG) subtractBackgroundPlus("CFP_copy", bgMethod, radius, smoothing, stackOption);

// Ratio = FRET / CFP (32-bit)
if (isStack) imageCalculator("Divide create 32-bit stack", "FRET_copy", "CFP_copy");
else imageCalculator("Divide create 32-bit", "FRET_copy", "CFP_copy");
rename("Ratio_FRET_CFP");
rname = "Ratio_FRET_CFP";

// Donor for masking = background-subtracted CFP
dname = "CFP_copy";

// ============================================================
// IMD CORE ALGORITHM
// ============================================================

run("Conversions...", " ");

// Mask from donor intensity, normalized to 0-1
selectWindow(dname);
if (isStack) run("Duplicate...", "title=mask duplicate");
else run("Duplicate...", "title=mask");
run("32-bit");
run("Subtract...", "value=&dmin" + stackOption);
run("Divide...", "value=&drange" + stackOption);
run("Min...", "value=0" + stackOption);
run("Max...", "value=1" + stackOption);

// Ratio -> normalize -> LUT -> RGB
selectWindow(rname);
if (isStack) run("Duplicate...", "title=tempratio duplicate");
else run("Duplicate...", "title=tempratio");
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

if (isStack) run("RGB Stack");

// Split RGB and modulate each channel by the mask
selectWindow("tempratio");
run("Split Channels");

if (isStack) {
    redChannel = "C1-tempratio";
    greenChannel = "C2-tempratio";
    blueChannel = "C3-tempratio";
} else {
    redChannel = "tempratio (red)";
    greenChannel = "tempratio (green)";
    blueChannel = "tempratio (blue)";
}

selectWindow(redChannel); run("32-bit");
selectWindow(greenChannel); run("32-bit");
selectWindow(blueChannel); run("32-bit");

if (isStack) imageCalculator("Multiply stack", redChannel, "mask");
else imageCalculator("Multiply", redChannel, "mask");
selectWindow(redChannel); rename("red"); run("8-bit");

if (isStack) imageCalculator("Multiply stack", greenChannel, "mask");
else imageCalculator("Multiply", greenChannel, "mask");
selectWindow(greenChannel); rename("green"); run("8-bit");

if (isStack) imageCalculator("Multiply stack", blueChannel, "mask");
else imageCalculator("Multiply", blueChannel, "mask");
selectWindow(blueChannel); rename("blue"); run("8-bit");

// Merge to a single RGB result
if (isStack) run("Merge Channels...", "c1=red c2=green c3=blue create");
else run("Merge Channels...", "c1=red c2=green c3=blue");

run("RGB Color");
run("Conversions...", "scale");
finalName = "IMD-Rmax" + rmax + "-Rmin" + rmin + "-Dmax" + dmax + "-Dmin" + dmin + "-" + lutChoice;
rename(finalName);

// ============================================================
// CLEANUP
// ============================================================

closeIfOpen("mask");
closeIfOpen(rname);
closeIfOpen("FRET_copy");
closeIfOpen("CFP_copy");

if (testMode) {
    closeIfOpen("FRET_test");
    closeIfOpen("CFP_test");
}
if (isMultiChannel) {
    closeIfOpen("FRET_src");
    closeIfOpen("CFP_src");
}

if (useBatchMode) {
    selectWindow(finalName);
    setBatchMode("exit and display");
}

print("=== Processing Complete ===");
print("Output: " + finalName);
if (testMode) {
    print("*** TEST MODE: first frame only. Uncheck Test mode to process all frames. ***");
}
print("==============================\n");

// ============================================================
// FUNCTIONS
// ============================================================

// Adds parameter fields shared by both input modes.
function addCommonParams(dRmax, dRmin, dDmax, dDmin, luts, lutDef, methods, dRadius, dSmooth) {
    Dialog.addMessage("\n=== Ratio Range ===");
    Dialog.addNumber("Ratio max:", dRmax);
    Dialog.addNumber("Ratio min:", dRmin);
    Dialog.addMessage("\n=== Donor Intensity Range ===");
    Dialog.addNumber("Donor max:", dDmax);
    Dialog.addNumber("Donor min:", dDmin);
    Dialog.addMessage("\n=== Display ===");
    Dialog.addChoice("LUT:", luts, lutDef);
    Dialog.addMessage("\n=== Options ===");
    Dialog.addCheckbox("Test mode (first frame only, for stacks)", false);
    Dialog.addCheckbox("Subtract background (Subtract Background Plus)", false);
    Dialog.addChoice("BG method:", methods, methods[0]);
    Dialog.addNumber("BG radius (pixels):", dRadius);
    Dialog.addNumber("BG smoothing sigma (px):", dSmooth);
    Dialog.addCheckbox("Save parameters to file", true);
    Dialog.addCheckbox("Use batch mode (hide intermediate images)", true);
}

// Calls the "Subtract Background Plus" plugin on the given image.
// Dialog field order in the plugin: Method, Radius, Smoothing sigma,
// Background post-smoothing sigma, Light background, Create background, Shrink factor.
// For stacks the " stack" option must be appended so IJ.setupDialog enables
// DOES_STACKS and every slice is processed. The command name has NO "..." suffix.
function subtractBackgroundPlus(imageName, method, radius, smoothing, stackOpt) {
    selectWindow(imageName);
    run("Subtract Background Plus",
        "method=[" + method + "] radius=" + radius + " smoothing=" + smoothing + " background=0 shrink=1" + stackOpt);
}

// Closes an image window if it is currently open.
function closeIfOpen(imageName) {
    if (isImageOpen(imageName)) {
        selectWindow(imageName);
        close();
    }
}

// Returns true if an image window with the given name is open.
function isImageOpen(imageName) {
    list = getList("image.titles");
    for (j = 0; j < list.length; j++) {
        if (list[j] == imageName) return true;
    }
    return false;
}
