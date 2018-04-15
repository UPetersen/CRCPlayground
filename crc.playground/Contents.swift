// Uwe Petersen, 2016-06-05
//
// Playground with crc 16 code to be used with freestyle libre data scans. The freestyle libre uses a crc16 to check for data integrity:
//
// 1.) The first two bytes of Block 0x00 are a crc 16 for the data range from Block 0x00 to Block 0x02 f(excluding the two crc16 bytes of Block 0x00).
// 2.) The first two bytes of Block 0x03 are a crc 16 for the data range from Block 0x03 to Block 0x28 f(excluding the two crc16 bytes of Block 0x00).
//
// This playground is structured into two parts, where the first part is the code to calculate the crc and test it. The second part contains the code 
// to calculate the crc table used in the first part.
//
// This code uses code from CryptoSwift, see its licence below:
//
// Copyright (C) 2014 Marcin Krzyżanowski <marcin.krzyzanowski@gmail.com>
// This software is provided 'as-is', without any express or implied warranty.
//
// In no event will the authors be held liable for any damages arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
//
// - The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation is required.
// - Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
// - This notice may not be removed or altered from any source or binary distribution.


import Cocoa


/// Structure for one glucose measurement including value, date and raw data bytes
struct Measurement {
    /// The date for this measurement
    let date: NSDate
    /// The bytes as read from the sensor. All data is derived from this \"raw data"
    let bytes: [UInt8]
    /// The bytes as String
    let byteString: String
    /// The raw value as read from the sensor
    let rawValue: Int
    /// slope to calculate glucose from raw value in (mg/dl)/raw
    let slope: Double
    /// glucose offset to be added in mg/dl
    let offset: Double
    /// The glucose value in mg/dl
    let glucose: Double
    /// Initialize a new glucose measurement
    ///
    /// - parameter bytes:  raw data bytes as read from the sensor
    /// - parameter slope:  slope to calculate glucose from raw value in (mg/dl)/raw
    /// - parameter offset: glucose offset to be added in mg/dl
    /// - parameter date:   date of the measurement
    ///
    /// - returns: Measurement
    init(bytes: [UInt8], slope: Double = 0.1, offset: Double = 0.0, date: NSDate) {
        self.bytes = bytes
        self.byteString = bytes.reduce("", {$0 + String(format: "%02X", arguments: [$1])})
        self.rawValue = (Int(bytes[1]) << 8) & 0x0F00 + Int(bytes[0])
        self.slope = slope
        self.offset = offset
        self.glucose = offset + slope * Double(rawValue)
        self.date = date
    }
    var description: String {
        return String("Glucose: \(glucose) (mg/dl), date:  \(date), slope: \(slope), offset: \(offset),rawValue: \(rawValue), bytes: \(bytes)" )
    }
}

// code to calculate the crc 16

