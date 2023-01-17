trigger AccountTrigger on Account (before insert) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Account');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        AccountTriggerHelper handlerInstance = AccountTriggerHelper.getInstance();
        system.debug('Inside Account Trigger');
        
        if(trigger.isBefore && trigger.isInsert){
            handlerInstance.updateAccountOwnership(trigger.new);
        }
    }
}