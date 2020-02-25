/******************** (C) COPYRIGHT 2018 STMicroelectronics **********************
 * File Name          : CompositionDataModel.h
 * Author             : BlueNRG-Mesh Team
 * Date First Issued  : 2018.06.07 :  V1.02
 * Description        : Header for CompositionDataPage0 ObjC Wrapper.
 
 ********************************************************************************
 This file may contain STMicroelectronics proprietary & confidential information
 *********************************************************************************/


#import <Foundation/Foundation.h>


@class ElementField;
@interface STMeshCompositionDataModel : NSObject

/* Feature */
@property (nonatomic, readonly)BOOL isRelayFeature;
@property (nonatomic, readonly)BOOL isProxyFeature;
@property (nonatomic, readonly)BOOL isFriendFeature;
@property (nonatomic, readonly)BOOL isLowPowerFeature;

/* Element */
@property (nonatomic, readonly)NSMutableArray <ElementField *>*elementList;

/* Identifiers */
@property (nonatomic, readonly)uint16_t cid; /* Company ID */
@property (nonatomic, readonly)uint16_t pid; /* Product ID */
@property (nonatomic, readonly)uint16_t vid; /* Version ID */
@property (nonatomic, readonly)uint16_t crpl;/* Replay protection list size */
@end

@interface ElementField:NSObject
/* element */
@property (nonatomic, readonly)uint16_t loc; /* Location descriptor */
@property (nonatomic, readonly)uint8_t numS;/* Count of SIG model ID's */
@property (nonatomic, readonly)uint8_t numV;/* Count of Vendor model ID's */
@property (nonatomic, readonly)NSMutableArray *sigModels;
@property (nonatomic, readonly)NSMutableArray *vendorModels;
@end

