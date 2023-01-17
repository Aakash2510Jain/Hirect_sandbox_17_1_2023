trigger TriggerOnLead on Lead(before insert, before update, after insert, after update ){
    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('Lead');
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        LeadTriggerHandler handlerInstance = LeadTriggerHandler.getInstance();
        system.debug('Inside Lead Trigger');

        if (trigger.isInsert && trigger.isBefore){
            handlerInstance.assignInboundLeadToDefaultQueue(trigger.new );
            handlerInstance.updateUTMparams(trigger.new );
            //handlerInstance.DisqualifiedLead(trigger.new);
        }
        if (trigger.isUpdate && trigger.isBefore){
            //handlerInstance.assignInboundLeadToDefaultQueue(trigger.new );
            handlerInstance.addValidation(trigger.newMap, trigger.oldMap);
            //LeadAssignmentExecutionCriteria.validateEntryCriteria(trigger.new );
            handlerInstance.sendEmailForPayment(trigger.oldMap, trigger.newMap);
            handlerInstance.updateMappingFields(trigger.oldMap, trigger.newMap);
            handlerInstance.updateUTMparams(trigger.new );
            handlerInstance.createFollowUpTask(trigger.newMap, trigger.oldMap);
            handlerInstance.createTaskForOperations(trigger.newMap, trigger.oldMap);
            //handlerInstance.markOperationTaskClose(trigger.newMap, trigger.oldMap);
            handlerInstance.sendPaymentAfterApproval(trigger.newMap, trigger.oldMap);
            //handlerInstance.updateLeadStageAsOnboarded(trigger.newMap, trigger.oldMap);
            handlerInstance.updateleadStage(trigger.newMap, trigger.oldMap);
            handlerInstance.updateOwnerDetails(trigger.newMap, trigger.oldMap);
            handlerInstance.handleStageDependingUponSubStage(trigger.newMap, trigger.oldMap);
            handlerInstance.closeAllAssociatedOpsTask(trigger.newMap, trigger.oldMap);
            //handlerInstance.assignToRevenueHead(trigger.newMap, trigger.oldMap);
            handlerInstance.markOnboardingStamp(trigger.newMap, trigger.oldMap);
            handlerInstance.handleSalesBdandSalesOwner(trigger.newMap, trigger.oldMap);

            // keep it at end
            handlerInstance.handleOnboardedStag(trigger.newMap, trigger.oldMap);
        }
        if (trigger.isInsert && trigger.isafter){
          //LeadAssignmentExecutionCriteria.validateEntryCriteria(trigger.new );
          handlerInstance.triggerRRLogic(Trigger.New);
        }
        if (trigger.isUpdate && trigger.isAfter){
        }
    }
}