# Quick Image Renaming Guide for VDC Services

## Step-by-Step Instructions:

### 1. Download all 11 images from the chat to your Downloads folder

### 2. Open Terminal and run these commands:

```bash
# Navigate to your Downloads folder
cd ~/Downloads

# Create numbered list to see your images
ls -1 *.jpg *.png 2>/dev/null | nl

# Then run this script to rename them automatically:
```

### 3. Copy and paste this entire block into Terminal:

```bash
# Navigate to Downloads
cd ~/Downloads

# Find the images (adjust the pattern if needed - might be .png, .jpg, or .jpeg)
# List them first to verify
echo "Current images in Downloads:"
ls -1 *.{jpg,png,jpeg,webp} 2>/dev/null | head -15

echo ""
echo "Ready to rename? Press Enter to continue or Ctrl+C to cancel"
read

# Get all image files sorted by date (newest first)
files=($(ls -t *.{jpg,png,jpeg,webp} 2>/dev/null | head -11))

# Rename them according to the VDC services mapping
# Adjust the index [0] [1] etc if your images are in different order

mv "${files[10]}" "bim-design.jpg" 2>/dev/null
mv "${files[9]}" "visualization.jpg" 2>/dev/null
mv "${files[8]}" "clash-detection.jpg" 2>/dev/null
mv "${files[7]}" "coordination.jpg" 2>/dev/null
mv "${files[6]}" "rebar-detailing.jpg" 2>/dev/null
mv "${files[5]}" "revit-drafting.jpg" 2>/dev/null
mv "${files[4]}" "4d-bim.jpg" 2>/dev/null
mv "${files[3]}" "quantity-takeoff.jpg" 2>/dev/null
cp "quantity-takeoff.jpg" "5d-bim.jpg" 2>/dev/null
mv "${files[2]}" "visualization-alt.jpg" 2>/dev/null
mv "${files[1]}" "design-iteration.jpg" 2>/dev/null
mv "${files[0]}" "bim-management.jpg" 2>/dev/null

echo ""
echo "Images renamed! Now moving to project directory..."

# Move to project
mv bim-design.jpg visualization.jpg clash-detection.jpg coordination.jpg rebar-detailing.jpg revit-drafting.jpg 4d-bim.jpg quantity-takeoff.jpg 5d-bim.jpg bim-management.jpg /Users/tasneemzaman/Desktop/Untitled/public/images/vdc-services/

echo ""
echo "✅ All images moved to /Users/tasneemzaman/Desktop/Untitled/public/images/vdc-services/"
echo ""
echo "Verifying..."
ls -lh /Users/tasneemzaman/Desktop/Untitled/public/images/vdc-services/
```

---

## OR - Manual Method (Easier):

If the script doesn't work, manually rename the 11 images like this:

1. **Image 1** (architectural sketch) → `bim-design.jpg`
2. **Image 2** (holographic building) → `visualization.jpg`
3. **Image 3** (clash detection) → `clash-detection.jpg`
4. **Image 4** (multi-layer building) → `coordination.jpg`
5. **Image 5** (rebar detail) → `rebar-detailing.jpg`
6. **Image 6** (computer BIM) → `revit-drafting.jpg`
7. **Image 7** (building phases) → `4d-bim.jpg`
8. **Image 8** (cost analysis) → `quantity-takeoff.jpg`
9. **Image 8** (duplicate) → `5d-bim.jpg` (same file as #8)
10. **Image 9** (sketch to render) → `visualization-alt.jpg`
11. **Image 10** (design pencils) → `design-iteration.jpg`
12. **Image 11** (multi-screen) → `bim-management.jpg`

Then drag all of them into:
`/Users/tasneemzaman/Desktop/Untitled/public/images/vdc-services/`

---

## Verification:

After moving, run this to verify:

```bash
ls -lh /Users/tasneemzaman/Desktop/Untitled/public/images/vdc-services/
```

You should see all 10-12 images listed!
