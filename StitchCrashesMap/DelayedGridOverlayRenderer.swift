//
//  Created by Brian Coyner on 3/12/22.
//

import MapKit

final class DelayedGridOverlayRenderer: MKOverlayRenderer {

    private let lock = NSLock()
    private var canDrawCache: [String: Bool] = [:]

    private static let colors = [
        UIColor.systemCyan,
        UIColor.systemRed,
        UIColor.systemOrange,
        UIColor.systemPink,
        UIColor.systemBlue,
        UIColor.systemPurple,
        UIColor.systemMint
    ]
}

extension DelayedGridOverlayRenderer {

    override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {

        //
        // This renderer simulates asynchronously rendering an overlay.
        // - The async behavior is simulated using the `DispatchQueue.asyncAfter` method.
        // - The `cache` stores a boolean for each map rect + zoom scale.
        // - The `cache` value is set to `true` at some random time in the future (1 and 5 seconds)
        //   - This simulates asynchronously loading geometry data from an offline sqlite database, for example.

        let key = "\(mapRect.minX).\(mapRect.minY).\(mapRect.maxX).\(mapRect.maxY).\(zoomScale)"
        let canDraw = doSafe { canDrawCache[key] ?? false }

        if canDraw {
            return true
        } else {
            let delay = Int.random(in: 1..<5)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(delay)) { [self] in
                // Mark that the map is now ready to draw the given map rect at the given zoom scale.
                doSafe { canDrawCache[key] = true }

                // Note: Calling any of the `setNeedsDisplay` methods causes an `MKTileOverlayRenderer`
                // to re-render its tiles, too, which is the bug this demo exposes.
                //
                // See `HackTileOverlayRenderer` for additional notes on how to workaround the bug.
                setNeedsDisplay(mapRect, zoomScale: zoomScale)
            }

            return false
        }
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let randomColorIndex = Int.random(in: 0..<DelayedGridOverlayRenderer.colors.count)
        let randomColor = DelayedGridOverlayRenderer.colors[randomColorIndex]
        context.setFillColor(randomColor.withAlphaComponent(0.4).cgColor)
        context.fill(rect(for: mapRect))
    }
}

extension DelayedGridOverlayRenderer {

    private func doSafe<T>(block: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return block()
    }
}
