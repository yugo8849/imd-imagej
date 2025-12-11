package com.fret.imd;

import ij.*;
import ij.gui.*;
import ij.plugin.*;
import ij.process.*;
import java.io.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Intensity Modulated Display (IMD) Plugin
 * 
 * High-performance FRET ratio visualization with intensity modulation.
 * 
 * Bug fixes in v1.1:
 * - Ratio calculation now uses 32-bit float (was integer division)
 * - Mask uses background-subtracted image (was using original)
 * - Mask source selectable: CFP, FRET, or Average
 * - LUT selection fixed
 * 
 * @author Converted and optimized from ImageJ macro
 * @version 1.1.0
 */
public class Intensity_Modulated_Display implements PlugIn {
    
    // Parameters (static to persist between runs)
    private static double rmax = 3.0;
    private static double rmin = -1.0;
    private static double dmax = 6000.0;
    private static double dmin = 0.0;
    private static double rollingBallRadius = 50.0;
    private static String lutChoice = "physics";
    private static boolean testMode = false;
    private static boolean subtractBG = false;
    private static boolean saveParams = true;
    private static boolean useMultiThread = true;
    private static String maskSource = "CFP (Donor)";  // New: mask source selection
    
    // Mask source options
    private static final String[] MASK_SOURCES = {"CFP (Donor)", "FRET", "Average (CFP+FRET)/2"};
    
    private int fretIndex = 0;
    private int cfpIndex = 1;
    
    // LUT cache
    private byte[] lutReds = new byte[256];
    private byte[] lutGreens = new byte[256];
    private byte[] lutBlues = new byte[256];
    
    @Override
    public void run(String arg) {
        // Check for open images
        int[] imageIDs = WindowManager.getIDList();
        if (imageIDs == null || imageIDs.length < 2) {
            IJ.error("IMD Error", "Please open at least 2 images (FRET and CFP).");
            return;
        }
        
        // Get image titles
        String[] imageTitles = new String[imageIDs.length];
        for (int i = 0; i < imageIDs.length; i++) {
            imageTitles[i] = WindowManager.getImage(imageIDs[i]).getTitle();
        }
        
        // Load saved parameters
        loadParameters();
        
        // Show dialog
        if (!showDialog(imageTitles)) return;
        
        // Get selected images
        ImagePlus fretImp = WindowManager.getImage(imageIDs[fretIndex]);
        ImagePlus cfpImp = WindowManager.getImage(imageIDs[cfpIndex]);
        
        // Validation
        if (fretImp == cfpImp) {
            IJ.error("IMD Error", "Please select different images for FRET and CFP.");
            return;
        }
        
        if (fretImp.getStackSize() != cfpImp.getStackSize()) {
            IJ.error("IMD Error", "FRET and CFP must have the same number of slices.");
            return;
        }
        
        // Save parameters
        if (saveParams) saveParameters();
        
        // Process
        long startTime = System.currentTimeMillis();
        ImagePlus result = processIMD(fretImp, cfpImp);
        long elapsed = System.currentTimeMillis() - startTime;
        
        if (result != null) {
            result.show();
            IJ.log("=== IMD Complete ===");
            IJ.log("Processing time: " + elapsed + " ms");
            IJ.log("Output: " + result.getTitle());
            if (testMode && fretImp.getStackSize() > 1) {
                IJ.log("*** TEST MODE: Only first frame processed ***");
            }
        }
    }
    
