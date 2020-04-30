//
//  input_source.h
//  InputExc
//

#ifndef input_source_h
#define input_source_h


@interface
ActionSequence: NSObject
{
    E_ACTION_TYPE e_type;
    @public
    CFMutableArrayRef ary_action;
}

- (id) init;
- (void) append:(const Action *)action;
@end


@interface
InputSource: NSObject
{
    CFMutableDictionaryRef dict_action_sequence;
}

- (id) init;
- (ActionSequence *) sequnece_get:(SInt32)k_trig;
- (void) sequnece_set:(SInt32)k_trig value:(ActionSequence *)v_ref_sequence;
@end


#endif /* input_source_h */
