//
//  academicRecordModel.h
//  OneBox
//
//  Created by 谢江新 on 15/5/18.
//  Copyright (c) 2015年 谢江新. All rights reserved.
//

#import "ADClusterAnnotation.h"

#import "ADMapCluster.h"

BOOL ADClusterCoordinate2DIsOffscreen(CLLocationCoordinate2D coord) {
    return (coord.latitude == kADCoordinate2DOffscreen.latitude && coord.longitude == kADCoordinate2DOffscreen.longitude);
}

@implementation ADClusterAnnotation
@synthesize cluster = _cluster;

- (id)init {
    self = [super init];
    if (self) {
        _cluster = nil;
        self.coordinate = kADCoordinate2DOffscreen;
        _type = ADClusterAnnotationTypeUnknown;
        _shouldBeRemovedAfterAnimation = NO;
    }
    return self;
}

- (void)setCluster:(ADMapCluster *)cluster {
    [self willChangeValueForKey:@"title"];
    [self willChangeValueForKey:@"subtitle"];
    _cluster = cluster;
    [self didChangeValueForKey:@"subtitle"];
    [self didChangeValueForKey:@"title"];
}

- (ADMapCluster *)cluster {
    return _cluster;
}

- (NSString *)title {
    return self.cluster.title;
}

- (NSString *)subtitle {
    return @"";
    return self.cluster.subtitle;
}

- (void)reset {
    self.cluster = nil;
    self.coordinate = kADCoordinate2DOffscreen;
}

- (NSArray *)originalAnnotations {
    NSAssert(self.cluster != nil, @"This annotation should have a cluster assigned!");
    return self.cluster.originalAnnotations;
}
@end
