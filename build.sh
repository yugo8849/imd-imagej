#!/bin/bash

echo "================================"
echo "IMD Plugin Build Script"
echo "================================"
echo

# Check Maven
if ! command -v mvn &> /dev/null; then
    echo "ERROR: Maven is not installed"
    echo ""
    echo "Install Maven:"
    echo "  macOS:  brew install maven"
    echo "  Ubuntu: sudo apt install maven"
    exit 1
fi

# Check Java
if ! command -v java &> /dev/null; then
    echo "ERROR: Java is not installed"
    echo ""
    echo "Install JDK 8+:"
    echo "  macOS:  brew install openjdk@11"
    echo "  Ubuntu: sudo apt install openjdk-11-jdk"
    exit 1
fi

echo "Building plugin..."
echo
mvn clean package

if [ $? -eq 0 ]; then
    echo ""
    echo "================================"
    echo "BUILD SUCCESSFUL!"
    echo "================================"
    echo ""
    echo "JAR file created: target/Intensity_Modulated_Display-1.1.0.jar"
    echo ""
    echo "Next steps:"
    echo "1. Copy JAR to Fiji.app/plugins/"
    echo "   cp target/Intensity_Modulated_Display-1.1.0.jar /path/to/Fiji.app/plugins/"
    echo ""
    echo "2. Restart Fiji"
    echo ""
    echo "3. Access via: Plugins > FRET > Intensity Modulated Display"
else
    echo ""
    echo "================================"
    echo "BUILD FAILED"
    echo "================================"
    exit 1
fi
