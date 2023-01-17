public class BatchToAssignLeadsToSalesManager implements Database.Batchable<SObject>{
    public Database.QueryLocator Start(Database.BatchableContext bc){
        Date todayDate = system.today();
        date threeDayAgoDate = todayDate.addDays(-3);
        
        String Query = 'SELECT Id FROM Lead Where Sales_BD__c = null and First_Visit_Date__c =: threeDayAgoDate LIMIT '+system.label.OnboardedManagerLeadLimit;        
        return Database.getQueryLocator(Query);
        
    }
    public void execute(Database.BatchableContext bc, List<Lead> newLeadList){
        Set<String> leadIdList =  new Set<String>();
        String assignmEntGroupName = [Select Id,Name From Assignment_Group__c where Name = :system.label.Sales_Assignment_Group_V1].name;
        if(!newLeadList.isEmpty()){
            for(Lead leadRec  : newLeadList){
                leadIdList.add(leadRec.Id);
            }
            system.debug('leadIdList-->'+leadIdList	);
            if(!leadIdList.isEmpty()){
                SalesTeamLeadAssignment.assignLeadsToBDS(assignmEntGroupName, leadIdList);
            }
        }       
    }
    public void Finish(Database.BatchableContext bc){
    }
}