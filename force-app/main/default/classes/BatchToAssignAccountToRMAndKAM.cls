public class BatchToAssignAccountToRMAndKAM implements Database.Batchable<sObject>, Database.Stateful{
    public Database.QueryLocator start(Database.BatchableContext bc) {
       
        String QueryString = 'SELECT Email__c,OwnerId,KAM__c,RM__c,Annual_Turnover__c,Id,BD__c,BD_KAM_RM_Updated__c FROM Account ';
        return  Database.getquerylocator(QueryString);
    }
    
    public void execute(Database.BatchableContext bc, List<Account> accountList){
       
    }
    
    public void finish(Database.BatchableContext bc){
    }
    
}