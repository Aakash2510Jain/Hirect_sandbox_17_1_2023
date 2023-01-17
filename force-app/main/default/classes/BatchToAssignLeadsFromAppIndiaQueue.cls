public class BatchToAssignLeadsFromAppIndiaQueue implements Database.Batchable<SObject>{
    public Database.QueryLocator Start(Database.BatchableContext bc){
        DateTime currentTime = system.now();
        DateTime threeHour = currentTime.addMinutes(-180);
        
        String appIndiaRegQueueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name =:constants.PUBLIC_LEAD_QUEUE limit 1].Id;
        
        String Query = 'SELECT Id FROM Lead Where OwnerId =: appIndiaRegQueueId AND  Homepage_Visited_Time__c = null ANd Company != \'no_company_name\' AND CreatedDate <= :threeHour LIMIT 150 ';        
        return Database.getQueryLocator(Query);
        
    }
    public void execute(Database.BatchableContext bc, List<Lead> newLeadList){
       Set<String> leadIdList =  new Set<String>();
        String assignmEntGroupName = [Select Id,Name From Assignment_Group__c where Name = :system.label.App_India_Registration_Group].name;
        if(!newLeadList.isEmpty()){
            for(Lead leadRec  : newLeadList){
                leadIdList.add(leadRec.Id);
            }
            if(!leadIdList.isEmpty()){
                AppIndiaLeadAssignement.assignLeadsToBDS(assignmEntGroupName, leadIdList, false, false);
            }
        }
        
        /*if(!newLeadList.isEmpty()){
            LeadAssignmentExecutionCriteria.validateEntryCriteria(newLeadList);
        }*/  
    }
    public void Finish(Database.BatchableContext bc){
    }
}