let crc16table: [UInt16] = [0, 4489, 8978, 12955, 17956, 22445, 25910, 29887, 35912, 40385, 44890, 48851, 51820, 56293, 59774, 63735, 4225, 264, 13203, 8730, 22181, 18220, 30135, 25662, 40137, 36160, 49115, 44626, 56045, 52068, 63999, 59510, 8450, 12427, 528, 5017, 26406, 30383, 17460, 21949, 44362, 48323, 36440, 40913, 60270, 64231, 51324, 55797, 12675, 8202, 4753, 792, 30631, 26158, 21685, 17724, 48587, 44098, 40665, 36688, 64495, 60006, 55549, 51572, 16900, 21389, 24854, 28831, 1056, 5545, 10034, 14011, 52812, 57285, 60766, 64727, 34920, 39393, 43898, 47859, 21125, 17164, 29079, 24606, 5281, 1320, 14259, 9786, 57037, 53060, 64991, 60502, 39145, 35168, 48123, 43634, 25350, 29327, 16404, 20893, 9506, 13483, 1584, 6073, 61262, 65223, 52316, 56789, 43370, 47331, 35448, 39921, 29575, 25102, 20629, 16668, 13731, 9258, 5809, 1848, 65487, 60998, 56541, 52564, 47595, 43106, 39673, 35696, 33800, 38273, 42778, 46739, 49708, 54181, 57662, 61623, 2112, 6601, 11090, 15067, 20068, 24557, 28022, 31999, 38025, 34048, 47003, 42514, 53933, 49956, 61887, 57398, 6337, 2376, 15315, 10842, 24293, 20332, 32247, 27774, 42250, 46211, 34328, 38801, 58158, 62119, 49212, 53685, 10562, 14539, 2640, 7129, 28518, 32495, 19572, 24061, 46475, 41986, 38553, 34576, 62383, 57894, 53437, 49460, 14787, 10314, 6865, 2904, 32743, 28270, 23797, 19836, 50700, 55173, 58654, 62615, 32808, 37281, 41786, 45747, 19012, 23501, 26966, 30943, 3168, 7657, 12146, 16123, 54925, 50948, 62879, 58390, 37033, 33056, 46011, 41522, 23237, 19276, 31191, 26718, 7393, 3432, 16371, 11898, 59150, 63111, 50204, 54677, 41258, 45219, 33336, 37809, 27462, 31439, 18516, 23005, 11618, 15595, 3696, 8185, 63375, 58886, 54429, 50452, 45483, 40994, 37561, 33584, 31687, 27214, 22741, 18780, 15843, 11370, 7921, 3960]



//
//  BytesSequence.swift
//  CryptoSwift
//
//  Created by Marcin Krzyzanowski on 26/09/15.
//  Copyright © 2015 Marcin Krzyzanowski. All rights reserved.
//
struct BytesSequence: Sequence {
    let chunkSize: Int
    let data: [UInt8]
    
    func makeIterator() -> AnyIterator<ArraySlice<UInt8>> {
        
        var offset:Int = 0
        
        return AnyIterator {
            let end = Swift.min(self.chunkSize, self.data.count - offset)
            let result = self.data[offset..<offset + end]
            offset += result.count
            return result.count > 0 ? result : nil
        }
    }
}

//
//  CRC.swift
//  CryptoSwift
//
//  Created by Marcin Krzyzanowski on 25/08/14.
//  Copyright (c) 2014 Marcin Krzyzanowski. All rights reserved.
//
func crc16(message:[UInt8], seed: UInt16? = nil) -> UInt16 {
    var crc: UInt16 = seed != nil ? seed! : 0x0000
    
    // calculate crc
    for chunk in BytesSequence(chunkSize: 256, data: message) {
        for b in chunk {
            crc = (crc >> 8) ^ crc16table[Int((crc ^ UInt16(b)) & 0xFF)]
        }
    }

    // reverse the bits (modification by Uwe Petersen, 2016-06-09
    var reverseCrc = UInt16(0)
    for _ in 0..<16 {
        reverseCrc = reverseCrc << 1 | crc & 1
        crc >>= 1
    }
    
    // swap bytes and return (modification by Uwe Petersen, 2016-06-09
    return reverseCrc.byteSwapped
}


// Test the code with two examples take from reading of the freestlye libre sensor having used a general nfc tag reader

let testString1Blanks =        "10 16 06 00 00 00" +
                         "00 00 00 00 00 00 00 00" +
                         "00 00 00 00 00 00 00 00"
// should return "FD 61", i.e. 64865 or 25085 (with bytes not swapped)
//    0x3a, 0xcf, 0x10, 0x16, 0x03, 0x00, 0x00, 0x00, // 0x00 Begin of header
//    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // 0x01
//    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,

let testString1 = testString1Blanks.replacingOccurrences(of: " ", with: "")
//let testString1 = testString1Blanks.stringByReplacingOccurrencesOfString(" ", withString: "")

var testString2 =        "00 00 00 00 00 00"  // should return "62 C2", i.e. 25282 oder 49762 (with bytes not swapped)
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2.append("00 00 00 00 00 00 00 00")
testString2 = testString2.replacingOccurrences(of: " ", with: "")

