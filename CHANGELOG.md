# Changelog

All notable changes to the Intensity Modulated Display (IMD) ImageJ Plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-11-06

### Added
- Interactive dialog for image selection
- Automatic FRET/CFP ratio calculation
- Automatic detection of stack vs. single images
- Test mode for processing first frame only (parameter optimization)
- Rolling Ball background subtraction with adjustable radius
- Batch mode to hide intermediate images
- Parameter persistence (save/load from text file)
- Detailed logging of processing steps
- Support for both stack and single image Split Channels naming conventions
- Comprehensive error handling and validation

### Features
- **Image Selection**: Choose FRET and CFP images from dropdown menu
- **Ratio Range**: Customizable min/max values (default: -1 to 3)
- **Donor Range**: Customizable intensity normalization (default: 0 to 6000)
- **Test Mode**: Process only first frame for quick parameter testing
- **Background Subtraction**: Optional Rolling Ball with configurable radius
- **Batch Mode**: Clean processing without intermediate image display
- **Parameter Storage**: Automatic save/load of settings

### Technical Details
- Handles ImageJ Split Channels naming differences:
  - Stack images: C1-, C2-, C3- prefix
  - Single images: (red), (green), (blue) suffix
- Preserves original images (works on duplicates)
- Automatic cleanup of temporary images
- Cross-platform compatibility (Windows, Mac, Linux)

### Documentation
- Comprehensive user guide (README_IMD.md)
- Installation instructions for multiple methods
- Troubleshooting guide
- Technical implementation notes

## [Unreleased]

### Planned Features
- GUI for real-time parameter preview
- Support for additional LUTs
- Batch processing of multiple image sets
- ROI-based parameter optimization
- Export presets for different experimental conditions

## Notes

### From Original Macro
This plugin is an enhanced version of the original IMD macro with the following improvements:
- No manual ratio image creation required
- Works with both stacks and snapshots
- Interactive parameter adjustment
- Persistent settings
- Batch mode support
- Background subtraction integration

### Known Issues
- None reported in v1.0.0

### Migration from Original Macro
Users of the original macro can:
1. Use saved parameters from previous sessions
2. Apply the same ratio and donor ranges
3. Benefit from automatic ratio calculation
4. Use test mode for faster parameter optimization

## Support

For issues, feature requests, or questions:
- GitHub Issues: https://github.com/yourusername/IMD-ImageJ-Plugin/issues
- Email: your.email@example.com

---

**Legend:**
- `Added` for new features
- `Changed` for changes in existing functionality
- `Deprecated` for soon-to-be removed features
- `Removed` for now removed features
- `Fixed` for any bug fixes
- `Security` in case of vulnerabilities
