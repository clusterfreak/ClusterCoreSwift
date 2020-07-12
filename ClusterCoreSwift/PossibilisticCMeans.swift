/**
 * Possivilistic-C-Means (PCM)
 * <P>
 * Cluster analysis with Possivilistic-C-Means clustering algorithm
 *
 * <PRE>
 * Step 1: Initialization
 * Step 2: Determination of the cluster centers
 * Step 3: Calculate the new partition matrix and ni
 * Step 4: Termination or repetition
 * Step 5: optional - Repeat calculation (steps 2 to 4)
 * </PRE>
 *
 * @version 1.2.2 (2020-05-24)
 * @author Thomas Heym
 * @see FuzzyCMeans
 */
import Foundation
public class PossibilisticCMeans {
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
     * npcm
     */
    var ni:[Double]
    /**
     * When false return only the class centers
     */
    var path:Bool = false
    /**
     * Perform calculation of ni
     */
    var ni_calc:Bool = true
    /**
     * Number of PCM passes
     */
    var rep:Int = 1
    /**
     * Partition matrix (Membership values of the k-th object to the i-th
     * cluster)
     */
    var getMikV:[[Double]]
    
    /**
     * Generates PCM-Object from a set of Points
     *
     * @param object
     *            Objects
     * @param clusterCount
     *            Number of clusters
     * @param rep
     *            Number of PCM passes for determination of the cluster centers
     * @see FuzzyCMeans
     */
    public init(object :[[Double]], clusterCount :Int, rep :Int) {
        self.object = object
        self.cluster = clusterCount
        self.vi = [[Double]](repeating:[Double](repeating:Double(), count: 2), count: self.cluster)
        self.viPath = [[Double]](repeating:[Double](repeating:Double(), count: 2), count: self.cluster)
        self.getMikV = [[Double]](repeating:[Double](repeating:Double(), count: clusterCount), count: object.count)
        self.ni = [Double](repeating:Double(), count: self.cluster)
        self.rep = rep
    }
    
    /**
     * Generates PCM-Object from a set of Points
     *
     * @param object
     *            Objects
     * @param clusterCount
     *            Number of clusters
     * @param rep
     *            Number of PCM passes for determination of the cluster centers
     * @param e
     *            Termination threshold, initial value 1.0e-7
     * @see FuzzyCMeans
     */
    public init(object :[[Double]], clusterCount :Int, rep :Int, e :Double) {
        self.object = object
        self.cluster = clusterCount
        self.vi = [[Double]](repeating:[Double](repeating:Double(), count: 2), count: self.cluster)
        self.viPath = [[Double]](repeating:[Double](repeating:Double(), count: 2), count: self.cluster)
        self.getMikV = [[Double]](repeating:[Double](repeating:Double(), count: clusterCount), count: object.count)
        self.ni = [Double](repeating:Double(), count: self.cluster)
        self.rep = rep
        self.e = e
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
        let path = returnPath
        var viPathRec = [[Double]](repeating:[Double](repeating:Double(), count: 2), count: self.cluster)
        // Step 1: Initialization
        var fcm:FuzzyCMeans
        if (e == 1.0e-7) {
            fcm = FuzzyCMeans(object: object, clusterCount: cluster)
        } else {
            fcm = FuzzyCMeans(object: object, clusterCount: cluster, e: e)
        }
        let getViPath:[[Double]] = fcm.determineClusterCenters(random: true, returnPath: false)
        for var v:Int in(0..<getViPath.count) {
            viPathRec.append([getViPath[v][0], getViPath[v][1]])
            v+=1
        }
        vi = fcm.getVi()
        var mik:[[Double]] = fcm.getMik()
        repeat { // while (repeat>0)
            rep -= 1
            ni_calc = true
            repeat { // while (euclideanDistance>=e)
                // Step 2: Determination of the cluster centers
                // --> Step 5: optional - Repeat calculation (steps 2 to 4)
                for var k:Int in (0..<vi.count) {
                    var mikm = 0.0, mikm0 = 0.0, mikm1 = 0.0, mikms = 0.0;
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
                // Step 3: Calculate the new partition matrix and ni
                var mik_before:[[Double]] = [[Double]](repeating:[Double](repeating:Double(), count: cluster), count: mik.count)
                var miks:[Double] = [Double](repeating:Double(),count: vi.count)
                if (ni_calc == true) {
                    // Calulate ni (Distance from the class center to the point
                    // with a membership value of 0.5 to the actual cluster)
                    // initial ni = 0
                    for var i:Int in (0..<vi.count) {
                        ni[i] = 0.0
                        miks[i] = 0.0
                        i+=1
                    }
                    // ni = sum mik²*dik²
                    for var i:Int in (0..<mik.count) {
                        for var k:Int in (0..<vi.count) {
                            var dik:Double = 0.0
                            dik = sqrt(pow(object[i][0] - vi[k][0], 2) + pow(object[i][1] - vi[k][1], 2))
                            ni[k] += pow(pow(mik[i][k], 2), 2) * pow(dik, 2)
                            miks[k] += pow(mik[i][k], 2)
                            k+=1
                        }
                        i+=1
                    }
                    // ni = sum(mik²*dik²) / sum mik²
                    for var i:Int in (0..<vi.count) {
                        ni[i] /= miks[i]
                        i+=1
                    }
                    ni_calc = false
                }
                for var k:Int in (0..<vi.count) {
                    for var i:Int in (0..<mik.count) {
                        mik_before[i][k] = mik[i][k]
                        mik[i][k] = 1 / (1 + (pow(
                            sqrt(pow(object[i][0] - vi[k][0], 2) + pow(object[i][1] - vi[k][1], 2)),
                            2)) / ni[k]);
                        // NaN-Error
                        if mik[i][k].isNaN {
                            mik[i][k] = 1.0
                        }
                        i+=1
                    }
                    k+=1
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
            }
                // Step 4: Termination or repetition
                while euclideanDistance >= e
        } while rep > 0
        getMikV = mik
        // Value return
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
     * i-th cluster)
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
