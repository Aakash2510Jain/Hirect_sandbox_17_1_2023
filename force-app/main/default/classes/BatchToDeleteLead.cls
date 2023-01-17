public class BatchToDeleteLead implements Database.Batchable<SObject>{
    public Database.QueryLocator Start(Database.BatchableContext bc){
        String Query = 'SELECT Id,Phone From Account where Phone != null';
        system.debug('Query------' + Query);
        return Database.getQueryLocator(Query);
    }
    public void execute(Database.BatchableContext bc, List<COntact> contactList){
        List<Lead> leadListToUpdate = new List<Lead>();
        List<Lead> leadListToQuery = new List<Lead>();
        for(COntact Con : contactList){
            leadListToQuery = [Select Id,Dupe_Phone_Con__c From Lead where Phone Like: '%'+Con.Phone.right(10) AND Dupe_Phone_Con__c = False];
        }
        if(!leadListToQuery.isEmpty()){
            for(Lead leadRec : leadListToQuery){
                Lead leadRecToUpdate = new Lead();
                leadRecToUpdate.Id = leadRec.Id;
                leadRecToUpdate.Dupe_Phone_Con__c = true;
                leadListToUpdate.add(leadRecToUpdate);
            }
            if(!leadListToUpdate.isEmpty()){
                update leadListToUpdate;
            }
        }   
    }
    
    public void Finish(Database.BatchableContext bc){
    }
    
}