public class BatchForDuplicateLeads implements Database.Batchable<SObject>{
    public Database.QueryLocator Start(Database.BatchableContext bc){
       
        String Query = 'SELECT Id,Name,Phone FROM Contact where phone != null';
        return Database.getQueryLocator(Query);
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> masterContact){
        set<String> mobileNos = new Set<String>();
        List<Contact> mergeContact = new List<Contact>();
        
        if(!masterContact.isEmpty()){
            for(Contact con : masterContact){
                mobileNos.add('%'+con.Phone.right(10));
            } 
            if(!mobileNos.isEmpty()){
                mergeContact = [select Id,Name,Phone From Contact where Phone Like : mobileNos AND phone != null];
            }
            for(Contact masterRec : masterContact){
                for(Contact childRec : mergeContact){
                    if((masterRec.Phone).right(10) == (childRec.phone).right(10)){
                        merge masterRec childRec;
                    }
                }
            }
        }
        
    }
    public void Finish(Database.BatchableContext bc){
    }
}