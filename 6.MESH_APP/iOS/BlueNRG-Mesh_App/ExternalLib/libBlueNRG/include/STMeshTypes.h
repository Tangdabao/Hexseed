/**
 ******************************************************************************
 * @file    STMeshTypes.h
 * @author  BlueNRG-Mesh Team
 * @version V1.03.000
 * @date    30-Jun-2017
 * @brief   Common types used in the library
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

#ifndef STMeshTypes_h
#define STMeshTypes_h
#import <Foundation/Foundation.h>
#include "STMeshBasicTypes.h"

#define STMesh_Provisioner_AddressLowRange_Key "lowAddress"
#define STMesh_Provisioner_AddressHighRange_Key "highAddress"


@class STMeshNode;
@class STMeshElement;
@class STMeshProvisionerData;
@class STMeshModel;
@class ProvisioningRangeObjects;
@class STMeshNodeFeatures;
@class STMeshSensorValues;
@class STMeshHeartbeat;
@class STMeshSensorData;
@interface STMeshGroup:NSObject
@property (nonatomic) NSString *groupName;
@property (nonatomic) uint16_t groupAddress;
@property (nonatomic) BOOL switchState;
@property (nonatomic) NSMutableArray<STMeshElement*> *subscribersElem;

@end
/**
 * @discussion Mesh Node class and its associated properties
 * @code
- node Properties
 ** nodeName : Represents the name of the node.
 ** nodeUUID : Represents the UUID of the node.
 ** deviceKey : Represents the device Key of the node.
 ** isProxyNode : Bool to indicate a node is proxy or not
 ** publishTarget : Publish address associated with node.
 ** unicastAddress : Address allocated to the node.
 ** configCompleted :Bool representing node configuration status.
 ** blackListed : Bool representing node blackListed Status.
 ** cid : Company Identifier of a node.
 ** pid : Product Identifier of a node.
 ** vid : Version Identifier of a node.
 ** crpl : Replay protection list size of a node.
 ** features : Features associated with a node. Ex isProxyFeature is supported by node , isLowPowerSupport is supported by node.
 ** elementList : List of all elements associated with a node.
 ** subscribedGroups : List of all subscribed groups.
*@endcode
 */
@interface STMeshNode:NSObject
@property (nonatomic) NSString *nodeName;
@property (nonatomic) NSString *nodeUUID;
@property (nonatomic) NSString *deviceKey;
@property (nonatomic) BOOL isProxyNode;
@property (nonatomic) BOOL switchState;
@property (nonatomic) uint16_t publishAddress;
@property (nonatomic) uint16_t unicastAddress;
@property (nonatomic,strong) id publishTarget;
@property (nonatomic) BOOL configComplete;
@property (nonatomic) BOOL blacklisted;
@property (nonatomic) NSString * cid;
@property (nonatomic) NSString * pid ;
@property (nonatomic) NSString * vid;
@property (nonatomic) NSString * crpl;
@property (nonatomic) STMeshNodeFeatures * features;
@property (nonatomic) NSMutableArray<STMeshElement *> *elementList;
@property (nonatomic) NSMutableArray<STMeshElement*> *subscribedGroups;
@property (nonatomic) STMeshHeartbeat *heartbeatInfo;
@end

/**
 * @discussion Mesh Element class and its associated properties
 * @code
 - node Properties
 ** name : Represents the name of the element.
 ** publishTarget : Publish address associated with element.
 ** unicastAddress : Address allocated to the element.
 ** modelList : List of all models associated with a node.
 ** configCompleted :Bool representing node configuration status.
 ** subscribedGroups : List of all subscribed groups.
 ** parentNode : Represents the immediate parent node of the element.
 *@endcode
 */
@interface STMeshElement : NSObject
@property (nonatomic) uint8_t index;
@property (nonatomic) NSString *elementName;
@property (nonatomic,strong) id  publishTarget;
@property (nonatomic) uint16_t unicastAddress;
@property (nonatomic) NSMutableArray<STMeshModel*> *modelList;
@property (nonatomic) BOOL configComplete;
@property (nonatomic) NSMutableArray<STMeshGroup*> *subscribedGroups;
@property (nonatomic) STMeshNode * parentNode;
@property (nonatomic) STMeshSensorValues *sensorModel;

@end

@interface ProvisioningRangeObjects : NSMutableDictionary

-(id)initRangeObjectsWithMinValue:(NSString*)lowRange maxValue:(NSString*)highRange;

@end

/**
 * @discussion Mesh Provisioner Data class and its associated properties
 * @code
 - node Properties
 ** provisionerName : Represents the name of the Provisioner.
 ** provisionerUUID :: Represents the UUID of the provisioner.
 ** marrProvisionerAllocatedUnicastRange : Allocated unicast range to the provisioner for assigning unicast address to the nodes/elements
 ** marrProvisionerAllocatedGroupRange : Allocated group range to the provisioner for assigning unicast address to the nodes/elements
 *@endcode
 */
