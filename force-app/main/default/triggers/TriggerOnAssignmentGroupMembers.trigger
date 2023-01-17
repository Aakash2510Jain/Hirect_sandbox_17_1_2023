trigger TriggerOnAssignmentGroupMembers on Assignment_Group_Member__c (after insert, before Delete){

    SObject_Trigger_Control__c triggerConfig = SObject_Trigger_Control__c.getValues('AssignmentGroupMembers');
    if (triggerConfig != null && triggerConfig.Trigger_Status__c){
        if (trigger.isBefore && trigger.isDelete){
            AssignmentGroupMemberTriggerHelper.AssignmentGroupMemberDeletion(trigger.oldMap);
        }
         if (trigger.isAfter && trigger.isInsert){
            AssignmentGroupMemberTriggerHelper.AssignmentGroupMemberDeletion(trigger.newMap);
        }
    }
}