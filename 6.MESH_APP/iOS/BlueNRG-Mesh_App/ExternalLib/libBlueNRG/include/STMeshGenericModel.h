/**
 ******************************************************************************
 * @file    GenericModel.h
 * @author  BlueNRG-Mesh Team
 * @version V1.03.000
 * @date    07-Mar-2018
 * @brief   Implementation of Generic model
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


#import <Foundation/Foundation.h>
#import "STMeshBasicTypes.h"

@protocol STMeshGenericModelDelegate;

@interface STMeshGenericModel : NSObject
@property(nonatomic , weak) id <STMeshGenericModelDelegate> delegate;

/**
 * @brief setGenericOnOff method. peerAddress, isOn and responseFlag three parameter required
 * @discussion This function is used to send Generic On/Off command without optional params to element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 isOn  Set Data Value
 * @param3 responseFlag  Response Flag
 * @code
    manager.getGenericModel().setGenericOnOff(element.unicastAddress, isOn: isOn, isUnacknowledged: true)
 * @endcode
 * @return  Enum STMeshStatus corresponding value.
 * @remarks Parameters peerAddress is uint16_t datatype, isOn is Bool datatype, responseFlag is Bool datatype.
 */
- (STMeshStatus) setGenericOnOff:(uint16_t)peerAddress isOn:(BOOL)isOn isUnacknowledged:(BOOL)responseFlag;


/**
 * @brief setGenericOnOff method. peerAddress, isOn,transitionTime, delay and responseFlag five parameter required
 * @discussion This function is used to send Generic On/Off command with optional params to element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 isOn  Set Data Value
 * @param3 time  transition Time
 * @param4 delay  delay time
 * @param5 responseFlag  Response Flag
 * @code
    manager.getGenericModel().setGenericOnOff(element.unicastAddress, isOn: true, transitionTime:10 withDelay:08, isUnacknowledged: true)
 * @endcode
 * @return  Enum STMeshStatus corresponding value.
 * @remarks Parameters peerAddress is uint16_t datatype, isOn is Bool datatype, transitionTime is uint_8t datatype, delay is uint_8t datatype, responseFlag is Bool datatype.
 */

- (STMeshStatus) setGenericOnOff:(uint16_t)peerAddress isOn:(BOOL)isOn
                  transitionTime:(uint8_t)time withDelay:(uint8_t)delay isUnacknowledged:(BOOL)responseFlag;


/**
 * @brief readGenericOnOff method. peerAddress, only one parameter required
 * @discussion This function is used to read  Generic On/Off status from a element of a peer node..
 * @param1 peerAddress Peer Address of element
 * @code
    manager.getGenericModel().readGenericOnOff(element.unicastAddress)
 * @endcode
 * @return  Enum STMeshStatus corresponding value.
 * @remarks Parameters peerAddress is uint16_t datatype.
 */
- (STMeshStatus) readGenericOnOff:(uint16_t)peerAddress;

/**
 * @brief setGenericLevel method. peerAddress, levelValue and responseFlag three parameter required
 * @discussion This function is used to send Generic level command without optional params to element of peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 levelValue  Set Data Value of level
 * @param3 responseFlag  Response Flag
 * @code
    manager.getGenericModel().setGenericLevel(element.unicastAddress, level:5767, isUnacknowledged: true)
 * @endcode
 * @return  Enum STMeshStatus corresponding value.
 * @remarks Parameters peerAddress is uint16_t datatype, levelValue is int16_t datatype, responseFlag is Bool datatype.
 */
- (STMeshStatus) setGenericLevel:(uint16_t)peerAddress level:(int16_t)levelValue
                isUnacknowledged:(BOOL)responseFlag;

/**
 * @brief setGenericLevel method. peerAddress, levelValue transitionTime, delay and responseFlag five parameter required
 * @discussion This function is used to send Generic level command with optional params to element of peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 levelValue  Set Data Value of level
 * @param3 time  transition Time
 * @param4 delay  delay time
 * @param5 responseFlag  Response Flag
 * @code
    manager.getGenericModel().setGenericLevel(element.unicastAddress, level:5767, transitionTime:20 withDelay:23, isUnacknowledged: true)
 * @endcode
 * @return  Enum STMeshStatus corresponding value.
 * @remarks Parameters peerAddress is uint16_t datatype, levelValue is int16_t datatype, transitionTime is uint_8t datatype, delay is uint_8t datatype, responseFlag is Bool datatype.
 */
- (STMeshStatus) setGenericLevel:(uint16_t)peerAddress level:(int16_t)levelValue
                  transitionTime:(uint8_t)time withDelay:(uint8_t)delay isUnacknowledged:(BOOL)responseFlag;

/**
 * @brief readGenericLevel method. peerAddress, only one parameter required
 * @discussion This function is used to read Generic level status from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @code
    manager.getGenericModel().readGenericLevel(element.unicastAddress)
 * @endcode
 * @return  Enum STMeshStatus corresponding value.
 * @remarks Parameters peerAddress is uint16_t datatype.
 */
- (STMeshStatus) readGenericLevel:(uint16_t)peerAddress;

@end

@protocol STMeshGenericModelDelegate <NSObject>

@optional
/**
 * @brief Status of the generic OnOff.
 * @discussion This is called method which is been invoked on callback of OnOff function.
 * @param1 peerAddress Peer Address.
 * @param2 presentState current State of element onOff.
 * @param3 targetState i.e targeted stae of element onOff.
 * @param4 time i.e remaining time.
 * @param5 stateFlag i.e is present target state
 * @remarks This needs to be implemented in order to get the response of the  Generic On/Off set/get  command
 */
- (void) genericModel:(STMeshGenericModel*)genericModel didReceiveOnOffStatusFromAddress:(uint16_t)peerAddress
         presentOnOff:(uint8_t)presentState targetOnOff:(uint8_t)targetState remainingTime:(uint8_t)time isTargetStatePresent:(BOOL)stateFlag;

/**
 * @brief Status of the generic Level.
 * @discussion This is called method which is been invoked on callback of generic Level function.
 * @param1 peerAddress Peer Address.
 * @param2 presentState current State of element Level.
 * @param3 targetState i.e targeted stae of element Level.
 * @param4 time i.e remaining time.
 * @param5 stateFlag i.e is present target state
 * @remarks This needs to be implemented in order to get the response of the  Generic Level set  command
 */
- (void) genericModel:(STMeshGenericModel*)genericModel didReceiveLevelStatusFromAddress:(uint16_t)peerAddress
         presentOnOff:(uint16_t)presentState targetOnOff:(uint16_t)targetState remainingTime:(uint8_t )time isTargetStatePresent:(BOOL)stateFlag;
@end


