/**
 ******************************************************************************
 * @file    STMeshLightingModel.h
 * @author  BlueNRG-Mesh Team
 * @version V1.03.000
 * @date    15-May-2018
 * @brief   Implementation of Lighting model
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

@protocol STMeshLightingModelDelegate;

@interface STMeshLightingModel : NSObject
@property(nonatomic , weak) id <STMeshLightingModelDelegate> delegate;

/**
 * @brief readLightingLightnessStatus method. peerAddress only one parameter required
 * @discussion This function is used to read Lighting lightness status from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @code
    manager.getLightingModel().readLightingLightnessStatus(element.unicastAddress)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype
 */
-(STMeshStatus)readLightingLightnessStatus:(uint16_t)peerAddress;

/**
 * @brief setLightingLightness method. peerAddress, lightness and responseFlag are parameter required
 * @discussion This function is used to send Lighting lightness command to element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 lightness lightness value
 * @param3 responseFlag response flag
 * @code
    manager.getLightingModel().setLightingLightness(element.unicastAddress, isUnacknowledged:true)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype, responseFlag is Bool datatype
 */
-(STMeshStatus)setLightingLightness:(uint16_t)peerAddress lightnessValue:(uint16_t)lightness isUnacknowledged:(BOOL)responseFlag;

/**
 * @brief readLightingLightnessStatus method. peerAddress, time, delay, responseFlag are the parameter required
 * @discussion This function is used to send Lighting lightness with optional command to element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 lightness lightness value
 * @param3 time transation time
 * @param4 delay delay
 * @param5 responseFlag response flag
 * @code
    manager.getLightingModel().setLightingLightness(element.unicastAddress,transationTime:23, withDelay:12 , isUnacknowledged:true)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype,time is uint_8t datatype, delay is uint_8t datatype, responseFlag is Bool datatype
 */
-(STMeshStatus)setLightingLightness:(uint16_t)peerAddress lightnessValue:(uint16_t)lightness transationTime:(uint8_t)time withDelay:(uint8_t)delay isUnacknowledged:(BOOL)responseFlag;


/**
 * @brief readLightCTLStatus method. peerAddress, is the parameter required.
 * @discussion This function is used to read Lighting CTL status from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @code
    manager.getLightingModel().readLightCTLStatus(element.unicastAddress)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype
 */
-(STMeshStatus)readLightCTLStatus:(uint16_t)peerAddress;


/**
 * @brief setLightingCTL method. peerAddress, lightness, temperature, deltaUV, responseFlag five parameter required
 * @discussion This function is used to send Lighting CTL command from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 lightness  lightness value
 * @param3 temperature  temperature value
 * @param4 deltaUV ie Delta UV value
 * @param5 responseFlag  response flag
 * @code
    manager.getLightingModel().setLightingCTL(element.unicastAddress,lightness:23, temperature:12 ,deltaUVValue:56,  isUnacknowledged:true)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype,lightness is uint16_t datatype, temperature is uint16_t datatype, deltaUV is uint16_t datatype, responseFlag is Bool datatype
 */
-(STMeshStatus)setLightingCTL:(uint16_t)peerAddress lightnessValue:(uint16_t)lightness temperatureValue:(uint16_t)temperature deltaUVValue:(int16_t)deltaUV isUnacknowledged:(BOOL)responseFlag;

/**
 * @brief setLightingCTL method. peerAddress, lightness, temperature, deltaUV,time, delay, responseFlag seven parameter required
 * @discussion This function is used to send Lighting CTL command from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 lightness  lightness value
 * @param3 temperature  temperature value
 * @param4 deltaUV ie Delta UV value
 * @param5 time  transation time
 * @param6 delay  delay
 * @param7 responseFlag  response flag
 * @code
    manager.getLightingModel().setLightingCTL(element.unicastAddress,lightness:23, temperature:12 ,deltaUVValue:56,transatimnTime:43, withDelay:12, isUnacknowledged:true)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype,lightness is uint16_t datatype, temperature is uint16_t datatype, deltaUV is uint16_t datatype,time is uint_8t datatype, delay is uint_8t datatype, responseFlag is Bool datatype
 */
-(STMeshStatus)setLightingCTL:(uint16_t)peerAddress lightnessValue:(uint16_t)lightness temperatureValue:(uint16_t)temperature deltaUVValue:(int16_t)deltaUV  transatimnTime:(uint16_t)time withDelay:(uint8_t)delay isUnacknowledged:(BOOL)responseFlag;

/**
 * @brief readLightCTLTemperatureStatus method. peerAddress one parameter required
 * @discussion This function is used to read Lighting CTL Temperature status from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @code
    manager.getLightingModel().readLightCTLTemperatureStatus(element.unicastAddress)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype
 */