/*
var testString4 =        "18 19 02 00 00 00 " // [00] should return "6B B6", i.e. 27574 or 46699 (with bytes not swapped)
testString4.append("00 00 00 00 00 00 00 00 ") // [01]
testString4.append("00 00 00 00 00 00 00 00 ") // [02]
testString4.append("B2 29 02 00 83 B4 80 E6 ") // [03]
testString4.append("98 80 F0 8D 80 42 99 80 ") // [04]
testString4.append("00 00 00 00 00 00 00 00 ") // [05]
testString4.append("00 00 00 00 00 00 00 00 ") // [06]
testString4.append("00 00 00 00 00 00 00 00 ") // [07]
testString4.append("00 00 00 00 00 00 00 00 ") // [08]
testString4.append("00 00 00 00 00 00 00 00 ") // [09]
testString4.append("00 00 00 00 00 00 00 00 ") // [0A]
testString4.append("00 00 00 00 00 00 00 00 ") // [0B]
testString4.append("00 00 00 00 00 00 00 00 ") // [0C]
testString4.append("00 00 00 00 00 00 00 00 ") // [0D]
testString4.append("00 00 00 00 00 00 00 00 ") // [0E]
testString4.append("00 00 00 00 00 00 00 00 ") // [0F]
testString4.append("00 00 00 00 00 00 00 00 ") // [10]
testString4.append("00 00 00 00 00 00 00 00 ") // [11]
testString4.append("00 00 00 00 00 00 00 00 ") // [12]
testString4.append("00 00 00 00 00 00 00 00 ") // [13]
testString4.append("00 00 00 00 00 00 00 00 ") // [14]
testString4.append("00 00 00 00 00 00 00 00 ") // [15]
testString4.append("00 00 00 00 00 00 00 00 ") // [16]
testString4.append("00 00 00 00 00 00 00 00 ") // [17]
testString4.append("00 00 00 00 00 00 00 00 ") // [18]
testString4.append("00 00 00 00 00 00 00 00 ") // [19]
testString4.append("00 00 00 00 00 00 00 00 ") // [1A]
testString4.append("00 00 00 00 00 00 00 00 ") // [1B]
testString4.append("00 00 00 00 00 00 00 00 ") // [1C]
testString4.append("00 00 00 00 00 00 00 00 ") // [1D]
testString4.append("00 00 00 00 00 00 00 00 ") // [1E]
testString4.append("00 00 00 00 00 00 00 00 ") // [1F]
testString4.append("00 00 00 00 00 00 00 00 ") // [20]
testString4.append("00 00 00 00 00 00 00 00 ") // [21]
testString4.append("00 00 00 00 00 00 00 00 ") // [22]
testString4.append("00 00 00 00 00 00 00 00 ") // [23]
testString4.append("00 00 00 00 00 00 00 00 ") // [24]
testString4.append("00 00 00 00 00 00 00 00 ") // [25]
testString4.append("00 00 00 00 00 00 00 00 ") // [26]
testString4.append("00 00 00 00 02 00 00 00 ") // [27]
testString4.append("58 C7 00 01 15 04 96 50 ") // [28]
testString4.append("14 07 96 80 5A 00 ED A6 ") // [29]
testString4.append("12 13 1B C8 04 99 28 66 ") // [2A]
*/
//var testString4 =       " 21 83 F2 90 07 00 " // [2B] should return "9E 42", i.e. 40514 or 17054 (with bytes not swapped)
//testString4.append("06 08 02 24 0C 43 17 3C ") // [2C]
//testString4.append("C2 43 08 08 B2 40 DF 00 ") // [2D]
//testString4.append("08 08 D2 42 A2 F9 08 08 ") // [2E]
//testString4.append("D2 42 A3 F9 08 08 0C 41 ") // [2F]
//testString4.append("0C 53 92 12 90 1C 5C 93 ") // [30]
//testString4.append("03 20 A2 41 08 08 02 3C ") // [31]
//testString4.append("B2 43 08 08 1C 43 21 53 ") // [32]
//testString4.append("30 41 0A 12 4A 4C 4C 93 ") // [33]
//testString4.append("0B 20 B2 40 50 CC 02 07 ") // [34]
//testString4.append("92 D3 00 07 B2 C0 00 02 ") // [35]
//testString4.append("00 07 A2 D2 00 07 02 3C ") // [36]
//testString4.append("92 12 82 1C 32 D0 D8 00 ") // [37]
//testString4.append("E2 B3 C3 1C 09 28 E2 C3 ") // [38]
//testString4.append("C3 1C 4A 93 05 24 12 C3 ") // [39]
//testString4.append("12 10 A4 1C 12 11 A4 1C ") // [3A]
//testString4.append("3A 41 30 41 0A 12 0B 12 ") // [3B]
//testString4.append("08 12 09 12 06 12 F2 90 ") // [3C]
//testString4.append("07 00 06 08 68 20 B0 12 ") // [3D]
//testString4.append("3A FB 61 20 92 12 78 1C ") // [3E]
//testString4.append("3A 40 FA F9 4C 43 8A 12 ") // [3F]
//testString4.append("3B 40 84 1C 26 4B 38 40 ") // [40]
//testString4.append("B0 F9 39 40 A4 1C B2 90 ") // [41]
//testString4.append("00 20 A4 1C 09 2C 1F 43 ") // [42]
//testString4.append("B0 12 30 FB 3F 40 00 20 ") // [43]
//testString4.append("2F 89 82 4F A4 1C 06 3C ") // [44]
//testString4.append("0F 43 B0 12 30 FB B2 50 ") // [45]
//testString4.append("00 E0 A4 1C 92 52 A4 1C ") // [46]
//testString4.append("A4 1C 2F 49 7E 42 0D 43 ") // [47]
//testString4.append("0C 48 AB 12 1F 43 5E 43 ") // [48]
//testString4.append("3D 40 22 00 0C 48 AB 12 ") // [49]
//testString4.append("B2 90 00 01 A4 1C 08 28 ") // [4A]
//testString4.append("7F 43 7E 42 0D 43 0C 48 ") // [4B]
//testString4.append("AB 12 7C 40 34 00 29 3C ") // [4C]
//testString4.append("6C 42 8A 12 2F 49 3F F0 ") // [4D]
//testString4.append("FF 07 82 4F A6 1C 1F 42 ") // [4E]
//testString4.append("A6 1C 7E 40 0B 00 3D 40 ") // [4F]
//testString4.append("16 00 0C 48 AB 12 7C 40 ") // [50]
//testString4.append("05 00 8A 12 2F 49 7E 40 ") // [51]
//testString4.append("0C 00 3D 40 28 00 0C 48 ") // [52]
//testString4.append("AB 12 7C 40 06 00 8A 12 ") // [53]
//testString4.append("2F 49 7E 40 0C 00 3D 40 ") // [54]
//testString4.append("34 00 0C 48 AB 12 B2 B0 ") // [55]
//testString4.append("10 00 22 01 06 2C 7C 40 ") // [56]
//testString4.append("28 00 92 12 8C 1C 0C 43 ") // [57]
//testString4.append("05 3C E2 C2 C3 1C 92 12 ") // [58]
//testString4.append("94 1C 1C 43 30 40 6C 5F ") // [59]
//testString4.append("5E 43 3D 40 21 00 0C 48 ") // [5A]
//testString4.append("00 46 C2 43 08 08 E2 D2 ") // [5B]
//testString4.append("C3 1C 92 12 98 1C 4C 93 ") // [5C]
//testString4.append("30 41 F2 90 07 00 06 08 ") // [5D]
//testString4.append("02 24 0C 43 30 41 B0 12 ") // [5E]
//testString4.append("3A FB 08 24 A2 43 DC F8 ") // [5F]
//testString4.append("7C 40 28 00 92 12 8C 1C ") // [60]
//testString4.append("0C 43 30 41 92 12 78 1C ") // [61]
//testString4.append("92 D3 00 07 B2 40 4B D8 ") // [62]
//testString4.append("02 07 B2 C0 00 02 00 07 ") // [63]  //
//testString4.append("A2 D2 00 07 92 43 DC F8 ") // [64]
//testString4.append("32 D0 D8 00 E2 B3 C3 1C ") // [65]
//testString4.append("05 28 E2 C3 C3 1C 92 42 ") // [66]
//testString4.append("A4 1C DE F8 5C 43 92 12 ") // [67]
//testString4.append("86 1C E2 C2 C3 1C 92 12 ") // [68]
//testString4.append("94 1C 1C 43 30 41 F2 90 ") // [69]
//testString4.append("07 00 06 08 02 24 0C 43 ") // [6A]
//testString4.append("30 41 C2 43 08 08 E2 D2 ") // [6B]
//testString4.append("C3 1C 92 12 72 1C 1C 43 ") // [6C]
//testString4.append("30 41 0A 12 92 12 20 1C ") // [6D]
//testString4.append("4C 93 14 24 F2 90 05 00 ") // [6E]
//testString4.append("0C 08 10 20 1D 42 06 08 ") // [6F]
//testString4.append("5F 42 06 08 0D 93 07 20 ") // [70]
//testString4.append("7F 93 05 20 92 12 94 1C ") // [71]
//testString4.append("C2 43 08 08 12 3C 7F 90 ") // [72]
//testString4.append("10 00 02 28 0C 43 0E 3C ") // [73]
//testString4.append("C2 43 08 08 0C 43 07 3C ") // [74]
//testString4.append("0E 4C 0E 5E 0A 4D 0A 5E ") // [75]
//testString4.append("A2 4A 08 08 1C 53 0C 9F ") // [76]
//testString4.append("F7 2B 1C 43 3A 41 30 41 ") // [77]
//testString4.append("0A 12 4A 4C B0 12 C8 5B ") // [78]
//testString4.append("6A 92 10 20 7E 40 0B 00 ") // [79]
//testString4.append("3D 40 16 00 3C 40 B0 F9 ") // [7A]
//testString4.append("92 12 4C 1C 82 4C A6 1C ") // [7B]
//testString4.append("92 52 A6 1C A6 1C 92 52 ") // [7C]
//testString4.append("A6 1C A6 1C 3A 41 30 41 ") // [7D]
//testString4.append("0E 43 1C 42 B6 F9 B0 12 ") // [7E]
//testString4.append("DE 5E 1D 42 AA 1C 12 C3 ") // [7F]
//testString4.append("0D 10 0D 11 0C 9D 02 2C ") // [80]
//testString4.append("0D 8C 04 3C 0C 8D 0D 4C ") // [81]
//testString4.append("3E 40 00 02 3D 90 00 02 ") // [82]
//testString4.append("02 28 3D 40 FF 01 5F 42 ") // [83]
//testString4.append("A8 F9 0F 9D 06 2C B2 D0 ") // [84]
//testString4.append("40 00 AE 1C F2 D0 40 00 ") // [85]
//testString4.append("C2 1C 0D DE 82 4D AA 1C ") // [86]
//testString4.append("30 41 0A 12 0B 12 08 12 ") // [87]
//testString4.append("09 12 5B 42 A9 F9 48 43 ") // [88]
//testString4.append("C2 93 64 F8 09 34 F2 C0 ") // [89]
//testString4.append("80 00 64 F8 6B B2 01 28 ") // [8A]
//testString4.append("58 43 4C 43 92 12 86 1C ") // [8B]
//testString4.append("59 42 64 F8 0A 3C 6A 93 ") // [8C]
//testString4.append("04 20 B2 B0 00 02 00 08 ") // [8D]
//testString4.append("04 28 7C 40 06 00 92 12 ") // [8E]
//testString4.append("88 1C 1A 42 9E 01 4A 93 ") // [8F]
//testString4.append("1F 24 4E 49 6E 83 7E 90 ") // [90]
//testString4.append("03 00 F7 2F 7A 90 10 00 ") // [91]
//testString4.append("02 20 58 B3 12 2C 4C 4A ") // [92]
//testString4.append("7C 50 11 00 92 12 60 1C ") // [93]
//testString4.append("5B B3 03 28 7A 90 06 00 ") // [94]
//testString4.append("E8 27 6B B3 03 28 7A 90 ") // [95]
//testString4.append("0E 00 E3 27 7A 90 10 00 ") // [96]
//testString4.append("D6 23 58 B3 DE 2F D9 3F ") // [97]
//testString4.append("5E 42 64 F8 6E 83 7E 90 ") // [98]
//testString4.append("03 00 25 2C 92 12 96 1C ") // [99]
//testString4.append("92 12 9A 1C 00 3C 3F 40 ") // [9A]
//testString4.append("33 05 3F 53 FE 2F A2 B3 ") // [9B]
//testString4.append("22 01 15 28 3F 40 4E C3 ") // [9C]
//testString4.append("03 43 0B 43 3F 53 3B 63 ") // [9D]
//testString4.append("FD 2F B2 B0 10 00 22 01 ") // [9E]
//testString4.append("07 28 B2 B0 00 02 00 08 ") // [9F]
//testString4.append("03 2C 92 12 70 1C 07 3C ") // [A0]
//testString4.append("7C 40 0A 00 02 3C 7C 40 ") // [A1]
//testString4.append("0B 00 92 12 8C 1C 92 12 ") // [A2]
//testString4.append("58 1C A2 D2 00 08 32 D2 ") // [A3]
//testString4.append("30 40 6E 5F 30 41 00 00 ") // [A4]
//testString4.append("00 00 00 00 00 00 00 00 ") // [A5]
//testString4.append("00 00 00 00 00 00 00 00 ") // [A6]
//testString4.append("00 00 00 00 00 00 00 00 ") // [A7]
//testString4.append("00 00 00 00 00 00 00 00 ") // [A8]
//testString4.append("00 00 00 00 00 00 00 00 ") // [A9]
//testString4.append("00 00 00 00 00 00 00 00 ") // [AA]
//testString4.append("00 00 00 00 00 00 00 00 ") // [AB]
//testString4.append("00 00 00 00 00 00 00 00 ") // [AC]
//testString4.append("00 00 00 00 00 00 00 00 ") // [AD]
//testString4.append("00 00 00 00 00 00 00 00 ") // [AE]
//testString4.append("00 00 00 00 00 00 00 00 ") // [AF]
//testString4.append("00 00 00 00 00 00 00 00 ") // [B0]
//testString4.append("00 00 00 00 00 00 00 00 ") // [B1]
//testString4.append("00 00 00 00 00 00 00 00 ") // [B2]
//testString4.append("00 00 00 00 00 00 00 00 ") // [B3]
//testString4.append("00 00 00 00 00 00 00 00 ") // [B4]
//testString4.append("00 00 00 00 00 00 00 00 ") // [B5]
//testString4.append("00 00 00 00 00 00 00 00 ") // [B6]
//testString4.append("00 00 00 00 00 00 00 00 ") // [B7]
//testString4.append("00 00 00 00 00 00 00 00 ") // [B8]
//testString4.append("00 00 00 00 00 00 00 00 ") // [B9]
//testString4.append("00 00 00 00 00 00 00 00 ") // [BA]
//testString4.append("00 00 00 00 00 00 00 00 ") // [BB]
//testString4.append("00 00 00 00 00 00 00 00 ") // [BC]
//testString4.append("00 00 00 00 00 00 00 00 ") // [BD]
//testString4.append("00 00 00 00 00 00 00 00 ") // [BE]
//testString4.append("00 00 00 00 00 00 00 00 ") // [BF]
//testString4.append("00 00 00 00 00 00 00 00 ") // [C0]
//testString4.append("00 00 00 00 00 00 00 00 ") // [C1]
//testString4.append("00 00 00 00 00 00 00 00 ") // [C2]
//testString4.append("00 00 00 00 00 00 00 00 ") // [C3]
//testString4.append("00 00 00 00 00 00 00 00 ") // [C4]
//testString4.append("00 00 00 00 00 00 00 00 ") // [C5]
//testString4.append("00 00 00 00 00 00 00 00 ") // [C6]
//testString4.append("00 00 00 00 00 00 00 00 ") // [C7]
//testString4.append("00 00 00 00 00 00 00 00 ") // [C8]
//testString4.append("00 00 00 00 00 00 00 00 ") // [C9]
//testString4.append("00 00 00 00 00 00 00 00 ") // [CA]
//testString4.append("00 00 00 00 00 00 00 00 ") // [CB]
//testString4.append("00 00 00 00 00 00 00 00 ") // [CC]
//testString4.append("00 00 00 00 00 00 00 00 ") // [CD]
//testString4.append("00 00 00 00 00 00 00 00 ") // [CE]
//testString4.append("00 00 00 00 00 00 00 00 ") // [CF]
//testString4.append("00 00 00 00 00 00 00 00 ") // [D0]
//testString4.append("00 00 00 00 00 00 00 00 ") // [D1]
//testString4.append("00 00 00 00 00 00 00 00 ") // [D2]
//testString4.append("00 00 00 00 00 00 00 00 ") // [D3]
//testString4.append("00 00 00 00 00 00 00 00 ") // [D4]
//testString4.append("00 00 00 00 00 00 00 00 ") // [D5]
//testString4.append("00 00 00 00 00 00 00 00 ") // [D6]
//testString4.append("00 00 00 00 00 00 00 00 ") // [D7]
//testString4.append("00 00 00 00 00 00 00 00 ") // [D8]
//testString4.append("00 00 00 00 00 00 00 00 ") // [D9]
//testString4.append("00 00 00 00 00 00 00 00 ") // [DA]
//testString4.append("00 00 00 00 00 00 00 00 ") // [DB]
//testString4.append("00 00 00 00 00 00 00 00 ") // [DC]
//testString4.append("00 00 00 00 00 00 00 00 ") // [DD]
//testString4.append("00 00 00 00 00 00 00 00 ") // [DE]
//testString4.append("00 00 00 00 00 00 00 00 ") // [DF]
//testString4.append("00 00 00 00 00 00 00 00 ") // [E0]
//testString4.append("00 00 00 00 00 00 00 00 ") // [E1]
//testString4.append("00 00 00 00 00 00 00 00 ") // [E2]
//testString4.append("00 00 00 00 00 00 00 00 ") // [E3]
//testString4.append("00 00 00 00 00 00 00 00 ") // [E4]
//testString4.append("FF FF 84 FD 25 00 9A FC ") // [E5]
//testString4.append("14 00 50 FC 19 00 20 FC ") // [E6]
//testString4.append("03 00 5F F5 00 00 00 00 ") // [E7]
//testString4.append("00 00 00 00 00 00 00 00 ") // [E8]
//testString4.append("00 00 00 00 AB AB 4A FB ") // [E9]
//testString4.append("E2 00 3C FA E1 00 AE FB ") // [EA]
//testString4.append("AB AB 2C 5A A4 00 CA FB ") // [EB]
//testString4.append("A3 00 56 5A A2 00 BA F9 ") // [EC]
//testString4.append("A1 00 24 57 A0 00 AB AB ") // [ED]
//testString4 = testString4.replacingOccurrences(of: " ", with: "")
//
//var testString5 =       " 00 00 FF FF FF FF " // [EE]  "00 00"  -> 0
//testString5.append("20 00 71 62 00 00 00 00 ") // [EF]
//testString5.append("00 00 00 00 00 00 00 00 ") // [F0]
//testString5.append("00 00 AE 5C 00 00 A8 57 ") // [F1]
//testString5.append("00 00 28 4E 68 45 00 00 ") // [F2]
//testString5.append("DC 5F AE 5A 7A 5A DA 50 ") // [F3]
//testString5 = testString5.replacingOccurrences(of: " ", with: "")


