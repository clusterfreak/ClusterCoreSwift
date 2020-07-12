/**
 * Point with 2D coordinates
 *
 * @version 1.3.2 (2020-05-24)
 * @author Thomas Heym
 */
public class Point2D {
    public var x:Double = 0.0
    public var y:Double = 0.0
    
    public init(xi:Double, yi:Double){
        self.x = xi
        self.y = yi
    }
    
    /**
     * Convert Point2D to PointPixel
     *
     * @param pixelOffset
     *            pixel Offset
     * @return PointPixel pixel point
     */
    public func toPointPixel(pixelOffset:Int) -> PointPixel {
        let pointPixel = PointPixel(xi:0, yi:0)
        var x:Int=0
        var y:Int=0
        var o:Double
        var p:Double
        for var t:Int in (0..<pixelOffset) {
            o = Double(t) / Double(pixelOffset)
            p = o + 1.0 / Double(pixelOffset)
            p = ((p * 100) / 100).rounded()
            if ((self.x >= o) && (self.x < p)){
                x = t
            }
            if ((self.y >= o) && (self.y < p)){
                y = t
            }
            t+=1
        }
        pointPixel.x = x;
        pointPixel.y = y;
        return pointPixel;
    }
}
