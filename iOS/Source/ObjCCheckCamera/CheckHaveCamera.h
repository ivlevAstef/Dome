//
//  CheckHaveCamera.h
//  Dome
//
//  Created by Ивлев Александр on 07/07/2019.
//  Copyright © 2019 SIA. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CheckHaveCamera : NSObject

// криво назвал - проверяет есть ли камера в black list
+(BOOL)checkHaveCamera;

@end

NS_ASSUME_NONNULL_END