////var testString5 =  "//00 00 FF FF FF FF " // [EE] 00 00
//var testString5 =  " 00 00 00 00 " // [EF]   20 00    7162 -> 29062
//testString5.append("00 00 00 00 00 00 00 00 ") // [F0]
//testString5.append("00 00 AE 5C 00 00 A8 57 ") // [F1]
//testString5.append("00 00 28 4E 68 45 00 00 ") // [F2]
//testString5.append("DC 5F AE 5A 7A 5A DA 50 ") // [F3]
//testString5 = testString5.replacingOccurrences(of: " ", with: "")


func stringToBytes(theString: String) -> [UInt8] {

    
    let length = theString.lengthOfBytes(using: String.Encoding.utf8)
    guard length % 2 == 0 else {
        print("Error in \(#function): String does not have an even number of characters and is thus not a valid string of pairs of characters where each pair represents a byte.")
        return [0]
    }
    
    var theBytes = [UInt8]()
    for index in stride(from: 0, to: length, by: 2) {
        let aIndex = theString.index(theString.startIndex, offsetBy: index)
        let bIndex = theString.index(theString.startIndex, offsetBy: index+2)
        let range =  aIndex..<bIndex
        let string = theString.substring(with: range)
        let aByte = UInt8(string, radix: 16)

        theBytes.append(aByte!)
    }
    return theBytes
}


