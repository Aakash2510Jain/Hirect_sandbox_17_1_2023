trigger UserTrigger on User (before update) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('User');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        UserTriggerHelper handlerInstance = UserTriggerHelper.getInstance();
        system.debug('Inside User Trigger');
        
        if(Trigger.isBefore && trigger.isUpdate){
            handlerInstance.handleLeaveDate(trigger.newMap, trigger.oldMap);
            handlerInstance.handleInactiveUser(trigger.newMap, trigger.oldMap);
        }
    }
}