//
//  input_source.m
//  InputExc
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "action.h"
#import "action_list.h"


@implementation ActionSequence


- (id) init {

    if(self = [super init])
    {
        ary_action = CFArrayCreateMutable(kCFAllocatorDefault, 0, &kCFTypeArrayCallBacks);
    }

    return self;
}


- (void) append:(const Action *)action {

    CFArrayAppendValue(ary_action, (__bridge const void *)(action));
}


@end


@implementation InputSource

- (id) init {

    if(self = [super init])
    {
        dict_action_sequence = CFDictionaryCreateMutable(
                                                         kCFAllocatorDefault,
                                                         0,
                                                         &kCFTypeDictionaryKeyCallBacks,
                                                         &kCFTypeDictionaryValueCallBacks
                                                         );
    }
    
    return self;
}


- (ActionSequence *) sequnece_get:(SInt32)k_trig {

    ActionSequence* result;

    CFNumberRef ref_k = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &k_trig);
    result = CFDictionaryGetValue(dict_action_sequence, ref_k);
    CFRelease(ref_k);
    
    return result;
}


- (void) sequnece_set:(SInt32)k_trig value:(ActionSequence *)v_ref_sequence {
    
    CFNumberRef ref_k = CFNumberCreate(kCFAllocatorDefault, kCFNumberIntType, &k_trig);
    
    CFDictionarySetValue(dict_action_sequence, ref_k, (__bridge const void *)(v_ref_sequence));
    CFRelease(ref_k);
}


@end
