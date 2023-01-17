trigger TaskTrigger on Task (after insert, before insert) {
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Task');
    if(triggerConfig != null && triggerConfig.Trigger_Status__c) {
        TaskTriggerHelper handlerInstance = TaskTriggerHelper.getInstance();
        system.debug('Inside Task Trigger');
        
        if(Trigger.isAfter && trigger.isInsert){
            handlerInstance.updateLeadStageForCallActivity(trigger.newMap);
            handlerInstance.updateCallActivityOnLead(trigger.newMap);
            handlerInstance.runTaskAssignmentLogic(trigger.new);
            handlerInstance.updateCallDetailsOnLead(trigger.newMap);
        }
        if(trigger.isBefore && trigger.isInsert){
           handlerInstance.handleCallTime(trigger.new);
        }
    }
}