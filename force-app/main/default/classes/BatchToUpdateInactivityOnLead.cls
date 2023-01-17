public class BatchToUpdateInactivityOnLead  implements Database.Batchable <SObject> {
    
    public Database.QueryLocator Start(Database.BatchableContext bc){
        Date nowDate = System.today().addDays(-Integer.valueOf(OrgConfigUtility.orgConfig.Inactive_Lead_Days__c));
        String Query = 'SELECT Id,ownerId FROM Lead Where Last_Called_Date_Time__c <= : nowDate';
        return Database.getQueryLocator(Query);
    }
    
    public void Execute(Database.BatchableContext bc, List<Lead> leadList){

        System.debug('leadList---->'+leadList);
        List<Lead> leadListToBeUpdated = new List<Lead>();
        String publicQueueId = [Select Id From Group where type='Queue' AND Name = 'Lead Queue' limit 1].Id;
        if(!leadList.isEmpty()){

            for(Lead leadRec : leadList){
                 Lead leadRecToBeUpdated = new Lead();
                    leadRecToBeUpdated.id= leadRec.Id;
                    leadRecToBeUpdated.OwnerId = publicQueueId;
                    leadListToBeUpdated.add(leadRecToBeUpdated);
                }
            
            if(!leadListToBeUpdated.isEmpty()){
                update leadListToBeUpdated;
            }
        }
       
    }
    public void Finish(Database.BatchableContext bc){
        System.debug('Batch Run Successfully');
    }
}