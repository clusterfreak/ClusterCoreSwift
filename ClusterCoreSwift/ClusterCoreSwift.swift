/**
* Internal Core Self Tests
* @version 0.1.1 (2020-05-24)
* @author Thomas Heym
*/

import Foundation

var object:[[Double]] = [[0.1,0.3],[0.1,0.5],[0.1,0.7],[0.7,0.3],[0.7,0.7],[0.8,0.5],[0.9,0.5]]
let cluster:Int = 2
var vi:[[Double]] = [[0.0],[0.0]]
var fcmReference:[[Double]] = [[0.147070835,0.5],[0.758778663,0.5]]
var pcm1Reference:[[Double]] = [[0.102492638,0.5],[0.83065648,0.5]]
var pcm2Reference:[[Double]] = [[0.10000244,0.5],[0.801756421,0.5]]
let delta:Double = 0.000003;

func testReference(vi :[[Double]], reference :[[Double]]) -> Bool {
    var test:Bool = true;
    if ((abs(vi[0][0] - reference[0][0]) < delta) && (abs(vi[0][1] - reference[0][1]) < delta)) {
        if ((abs(vi[1][0] - reference[1][0]) > delta) || (abs(vi[1][1] - reference[1][1]) > delta)) {
            test = false
        }
    } else {
        if ((abs(vi[0][0] - reference[1][0]) < delta) && (abs(vi[0][1] - reference[1][1]) < delta)) {
            if ((abs(vi[1][0] - reference[0][0]) > delta) || (abs(vi[1][1] - reference[0][1]) > delta)) {
                test = false;
            }
        } else {
            test = false;
        }
    }
    /*
    for var i:Int in (0..<vi.count){
        var vix:String = String(vi[i][0])
        var viy:String = String(vi[i][1])
        print(String(i) + ": " + vix + ", " + viy);
        i+=1
    }
    */
    return test;
}

public func CoreTest(){
    let point = Point2D(xi:0.5, yi:0.5)
    var pixel = PointPixel(xi:0, yi:0)
    print("Test")
    print(String(point.x)+" "+String(point.y))
    pixel=point.toPointPixel(pixelOffset: 100)
    print(String(pixel.x)+" "+String(pixel.y))

    let fcm:FuzzyCMeans = FuzzyCMeans(object: object, clusterCount: cluster)
    vi = fcm.determineClusterCenters(random: true, returnPath: false)
    print("FCM Test ")
    if (testReference(vi :vi, reference :fcmReference)){
        print("ok")
    }
    else {
        print("error")
    }


    var pcm:PossibilisticCMeans = PossibilisticCMeans(object: object, clusterCount: cluster, rep: 1);
    vi = pcm.determineClusterCenters(random: true, returnPath: false);
    print("PCM Test 1. Durchlauf ")
    if (testReference(vi :vi, reference :pcm1Reference)) {
        print("ok");
    }
    else {
        print("error");
    }


    pcm = PossibilisticCMeans(object: object, clusterCount: cluster, rep: 2);
    vi = pcm.determineClusterCenters(random: true, returnPath: false);
    print("PCM Test 2. Durchlauf ")
    if (testReference(vi :vi, reference :pcm2Reference)) {
        print("ok");
    }
    else {
        print("error");
    }

}
