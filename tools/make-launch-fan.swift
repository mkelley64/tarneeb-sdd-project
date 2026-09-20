import Foundation
import CoreGraphics
import ImageIO

// Run from the repository root. Composes the existing xCards artwork into a
// transparent PDF for a static UIKit launch screen; no new card art is invented.
let root = URL(fileURLWithPath:FileManager.default.currentDirectoryPath)
let output = root.appendingPathComponent("Tarneeb/Assets.xcassets/LaunchCardFan.imageset/LaunchCardFan.pdf")
try FileManager.default.createDirectory(at:output.deletingLastPathComponent(),withIntermediateDirectories:true)
var bounds = CGRect(x:0,y:0,width:320,height:210)
let context = CGContext(output as CFURL,mediaBox:&bounds,nil)!
context.beginPDFPage(nil)
for (i,code) in ["TS","JH","QC","KD","AS"].enumerated() {
    let url = root.appendingPathComponent("Tarneeb/Assets.xcassets/card_face_\(code).imageset/\(code)@3x.png")
    let source = CGImageSourceCreateWithURL(url as CFURL,nil)!
    // The largest displayed card is 104 × 146 pt; keep 3× pixels without
    // embedding each original 1242 × 1739 image in the launch resource.
    let card = CGImageSourceCreateThumbnailAtIndex(source,0,[
        kCGImageSourceCreateThumbnailFromImageAlways:true,
        kCGImageSourceThumbnailMaxPixelSize:438,
        kCGImageSourceCreateThumbnailWithTransform:true
    ] as CFDictionary)!
    context.saveGState()
    context.translateBy(x:160+Double(i-2)*24,y:26)
    context.rotate(by:Double(2-i)*12 * .pi/180)
    context.setShadow(offset:CGSize(width:0,height:-2),blur:5,color:CGColor(gray:0,alpha:0.18))
    context.draw(card,in:CGRect(x:-52,y:0,width:104,height:146))
    context.restoreGState()
}
context.endPDFPage(); context.closePDF()
