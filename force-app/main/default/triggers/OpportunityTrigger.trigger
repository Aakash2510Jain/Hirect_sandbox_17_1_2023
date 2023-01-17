trigger OpportunityTrigger on Opportunity (before Update, after insert) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Opportunity');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        OpportunityTriggerHelper handlerInstance = OpportunityTriggerHelper.getInstance();
        
        if(Trigger.isBefore && Trigger.isUpdate) {
            system.debug('Before Opportunity Update');
            handlerInstance.sendEmailNotificationOnPayment(Trigger.OldMap, Trigger.NewMap);
            handlerInstance.updateAccountOnOppChange(Trigger.OldMap, Trigger.NewMap);
        }
        if(Trigger.isafter && Trigger.isinsert){
            handlerInstance.AccountUpdateOnOppRenewal(Trigger.OldMap, Trigger.NewMap);
        }
    }
}