-(STMeshStatus)readLightCTLTemperatureStatus:(uint16_t)peerAddress;


/**
 * @brief setLightingCTLTemperature method. peerAddress, temperature, deltaUV, responseFlag are the parameter required
 * @discussion This function is used to send Lighting CTL command from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 temperature  temperature value
 * @param3 deltaUV  Delta UV value
 * @param4 responseFlag  response flag
 * @code
    manager.getLightingModel().setLightingCTLTemperature(element.unicastAddress, temperature:12 ,deltaUVValue:56, isUnacknowledged:true)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype, temperature is uint16_t dataType, deltaUV is uint16_t datatype, responseFlag is Bool datatype
 */
-(STMeshStatus)setLightingCTLTemperature:(uint16_t)peerAddress temperatureValue:(uint16_t)temperature deltaUVValue:(int16_t)deltaUV isUnacknowledged:(BOOL)responseFlag;


/**
 * @brief setLightingCTLTemperature method. peerAddress, temperature, deltaUV,time, delay, responseFlag six parameter required
 * @discussion This function is used to send Lighting CTL command with optional params from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 temperature  temperature value
 * @param3 deltaUV ie Delta UV value
 * @param4 time  transation time
 * @param5 delay  delay
 * @param6 responseFlag  response flag
 * @code
    manager.getLightingModel().setLightingCTLTemperature(element.unicastAddress, temperature:12 ,deltaUVValue:56,transatimnTime:43, withDelay:12, isUnacknowledged:true)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype, temperature is uint16_t datatype, deltaUV is uint16_t datatype,time is uint_8t datatype, delay is uint_8t datatype, responseFlag is Bool datatype
 */
-(STMeshStatus)setLightingCTLTemperature:(uint16_t)peerAddress temperatureValue:(uint16_t)temperature deltaUVValue:(int16_t)deltaUV  transatimnTime:(uint16_t)time withDelay:(uint8_t)delay isUnacknowledged:(BOOL)responseFlag;


/**
 * @brief readLightHSLStatus method. peerAddress one parameter required
 * @discussion This function is used to read Lighting HSL status from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @code
    manager.getLightingModel().readLightHSLStatus(element.unicastAddress)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype
 */
-(STMeshStatus)readLightHSLStatus:(uint16_t)peerAddress;


/**
 * @brief setLightingHSL method. peerAddress, lightness, hue, saturation,time, delay, responseFlag seven parameter required
 * @discussion This function is used to send lightness HSL command with optional params from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 lightness  lightness value
 * @param3 hue  Hue value
 * @param4 saturation ie Saturation value
 * @param5 time  transation time
 * @param6 delay  delay
 * @param7 responseFlag  response flag
 * @code
    manager.getLightingModel().setLightingHSL(element.unicastAddress,lightness:23, hueValue:12 ,saturationValue:56,transatimnTime:43, withDelay:12, isUnacknowledged:true)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype,lightness is uint16_t datatype, hue is uint16_t datatype, saturation is uint16_t datatype,time is uint_8t datatype, delay is uint_8t datatype, responseFlag is Bool datatype
 */


-(STMeshStatus)setLightingHSL:(uint16_t)peerAddress lightnessValue:(uint16_t)lightness hueValue:(uint16_t)hue saturationValue:(uint16_t)saturation transitionTime:(uint16_t)time withDelay:(uint8_t)delay isUnacknowledged:(BOOL)responseFlag;

/**
 * @brief setLightingHSL method. peerAddress, lightness, hue, saturation, responseFlag five parameter required
 * @discussion This function is used to send  Lighting HSL command from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 lightness  lightness value
 * @param3 hue  Hue value
 * @param4 saturation ie Saturation value
 * @param5 responseFlag  response flag
 * @code
    manager.getLightingModel().setLightingHSL(element.unicastAddress,lightness:23, hueValue:12 ,saturationValue:56, isUnacknowledged:true)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype,lightness is uint16_t datatype, hue is uint16_t datatype, saturation is uint16_t datatype, responseFlag is Bool datatype
 */
-(STMeshStatus)setLightingHSL:(uint16_t)peerAddress lightnessValue:(uint16_t)lightness hueValue:(uint16_t)hue saturationValue:(uint16_t)saturation isUnacknowledged:(BOOL)responseFlag;


/**
 * @brief readLightHSLHueStatus method. peerAddress one parameter required
 * @discussion This function is used to read Lighting HSL hue status from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @code
    manager.getLightingModel().readLightHSLHueStatus(element.unicastAddress)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype
 */
-(STMeshStatus)readLightHSLHueStatus:(uint16_t)peerAddress;

