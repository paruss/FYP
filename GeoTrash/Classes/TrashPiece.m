//
//  TrashPiece.m
//  GeoTrash
//
//  Created by Patrick Russell on 06/02/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrashPiece.h"


@implementation TrashPiece
@synthesize iD, timestamp, latitude, longitude;


-(id)initWithID:(NSString *)i ts:(NSString *)t lat:(NSString *)a lon:(NSString *)o {
	
	self.iD = i;
	self.timestamp = t;
	self.latitude = a;
	self.longitude = o;
	return self;
}
@end
