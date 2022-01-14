//
//  FileAccess.swift
//  Canyoneer
//
//  Created by Brice Pollock on 1/14/22.
// https://stackoverflow.com/questions/35851118/how-do-i-share-files-using-share-sheet-in-ios

import Foundation

/// Get the current directory
///
/// - Returns: the Current directory in NSURL
func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory as NSString
}
