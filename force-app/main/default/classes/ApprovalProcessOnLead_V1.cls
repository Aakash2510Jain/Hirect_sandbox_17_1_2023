public without sharing class ApprovalProcessOnLead_V1 {
    //Shantanu  ->  Inbound HOD
    //pawan     ->  KAM HOD
    //Azaz      ->  RM HOD
    //Abhishek  ->  Outbound HOD
    @InvocableMethod(label = 'Submit Lead For Approval_v1'description = ''category = 'Lead')
    public static void submitLeadForDiscountApproval(List<Id> leadIds){
        system.debug('Inside Approval process for Lead');
        try{
            set<Id> leadIdSet = new Set<Id>();
            List<Lead> existingLeadsForApproval = new List<Lead>();
            List<User> usersList = new List<User>();
            List<String> approversEmail = new List<String>();
            List<ProcessInstance> recordUnderApproval = new List<ProcessInstance>();
            Map<Id, Lead> leadByIdMap = new Map<Id, Lead>();
            Map<String, String> usernameById = new Map<String, String>();
            
            List<ApproverForDiscountOnLead__c> approverList = ApproverForDiscountOnLead__c.getall().values();
			system.debug('approverList-->'+approverList);
            if(!approverList.isEmpty()){
                for(ApproverForDiscountOnLead__c approverRec : approverList){
                    approversEmail.add(approverRec.Email__c);
                }
                if(!approversEmail.isEmpty()){
                    usersList = [Select Id, Name From User Where Email in : approversEmail];
                    if (!usersList.isEmpty()){
                        for (User userRec : usersList){
                            system.debug('userRec.Name-->' + userRec.Name);
                            usernameById.put(userRec.Name, userRec.Id);
                        }
                    }
                }
                
            }
            existingLeadsForApproval = [SELECT Id, OwnerId, owner.ProfileId, NumberOfEmployees, Discount_Threshold__c
                                        FROM Lead
                                        WHERE Id in:leadIds];
            
            if (!existingLeadsForApproval.isEmpty()){
                for (Lead leadRec : existingLeadsForApproval){
                    if (leadRec.Discount_Threshold__c != null){
                        leadIdSet.add(leadRec.Id);
                    }
                }
                system.debug('leadIdSet-->' + leadIdSet);
                if (!leadIdSet.isEmpty()){
                    recordUnderApproval = [Select ID, Status, TargetObjectID, TargetObject.Name
                                           From ProcessInstance
                                           Where Status = :Constants.PENDING AND TargetObjectID In:leadIdSet];
                    leadByIdMap = new Map<Id, Lead>([SELECT Id, OwnerId, owner.ProfileId, owner.Profile.Name, NumberOfEmployees, Discount_Threshold__c
                                                     FROM Lead
                                                     WHERE Id in:leadIdSet]);
                }
                if (!recordUnderApproval.isEmpty()){
                    return;
                } else{
                    if (!leadIds.isEmpty()){
                        for (Id leadId : leadIds){
                            if (leadByIdMap.containsKey(leadId) != null){
                                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                                approvalRequest.setComments('Submitting Lead for an approval as discount is provided.');
                                approvalRequest.setObjectId(leadId);
                                // Submit on behalf of a specific submitter
                                approvalRequest.setSubmitterId(leadByIdMap.get(leadId).OwnerId);
                                // Submit the record to specific process and skip the criteria evaluation
                                approvalRequest.setProcessDefinitionNameOrId(Constants.LEAD_APPROVAL_PROCESS);
                                approvalRequest.setSkipEntryCriteria(false);
                                system.debug('Initiate Lead  Approval');
                                system.debug('leadByIdMap.get(leadId).Discount_Threshold__c-->' + leadByIdMap.get(leadId).Discount_Threshold__c);
                                system.debug('leadByIdMap.get(leadId).NumberOfEmployees-->'+leadByIdMap.get(leadId).NumberOfEmployees);
                                if (leadByIdMap.get(leadId).Discount_Threshold__c < 5 && (leadByIdMap.get(leadId).NumberOfEmployees < 100 || leadByIdMap.get(leadId).NumberOfEmployees == null) ){
                                    // to RM
                                    system.debug('Setting Approver Id-->>'+usernameById.get('Azaz'));
                                    approvalRequest.setNextApproverIds(new List<Id>{ usernameById.get('Azaz') });
                                } else if (leadByIdMap.get(leadId).Discount_Threshold__c < 5 && leadByIdMap.get(leadId).NumberOfEmployees > 100){
                                    // to KAM
                                    system.debug('Setting Approver Id-->>'+usernameById.get('pawan'));
                                    approvalRequest.setNextApproverIds(new List<Id>{ usernameById.get('pawan') });
                                } else if (leadByIdMap.get(leadId).Discount_Threshold__c > 5 && leadByIdMap.get(leadId).Discount_Threshold__c < 10){
                                    if ((leadByIdMap.get(leadId).owner.Profile.Name).containsIgnoreCase('Inbound')){
                                        // Inbound HOd
                                        system.debug('Setting Approver Id-->>'+usernameById.get('Shantanu'));
                                        approvalRequest.setNextApproverIds(new List<Id>{ usernameById.get('Shantanu') });
                                    } else if ((leadByIdMap.get(leadId).owner.Profile.Name).containsIgnoreCase('Outbound')){
                                        //outbound HOD
                                        system.debug('Setting Approver Id-->>'+usernameById.get('Abhishek'));
                                        approvalRequest.setNextApproverIds(new List<Id>{ usernameById.get('Abhishek') });
                                    }
                                } else if (leadByIdMap.get(leadId).Discount_Threshold__c > 10){
                                    system.debug('Setting Approver Id-->>'+usernameById.get('Raz'));
                                    approvalRequest.setNextApproverIds(new List<Id>{ usernameById.get('Raz') });
                                    
                                }
                                //approvalRequest.setNextApproverIds(new List<Id>{ leadByIdMap.get(leadId).OwnerId });
                                // Submit the approval request for the account
                                if(approvalRequest != null)
                                    Approval.ProcessResult result = Approval.process(approvalRequest);
                            }
                        }
                    }
                }
            }
        } catch (exception ex){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error>>><<' + ex.getLineNumber());
        }
    }
}