    /**
     * Show parameter dialog
     */
    private boolean showDialog(String[] imageTitles) {
        // Get available LUTs
        String[] lutOptions = getAvailableLUTs();
        
        // Find default LUT index
        int lutIndex = 0;
        for (int i = 0; i < lutOptions.length; i++) {
            if (lutOptions[i].equals(lutChoice)) {
                lutIndex = i;
                break;
            }
        }
        
        // Find mask source index
        int maskIndex = 0;
        for (int i = 0; i < MASK_SOURCES.length; i++) {
            if (MASK_SOURCES[i].equals(maskSource)) {
                maskIndex = i;
                break;
            }
        }
        
        GenericDialog gd = new GenericDialog("IMD - Intensity Modulated Display v1.1");
        
        gd.addMessage("=== Image Selection ===");
        gd.addChoice("FRET image:", imageTitles, imageTitles[0]);
        gd.addChoice("CFP (Donor) image:", imageTitles, imageTitles[Math.min(1, imageTitles.length-1)]);
        
        gd.addMessage("=== Ratio Range ===");
        gd.addNumericField("Ratio max:", rmax, 2);
        gd.addNumericField("Ratio min:", rmin, 2);
        
        gd.addMessage("=== Intensity Mask Settings ===");
        gd.addNumericField("Intensity max:", dmax, 0);
        gd.addNumericField("Intensity min:", dmin, 0);
        gd.addChoice("Mask source:", MASK_SOURCES, MASK_SOURCES[maskIndex]);
        
        gd.addMessage("=== Display Options ===");
        gd.addChoice("LUT:", lutOptions, lutOptions[lutIndex]);
        
        gd.addMessage("=== Processing Options ===");
        gd.addCheckbox("Test mode (first frame only)", testMode);
        gd.addCheckbox("Subtract background (Rolling ball)", subtractBG);
        gd.addNumericField("Rolling ball radius:", rollingBallRadius, 0);
        gd.addCheckbox("Multi-threaded processing", useMultiThread);
        gd.addCheckbox("Save parameters", saveParams);
        
        gd.showDialog();
        
        if (gd.wasCanceled()) return false;
        
        // Get values
        fretIndex = gd.getNextChoiceIndex();
        cfpIndex = gd.getNextChoiceIndex();
        rmax = gd.getNextNumber();
        rmin = gd.getNextNumber();
        dmax = gd.getNextNumber();
        dmin = gd.getNextNumber();
        maskSource = gd.getNextChoice();
        lutChoice = gd.getNextChoice();
        testMode = gd.getNextBoolean();
        subtractBG = gd.getNextBoolean();
        rollingBallRadius = gd.getNextNumber();
        useMultiThread = gd.getNextBoolean();
        saveParams = gd.getNextBoolean();
        
        return true;
    }
    
    /**
     * Main IMD processing - optimized version with bug fixes
     */
    private ImagePlus processIMD(ImagePlus fretOrig, ImagePlus cfpOrig) {
        IJ.log("\n=== IMD Processing Started ===");
        IJ.log("FRET: " + fretOrig.getTitle() + ", CFP: " + cfpOrig.getTitle());
        IJ.log("Ratio range: " + rmin + " to " + rmax);
        IJ.log("Intensity range: " + dmin + " to " + dmax);
        IJ.log("Mask source: " + maskSource);
        IJ.log("LUT: " + lutChoice);
        
        int width = fretOrig.getWidth();
        int height = fretOrig.getHeight();
        int nSlices = fretOrig.getStackSize();
        boolean isStack = nSlices > 1;
        
        // Duplicate for processing
        ImagePlus fretImp, cfpImp;
        if (testMode && isStack) {
            IJ.log("*** TEST MODE: first frame only ***");
            fretImp = new Duplicator().run(fretOrig, 1, 1, 1, 1, 1, 1);
            cfpImp = new Duplicator().run(cfpOrig, 1, 1, 1, 1, 1, 1);
            nSlices = 1;
        } else {
            fretImp = new Duplicator().run(fretOrig);
            cfpImp = new Duplicator().run(cfpOrig);
        }
        
        // Background subtraction (use IJ.run for native speed)
        // Important: Do this BEFORE extracting pixel data for mask
        if (subtractBG) {
            IJ.log("Subtracting background (radius=" + rollingBallRadius + ")...");
            String stackOpt = nSlices > 1 ? " stack" : "";
            IJ.run(fretImp, "Subtract Background...", "rolling=" + rollingBallRadius + stackOpt);
            IJ.run(cfpImp, "Subtract Background...", "rolling=" + rollingBallRadius + stackOpt);
        }
        
        // Load LUT colors
        if (!loadLUTColors(lutChoice)) {
            IJ.log("Warning: Could not load LUT '" + lutChoice + "', using Fire");
            loadLUTColors("Fire");
        }
        
        // Pre-calculate constants (using float for precision - bug fix)
        final float fRmin = (float) rmin;
        final float fRrange = (float) (rmax - rmin);
        final float fDmin = (float) dmin;
        final float fDrange = (float) (dmax - dmin);
        
        // Create output stack
        ImageStack outputStack = new ImageStack(width, height);
        
        // Multi-threaded or single-threaded processing
        if (useMultiThread && nSlices > 1) {
            processMultiThreaded(fretImp, cfpImp, outputStack, width, height, nSlices,
                                 fRmin, fRrange, fDmin, fDrange);
        } else {
            processSingleThreaded(fretImp, cfpImp, outputStack, width, height, nSlices,
                                  fRmin, fRrange, fDmin, fDrange);
        }
        
        // Create output image
        String title = "IMD-Rmax" + rmax + "-Rmin" + rmin + 
                      "-Dmax" + (int)dmax + "-Dmin" + (int)dmin + "-" + lutChoice;
        ImagePlus output = new ImagePlus(title, outputStack);
        output.setCalibration(fretOrig.getCalibration().copy());
        
        // Cleanup
        fretImp.close();
        cfpImp.close();
        
        IJ.showProgress(1.0);
        IJ.showStatus("IMD complete");
        
        return output;
    }
    
