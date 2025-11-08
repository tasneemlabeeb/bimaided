#!/bin/bash

echo "=========================================="
echo "VDC Services Image Renamer"
echo "=========================================="
echo ""
echo "This script will help you rename your VDC service images."
echo ""
echo "First, make sure all 11 images are downloaded to your Downloads folder."
echo ""
echo "Press Enter when ready..."
read

cd ~/Downloads

echo ""
echo "Looking for image files in Downloads..."
echo ""

# List all recent image files
files=($(ls -t *.{jpg,png,jpeg,webp,JPG,PNG,JPEG,WEBP} 2>/dev/null | head -15))

if [ ${#files[@]} -eq 0 ]; then
    echo "❌ No image files found in Downloads folder!"
    echo "Please download the images first and run this script again."
    exit 1
fi

echo "Found ${#files[@]} image files:"
echo ""

for i in "${!files[@]}"; do
    printf "%2d: %s\n" $((i+1)) "${files[$i]}"
done

echo ""
echo "=========================================="
echo "Image Mapping (from newest to oldest):"
echo "=========================================="
echo " 1 → bim-management.jpg"
echo " 2 → design-iteration.jpg"
echo " 3 → visualization-alt.jpg"
echo " 4 → quantity-takeoff.jpg (+ 5d-bim.jpg)"
echo " 5 → 4d-bim.jpg"
echo " 6 → revit-drafting.jpg"
echo " 7 → rebar-detailing.jpg"
echo " 8 → coordination.jpg"
echo " 9 → clash-detection.jpg"
echo "10 → visualization.jpg"
echo "11 → bim-design.jpg"
echo ""
echo "⚠️  Make sure these match your images!"
echo ""
echo "Type 'yes' to proceed with renaming, or anything else to cancel:"
read confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Renaming files..."

# Rename based on array index (0-based)
[ -f "${files[0]}" ] && mv "${files[0]}" "bim-management.jpg" && echo "✓ bim-management.jpg"
[ -f "${files[1]}" ] && mv "${files[1]}" "design-iteration.jpg" && echo "✓ design-iteration.jpg"
[ -f "${files[2]}" ] && mv "${files[2]}" "visualization-alt.jpg" && echo "✓ visualization-alt.jpg"
[ -f "${files[3]}" ] && mv "${files[3]}" "quantity-takeoff.jpg" && echo "✓ quantity-takeoff.jpg"
[ -f "quantity-takeoff.jpg" ] && cp "quantity-takeoff.jpg" "5d-bim.jpg" && echo "✓ 5d-bim.jpg (copy)"
[ -f "${files[4]}" ] && mv "${files[4]}" "4d-bim.jpg" && echo "✓ 4d-bim.jpg"
[ -f "${files[5]}" ] && mv "${files[5]}" "revit-drafting.jpg" && echo "✓ revit-drafting.jpg"
[ -f "${files[6]}" ] && mv "${files[6]}" "rebar-detailing.jpg" && echo "✓ rebar-detailing.jpg"
[ -f "${files[7]}" ] && mv "${files[7]}" "coordination.jpg" && echo "✓ coordination.jpg"
[ -f "${files[8]}" ] && mv "${files[8]}" "clash-detection.jpg" && echo "✓ clash-detection.jpg"
[ -f "${files[9]}" ] && mv "${files[9]}" "visualization.jpg" && echo "✓ visualization.jpg"
[ -f "${files[10]}" ] && mv "${files[10]}" "bim-design.jpg" && echo "✓ bim-design.jpg"

echo ""
echo "Moving to project directory..."

mv bim-*.jpg visualization*.jpg clash-*.jpg coordination.jpg rebar-*.jpg revit-*.jpg 4d-*.jpg 5d-*.jpg quantity-*.jpg design-*.jpg /Users/tasneemzaman/Desktop/Untitled/public/images/vdc-services/ 2>/dev/null

echo ""
echo "✅ Done! Verifying..."
echo ""
ls -lh /Users/tasneemzaman/Desktop/Untitled/public/images/vdc-services/

echo ""
echo "=========================================="
echo "✅ All VDC service images are now in place!"
echo "=========================================="