@interface STMeshProvisionerData : STMeshNode
@property (nonatomic) NSString *provisionerName;
@property (nonatomic) NSString *provisionerUUID;
@property (nonatomic) NSMutableArray<ProvisioningRangeObjects*> *marrProvisionerAllocatedUnicastRange;
@property (nonatomic) NSMutableArray<ProvisioningRangeObjects*> *marrProvisionerAllocatedGroupRange;
@end

/**
 * @discussion Mesh Network Setting class and its associated properties
 * @code
 - node Properties
 ** iVindex : Represents the iVindex of the network.
 ** netKey :: Represents the network Key of the network.
 ** appKey :: Represents the application Key of the network.
 ** devKey :: Represents the device Key of the network.
 ** meshName :: Represents the mesh name of the network.
 ** meshUUID :: Represents the mesh UUID of the network.
 ** nodes : Array of all nodes in the network.
 ** groups : Array of all groups in the network.
 
 * + (instancetype) initAsNewNetwork : A class method to instantiate the network
 *@endcode
 */
@interface STMeshNetworkSettings : NSObject

@property (nonatomic) uint32_t iVindex;
@property (nonatomic) NSString *netKey;
@property (nonatomic) NSString *appKey;
@property (nonatomic) NSString *devKey;
@property (nonatomic) NSString *meshName;
@property (nonatomic) NSString *meshUUID;
@property BOOL useDefaultSecuritiesCredential;
@property (nonatomic) NSMutableArray<STMeshNode*> *nodes;
@property (nonatomic) NSMutableArray<STMeshGroup*> *groups;
@property (nonatomic) NSMutableArray<STMeshProvisionerData*> *provisionerDataArray;
@property (nonatomic) NSMutableArray<STMeshProvisionerData*> *onlyProvisionerArray;

+ (instancetype) initAsNewNetwork;
- (void)reinitNetworkDataList;
@end

/**
 * @discussion Mesh Model class and its associated properties
 * @code
 - node Properties
 ** modelId : Represents the model Id of the model.
 ** modelName :: Represents the model name of the model.
 ** subscribedList : List of all subscribed groups.
 ** publishTarget : Publish address associated with Model.
 *@endcode
 */
@interface STMeshModel: NSObject
@property (nonatomic) uint32_t modelId;
@property (nonatomic) NSString * modelName;
@property (nonatomic) NSMutableArray<STMeshGroup*> *subscribeList;
@property (nonatomic) id publish;

@end
/**
 * @discussion Mesh Node Feature class and its associated properties
 * @code
 ** relay : Represents, if node supports relay feature.
 ** proxy : Represents, if node supports proxy feature.
 ** friend : Represents, if node supports friend feature.
 ** lowPower : Represents, if node supports low power feature.
 *@endcode
 */
@interface STMeshNodeFeatures :NSObject
@property (nonatomic) uint8_t relay;
@property (nonatomic) uint8_t proxy;
@property (nonatomic) uint8_t friendFeature;
@property (nonatomic) uint8_t lowPower;

@end

/**
 * @discussion Sensor Value Data Model class and its associated properties
 * @code
 ** sensorTemperatureValue : Represents, Temperature Sensor Value associated with the node.
 ** sensorPressureValue : Represents, Pressure Sensor Value associated with the node.
 *@endcode
 */
@interface STMeshSensorValues :NSObject
@property (nonatomic) float sensorTemperatureValue;
@property (nonatomic) float sensorPressureValue;
@end


/**
 * @discussion Heartbeat Value Data Model class and its associated properties
 * @code
 ** strLastHeartbeatRecieved : Represents, Last heartbeat recieved time.
 ** maxHops : Represents, Maximum Hops required to reach destination.
 ** minHops : Represents, Minimum Hops required to reach destination.

 *@endcode
 */
@interface STMeshHeartbeat : NSObject
@property(nonatomic) STMeshNodeFeatures *nodeFeatures;
@property(nonatomic) NSString *strLastHeartbeatRecieved;
@property(nonatomic) NSString *maxHops;
@property(nonatomic) NSString *minHops;
@end


/**
 * @discussion Sensor Data Model class and its associated properties
 * @code
 ** timestanmp : Represents, Last sensor data recieved time.
 ** propertyID : Represents, Property ID required of the sensor.
 ** sensorName : Represents, name of the sensor model. i.e Temperature , pressure etc.
 ** sensorValue : Represents, actual value of the sensor.
 ** sensorFormatType : Represents, type of the fornat used to transfer the data, ex either FormatA or FornatB
 *@endcode
 */
@interface STMeshSensorData : NSObject
@property (nonatomic) NSTimeInterval timestanmp;
@property (nonatomic) int propertyID;
@property (nonatomic) NSString * sensorName;
@property (nonatomic) NSString * stringUnit;
@property (nonatomic) NSNumber* sensorValue;
@property (nonatomic) NSString *sensorFormatType;

@end

#endif /* STMeshTypes_h */

