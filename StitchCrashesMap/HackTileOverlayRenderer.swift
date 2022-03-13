//
//  Created by Brian Coyner on 3/12/22.
//

import MapKit

final class HackTileOverlayRenderer: MKTileOverlayRenderer {

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
}
