trigger Attachement_Trigger on Attachment (after insert) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Attachment');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        Attachement_Trigger_Helper handlerInstance = Attachement_Trigger_Helper.getInstance();
        
        if(Trigger.isinsert && Trigger.isafter){
            system.debug('Inside Attachment Trigger After Insert');
            handlerInstance.HandleAttachements(Trigger.new);
        }
    }
}