To update the app icon, add a new `icon.png` and then from the `Resources`
folder run:

```
mkdir AppIcon.iconset
for size in 16 32 128 256 512; do
  sips -z $size $size icon.png --out AppIcon.iconset/icon_${size}x${size}.png
  sips -z $((size*2)) $((size*2)) icon.png --out AppIcon.iconset/icon_${size}x${size}@2x.png
done
iconutil -c icns AppIcon.iconset -o AppIcon.icns
```