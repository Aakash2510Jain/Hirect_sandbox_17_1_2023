public class BatchToUpdateTriggerAndClickPayContact implements Database.Batchable<SObject>{
    public Database.QueryLocator Start(Database.BatchableContext bc){
        String Query = 'SELECT Id,Trigger_0day__c,Clickpay_0day__c From Contact where Trigger_0day__c > 0 OR Clickpay_0day__c >0 ';
        system.debug('Query------' + Query);
        return Database.getQueryLocator(Query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> contactList){
        List<Contact> contactListToUpdate = new List<Contact>();
        
        if(!contactList.isEmpty()){
            for(Contact conRec : contactList){
                Contact conRecToUpdate = new Contact();
                conRecToUpdate.Id= conRec.Id;
                conRecToUpdate.Trigger_0day__c = 0;
                conRecToUpdate.Clickpay_0day__c = 0;
                contactListToUpdate.add(conRecToUpdate);
            }
            if(!contactListToUpdate.isEmpty()){
                update contactListToUpdate;
            }
        }   
    }
    
    public void Finish(Database.BatchableContext bc){
    }
    
}