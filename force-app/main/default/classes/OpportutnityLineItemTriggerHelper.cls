public without sharing class OpportutnityLineItemTriggerHelper {
    static OpportutnityLineItemTriggerHelper handlerInstance;
    public static OpportutnityLineItemTriggerHelper getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new OpportutnityLineItemTriggerHelper();
        return handlerInstance;
    }
    
    public void submitOpportunityForApproval(Map<Id, OpportunityLineItem> oppLineItemMap){
        try{
            set<Id> OpportunityIds = new Set<Id>();
            List<ProcessInstance> recordUnderApproval = new List<ProcessInstance>();
            Map<Id ,Opportunity> opportunityByIdMap  = new Map<Id ,Opportunity>();
            
            
            if(!oppLineItemMap.isEmpty()) {
                for(OpportunityLineItem oppLineItemRec : oppLineItemMap.values()){
                    if(oppLineItemRec.Discount > 10)
                        OpportunityIds.add(oppLineItemRec.OpportunityId	);
                }
                if(!OpportunityIds.isEmpty()){
                    recordUnderApproval = [Select ID, Status,TargetObjectID, TargetObject.Name From ProcessInstance Where Status =: Constants.PENDING AND TargetObjectID In: OpportunityIds];
                    opportunityByIdMap = new Map<Id, Opportunity>([SELECT Id,OwnerId, Owner.ManagerId  FROM Opportunity  WHERE Id = : OpportunityIds]);
                }
                if(!recordUnderApproval.isEmpty()){
                    return;
                }
                if(!OpportunityIds.isEmpty()) {
                    for(Id oppID : OpportunityIds){
                        if(opportunityByIdMap.containsKey(oppID) != null) {
                            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                            approvalRequest.setComments('Submitting Opportunity for an approval as discount exceeded 10 %.');
                            approvalRequest.setObjectId(oppID);
                            // Submit on behalf of a specific submitter
                            approvalRequest.setSubmitterId(opportunityByIdMap.get(oppID).OwnerId);
                            // Submit the record to specific process and skip the criteria evaluation
                            approvalRequest.setProcessDefinitionNameOrId(Constants.OPPORTUNITY_APPROVAL_PROCESS);
                            approvalRequest.setSkipEntryCriteria(false);
                            system.debug('Initiate Opportunity Approval');
                            approvalRequest.setNextApproverIds(new List<Id>{ opportunityByIdMap.get(oppID).Owner.ManagerId }); 
                            // Submit the approval request for the account
                            Approval.ProcessResult result = Approval.process(approvalRequest);
                        }
                    }
                    
                } 
            }
        }catch(exception ex){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error>>><<'+ex.getLineNumber());
        }
    }
    
    public void updateRenewableDays(List<OpportunityLineItem> oppLineItemList){
        try{
            set<Id> oppIds = new Set<Id>();
            Map<String, integer> numberOfDaysByOppId = new Map<String, integer>();
            List<Opportunity> existingOpportunityList = new List<Opportunity>();
            List<Opportunity> existingOpportunityListToUpdate = new List<Opportunity>();
            
            if(!oppLineItemList.isEMpty()){
                for(OpportunityLineItem oppLineItemRec : oppLineItemList){
                    numberOfDaysByOppId.put(oppLineItemRec.OpportunityId, Integer.valueOf(oppLineItemRec.Duration_of_Subscription__c));
                }
                if(!numberOfDaysByOppId.isEmpty()){
                    existingOpportunityList = [Select Id, Renewable_Date__c,createdDate From Opportunity where Id in: numberOfDaysByOppId.keyset()];
                    if(!existingOpportunityList.isEmpty()){
                        for(Opportunity oppRec : existingOpportunityList){
                            Opportunity oppRecToUpdate = new Opportunity();
                            oppRecToUpdate.Id = oppRec.Id;
                            oppRecToUpdate.Renewable_Date__c = ((oppRec.createdDate).date()).addDays(Integer.ValueOf(numberOfDaysByOppId.get(oppRec.Id)));
                            existingOpportunityListToUpdate.add(oppRecToUpdate);
                        }
                        if(!existingOpportunityListToUpdate.isEmpty()){
                            update existingOpportunityListToUpdate;
                        }
                    }
                }
            }
            
        }catch(exception ex){
            system.debug('Errror-->'+ex.getMessage());
            system.debug('Errror-->'+ex.getCause());
            system.debug('Errror-->'+ex.getLineNumber());
        }
    }
}