/**
 * @brief setLightingHSLHue method. peerAddress,  hue, responseFlag, three parameter required
 * @discussion This function is used to  send Lighting HSL hue command from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 hue  Hue value
 * @param3 responseFlag  response flag
 * @code
    manager.getLightingModel().setLightingHSLHue(element.unicastAddress,hueValue:45, isUnacknowledged:true)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype, hue is uint16_t datatype
 */
-(STMeshStatus)setLightingHSLHue:(uint16_t)peerAddress hueValue:(uint16_t)hue isUnacknowledged:(BOOL)responseFlag;


/**
 * @brief setLightingHSLHue method. peerAddress, lightness, hue, saturation,time, delay, responseFlag seven parameter required
 * @discussion This function is used to  send Lighting HSL Hue command with optional params from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 hue  Hue value
 * @param3 time  transation time
 * @param4 delay  delay
 * @param5 responseFlag  response flag
 * @code
    manager.getLightingModel().setLightingHSLHue(element.unicastAddress, hueValue:12 ,transatimnTime:43, withDelay:12, isUnacknowledged:true)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype, hue is uint16_t datatype, time is uint_8t datatype, delay is uint_8t datatype, responseFlag is Bool datatype
 */
-(STMeshStatus)setLightingHSLHue:(uint16_t)peerAddress hueValue:(uint16_t)hue transitionTime:(uint16_t)time withDelay:(uint8_t)delay isUnacknowledged:(BOOL)responseFlag;


/**
 * @brief readLightHSLSaturationStatus method. peerAddress one parameter required
 * @discussion This function is used to read Lighting HSL Saturation status from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @code
    manager.getLightingModel().readLightHSLSaturationStatus(element.unicastAddress)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype
 */
-(STMeshStatus)readLightHSLSaturationStatus:(uint16_t)peerAddress;


/**
 * @brief setLightingHSLSaturation method. peerAddress,  saturation, responseFlag, three parameter required
 * @discussion This function is used to send Lighting HSL saturation command to a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 saturation  Saturation value
 * @param3 responseFlag  response flag
 * @code
    manager.getLightingModel().setLightingHSLSaturation(element.unicastAddress,saturationValue:45, isUnacknowledged:true)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype, saturation is uint16_t datatype
 */
-(STMeshStatus)setLightingHSLSaturation:(uint16_t)peerAddress saturationValue:(uint16_t)saturation isUnacknowledged:(BOOL)responseFlag;


/**
 * @brief setLightingHSL method. peerAddress, saturation,time, delay, responseFlag five parameter required
 * @discussion This function is used to  send Lighting HSL Saturation command with optional params from a element of a peer node.
 * @param1 peerAddress Peer Address of element
 * @param2 saturation  Saturation value
 * @param3 time  transation time
 * @param4 delay  delay
 * @param5 responseFlag  response flag
 * @code
    manager.getLightingModel().setLightingHSLHue(element.unicastAddress, saturationValue:12 ,transatimnTime:43, withDelay:12, isUnacknowledged:true)
 * @endcode
 * @return  Result of the method execution.
 * @remarks Parameters peerAddress is uint16_t datatype, saturation is uint16_t datatype, time is uint_8t datatype, delay is uint_8t datatype, responseFlag is Bool datatype
 */
-(STMeshStatus)setLightingHSLSaturation:(uint16_t)peerAddress saturationValue:(uint16_t)saturation transitionTime:(uint16_t)time withDelay:(uint8_t)delay isUnacknowledged:(BOOL)responseFlag;

@end

@protocol STMeshLightingModelDelegate <NSObject>

@optional
/**
 * @brief  This is a callback Lighting Lightness status of lighting models with lightingModel, peerAddress, presentLightness, targetLightness, time,stateFlag Six Param required.
 * @discussion This callback is invoked when Lighting Lightness value read or  Lighting Lightness value set with response flag.
 * @param1  lightingModel  object of lighting model.
 * @param2  peerAddress  Unicast address of the current proxy node.
 * @param3  presentLightness Present Lightness Value.
 * @param4  targetLightness Target Lightness value
 * @param5  time  remaining time value
 * @param6  stateFlag  target value flag
 */
- (void) lightingModel:(STMeshLightingModel*)lightingModel didReceiveLightnessStatusFromAddress:(uint16_t)peerAddress
      presentLightness:(uint16_t)presentLightness targetLightness:(uint16_t)targetLightness remainingTime:(uint8_t)time isTargetStatePresent:(BOOL)stateFlag;


/**
 * @brief  This is a callback Lighting CTL status of lighting models with lightingModel, peerAddress,presentLightness, presentTemperature,targetLightness,targetTemperature, stateFlag Seven Param required.
 * @discussion This callback is invoked when Lighting CTL value read or Lighting CTL value set with response flag.
 * @param1  lightingModel  object of lighting model.
 * @param2  peerAddress  Unicast address of the current proxy node.
 * @param3  presentLightness Present Lightness Value.
 * @param4  presentTemperature  Present Temperature value
 * @param5  targetLightness  Target Lightness value
 * @Param6  targetTemperature Target Temperature Value
 * @Param7 stateFlag target value flag
 */
