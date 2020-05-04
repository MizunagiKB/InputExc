//
//  test-IntpuAction-Keyboard.m
//  InputExcTests
//

#import <XCTest/XCTest.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>


@interface InputActionKeyboardTest: XCTestCase {}
@end


@implementation InputActionKeyboardTest
 

- (void) testKeyCodeToString {

    CGKeyCode kcode = StringToKeyCode(@"a");
    KeyCodeToString(kcode);
}


@end
