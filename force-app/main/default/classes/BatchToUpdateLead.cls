public class BatchToUpdateLead implements Database.Batchable<SObject>{
    public Database.QueryLocator Start(Database.BatchableContext bc){
        string RegistrationProgress = system.label.RegistrationProgress;
        string leadStage = system.label.LeadStage;
        String Query = 'SELECT Id,Lead_Stage__c,Lead_Substage__c FROM Lead WHERE RegistrationProgress__c =: RegistrationProgress AND Lead_Stage__c !=: leadStage LIMIT 50000';
        system.debug('Query------'+Query);
        return Database.getQueryLocator(Query);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> newLeadList){
        if(!newLeadList.isEmpty()){
            for(Lead leadRec  : newLeadList){
                leadRec.Lead_Stage__c = system.label.LeadStage;
                leadRec.Lead_Substage__c = system.label.LeadSubStage;
            }
            update newLeadList;
        }
    }
    public void Finish(Database.BatchableContext bc){
    }
}