- (void) lightingModel:(STMeshLightingModel*)lightingModel didReceiveCTLStatusFromAddress:(uint16_t)peerAddress
      presentLightness:(uint16_t)presentLightness presentTemperature:(uint16_t)presentTemperature targetLightness:(uint16_t)targetLightness  targeTemperature:(uint16_t)targetTemperature  isTargetStatePresent:(BOOL)stateFlag;

/**
 * @brief  This is a callback Lighting CTL Temperature status of lighting models with lightingModel, peerAddress, presentTemperature,presentDeltaUV,targetTemperature, targetDeltaVU, stateFlag Seven Param required.
 * @discussion This callback is invoked when Lighting CTL Temperature value read or Lighting CTL Temperature value set with response flag.
 * @param1  lightingModel  object of lighting model.
 * @param2  peerAddress  Unicast address of the current proxy node.
 * @param3  presentTemperature  Present Temperature value
 * @param4  presentDeltaUV Present DeltaUV Value.
 * @Param5  targetTemperature Target Temperature Value
 * @param6  targetDeltaVU  Target DeltaVU value
 * @Param7 stateFlag target value flag
 */
- (void) lightingModel:(STMeshLightingModel*)lightingModel didReceiveCTLTemperatureStatusFromAddress:(uint16_t)peerAddress
    presentTemperature:(uint16_t)presentTemperature presentDeltaVU:(uint16_t)presentDeltaUV targeTemperature:(uint16_t)targetTemperature targetDeltaVU:(uint16_t)targetDeltaVU isTargetStatePresent:(BOOL)stateFlag;


/**
 * @brief  This is a callback Lighting HSL status of lighting models with lightingModel, peerAddress, lightness, hue, saturation, remainingTime, stateFlag Seven Param required.
 
 * @discussion This callback is invoked when Lighting HSL value read or Lighting HSL value set with response flag.
 * @param1  lightingModel  object of lighting model.
 * @param2  peerAddress  Unicast address of the current proxy node.
 * @param3  lightness  Lightness Value.
 * @param4  hue Hue Value.
 * @param5  saturation saturation value.
 * @param6  remainingTime  Remaining Time.
 * @param7  stateFlag  target flag Value.
 */
- (void) lightingModel:(STMeshLightingModel*)lightingModel didReceiveHSLStatusFromAddress:(uint16_t)peerAddress
        lightnessValue:(uint16_t)lightness hueValue:(uint16_t)hue saturationValue:(uint16_t)saturation remainingTime:(uint8_t)remainingTime isTargetStatePresent:(BOOL)stateFlag;

/**
 * @brief  This is a callback Lighting HSL Hue status of lighting models with lightingModel, peerAddress, presentHue, targetHue, remainingTime, stateFlag Six Param required.
 
 * @discussion This callback is invoked when Lighting HSL Hue value read or Lighting HSL Hue value set with response flag.
 * @param1  lightingModel  object of lighting model.
 * @param2  peerAddress  Unicast address of the current proxy node.
 * @param3  presentHue  Present Hue Value.
 * @param4  targetHue  Target Hue Value.
 * @param5  time  Remaining Time.
 * @param6  stateFlag  target flag Value.
 */
- (void) lightingModel:(STMeshLightingModel*)lightingModel didReceiveHSLHueStatusFromAddress:(uint16_t)peerAddress
            presentHue:(uint16_t)presentHue targetHue:(uint16_t)targetHue remainingTime:(uint16_t)time  isTargetStatePresent:(BOOL)stateFlag;


/**
 * @brief  This is a callback Lighting HSL Saturation status of lighting models with lightingModel, peerAddress, presentHue, targetHue, remainingTime, stateFlag Six Param required.
 
 * @discussion This callback is invoked when Lighting HSL Saturation value read or Lighting HSL Saturation value set with response flag.
 * @param1  lightingModel  object of lighting model.
 * @param2  peerAddress  Unicast address of the current proxy node.
 * @param3  presentSaturation  Present Saturation Value.
 * @param4  targetSaturation  Target Saturation Value.
 * @param5  time  Remaining Time.
 * @param6  stateFlag  target flag Value.
 */
- (void) lightingModel:(STMeshLightingModel*)lightingModel didReceiveHSLSaturationStatusFromAddress:(uint16_t)peerAddress
     presentSaturation:(uint16_t)presentSaturation targetSaturation:(uint16_t)targetSaturation remainingTime:(uint16_t)time  isTargetStatePresent:(BOOL)stateFlag;

@end

