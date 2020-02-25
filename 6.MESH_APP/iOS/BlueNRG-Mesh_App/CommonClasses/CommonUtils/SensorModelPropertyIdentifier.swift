/**
 ******************************************************************************
 * @file    SensorModelPropertyIdentifier.swift
 * @author  BlueNRG-Mesh Team
 * @version V1.01.000
 * @date    08-Oct-2018
 * @brief   Models Support Class
 ******************************************************************************
 * @attention
 *
 * <h2><center>&copy; COPYRIGHT(c) 2018 STMicroelectronics</center></h2>
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************
 */

import Foundation
// swiftlint:disable type_body_length file_length
public struct SensorModelPropertyIdentifier {
    public var identifiersMap: [UInt16: String]
    
    public init() {
        identifiersMap = [
            0x0000 : "Prohibited",
            0x004F : "Temperature",
            0x2A6D : "Pressure"
        ]
    }
    
    public func humanReadableNameFromIdentifier(_ anIdentifier: Data) -> String? {
        let highByte = UInt16(anIdentifier[0]) << 8
        let lowByte  = UInt16(anIdentifier[1])
        return self.identifiersMap[highByte | lowByte]
    }
    
    public func humanReadableNameFromIdentifier(_ anIdentifier: UInt16) -> String? {
        return self.identifiersMap[anIdentifier]
    }
}



