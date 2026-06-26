# Intensity Modulated Display (IMD) for ImageJ/Fiji

A macro for ImageJ/Fiji that creates intensity-modulated FRET ratio displays normalized by donor (CFP) intensity.

## Overview

This macro converts FRET/CFP ratio images into color-coded displays with intensity modulation, making it easier to visualize both FRET activity and cell localization simultaneously.

**Key Features:**
- Two input modes: two separate images, or a single multi-channel stack (select channels)
- Automatic FRET/CFP ratio calculation
- Dynamic LUT (color map) selection from all available ImageJ LUTs
- Test mode for rapid parameter optimization
- Background subtraction via the Subtract Background Plus plugin (Sliding paraboloid, Rolling ball, or Morphological opening)
- Batch processing mode
- Automatic parameter saving and loading
- Support for both stack and single images

Available both as a compiled plugin (Plugins/FRET menu) and as an editable macro.

## Requirements

- ImageJ 1.53c or later
- Fiji (compatible)
- Operating System: Windows, Mac, or Linux
- [Subtract Background Plus](https://github.com/yugo8849/subtract-background-plus) plugin — required only when background subtraction is enabled

## Installation

### Installation as Plugin (recommended)

1. Go to the [Releases](../../releases) page and download the latest `.jar` file.
2. Copy to ImageJ's `plugins/` folder:
   - Windows: `C:\Program Files\ImageJ\plugins\`
   - Mac: `/Applications/ImageJ.app/plugins/` (right-click app, "Show Package Contents")
   - Linux: `~/ImageJ/plugins/`
3. Restart ImageJ

The plugin will appear in the **Plugins/FRET** menu.

If you plan to use background subtraction, also install the
[Subtract Background Plus](https://github.com/yugo8849/subtract-background-plus) JAR
in the same `plugins/` folder.

### Installation as Macro (if you need modification)

1. Download `Intensity_Modulated_Display.ijm`
2. Copy to ImageJ's `plugins/` folder:
   - Windows: `C:\Program Files\ImageJ\plugins\`
   - Mac: `/Applications/ImageJ.app/plugins/` (right-click app, "Show Package Contents")
   - Linux: `~/ImageJ/plugins/`
3. Restart ImageJ

The macro will appear in the **Plugins** menu.

## Quick Start

### Basic Workflow

1. Open your images in ImageJ (either two separate FRET/CFP images, or one multi-channel stack)
2. Run **Plugins > FRET > Intensity Modulated Display**
3. Choose the input mode:
   - **Two separate images**: pick the FRET and CFP images
   - **Single multi-channel stack**: pick the image and specify the acceptor (FRET) and donor (CFP) channel numbers
4. Set parameters in the dialog
5. For stacks, use **Test mode** to optimize parameters quickly
6. Click **OK** to process

### Example Parameters

- Ratio max: 2 (adjust based on your FRET/CFP ratio range)
- Ratio min: 1
- Donor max: 6000 (adjust based on CFP intensity histogram)
- Donor min: 100
- LUT: physics (or choose from available LUTs)
- Background subtraction: optional (radius 50-100 recommended)

## Features

### Input Modes

**Two separate images** — Select FRET and CFP from independently opened images.

**Single multi-channel stack** — Common for data where acceptor and donor are different
channels of one hyperstack. Select the image and specify the acceptor (FRET) and donor
(CFP) channel numbers; the plugin extracts the channels automatically, so no manual
Split Channels step is needed.

### LUT Selection

Choose from all LUTs installed in ImageJ:
- Built-in LUTs: physics, Fire, Jet, Spectrum, Thermal, and more
- Custom LUTs: Any .lut files in ImageJ/luts/ folder are automatically detected

**Adding Custom LUTs:**
1. Place .lut files in `ImageJ/luts/` folder
2. Restart ImageJ
3. Custom LUTs will appear in the macro's LUT dropdown

See [CUSTOM_LUT_GUIDE.md](CUSTOM_LUT_GUIDE.md) for details.

### Test Mode

For stack images, Test mode processes only the first frame, allowing rapid parameter adjustment without processing the entire stack.

**Recommended Workflow:**
1. Enable Test mode
2. Adjust parameters and run multiple times
3. Save parameters when satisfied
4. Disable Test mode and process full stack

### Background Subtraction

Optional background subtraction via the **Subtract Background Plus** plugin. Choose the method:
- **Sliding paraboloid (separable, fast)** — default
- **Rolling ball (full resolution)**
- **Morphological opening (flat disk)**

Adjustable radius (recommended: larger than cell diameter, typically 50-100) and smoothing
sigma. Applied to both FRET and CFP images, across all slices of a stack, before ratio calculation.
Requires the [Subtract Background Plus](https://github.com/yugo8849/subtract-background-plus) plugin.

### Batch Mode

Hides intermediate images during processing for cleaner interface and faster performance.

### Parameter Persistence

Parameters are automatically saved to `IMD_parameters.txt` in the ImageJ directory and loaded on next run.

## Parameters

### Ratio Range
- **Ratio max/min**: Display range for FRET/CFP ratio
- Check ratio image histogram to determine appropriate range

### Donor Intensity Range
- **Donor max/min**: Normalization range for CFP intensity
- Check CFP histogram (Analyze > Histogram) to determine range

### Display Options
- **LUT**: Color map for ratio display
- Choose from all available ImageJ LUTs

### Processing Options
- **Test mode**: Process first frame only (stack images)
- **Background subtraction**: Apply Subtract Background Plus
- **BG method**: Sliding paraboloid / Rolling ball / Morphological opening
- **BG radius / smoothing sigma**: Background subtraction parameters
- **Save parameters**: Save settings to file
- **Batch mode**: Hide intermediate images

## Output

Output image is named: `IMD-Rmax[X]-Rmin[Y]-Dmax[Z]-Dmin[W]-[LUT].tif`

The image is an RGB color image combining:
- Ratio values mapped to the selected LUT
- Intensity modulated by CFP (donor) brightness

## Documentation

- **QUICKSTART.md** - 5-minute getting started guide
- **USER_GUIDE.md** - Detailed usage instructions
- **CUSTOM_LUT_GUIDE.md** - Guide for adding custom LUTs
- **TROUBLESHOOTING.md** - Common issues and solutions
- **INSTALLATION.md** - Complete installation instructions
- **CHANGELOG.md** - Version history

## Scientific Background

This macro implements intensity-modulated display for FRET imaging:
- FRET/CFP ratio values are pseudocolored using the selected LUT
- Brightness is normalized by CFP (donor) intensity
- Result shows both FRET activity (color) and localization (brightness)

## Troubleshooting

### Macro not appearing in menu
- Restart ImageJ
- Verify file is in `plugins/` folder
- Check file has .ijm extension

### Dark or bright results
- Adjust Donor max/min based on CFP histogram
- Use Test mode to optimize quickly

### LUT not appearing
- Verify .lut file is in `ImageJ/luts/` folder
- File size should be 768 bytes
- Restart ImageJ after adding LUTs

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more solutions.

## Version History

### v2.0.1 (2026-06-24)
- Added single multi-channel stack input mode (select acceptor/donor channels)
- Background subtraction now uses the Subtract Background Plus plugin (Sliding paraboloid, Rolling ball, or Morphological opening)
- Fixed: background subtraction now applies to all slices of a stack
- Added background smoothing sigma parameter; channel numbers persisted

### v1.1.0 (2025-12-02)
- Added dynamic LUT selection from all available ImageJ LUTs
- Added support for custom LUTs
- Improved RGB color output consistency
- LUT name included in output filename

### v1.0.0 (2025-11-06)
- Initial release
- Dialog-based image selection
- Test mode implementation
- Background subtraction
- Parameter persistence

See [CHANGELOG.md](CHANGELOG.md) for complete history.

## Contributing

Bug reports, feature requests, and pull requests are welcome.

### Development

```bash
git clone https://github.com/yugo8849/imd-imagej.git
cd imd-imagej
```

Edit the macro in ImageJ's Script Editor or any text editor.

## License

MIT License - see [LICENSE](LICENSE) for details.

## Citation

If you use this macro in your research, please cite:

```
Intensity Modulated Display (IMD) for ImageJ (2025)
GitHub: https://github.com/yugo8849/imd-imagej
```

## Support

- Issues: https://github.com/yugo8849/imd-imagej/issues
- Discussions: https://github.com/yugo8849/imd-imagej/discussions

## Acknowledgments

- Developed with assistance from Claude (Anthropic)
- Based on the original IMD macro concept (Dr. Yohei Kondo)
- Thanks to all users and contributors

---

**Version 2.0.1 - June 2026**