    /**
     * Single-threaded processing
     */
    private void processSingleThreaded(ImagePlus fretImp, ImagePlus cfpImp, 
                                       ImageStack outputStack, int width, int height, int nSlices,
                                       float fRmin, float fRrange, float fDmin, float fDrange) {
        for (int slice = 1; slice <= nSlices; slice++) {
            if (nSlices > 1) {
                IJ.showProgress(slice - 1, nSlices);
                IJ.showStatus("IMD: slice " + slice + "/" + nSlices);
            }
            
            fretImp.setSlice(slice);
            cfpImp.setSlice(slice);
            
            // Get pixel data as float (important for accurate ratio calculation)
            float[] fretPixels = getFloatPixels(fretImp.getProcessor());
            float[] cfpPixels = getFloatPixels(cfpImp.getProcessor());
            
            int[] rgbPixels = processPixelArrays(fretPixels, cfpPixels,
                                                 width * height, fRmin, fRrange, fDmin, fDrange);
            
            outputStack.addSlice(new ColorProcessor(width, height, rgbPixels));
        }
    }
    
    /**
     * Multi-threaded processing for stacks
     */
    private void processMultiThreaded(ImagePlus fretImp, ImagePlus cfpImp,
                                      ImageStack outputStack, int width, int height, int nSlices,
                                      float fRmin, float fRrange, float fDmin, float fDrange) {
        
        // Pre-extract all slice data as float arrays (bug fix: ensures float precision)
        final float[][] fretData = new float[nSlices][];
        final float[][] cfpData = new float[nSlices][];
        
        for (int s = 0; s < nSlices; s++) {
            fretImp.setSlice(s + 1);
            cfpImp.setSlice(s + 1);
            fretData[s] = getFloatPixels(fretImp.getProcessor());
            cfpData[s] = getFloatPixels(cfpImp.getProcessor());
        }
        
        // Prepare result array
        final int[][] results = new int[nSlices][];
        
        int nThreads = Runtime.getRuntime().availableProcessors();
        ExecutorService executor = Executors.newFixedThreadPool(nThreads);
        AtomicInteger progress = new AtomicInteger(0);
        
        IJ.log("Using " + nThreads + " threads");
        
        // Submit tasks
        for (int s = 0; s < nSlices; s++) {
            final int slice = s;
            executor.submit(() -> {
                results[slice] = processPixelArrays(fretData[slice], cfpData[slice],
                                                    width * height, fRmin, fRrange, fDmin, fDrange);
                int done = progress.incrementAndGet();
                IJ.showProgress(done, nSlices);
                IJ.showStatus("IMD: " + done + "/" + nSlices);
            });
        }
        
        // Wait for completion
        executor.shutdown();
        try {
            executor.awaitTermination(1, TimeUnit.HOURS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        // Add results to stack
        for (int s = 0; s < nSlices; s++) {
            outputStack.addSlice(new ColorProcessor(width, height, results[s]));
        }
    }
    
    /**
     * Core pixel processing - with bug fixes
     * - Uses float division for accurate ratio
     * - Supports multiple mask sources
     */
    private int[] processPixelArrays(float[] fretPixels, float[] cfpPixels, int size,
                                     float fRmin, float fRrange, float fDmin, float fDrange) {
        int[] rgbPixels = new int[size];
        
        // Local references for speed
        final byte[] reds = this.lutReds;
        final byte[] greens = this.lutGreens;
        final byte[] blues = this.lutBlues;
        
        for (int i = 0; i < size; i++) {
            float fretVal = fretPixels[i];
            float cfpVal = cfpPixels[i];
            
            // Calculate ratio using FLOAT division (bug fix)
            float ratio;
            if (cfpVal != 0) {
                ratio = fretVal / cfpVal;
            } else {
                ratio = 0;
            }
            
            // Handle NaN
            if (Float.isNaN(ratio)) {
                ratio = 0;
            }
            
            // Normalize ratio to 0-1
            float normRatio = (ratio - fRmin) / fRrange;
            if (normRatio < 0) normRatio = 0;
            else if (normRatio > 1) normRatio = 1;
            
            // LUT index (0-255)
            int idx = (int) (normRatio * 255);
            if (idx > 255) idx = 255;
            if (idx < 0) idx = 0;
            
            // Calculate mask from selected source (bug fix: use processed image)
            float maskValue;
            if (maskSource.equals("FRET")) {
                maskValue = fretVal;
            } else if (maskSource.equals("Average (CFP+FRET)/2")) {
                maskValue = (cfpVal + fretVal) / 2.0f;
            } else {
                // Default: CFP (Donor)
                maskValue = cfpVal;
            }
            
            float mask = (maskValue - fDmin) / fDrange;
            if (mask < 0) mask = 0;
            else if (mask > 1) mask = 1;
            
            // Apply LUT and mask
            int r = (int) ((reds[idx] & 0xff) * mask);
            int g = (int) ((greens[idx] & 0xff) * mask);
            int b = (int) ((blues[idx] & 0xff) * mask);
            
            // Clamp values (shouldn't be necessary but for safety)
            if (r > 255) r = 255;
            if (g > 255) g = 255;
            if (b > 255) b = 255;
            
            rgbPixels[i] = (r << 16) | (g << 8) | b;
        }
        
        return rgbPixels;
    }
    
    /**
     * Get pixels as float array (handles 8, 16, 32-bit)
     * This ensures accurate ratio calculation regardless of input bit depth
     */
    private float[] getFloatPixels(ImageProcessor ip) {
        int size = ip.getWidth() * ip.getHeight();
        float[] result = new float[size];
        
        if (ip instanceof FloatProcessor) {
            float[] src = (float[]) ip.getPixels();
            System.arraycopy(src, 0, result, 0, size);
        } else if (ip instanceof ShortProcessor) {
            short[] pixels = (short[]) ip.getPixels();
            for (int i = 0; i < size; i++) {
                result[i] = pixels[i] & 0xffff;
            }
        } else if (ip instanceof ByteProcessor) {
            byte[] pixels = (byte[]) ip.getPixels();
            for (int i = 0; i < size; i++) {
                result[i] = pixels[i] & 0xff;
            }
        } else {
            // Fallback for other types
            for (int i = 0; i < size; i++) {
                result[i] = ip.getf(i);
            }
        }
        return result;
    }
    
    /**
     * Load LUT colors into arrays
     * Fixed: properly handles LUT loading and returns success status
     */
    private boolean loadLUTColors(String lutName) {
        try {
            // Create a test image to apply LUT
            ByteProcessor bp = new ByteProcessor(256, 1);
            for (int i = 0; i < 256; i++) {
                bp.set(i, 0, i);
            }
            ImagePlus tempImp = new ImagePlus("temp", bp);
            
            // Try to apply the LUT
            IJ.run(tempImp, lutName, "");
            
            // Get the LUT
            LUT lut = tempImp.getProcessor().getLut();
            if (lut != null) {
                lut.getReds(lutReds);
                lut.getGreens(lutGreens);
                lut.getBlues(lutBlues);
                tempImp.close();
                return true;
            }
            
            tempImp.close();
            return false;
            
        } catch (Exception e) {
            IJ.log("Error loading LUT: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Get available LUTs - comprehensive list
     */
    private String[] getAvailableLUTs() {
        TreeSet<String> luts = new TreeSet<>();
        
        // Built-in LUTs (comprehensive list)
        String[] builtIn = {
            "Grays", "Fire", "Ice", "Spectrum", "Red", "Green", "Blue",
            "Cyan", "Magenta", "Yellow", "Red/Green", "physics", "Jet", 
            "Thermal", "Rainbow RGB", "Red Hot", "Green Fire Blue", 
            "16 colors", "5 ramps", "6 shades"
        };
        Collections.addAll(luts, builtIn);
        
        // Custom LUTs from luts folder
        String ijDir = IJ.getDirectory("imagej");
        if (ijDir != null) {
            String lutDir = ijDir + "luts" + File.separator;
            File folder = new File(lutDir);
            if (folder.exists() && folder.isDirectory()) {
                File[] files = folder.listFiles((d, n) -> n.endsWith(".lut"));
                if (files != null) {
                    for (File f : files) {
                        String name = f.getName();
                        luts.add(name.substring(0, name.length() - 4));
                    }
                }
            }
        }
        
        return luts.toArray(new String[0]);
    }
    
    /**
     * Load parameters from file
     */
    private void loadParameters() {
        String ijDir = IJ.getDirectory("imagej");
        if (ijDir == null) return;
        
        String paramFile = ijDir + "IMD_parameters.txt";
        File f = new File(paramFile);
        if (!f.exists()) return;
        
        try (BufferedReader reader = new BufferedReader(new FileReader(f))) {
            String line;
            while ((line = reader.readLine()) != null) {
                line = line.trim();
                if (line.startsWith("rmax=")) {
                    rmax = Double.parseDouble(line.substring(5));
                } else if (line.startsWith("rmin=")) {
                    rmin = Double.parseDouble(line.substring(5));
                } else if (line.startsWith("dmax=")) {
                    dmax = Double.parseDouble(line.substring(5));
                } else if (line.startsWith("dmin=")) {
                    dmin = Double.parseDouble(line.substring(5));
                } else if (line.startsWith("rolling_ball_radius=")) {
                    rollingBallRadius = Double.parseDouble(line.substring(20));
                } else if (line.startsWith("lut=")) {
                    lutChoice = line.substring(4).trim();
                } else if (line.startsWith("mask_source=")) {
                    maskSource = line.substring(12).trim();
                }
            }
        } catch (Exception e) { 
            // Ignore errors, use defaults
        }
    }
    
    /**
     * Save parameters to file
     */
    private void saveParameters() {
        String ijDir = IJ.getDirectory("imagej");
        if (ijDir == null) return;
        
        String paramFile = ijDir + "IMD_parameters.txt";
        try (PrintWriter w = new PrintWriter(new FileWriter(paramFile))) {
            w.println("rmax=" + rmax);
            w.println("rmin=" + rmin);
            w.println("dmax=" + dmax);
            w.println("dmin=" + dmin);
            w.println("rolling_ball_radius=" + rollingBallRadius);
            w.println("lut=" + lutChoice);
            w.println("mask_source=" + maskSource);
            IJ.log("Parameters saved to: " + paramFile);
        } catch (Exception e) {
            IJ.log("Warning: Could not save parameters");
        }
    }
}
