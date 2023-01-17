public without Sharing class LeadTriggerHandler{
    static LeadTriggerHandler handlerInstance;
    
    public static LeadTriggerHandler getInstance(){
        if ( handlerInstance == null )
            handlerInstance = new LeadTriggerHandler();
        return handlerInstance;
    }
    
    public void addValidation(Map<Id, lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        //Custom Sett
        Map<String, string> usernameByName = new Map<String, String>();
        
        List<LeadEditAccess__c> userDetails = [Select Name, username__c
                                               from LeadEditAccess__c];
        string currentUsername = [Select Id, UserName
                                  From User
                                  where Id = :UserInfo.getUserId()].username;
        if ( !userDetails.isEmpty() ){
            for ( LeadEditAccess__c usernameFromCustomSetting : userDetails ){
                usernameByName.put(usernameFromCustomSetting.username__c, usernameFromCustomSetting.Name);
            }
        }
        
        for ( Id leadId : newLeadMap.keyset() ){
            if ( !usernameByName.containsKey(currentUsername) && oldLeadMap.get(leadId).Lead_stage__c == 'Onboarded' 
                && newLeadMap.get(leadId).Sales_Stage__c == oldLeadMap.get(leadId).Sales_Stage__c && 
                newLeadMap.get(leadId).Sales_Sub_Stage__c == oldLeadMap.get(leadId).Sales_Sub_Stage__c &&
                newLeadMap.get(leadId).CommentA__c == oldLeadMap.get(leadId).CommentA__c &&
                newLeadMap.get(leadId).CommentB__c == oldLeadMap.get(leadId).CommentB__c &&
                newLeadMap.get(leadId).CommentC__c == oldLeadMap.get(leadId).CommentC__c &&
                newLeadMap.get(leadId).CommentD__c == oldLeadMap.get(leadId).CommentD__c &&
                newLeadMap.get(leadId).Comments_Notes__c == oldLeadMap.get(leadId).Comments_Notes__c &&
                newLeadMap.get(leadId).Feedback_Comments__c == oldLeadMap.get(leadId).Feedback_Comments__c &&
                newLeadMap.get(leadId).Followup_Comments__c == oldLeadMap.get(leadId).Followup_Comments__c
                
               ){
                   newLeadMap.get(leadId).addError('Lead Cannot Be editted');
                   
            }
        }
    }
    
    public void assignInboundLeadToDefaultQueue(list<lead> newLeadList){
        try{
            User userRec = [Select Id, Alias, ProfileId, Profile.Name
                            From user
                            where Id = :UserInfo.getUserId()];
            //Is_Manually_Created__c
            String queueId = [SELECT Id, Type
                              FROM Group
                              WHERE Type = 'Queue' AND Name = :Constants.PRIVATE_LEAD_QUEUE
                              limit 1].Id;
            
            String appIndiaRegQueueId = [SELECT Id, Type
                                         FROM Group
                                         WHERE Type = 'Queue' AND Name = :Constants.PUBLIC_LEAD_QUEUE
                                         limit 1].Id;
            
            for ( Lead ld : newLeadList ){
                If ( ld.Phone != null ){
                    ld.Phone = ld.Phone.deleteWhitespace();
                    ld.Phone = ld.Phone.replaceAll('[()\\s-]+', '');
                    ld.phone = ld.phone.removeStart('+');
                }
                system.debug('ld-->' + ld);
                // lead pushed from backkend
                system.debug('');
                if ( userRec.Alias == Constants.INTEGRATION_USER_ALIAS ){
                    system.debug('ld.Enter_URL__c::' + ld.Enter_URL__c);
                    if ( ld.LeadSource == Constants.LEAD_SOURCE_APP_INDIA || ld.LeadSource == 'Webapp' ){
                        ld.ownerId = appIndiaRegQueueId;
                    }
                    else if ( ld.Enter_URL__c != null && ld.Enter_URL__c.containsIgnoreCase('utm_source') ){
                        string urlValue = string.valueOf(ld.Enter_URL__c);
                        System.PageReference pageReference = new System.PageReference( '/' + urlValue );
                        Map<String, String> parameters = pageReference.getParameters();
                        system.debug('test::' + parameters.get('ref_id'));
                        if ( parameters.get('ref_id') == null ){
                            system.debug('Inside Ref Id Loop calling round robin for lead assignment');
                            ld.ownerId = queueId;
                        }
                        else{
                            ld.ownerId = parameters.get('ref_id');
                            system.debug('Inside Ref Id else Loop');
                            ld.BD__c = parameters.get('ref_id');
                        }
                        system.debug('parameters.get()-->' + parameters.get('ref_id'));
                        if ( ld.Enter_URL__c != null ){
                            if ( ld.Enter_URL__c.containsIgnoreCase('hirect_oofl') ){
                                system.debug('Offline');
                                ld.LeadSource = 'Offline Outreach';
                                ld.Don_t_Change_Source__c = true;
                            }
                            else if ( ld.Enter_URL__c.containsIgnoreCase('hirect_oonl') ){
                                system.debug('Online');
                                ld.LeadSource = 'LinkedIn Request (India)';
                                ld.Don_t_Change_Source__c = true;
                            }
                        }
                    }
                    else{
                        system.debug('Callling lead assignment Criterian');
                        ld.ownerId = queueId;
                    }
                }
                else{
                    
                    ld.Phone = '91'+ld.Phone.right(10);
                    // ld.Lead_Assigned_Date__c = System.today();
                    //Time myTime = Time.newInstance(System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
                    //ld.Lead_Assigned_Time__c = Time.newInstance(System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
                    
                    System.debug('ld assigned date time  =====> ' + ld.Lead_Assigned_Time__c);
                    //ld.New_Lead_Assigned_Date_Time__c = System.now();
                }
                /* else{
if (userRec.Profile.Name.containsIgnoreCase(Constants.ONLINE)){
ld.LeadSource = Constants.LEAD_SOURCE_LINKEDIN;
ld.Don_t_Change_Source__c = true;
} else if (userRec.Profile.Name.containsIgnoreCase(Constants.OFFLINE)){
ld.LeadSource = Constants.LEAD_SOURCE_OFFLINE_OUTREACH;
ld.Don_t_Change_Source__c = true;
}
}*/
                
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public void triggerRRLogic(List<Lead> newLeadList){
        try{
            List<Lead> leadListToBeAssigned = new List<Lead>();
            
            String queueId = [SELECT Id, Type
                              FROM Group
                              WHERE Type = 'Queue' AND Name = :Constants.PRIVATE_LEAD_QUEUE
                              limit 1].Id;
            leadListToBeAssigned = [SELECT Address,City,Company,Country,CreatedById,CreatedDate,
                                    Email,FirstName,
                                    GeocodeAccuracy,Id,Industry,
                                    IsConverted,IsDeleted,IsUnreadByOwner,LastActivityDate,LastModifiedById,LastModifiedDate,LastName,LastReferencedDate,
                                    LastViewedDate,Latitude,LeadSource,MasterRecordId,
                                    MiddleName,MobilePhone,Name,Next_Followup_Date_Time__c,NumberOfEmployees,OwnerId,Phone,
                                    PhotoUrl,PostalCode,Rating,Salutation,
                                    State,Status,Street,Suffix,Is_US_no__c,RegistrationProgress__c,SystemModstamp,Title,Homepage_Visited_Time__c,Website FROM Lead where OwnerId =:queueId And LeadSource != null limit 1000];
            if(!leadListToBeAssigned.isEmpty()){
                System.enqueueJob(new AsyncLeadAssignmentExecutionCriteria(leadListToBeAssigned));
            }
            /*if ( !newLeadList.isEmpty() ){
for ( Lead leadRec : newLeadList ){
if ( leadRec.OwnerId == queueId ){
                        leadListToBeAssigned.add(leadRec);
                    }
                }
                if ( !leadListToBeAssigned.isEmpty() ){
                    System.enqueueJob(new AsyncLeadAssignmentExecutionCriteria(leadListToBeAssigned));
                }
            }*/
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public void sendEmailForPayment(Map<Id, Lead> oldLeadMap, Map<Id, Lead> newLeadMap){
        try{
            set<Id> paymentSuccessId = new Set<Id>();
            Set<id> paymentFailureId = new Set<Id>();
            set<id> verifiedLeadIds = new Set<Id>();
            
            for ( Lead leadRec : newLeadMap.values() ){
                if ( leadRec.Payment_Captured__c != oldLeadMap.get(leadRec.id).Payment_Captured__c && leadRec.Payment_Captured__c == Constants.PAYMENT_SUCCESS ){
                    paymentSuccessId.add(leadRec.Id);
                }
                if ( leadRec.Payment_Captured__c != oldLeadMap.get(leadRec.id).Payment_Captured__c && leadRec.Payment_Captured__c == Constants.PAYMENT_FAILED ){
                    paymentFailureId.add(leadRec.Id);
                }
                //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2
                /*if(leadRec.Lead_Stage__c != oldLeadMap.get(leadRec.id).Lead_Stage__c && oldLeadMap.get(leadRec.id).Lead_Stage__c == 'Verified'){
                    verifiedLeadIds.add(leadRec.Id);
                }*/
            }
            if ( !paymentSuccessId.isEmpty() ){
                //EmailIUtility.sendEmailForPaymentStatus(paymentSuccessId, Constants.RAZOR_PAY_SUCCESS_EMAIL_LEAD, Constants.LEAD);
            }
            if ( !paymentFailureId.isEmpty() ){
                EmailIUtility.sendEmailForFailureStatus(paymentFailureId, Constants.RAZOR_PAY_FAILURE_EMAIL_LEAD, Constants.LEAD);
            }
            //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2
            /*
            if(!verifiedLeadIds.isEmpty()){
                EmailIUtility.sendEmailNotificationForVerifiedLead('Email After Verification',verifiedLeadIds);

            }*/
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public void updateMappingFields(Map<Id, Lead> oldLeadMap, Map<Id, Lead> newLeadMap){
        try{
            List<Account> accountListToBeUpdated = new List<Account>();
            for ( Lead leadRec : newLeadMap.values() ){
                if ( leadRec.IsConverted == true && oldLeadMap.get(leadRec.Id).IsConverted == false ){
                    String accountId = leadRec.convertedAccountId;
                    Account updateEmailOnAccount = new Account();
                    updateEmailOnAccount.Id = accountId;
                    updateEmailOnAccount.Email__c = leadRec.Email;
                    accountListToBeUpdated.add(updateEmailOnAccount);
                }
            }
            if ( !accountListToBeUpdated.isEmpty() ){
                update accountListToBeUpdated;
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void convertLeadAfterPayment(string leadId, Map<String, Object> paymentResponse){
        try{
            Map<String, string> priceBookIdByProductId = new Map<String, String>();
            if ( paymentResponse.get('captured') == true ){
                //covert lead
                LeadStatus convertStatus = [SELECT Id, MasterLabel
                                            FROM LeadStatus
                                            WHERE IsConverted = true
                                            LIMIT 1];
                Database.LeadConvert convert = new Database.LeadConvert(  );
                convert.setConvertedStatus(convertStatus.MasterLabel);
                convert.setLeadId(leadId);
                Database.LeadConvertResult convertedLead = Database.convertLead(convert);
                if ( convertedLead.isSuccess() ){
                    //invoice tag
                    //opp item tag
                    //opportunity to be updated
                    Lead convertedLeadRec = [Select Id, Payment_initiated_Date_Time__c, Discount__c, Quantity__c, Product__c, Amount__c, Payment_Captured__c, Payment_Status__c
                                             From Lead
                                             Where Id = :convertedLead.getLeadId()];
                    Account covertedAccRec = [Select Id, (Select Id
                                                          From Opportunities)
                                              From Account
                                              where id = :convertedLead.getAccountId()];
                    //Opportunity opportunityRec = [Select Id From Opportunity where id =: ]
                    Invoice__c invoiceRecTaggedWithLead = [Select Id, Opportunity__c, Status__c
                                                           from Invoice__c
                                                           Where Lead__c = :convertedLeadRec.Id
                                                           order by createdDate Desc
                                                           limit 1];
                    List<PricebookEntry> priceBookEntryList = [Select Id, Product2Id
                                                               From PricebookEntry
                                                               where Product2Id = :convertedLeadRec.Product__c];
                    for ( PricebookEntry pbe : priceBookEntryList ){
                        priceBookIdByProductId.put(pbe.Product2Id, pbe.Id);
                    }
                    
                    Opportunity oppRec = new Opportunity();
                    oppRec.Id = covertedAccRec.Opportunities[0].Id;
                    oppRec.StageName = Constants.OPPORTUNITY_CLOSED_WON;
                    update oppRec;
                    
                    OpportunityLineItem oppProdRec = new OpportunityLineItem();
                    oppProdRec.Discount = convertedLeadRec.Discount__c;
                    oppProdRec.OpportunityId = covertedAccRec.Opportunities[0].Id;
                    oppProdRec.Product2Id = convertedLeadRec.Product__c;
                    oppProdRec.Quantity = convertedLeadRec.Quantity__c;
                    oppProdRec.TotalPrice = convertedLeadRec.Amount__c;
                    oppProdRec.PricebookEntryId = priceBookIdByProductId.get(convertedLeadRec.Product__c);
                    insert oppProdRec;
                    
                    invoiceRecTaggedWithLead.Opportunity__c = covertedAccRec.Opportunities[0].Id;
                    invoiceRecTaggedWithLead.Status__c = Constants.INVOICE_STATUS_REALIZED;
                    update invoiceRecTaggedWithLead;
                }
            }
            else{
                //update status as failed
                Lead leadRec = new Lead(  );
                leadRec.Id = leadId;
                leadRec.Payment_Status__c = Constants.LEAD_PAYMENT_STATUS_NOT_REALISED;
                leadRec.Payment_Captured__c = Constants.LEAD_PAYMENT_CAPTURED_FAILED;
                update leadRec;
                
                List<Invoice__c> invoiceList = [Select Id, Status__c, Opportunity__c
                                                From Invoice__c
                                                where Lead__c = :leadId
                                                order by CreatedDate DESC
                                                limit 1];
                invoiceList[0].Status__c = Constants.LEAD_PAYMENT_STATUS_NOT_REALISED;
                update invoiceList;
                
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public void updateUTMparams(List<Lead> leadList){
        try{
            if ( !leadList.isEmpty() ){
                for ( Lead leadRec : leadList ){
                    if ( leadRec.Homepage_Visited_Time__c != null ){
                        leadRec.Lead_Stage__C = 'Onboarded';
                    }
                    if ( leadRec.Enter_URL__c != null ){
                        if ( ( leadRec.Enter_URL__c ).containsIgnoreCase('utm') ){
                            string urlValue = string.valueOf(leadRec.Enter_URL__c);
                            /*'https://www.hirect.in/connect/?
utm_source=google&
utm_medium=cpc&
utm_device=c&
utm_adposition&
utm_campaign=17364989494&
adgroupid=139776406920&
adid=600991241976&
keywordid=kwd-1287298268520&
network=g&
feeditemid&
gclid=CjwKCAjwk_WVBhBZEiwAUHQCmc3WpJgRlEpxFg5lbdDGbZxfAwJrbk9B19EcDoB3CU996aiv3P-gWBoC21IQAvD_BwE';
*/
                            System.PageReference pageReference = new System.PageReference( '/' + urlValue );
                            Map<String, String> parameters = pageReference.getParameters();
                            
                            leadRec.GCL_Id__c = parameters.get('gclid');
                            leadRec.UTM_Source__c = parameters.get('utm_source');
                            leadRec.UTM_Medium__c = parameters.get('utm_medium');
                            leadRec.UTM_Device__c = parameters.get('utm_device');
                            leadRec.UTM_Ad_Position__c = parameters.get('utm_adposition');
                            leadRec.UTM_Campaign__c = parameters.get('utm_campaign');
                            leadRec.Ad_Group_Id__c = parameters.get('adgroupid');
                            leadRec.Ad_id__c = parameters.get('adid');
                            leadRec.Key_Word_Id__c = parameters.get('keywordid');
                            leadRec.Network__c = parameters.get('network');
                            leadRec.Feed_Item_Id__c = parameters.get('feeditemid');
                        }
                    }
                }
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public void createFollowUpTask(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            set<Id> leadIds = new set<Id>();
            List<Task> followUpTasks = new List<Task>();
            List<Task> insertFollowupTask = new List<Task>();
            
            // ================ instances for notifications ===================================
            set<Id> leadIdsTonotify = new set<Id>();
            set<String> RecipientIds = new set<String>();
            Map<Id, Lead> leadByIdMap = new Map<Id, Lead>();
            
            
            User userRec = [Select Id, Alias, ProfileId, Profile.Name
                            From user
                            where Id = :UserInfo.getUserId()];
            
            
            for ( Lead leadRec : newLeadMap.values() ){
                if ( leadRec.Next_Followup_Date_Time__c != null && leadRec.Next_Followup_Date_Time__c != oldLeadMap.get(leadRec.Id).Next_Followup_Date_Time__c ){
                    leadIds.add(leadRec.Id);
                }
                if(leadRec.Comments_Notes__c != null &&  leadRec.Comments_Notes__c !=  oldLeadMap.get(leadRec.Id).Comments_Notes__c &&  leadRec.OwnerId != userRec.Id){
                    leadIdsTonotify.add(leadRec.Id);
                    
                }
            }
            if ( !leadIds.isEmpty() ){
                followUpTasks = [Select Id, Status
                                 From Task
                                 Where whoID in:leadIds];
                if ( !followUpTasks.isEmpty() ){
                    for ( Task taskRec : followUpTasks ){
                        taskRec.status = Constants.TASK_STATUS_COMPLETED;
                    }
                    update followUpTasks;
                }
                for ( Id leadId : leadIds ){
                    Task taskRec = new Task();
                    taskRec.whoid = leadId;
                    taskRec.ActivityDate = Date.valueOf(newLeadMap.get(leadId).Next_Followup_Date_Time__c);
                    taskRec.Status = Constants.TASK_STATUS_OPEN;
                    taskRec.Subject = Constants.FOLLOW_UP_CLIENT;
                    taskRec.Priority = Constants.TASK_STATUS_MEDIUM;
                    insertFollowupTask.add(taskRec);
                }
                if ( !insertFollowupTask.isEmpty() ){
                    insert insertFollowupTask;
                }
            }
            
            // ===================================== For Sending notification on change of Comments/ notes by opps ===============================
            
            if(!leadIdsTonotify.isEmpty()){
                List<Lead> Leadlist = [Select Id, FirstName, LastName, ownerId from Lead Where Id IN: leadIdsTonotify];
                if(!Leadlist.isEmpty()){
                    for(lead Ld : Leadlist){
                        RecipientIds.add(Ld.OwnerId);
                        leadByIdMap.put(ld.id, ld);
                    }
                }
                
                if(!RecipientIds.isEmpty() && !leadByIdMap.isEmpty()){
                    //CustomNotification.notifyUsers(RecipientIds, leadByIdMap);
                }
            }
            
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public void createTaskForOperations(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            User userRec = [Select Id
                            From User
                            where userRole.Name = 'Operations'];
            List<Task> taskListToBeInserted = new List<task>();
            
            for ( Lead leadRec : newLeadMap.values() ){
                if ( leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == system.label.OpsTaskCreationStatus ){
                    Task taskrec = new Task();
                    taskrec.whoid = leadRec.id;
                    taskRec.ownerId = userRec.Id;
                    taskRec.ActivityDate = system.today();
                    taskRec.Priority = Constants.TASK_STATUS_MEDIUM;
                    taskRec.Status = Constants.TASK_STATUS_OPEN;
                    taskRec.Subject = Constants.VERIFY_DOCUMENT_UPLOADED;
                    taskRec.Phone__c = leadRec.Phone;
                    taskListToBeInserted.add(taskRec);
                }
            }
            if ( !taskListToBeInserted.isEmpty() ){
                insert taskListToBeInserted;
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    @InvocableMethod(label = 'Assign Leads if NOt Onboarded'description = ''category = 'Lead')
    public static void assignNotBoardedLeads(List<ID> ids){
        try{
            List<Lead> leadListForRoundRobinAssignment = new List<Lead>();
            List<Lead> leadListForDummyUser = new List<Lead>();
            List<Lead> leadsListToBeUpdated = new List<Lead>();
            
            User dummyUserRec = [Select Id
                                 From User
                                 Where Username Like '%Dummy%'];
            
            if ( !ids.isEmpty() ){
                leadListForRoundRobinAssignment = [Select Id, OwnerId
                                                   From Lead
                                                   Where Id in:ids AND ( Audit_Status__c = :Constants.Audit_Status_Document_Uploaded OR Audit_Status__c = :Constants.Audit_Status_Rejected )];
                leadListForDummyUser = [Select Id, OwnerId
                                        From Lead
                                        Where Id in:ids AND ( Audit_Status__c = :Constants.Audit_Status_Accepted )];
                if ( !leadListForRoundRobinAssignment.isEMpty() ){
                    //passs to roundrobin method
                    
                }
                if ( !leadListForDummyUser.isEmpty() ){
                    for ( Lead leadRec : leadListForDummyUser ){
                        Lead leadRecToBeUpdated = new Lead(  );
                        leadRecToBeUpdated.ID = leadRec.Id;
                        leadRecToBeUpdated.OwnerId = dummyUserRec.Id;
                        leadsListToBeUpdated.add(leadRecToBeUpdated);
                    }
                    if ( !leadsListToBeUpdated.isEmpty() ){
                        update leadsListToBeUpdated;
                    }
                }
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    public static void tagLeadInvoiceToOpp(String OppId, invoice__c inv){
        try{
            if ( OppId != Null && inv != null ){
                inv.Opportunity__c = OppId;
                inv.Status__c = Constants.INVOICE_STATUS_REALIZED;
                inv.Subscription_Start_Date_Time__c = system.now();
                Update inv;
            }
        }
        catch ( Exception e ){
            System.debug('An exception occurred: ' + e.getMessage() + 'at line Number :: ' + e.getLineNumber());
        }
    }
    
    /*public void markOperationTaskClose(Map<id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
try{
List<Task> operationsTask = new List<Task>();
set<id> leadIds = new Set<Id>();

for ( Lead leadRec : newLeadMap.values() ){
if ( leadRec.Lead_Stage__c != null && leadRec.Lead_Stage__c != oldLeadMap.get(leadRec.Id).Lead_Stage__c && ( leadRec.Lead_Stage__c == 'Not Verified' || leadRec.Lead_Stage__c == 'Verified' ) ){
leadIds.add(leadRec.Id);
}
}
if ( !leadIds.isEmpty() ){
operationsTask = [Select Id, Status
From Task
where whoid in:leadIds AND Subject = 'Verify Documents Uploaded'];
if ( !operationsTask.isEmpty() ){
for ( Task taskRec : operationsTask ){
taskRec.Status = Constants.TASK_STATUS_COMPLETED;
}
update operationsTask;
}
}
}
catch ( exception ex ){
system.debug('Error==>' + ex.getMessage());
system.debug('Error==>@@' + ex.getLineNumber());
}
}*/
    
    public void submitLeadForDiscountApproval(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            set<Id> leadIds = new Set<Id>();
            List<ProcessInstance> recordUnderApproval = new List<ProcessInstance>();
            Map<Id, Lead> leadByIdMap = new Map<Id, Lead>();
            
            if ( !newLeadMap.isEmpty() ){
                for ( Lead leadRec : newLeadMap.values() ){
                    system.debug('leadRec.Discount-->' + leadRec.Discount__c);
                    if ( leadRec.Under_Approval__c == false ){
                        if ( leadRec.Discount_Threshold__c != null && leadRec.Discount_Threshold__c != oldLeadMap.get(leadRec.Id).Discount_Threshold__c ){
                            leadIds.add(leadRec.Id);
                            leadRec.Under_Approval__c = true;
                        }
                    }
                }
                system.debug('leadIds-->' + leadIds);
                if ( !leadIds.isEmpty() ){
                    recordUnderApproval = [Select ID, Status, TargetObjectID, TargetObject.Name
                                           From ProcessInstance
                                           Where Status = :Constants.PENDING AND TargetObjectID In:leadIds];
                    leadByIdMap = new Map<Id, LEad>([SELECT Id, OwnerId
                                                     FROM Lead
                                                     WHERE Id = :leadIds]);
                }
                system.debug('recordUnderApproval-->' + recordUnderApproval);
                system.debug('leadByIdMap-->' + leadByIdMap);
                if ( !recordUnderApproval.isEmpty() ){
                    return;
                }
                if ( !leadIds.isEmpty() ){
                    for ( Id leadId : leadIds ){
                        if ( leadByIdMap.containsKey(leadId) != null ){
                            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest(  );
                            approvalRequest.setComments('Submitting Lead for an approval as discount is provided.');
                            approvalRequest.setObjectId(leadId);
                            // Submit on behalf of a specific submitter
                            approvalRequest.setSubmitterId(leadByIdMap.get(leadId).OwnerId);
                            // Submit the record to specific process and skip the criteria evaluation
                            approvalRequest.setProcessDefinitionNameOrId(Constants.LEAD_APPROVAL_PROCESS);
                            approvalRequest.setSkipEntryCriteria(false);
                            system.debug('Initiate Lead  Approval');
                            // approvalRequest.setNextApproverIds(new List<Id>{ leadByIdMap.get(leadId).Owner.ManagerId });
                            // Submit the approval request for the account
                            Approval.ProcessResult result = Approval.process( approvalRequest );
                        }
                    }
                    
                }
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error>>><<' + ex.getLineNumber());
        }
    }
    
    public void sendPaymentAfterApproval(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        set<Id> leadIds = new Set<Id>();
        system.debug('Inside Approval');
        for ( Lead leadRec : newLeadMap.values() ){
            if ( leadRec.Approval_Status__c != oldLeadMap.get(leadRec.Id).Approval_Status__c && leadRec.Approval_Status__c == Constants.LEAD_APPROVED ){
                leadIds.add(leadRec.ID);
            }
        }
        if ( !leadIds.isEmpty() ){
            for ( Id leadId : leadIds ){
                RazorpayPaymentHandler.createInvoiceRec(leadId);
                RazorpayPaymentHandler.sendPaymentLink(leadId);
            }
        }
    }
    
    /*public void 
* (Map<Id, Lead> leadNewMap, Map<Id, Lead> oldLeadMap){
try{
for (Lead leadRec : leadNewMap.values()){
//Document Uploaded Stage
if (leadRec.Onboarding_Stages__c != null && leadRec.Onboarding_Stages__c != oldLeadMap.get(leadRec.Id).Onboarding_Stages__c && leadRec.Onboarding_Stages__c == Constants.Onboarding_Stage_Document_uploaded && (oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'Open' || oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'New')){
leadRec.Lead_Stage__c = Constants.Lead_Stage_Document_Uploaded;
}
//New Lead
if (leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == Constants.RegistrationProgress_Filled_up_Lead_form){
leadRec.Lead_Stage__c = Constants.Lead_Stage_New;
}
//Open Lead
if (leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == Constants.RegistrationProgress_VERIFIED_PHONE_NUMBER && (oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'New')){
leadRec.Lead_Stage__c = Constants.Lead_Stage_OPEN;
}
//Follow up Lead
if (leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && (leadRec.RegistrationProgress__c == Constants.RegistrationProgress_POSTED_JOB || leadRec.RegistrationProgress__c == Constants.RegistrationProgress_CREATED_RECRUITER_CARD) && (oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'Open' || oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'New')){
leadRec.Lead_Stage__c = Constants.Lead_Stage_FOLLOWUP;
}
//Audit in Progress
if (leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && (leadRec.RegistrationProgress__c == Constants.RegistrationProgress_Audit_Checking || leadRec.RegistrationProgress__c == Constants.RegistrationProgress_AUDITED_HOLD) && (oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'Open' || oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'New' || oldLeadMap.get(leadRec.Id).Lead_Stage__c == Constants.Lead_Stage_FOLLOWUP)){
leadRec.Lead_Stage__c = Constants.Lead_Stage_Audit_In_Progress;
}
//Audit Rejected
if (leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == Constants.RegistrationProgress_Audited_Rejected && (oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'Open' || oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'New' || oldLeadMap.get(leadRec.Id).Lead_Stage__c == Constants.Lead_Stage_FOLLOWUP || oldLeadMap.get(leadRec.Id).Lead_Stage__c == Constants.Lead_Stage_Audit_In_Progress)){
leadRec.Lead_Stage__c = Constants.Lead_Stage_Not_Verified;
}
//Not Verified
if (leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == Constants.RegistrationProgress_Audit_Rejected && (oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'Open' || oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'New' || oldLeadMap.get(leadRec.Id).Lead_Stage__c == Constants.Lead_Stage_FOLLOWUP || oldLeadMap.get(leadRec.Id).Lead_Stage__c == Constants.Lead_Stage_Audit_In_Progress)){
leadRec.Lead_Stage__c = Constants.Lead_Stage_Not_Verified;
}
//Verified / Onboarded
if (leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && (leadRec.RegistrationProgress__c == Constants.RegistrationProgress_Audited_Verified || leadRec.RegistrationProgress__c == Constants.RegistrationProgress_COMPLETED_ALL_REGISTRATION_STEPS) && (oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'Open' || oldLeadMap.get(leadRec.Id).Lead_Stage__c == 'New' || oldLeadMap.get(leadRec.Id).Lead_Stage__c == Constants.Lead_Stage_FOLLOWUP || oldLeadMap.get(leadRec.Id).Lead_Stage__c == Constants.Lead_Stage_Audit_In_Progress || oldLeadMap.get(leadRec.Id).Lead_Stage__c == Constants.Lead_Stage_AUDIT_REJECTED)){
leadRec.Lead_Stage__c = Constants.Lead_Stage_Verified;
}
//Payment Initiated
if (leadRec.Payment_Status__c != null && leadRec.Payment_Status__c != oldLeadMap.get(leadRec.Id).Payment_Status__c && leadRec.Payment_Status__c == Constants.Payment_Status_Initiated && (oldLeadMap.get(leadRec.Id).Lead_Stage__c != 'Disqualified' || oldLeadMap.get(leadRec.Id).Lead_Stage__c != 'Nurturing')){
leadRec.Lead_Stage__c = Constants.Lead_Stage_Payment_Initiated;
}
}
} catch (exception ex){
system.debug('Error==>' + ex.getMessage());
system.debug('Error==>@@' + ex.getLineNumber());
}
}*/
    public void updateleadStage(Map<Id, Lead> mewLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            
            for ( Lead leadRec : mewLeadMap.values() ){
                //Payment Initiated
                if ( leadRec.Payment_Status__c != null && leadRec.Payment_Status__c != oldLeadMap.get(leadRec.Id).Payment_Status__c && leadRec.Payment_Status__c == Constants.Payment_Status_Initiated && ( oldLeadMap.get(leadRec.Id).Lead_Stage__c != 'Disqualified' || oldLeadMap.get(leadRec.Id).Lead_Stage__c != 'Nurturing' ) ){
                    leadRec.Lead_Stage__c = Constants.Lead_Stage_Payment_Initiated;
                }
                if ( leadRec.Homepage_Visited_Time__c != null && leadRec.Homepage_Visited_Time__c != oldLeadMap.get(leadRec.Id).Homepage_Visited_Time__c ){
                    leadRec.Lead_Stage__C = 'Onboarded';
                }
                if ( leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == 'Upload documents' ){
                    leadRec.Lead_Stage__C = 'Document Uploaded';
                }
                if ( leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == 'Audited Rejected' ){
                    leadRec.Lead_Stage__C = 'Not Verified';
                }
                if ( ( leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == 'Audited Verified' ) || ( leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == 'Completed all registration steps' ) ){
                    leadRec.Lead_Stage__C = 'Verified';
                }
                if ( leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == 'Posted Job' ){
                    leadRec.Lead_Stage__C = 'Followup';
                    leadRec.Lead_Substage__c = 'OIP';
                }
                if ( leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == 'Created recruiter card' ){
                    leadRec.Lead_Stage__C = 'Followup';
                    leadRec.Lead_Substage__c = 'Call Back';
                }
                if ( leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == 'Verified Phone Number' ){
                    leadRec.Lead_Stage__C = 'Open';
                }
                if ( leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == 'Filled up leads form' ){
                    leadRec.Lead_Stage__C = 'New';
                }
                if ( ( leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == 'Audited Checking' ) || ( leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && leadRec.RegistrationProgress__c == 'Audited Hold' ) ){
                    leadRec.Lead_Stage__C = 'Audit in Progress';
                }
                if ( leadRec.Lead_Stage__C != oldLeadMap.get(leadRec.Id).Lead_Stage__C && oldLeadMap.get(leadRec.Id).Lead_Stage__C == 'Onboarded' ){
                    leadRec.Lead_Stage__C = 'Onboarded';
                }
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error>>><<' + ex.getLineNumber());
        }
    }
    
    public void updateOwnerDetails(Map<ID, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            //Is_Manually_Created__c
            String queueId = [SELECT Id, Type
                              FROM Group
                              WHERE Type = 'Queue' AND Name = :Constants.PRIVATE_LEAD_QUEUE
                              limit 1].Id;
            
            String appIndiaRegQueueId = [SELECT Id, Type
                                         FROM Group
                                         WHERE Type = 'Queue' AND Name = :Constants.PUBLIC_LEAD_QUEUE
                                         limit 1].Id;
            
            for ( Lead leadRec : newLeadMap.values() ){
                if ( leadRec.OwnerId != null && leadRec.OwnerId != oldLeadMap.get(leadRec.Id).OwnerId && ( oldLeadMap.get(leadRec.Id).OwnerId != queueId || oldLeadMap.get(leadRec.Id).OwnerId != appIndiaRegQueueId ) ){
                    leadRec.Owner_Change_Date_Time__c = system.now();
                }
                if ( leadRec.OwnerId != null && leadRec.OwnerId != oldLeadMap.get(leadRec.Id).OwnerId && ( oldLeadMap.get(leadRec.Id).OwnerId == queueId || oldLeadMap.get(leadRec.Id).OwnerId == appIndiaRegQueueId ) ){
                    leadRec.New_Lead_Assigned_Date_Time__c = system.now();
                }
                leadRec.Owner_Changed_By__c = UserInfo.getUserId();
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error>>><<' + ex.getLineNumber());
        }
    }
    
    public void handleStageDependingUponSubStage(Map<ID, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            //Not Paid
            //
            for ( Lead leadRec : newLeadMap.values() ){
                if ( leadRec.Lead_Substage__c != oldLeadMap.get(leadRec.Id).Lead_Substage__c ){
                    if ( leadRec.Lead_Substage__c == 'Disqualified' ){
                        leadRec.Lead_Stage__C = 'Disqualified';
                    }
                    if ( leadRec.Lead_Substage__c == 'Followup' ){
                        leadRec.Lead_Stage__C = 'Followup';
                    }
                    if ( leadRec.Lead_Substage__c == 'Not Interested' ){
                        leadRec.Lead_Stage__C = 'Not Interested';
                    }
                    if ( leadRec.Lead_Substage__c == 'NATC' ){
                        leadRec.Lead_Stage__C = 'NATC';
                    }
                    if ( leadRec.Lead_Substage__c == 'Link Shared' ){
                        leadRec.Lead_Stage__C = 'Payment Initiated';
                    }
                    if ( leadRec.Lead_Substage__c == 'Consultancy' ){
                        leadRec.Lead_Stage__C = 'Disqualified';
                    }
                    if ( leadRec.Lead_Substage__c == 'Job Seeker' ){
                        leadRec.Lead_Stage__C = 'Disqualified';
                    }
                    if ( leadRec.Lead_Substage__c == 'MLM' ){
                        leadRec.Lead_Stage__C = 'Disqualified';
                    }
                    if ( leadRec.Lead_Substage__c == 'Asking for Money' ){
                        leadRec.Lead_Stage__C = 'Disqualified';
                    }
                    if ( leadRec.Lead_Substage__c == 'Casual Browsing' ){
                        leadRec.Lead_Stage__C = 'Disqualified';
                    }
                    if ( leadRec.Lead_Substage__c == 'Document Incomplete' ){
                        leadRec.Lead_Stage__C = 'Followup';
                    }
                    if ( leadRec.Lead_Substage__c == 'Busy' ){
                        leadRec.Lead_Stage__C = 'Followup';
                    }
                    if ( leadRec.Lead_Substage__c == 'Call Back' ){
                        leadRec.Lead_Stage__C = 'Followup';
                    }
                    if ( leadRec.Lead_Substage__c == 'OIP' ){
                        leadRec.Lead_Stage__C = 'Followup';
                    }
                }
                
                if(leadRec.Sales_Stage__c != oldLeadMap.get(leadRec.Id).Sales_Stage__c && leadRec.Sales_Stage__c == 'Qualified'){
                    if(leadRec.Qualified__c == Null){
                        leadRec.Qualified__c = system.now();
                        system.debug('Qualified__c='+leadRec.Qualified__c);
                    }
                }
                if(leadRec.Sales_Sub_Stage__c!= oldLeadMap.get(leadRec.Id).Sales_Sub_Stage__c && leadRec.Sales_Sub_Stage__c == 'Q1' ){
                    if(leadRec.Q1__c == Null){
                        leadRec.Q1__c = system.now();
                        system.debug('Q1__c='+leadRec.Q1__c);
                    }
                }
                if(leadRec.Sales_Sub_Stage__c!= oldLeadMap.get(leadRec.Id).Sales_Sub_Stage__c && leadRec.Sales_Sub_Stage__c == 'Q2'){
                    if(leadRec.Q2__c == Null){
                        leadRec.Q2__c = system.now();
                        system.debug('Q2__c='+leadRec.Q2__c);
                    }
                }
                if(leadRec.Sales_Sub_Stage__c!= oldLeadMap.get(leadRec.Id).Sales_Sub_Stage__c && leadRec.Sales_Sub_Stage__c == 'Q3'){
                    if(leadRec.Q3__c == Null){
                        leadRec.Q3__c = system.now();
                        system.debug('Q3__c='+leadRec.Q3__c);
                    }
                } 
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error>>><<' + ex.getLineNumber());
        }
    }
    
    public void closeAllAssociatedOpsTask(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            system.debug('inside closing all open ops task');
            set<Id> leadIds = new Set<Id>();
            List<Task> taskListToBeClosed = new List<task>();
            
            for ( Lead leadRec : newLeadMap.values() ){
                if ( leadRec.RegistrationProgress__c != null && leadRec.RegistrationProgress__c != oldLeadMap.get(leadRec.Id).RegistrationProgress__c && oldLeadMap.get(leadRec.Id).RegistrationProgress__c == 'Uploaded documents' ){
                    leadIds.add(leadRec.Id);
                }
            }
            if ( !leadIds.isEmpty() ){
                taskListToBeClosed = [Select id, Status
                                      From Task
                                      Where WhoId In:leadIds AND Subject = :Constants.VERIFY_DOCUMENT_UPLOADED
                                      limit 49000];
                if ( !taskListToBeClosed.isEmpty() ){
                    for ( Task taskRec : taskListToBeClosed ){
                        taskRec.Status = 'Completed';
                    }
                    update taskListToBeClosed;
                }
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    
    // keep it at end
    
    
    public void DisqualifiedLead(List<Lead> newLeadList){
        
        try {
            String queueId = [SELECT Id, Type
                              FROM Group
                              WHERE Type = 'Queue' AND Name = :Constants.DISQUALIFIED_lEAD_QUEUE
                              limit 1].Id;
            
            List<Disqualified_Companies_and_Job_Title__c> DC_JTList = [Select Id, Company_Name__c, Job_Title__c
                                                                       From Disqualified_Companies_and_Job_Title__c];
            map<String, String> mapofDCAndJT = new map<String, String>();
            if ( !newLeadList.isEmpty() ){
                if ( !DC_JTList.isEmpty() ){
                    for ( Disqualified_Companies_and_Job_Title__c DC_JT : DC_JTList ){
                        if ( DC_JT.Company_Name__c != null ){
                            mapofDCAndJT.put(DC_JT.Company_Name__c, DC_JT.Company_Name__c);
                        }
                        if ( DC_JT.Job_Title__c != null ){
                            mapofDCAndJT.put(DC_JT.Job_Title__c, DC_JT.Job_Title__c);
                        }
                    }
                }
                
                if(!mapofDCAndJT.isEmpty()){
                    for(Lead manualLead : newLeadList){
                        if(mapofDCAndJT.containsKey(manualLead.Company) || mapofDCAndJT.containsKey(manualLead.Job_title__c )){
                            //manualLead.addError('Company/Job Title you have Enetered is one of the Disqualified One. Please Enter Different value');
                            manualLead.OwnerId = queueId;
                            
                        }
                    }
                    
                }
            }
        }
        catch (Exception e) {
        }
    }
    public void markOnboardingStamp(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            for ( Lead leadRec : newLeadMap.values() ){
                if ( leadRec.Lead_Stage__c != oldLeadMap.get(leadRec.Id).Lead_Stage__C && leadRec.Lead_Stage__C == 'Onboarded' ){
                    if(leadRec.owner_email__c != null)
                        leadRec.Onboarded_By__c = leadRec.OwnerId;
                    leadRec.Onboarded_Date_Time__c = system.now();
                }
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    public void assignToRevenueHead(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            set<Id> leadIds = new set<Id>();
            
            User userRec = [Select Id from User Where UserName = 'parth@hirect.in'];
            for ( Lead leadRec : newLeadMap.values() ){
                if ( leadRec.Lead_Stage__c != oldLeadMap.get(leadRec.Id).Lead_Stage__C && leadRec.Lead_Stage__C == 'Onboarded' &&(leadRec.LeadSource == 'LinkedIn request (India)' || leadRec.LeadSource == 'Offline outreach' )){
                    leadRec.Onboarded_By__c = leadRec.OwnerId;
                    leadRec.Revenue_BD__c = userRec.ID;
                    leadRec.OwnerId = userRec.ID;
                    leadRec.Revenue_Team_Member__c = userRec.ID;
                    leadRec.Onboarded_Date_Time__c = system.now();
                }
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    public void handleSalesBdandSalesOwner(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            set<Id> salesTeamMembersId = new Set<Id>();
            set<Id> leadIdsSet = new Set<Id>();
            List<LeadShare> leadShareList = new List<LeadShare> ();
            
            for ( Lead leadRec : newLeadMap.values()){
                if ( leadRec.Sales_BD__c != oldLeadMap.get(leadRec.Id).Sales_BD__c && leadRec.Sales_BD__c != null ){
                    salesTeamMembersId.add(oldLeadMap.get(leadRec.Id).Sales_BD__c);
                    leadIdsSet.add(leadRec.Id);
                    LeadShare ls = new LeadShare();
                    ls.leadId = leadRec.Id;
                    ls.leadAccessLevel = 'Edit';
                    ls.userOrGroupId = Id.valueOf(leadRec.Sales_BD__c);
                    leadShareList.add(ls);
                }
                if ( leadRec.Sales_Owner_V1__c != oldLeadMap.get(leadRec.Id).Sales_Owner_V1__c && leadRec.Sales_Owner_V1__c != null  ){
                    salesTeamMembersId.add(oldLeadMap.get(leadRec.Id).Sales_Owner_V1__c);
                    leadIdsSet.add(leadRec.Id);
                    LeadShare ls = new LeadShare();
                    ls.leadId = leadRec.Id;
                    ls.leadAccessLevel = 'Edit';
                    ls.userOrGroupId = Id.valueOf(leadRec.Sales_Owner_V1__c);
                    leadShareList.add(ls);
                }
            }
            if(!salesTeamMembersId.isEmpty() && !leadIdsSet.isEmpty()){
                delete[select id from LeadShare where userOrGroupId in : salesTeamMembersId And leadId in : leadIdsSet];
            }
            if(!leadShareList.isEmpty()){
                Database.SaveResult[] srList = Database.insert(leadShareList, false);
                //insert leadShareList;
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
    public void handleOnboardedStag(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){
        try{
            for ( Lead leadRec : newLeadMap.values() ){
                if ( leadRec.Lead_Stage__C != oldLeadMap.get(leadRec.Id).Lead_Stage__C && oldLeadMap.get(leadRec.Id).Lead_Stage__C == 'Onboarded' ){
                    leadRec.Lead_Stage__C = 'Onboarded';
                }
                if ( leadRec.Sales_Stage__c != oldLeadMap.get(leadRec.Id).Sales_Stage__c && oldLeadMap.get(leadRec.Id).Sales_Stage__c == 'Converted' ){
                    leadRec.Sales_Stage__c = 'Converted';
                }
                if(leadRec.Sales_Stage__c != oldLeadMap.get(leadRec.Id).Sales_Stage__c && oldLeadMap.get(leadRec.Id).Sales_Stage__c == 'Qualified' && leadRec.Sales_Stage__c != 'Converted'){
                    leadRec.Sales_Stage__c = 'Qualified';
                }
            }
        }
        catch ( exception ex ){
            system.debug('Error==>' + ex.getMessage());
            system.debug('Error==>@@' + ex.getLineNumber());
        }
    }
}