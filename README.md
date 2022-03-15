##  `MKOverlayRenderer.setNeedsDisplay` Causes `MKTileOverlayRenderer` To Re-Render Tiles

### Bug Report ID

FB9957545

Note: this is still broken as of iOS 15 (Xcode 13.3).

### Notes 

This demo app exposes a MapKit bug that re-renders `MKTileOverlayRenderer` tiles when:
- another `MKOverlayRenderer` calls any of the `setNeedsDisplay` methods.
- an overlay is added to the map (e.g. simple `MKPolyline` + `MKPolylineRenderer`).

Here are the main players in this demo:
- `MapViewController`:
  - Basic `MKMapView` host view controller and `MKMapDelegate`.
  - Contains two toolbar buttons to add and remove a `GridOverlay`.
- A `GridOverlay` renders using a `DelayedGridOverlayRenderer`.
- A `DelayedGridOverlayRenderer` is a simple `MKOverlayRenderer` that calls the `setNeedsDisplay` function "later".
  - Simulates asynchronously generating/ loading tiles (but for simplicity just renders a box around the tile).

Feedback ID: FB9957545

### Demo showing the "flickering" bug

![Bug](standardrenderer-flickering.gif)

```swift
func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    switch overlay {
    case let tileOverlay as MKTileOverlay:
        // Note: Replace the `MKTileOverlayRenderer` with the `HackTileOverlayRenderer` to stop re-drawing madness.
        return MKTileOverlayRenderer(tileOverlay: tileOverlay)
    case is GridOverlay:
        return DelayedGridOverlayRenderer()
    default:
        return MKOverlayRenderer(overlay: overlay)
    }
}
```


### Demo that includes a hack to eliminate the "flickering" bug

![Fixed](hackrenderer-no-flickering.gif)

```swift
func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    switch overlay {
    case let tileOverlay as MKTileOverlay:
        // Note: Replace the `HackTileOverlayRenderer` with the `MKTileOverlayRenderer` to expose re-drawing madness.
        return HackTileOverlayRenderer(tileOverlay: tileOverlay)
    case is GridOverlay:
        return DelayedGridOverlayRenderer()
    default:
        return MKOverlayRenderer(overlay: overlay)
    }
}
```

### Possible workaround (aka super-duper hack)

It turns out that simply subclassing `MKTileOverlayRenderer`, overriding `draw(_:zoomScale:in)`, and calling
`super` resolves the re-drawing problem. I can't explain why. Possible ObjC runtime shenanigans?

Here's the full hack-workaround.

```
import MapKit

final class HackTileOverlayRenderer: MKTileOverlayRenderer {

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
}
```

### Other

This sample demo uses OpenStreetMap tiles to help demonstrate the MapKit bug.
https://www.openstreetmap.org/copyright
