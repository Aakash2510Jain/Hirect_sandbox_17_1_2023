public without sharing class OpportunityTriggerHelper {
    static OpportunityTriggerHelper handlerInstance;
    public static OpportunityTriggerHelper getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new OpportunityTriggerHelper();
        return handlerInstance;
    }
    public void sendEmailNotificationOnPayment(Map<Id,Opportunity> oldOpportunityMap, Map<Id,Opportunity> newOpportunityMap) {
        try{
            set<Id> paymentSuccessId = new Set<Id>();
            Set<id> paymentFailureId = new Set<Id>();
            
            for(Opportunity oppRec : newOpportunityMap.values()){
                if(oppRec.Payment_Captured__c != oldOpportunityMap.get(oppRec.id).Payment_Captured__c && oppRec.Payment_Captured__c == Constants.PAYMENT_SUCCESS){
                    paymentSuccessId.add(oppRec.Id);
                }     
                
                if(oppRec.Payment_Captured__c != oldOpportunityMap.get(oppRec.id).Payment_Captured__c && oppRec.Payment_Captured__c == Constants.PAYMENT_FAILED){
                    paymentFailureId.add(oppRec.Id);
                }          
            }
            if(!paymentSuccessId.isEmpty()){
                //EmailIUtility.sendEmailForPaymentStatus(paymentSuccessId, Constants.RAZOR_PAY_SUCCESS_EMAIL_OPPORTUNITY, Constants.OPPORTUNITY);
            }
            if(!paymentFailureId.isEmpty()){
                EmailIUtility.sendEmailForFailureStatus(paymentFailureId, Constants.RAZOR_PAY_FAILURE_EMAIL_OPPORTUNITY, Constants.OPPORTUNITY);
            }
        }catch(exception ex){
            system.debug('Errror-->'+ex.getMessage());
            system.debug('Errror-->'+ex.getCause());
            system.debug('Errror-->'+ex.getLineNumber());
        }
    }
    
    public void updateAccountOnOppChange(Map<Id,Opportunity> oldOpportunityMap, Map<Id,Opportunity> newOpportunityMap){
        try{
            List<Account> AccountListClosedWon = new List<Account>();
            List<Account> AccountListClosedLost = new List<Account>();
            List<Account> AccountListClosedWonToBeUpdated = new List<Account>();
            List<Account> AccountListClosedLostToBeUpdated = new List<Account>();
            set<Id> IdSetOfAccountClosedWon = new Set<Id>();
            set<Id> IdSetOfAccountClosedLost = new Set<Id>();
            
            if(!newOpportunityMap.isEmpty()){            
                for(opportunity opp : newOpportunityMap.values()){
                    if(opp.StageName != null && opp.StageName != oldOpportunityMap.get(opp.id).StageName && opp.StageName == 'Closed won'){
                        IdSetOfAccountClosedWon.add(opp.AccountId);
                    }
                    else if(opp.StageName != null && opp.StageName != oldOpportunityMap.get(opp.id).StageName && opp.StageName == 'Closed Lost'){
                        IdSetOfAccountClosedLost.add(opp.AccountId);
                    }
                }
                
                // ================ Closed Won opportunity Account Update ==========================
                if(!IdSetOfAccountClosedWon.isEmpty()){
                    AccountListClosedWon = [SELECT Id,Name,Status__c FROM Account where Id IN: IdSetOfAccountClosedWon];
                }
                if(!AccountListClosedWon.isEmpty()){
                    for(Account acc : AccountListClosedWon){
                        account newAcc = new Account();
                        newAcc.id = acc.id;
                        newAcc.Status__c = 'Active';
                        AccountListClosedWonToBeUpdated.add(newAcc);
                    }
                }
                if(!AccountListClosedWonToBeUpdated.isEmpty()){
                    update AccountListClosedWonToBeUpdated;
                }
                
                // ================ Closed Lost opportunity Account Update ==========================
                if(!IdSetOfAccountClosedLost.isEmpty()){
                    AccountListClosedLost = [SELECT Id,Name,Status__c FROM Account where Id IN: IdSetOfAccountClosedLost];
                }
                if(!AccountListClosedLost.isEmpty()){
                    for(Account acc : AccountListClosedLost){
                        account newAcc = new Account();
                        newAcc.id = acc.id;
                        newAcc.Status__c = 'Lost';
                        AccountListClosedLostToBeUpdated.add(newAcc);
                    }
                }
                if(!AccountListClosedLostToBeUpdated.isEmpty()){
                    update AccountListClosedLostToBeUpdated;
                }
            }
        }catch(exception ex){
            system.debug('Errror-->'+ex.getMessage());
            system.debug('Errror-->'+ex.getCause());
            system.debug('Errror-->'+ex.getLineNumber());
        }
    }
    
    public void AccountUpdateOnOppRenewal(Map<Id,Opportunity> oldOpportunityMap, Map<Id,Opportunity> newOpportunityMap){
        try{
            List<Account> AccountList = new List<Account>();
            List<Account> AccountListToBeUpdated = new List<Account>();
            set<Id> IdSetOfAccount = new Set<Id>();
            
            if(!newOpportunityMap.isEmpty()){
                for(Opportunity opp : newOpportunityMap.values()){
                    if(opp.Opportunity_Type__c != Null && opp.Opportunity_Type__c == 'Renewable Record'){
                        IdSetOfAccount.add(opp.AccountId);
                    }
                }
                if(!IdSetOfAccount.isEmpty()){
                    AccountList = [SELECT Id,Name,Status__c FROM Account where Id IN: IdSetOfAccount];
                }
                if(!AccountList.isEmpty()){
                    for(Account acc : AccountList){
                        account newAcc = new Account();
                        newAcc.id = acc.id;
                        newAcc.Status__c = 'Renewed';
                        AccountListToBeUpdated.add(newAcc);
                    }
                }
                if(!AccountListToBeUpdated.isEmpty()){
                    update AccountListToBeUpdated;
                }
            }
        }catch(exception ex){
            system.debug('Errror-->'+ex.getMessage());
            system.debug('Errror-->'+ex.getCause());
            system.debug('Errror-->'+ex.getLineNumber());
        }
    }
}