let bytes1 = stringToBytes(theString: testString1)
let crc1 = crc16(message: bytes1, seed: 0xffff)  // should return "FD 61", i.e. 64865 or 25085 (the latter when bytes are not swapped)
let hexString = String(format: "%02X", crc1)
print(hexString)

let bytes2 = stringToBytes(theString: testString2)
let crc2 = crc16(message: bytes2, seed: 0xffff)  // should return "62 C2", i.e. 25282 or 49762 (the latter when bytes are not swapped)


//var bytes4 = stringToBytes(theString: testString4)
//let crc4 = crc16(message: bytes4, seed: 0xffff)  // [2B] should return "9E 42", i.e. 40514 or 17054 (with bytes not swapped)
//for i in 1..<244*8{
//
//    let crc4 = crc16(message: bytes4, seed: 0xffff)  // [2B] should return "9E 42", i.e. 40514 or 17054 (with bytes not swapped)
//    if crc4 == 40514 {
//        print("TRRRRRRRUUUUUUUUUEEEEEEEEEEEEEEEEEEEEEEEEEE")
//    }
//    print(String("crc is \(crc4) and should be 40514") ?? "no String")
//
//    bytes4 = Array(bytes4.dropLast(8))
//    if bytes4.count <= 0 {
//        break
//    }
//}
//
//var bytes5 = stringToBytes(theString: testString5)
//let crc5 = crc16(message: bytes5, seed: 0xffff)  //
//for i in 1..<244*8{
//
//    let crc5 = crc16(message: bytes5, seed: 0xffff)  // [EE] should return 0
//    if crc5 == 0 {
//        print("TRRRRRRRUUUUUUUUUEEEEEEEEEEEEEEEEEEEEEEEEEE")
//    }
//    print(String("crc is \(crc5) and should be 0") ?? "no String")
//
//    bytes5 = Array(bytes5.dropLast(1))
//    if bytes5.count <= 0 {
//        break
//    }
//}



/// Calculate crc look-up-table. Code take from http://stackoverflow.com/questions/24694713/calculation-of-ccitt-standard-crc-with-polynomial-x16-x12-x5-1-in-java and transfered to swift
func calcCRCTable() -> [UInt16] {
    var crcTable = [UInt16]()
    
    // Polynomial, x**0 + x**5 + x**12 + x**16 (0x8408), CRC-CCITT, see http://stackoverflow.com/questions/24694713/calculation-of-ccitt-standard-crc-with-polynomial-x16-x12-x5-1-in-java or https://en.wikipedia.org/wiki/Polynomial_representations_of_cyclic_redundancy_checks
    let polynomial = UInt16(0x8408)

    for i: UInt16 in 0...255 {
        var crc = i
        for _ in 1...8 {
            if crc & 1 == 1 {
                crc = (crc >> 1) ^ polynomial
            } else {
                crc = crc >> 1
            }
        }
        crcTable.append(crc)
    }
    return crcTable
}


let crcn = calcCRCTable()
print(crcn)



