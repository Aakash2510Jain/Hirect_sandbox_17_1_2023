trigger UserTrackingTrigger on User_Tracking__c (after insert){
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('User_Tracking');
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        UserTrackingHelper handlerInstance = UserTrackingHelper.getInstance();
        system.debug('Inside User Traking Trigger');

        if (trigger.isAfter && trigger.isInsert){
            handlerInstance.afterinsert(trigger.newMap);
        }
    }
}