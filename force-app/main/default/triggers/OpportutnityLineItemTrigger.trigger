trigger OpportutnityLineItemTrigger on OpportunityLineItem (after insert, after update) {
     SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Opportunity Line Item');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        OpportutnityLineItemTriggerHelper handlerInstance = OpportutnityLineItemTriggerHelper.getInstance();
       
        if(Trigger.isAfter && (Trigger.isInsert|| Trigger.isUpdate)) {
            system.debug('After insert Opportunity Line Item');
            handlerInstance.submitOpportunityForApproval(trigger.newMap);
            handlerInstance.updateRenewableDays(trigger.new);
        }
    }
}