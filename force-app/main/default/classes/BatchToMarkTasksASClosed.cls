public class BatchToMarkTasksASClosed implements Database.Batchable<SObject>{
    public Database.QueryLocator Start(Database.BatchableContext bc){ 
        String Query = 'Select Id,Status,whoid From task Where Status = \'Open\' AND Subject = \'Verify Documents Uploaded\'';
        return Database.getQueryLocator(Query);
    }
    public void execute(Database.BatchableContext bc, List<Task> taskList){
        set<Id> LeadIds  = new set<Id>();
        Map<id, Lead> leadMap =  new Map<Id,Lead>();
        List<Task> taskListToUpdate =  new List<Task>();
        
        
        if(!taskList.isEmpty()){
            for(Task taskRec : taskList){
                LeadIds.add(taskRec.whoid);
            }
            if(!LeadIds.isEmpty()){
                leadMap = new Map<Id,Lead>([Select Id From Lead Where Id In : LeadIds AND RegistrationProgress__c != 'Audited Checking']);
                if(!leadMap.isEmpty()){
                    taskListToUpdate = [Select Id,Status From task where whoId in :leadMap.keyset() and Status = 'Open'];
                    if(!taskListToUpdate.isEMpty()){
                        for(Task taskRec : taskListToUpdate){
                            taskRec.Status = 'Completed';
                        }
                        update taskListToUpdate;
                    }
                }
            }
        }    
    }
    public void Finish(Database.BatchableContext bc){
    }
}