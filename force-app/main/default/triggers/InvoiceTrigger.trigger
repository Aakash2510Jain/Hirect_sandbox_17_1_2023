trigger InvoiceTrigger on Invoice__c (before update) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Invoice');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        InvoiceTriggerHelper handlerInstance = InvoiceTriggerHelper.getInstance();
        if(Trigger.isBefore && Trigger.isUpdate) {
            
            system.debug('Before insert Invoice');
            handlerInstance.paymentStatusUpdated(trigger.oldMap, trigger.newMap);
        }
    }
}