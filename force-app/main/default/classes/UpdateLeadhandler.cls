public without sharing class UpdateLeadhandler {
    
    @AuraEnabled
    public static void UpdateLeadSourceAndOwner(String RecID){
        try{
            String profilename = [SELECT Id,Name FROM Profile where id=: UserInfo.getProfileId()].name;
            if(RecID !=Null){
                Lead LeadRecord = [Select id, name, Don_t_Change_Source__c, ownerId,LeadSource from lead Where Id =:RecID LIMIT 1];
                if(LeadRecord !=NULL){
                    Lead ld = new Lead();
                    ld.Id = LeadRecord.id;
                    if(profilename.containsIgnoreCase('Offline')){
                        ld.LeadSource = 'Offline Outreach';
                    }
                    else if(profilename.containsIgnoreCase('Online')){
                        ld.LeadSource = 'LinkedIn Request (India)';
                    }
                    ld.Don_t_Change_Source__c = true;
                    ld.OwnerId = UserInfo.getUserId();
                    system.debug('Lead details updated :: ' + ld);
                    update ld;
                }
            }
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage() + ' at Line Number :: ' + e.getLineNumber() + ' due to :: ' + e.getCause());
        }
        
    }
    
}