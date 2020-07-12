/**
 * Fuzzy-C-Means (FCM)
 * <P>
 * Cluster analysis with Fuzzy-C-Means clustering algorithm
 *
 * <pre>
 * Step 1: Initialization
 * Step 2: Determination of the cluster centers
 * Step 3: Calculate the new partition matrix
 * Step 4: Termination or repetition
 * Step 5: optional - Repeat calculation (steps 2 to 4)
 * </PRE>
 *
 * @version 1.6.2 (2020-05-24)
 * @author Thomas Heym
 */
import Foundation

public class FuzzyCMeans {
    /**
     * Quantity/number of clusters, initial value 2
     */
    var cluster:Int = 2
    /**
     * Euclidean distance norm, exponent, initial value 2
     */
    let m:Int = 2
    /**
     * Termination threshold, initial value 1.0e-7
     */
    var e:Double = 1.0e-7
    /**
     * Each Object represents 1 cluster vi
     */
    var object:[[Double]]
    /**
     * Cluster centers vi
     */
    var vi:[[Double]]
    /**
     * Complete search path
     */
    var viPath:[[Double]]
    /**
     * Partition matrix (Membership values of the k-th object to the i-th
     * cluster)
     */
    var getMikV:[[Double]]
    /**
     * When false return only the class centers
     */
    var path:Bool = false
    
    /**
     * Generates FCM-Object from a set of Points
     *
     * @param object
     *            Objects
     * @param clusterCount
     *            Number of clusters
     */
    public init(object :[[Double]], clusterCount :Int) {
        self.cluster = clusterCount
        self.e = 1.0e-7
        self.object = object
        self.vi = [[Double]](repeating:[Double](repeating:Double(), count: 2), count: self.cluster)
        self.viPath = [[Double]](repeating:[Double](repeating:Double(), count: 2), count: self.cluster)
        self.getMikV = [[Double]](repeating:[Double](repeating:Double(), count: clusterCount), count: object.count)
    }
    
    /**
     * Generates FCM-Object from a set of Points
     *
     * @param object
     *            Objects
     * @param clusterCount
     *            Number of clusters
     * @param e
     *            Termination threshold, initial value 1.0e-7
     */
    public init(object :[[Double]], clusterCount :Int, e :Double) {
        self.cluster = clusterCount
        self.e = e
        self.object = object
        self.vi = [[Double]](repeating:[Double](repeating:Double(), count: 2), count: self.cluster)
        self.viPath = [[Double]](repeating:[Double](repeating:Double(), count: 2), count: self.cluster)
        self.getMikV = [[Double]](repeating:[Double](repeating:Double(), count: clusterCount), count: object.count)
    }
    
    /**
     * Returns the cluster centers
     *
     * @param random
     *            random initialization
     * @param returnPath
     *            Determines whether return the complete search path. Values:
     *            <code>true</code>, <code>false</code>
     * @return Cluster centers and serarch path (optional); The cluster centers
     *         are at the end.
     */
    public func determineClusterCenters(random :Bool, returnPath :Bool) -> [[Double]] {
        var euclideanDistance:Double=0
        var mik = [[Double]](repeating:[Double](repeating:Double(), count: cluster), count: object.count)
        let path = returnPath
        var viPathRec = [[Double]](repeating:[Double](repeating:Double(), count: 2), count: self.cluster)
        // Step 1: Initialization
        if (random) {
            for var i:Int in(0..<mik.count) {
                for var k:Int in(0..<cluster) {
                    mik[i][k] = Math.random()
                    k+=1
                }
                i+=1
            }
        } else {
            var s:Int = 0
            for var i:Int in (0..<mik.count) {
                for var k:Int in (0..<cluster) {
                    if (k == s){
                        mik[i][k] = 1
                    }
                    else{
                        mik[i][k] = 0.0
                    }
                    k+=1
                }
                s += 1
                if (s == cluster){
                    s = 0
                }
                i+=1
            }
        }
        repeat {
            // Step 2: Determination of the cluster centers
            // --> Step 5: optional - Repeat calculation (steps 2 to 4)
            for var k:Int in (0..<vi.count) {
                var mikm = 0.0, mikm0 = 0.0, mikm1 = 0.0, mikms = 0.0
                for var i:Int in (0..<mik.count) {
                    mikm = pow(mik[i][k], Double(m))
                    mikm0 += mikm * object[i][0]
                    mikm1 += mikm * object[i][1]
                    mikms += mikm
                    i+=1
                }
                vi[k][0] = mikm0 / mikms
                vi[k][1] = mikm1 / mikms
                k+=1
            }
            // record cluster points
            if (path == true) {
                for var k:Int in (0..<vi.count){
                    viPathRec.append([vi[k][0], vi[k][1]])
                    k+=1
                }
            }
            
            // Step 3: Calculate the new partition matrix
            var mik_before:[[Double]] = [[Double]](repeating:[Double](repeating:Double(), count: cluster), count: mik.count)
            for var k:Int in (0..<vi.count) {
                for var i:Int in (0..<mik.count) {
                    var dik:Double = 0.0
                    mik_before[i][k] = mik[i][k]
                    for var j:Int in (0..<vi.count) {
                        dik += pow(1.0 / (sqrt(pow(object[i][0] - vi[j][0], 2) + pow(object[i][1] - vi[j][1], 2))),1.0 / (Double(m) - 1.0))
                        j+=1
                    }
                    mik[i][k] = pow(1.0 / (sqrt(pow(object[i][0] - vi[k][0], 2) + pow(object[i][1] - vi[k][1], 2))),1.0 / (Double(m) - 1.0)) / dik
                    // NaN-Error
                    if mik[i][k].isNaN {
                        mik[i][k] = 1.0
                    }
                    i+=1
                }
                // calculate euclidean distance
                euclideanDistance = 0.0
                for var k:Int in (0..<vi.count) {
                    for var i:Int in (0..<mik.count) {
                        euclideanDistance += pow((mik[i][k] - mik_before[i][k]), 2)
                        i+=1
                    }
                    k+=1
                }
                euclideanDistance = euclideanDistance.squareRoot()
                k+=1
            }
            // Step 4: Termination or repetition
        }
            while euclideanDistance >= e
        getMikV = mik
        if (path == true) {
            var viPathCut = [[Double]](repeating:[Double](repeating:Double(), count: viPathRec.count), count: 2)
            for var k:Int in (0..<viPathCut.count) {
                viPathCut[k][0] = viPathRec[k][0]
                viPathCut[k][1] = viPathRec[k][1]
                k+=1
            }
            setViPath(setViPath:viPathCut)
        }
        return vi
    }
    
    /**
     * Returns the partition matrix (Membership values of the k-th object to the
     * i-th cluster) The method is also called from PossibilisticCMeans.
     *
     * @return Partition matrix
     */
    public func getMik() -> [[Double]] {
        return getMikV
    }
    
    /**
     * Set partition matrix
     *
     * @param setMik
     *            partition matrix
     */
    public func setMik(setMik :[[Double]]) {
        self.getMikV = setMik
    }
    
    /**
     * Returns cluster centers vi
     *
     * @return vi
     */
    public func getVi() -> [[Double]] {
        return vi
    }
    
    /**
     * Set viPath
     *
     * @param setViPath
     */
    public func setViPath(setViPath :[[Double]]) {
        self.viPath = setViPath
    }
    
    /**
     * Returns the complete search path
     *
     * @return viPath
     */
    public func getViPath() -> [[Double]] {
        return viPath
    }
}
