public class BatchToAssignOnboardedLeads implements Database.Batchable<SObject>{
    public Database.QueryLocator Start(Database.BatchableContext bc){
        DateTime currentTime = system.now();
        DateTime fortyEightHoursAgo = currentTime.addHours(-48);
        DateTime thirtyDaysAgo = currentTime.addDays(-30);
        
        String Query = system.label.QueryToAssignOnboardedLeads+' '+system.label.Onboarded_Leads_Limit;        
        return Database.getQueryLocator(Query);
        
    }
    public void execute(Database.BatchableContext bc, List<Lead> newLeadList){
        Set<String> leadIdList =  new Set<String>();
        String assignmEntGroupName = [Select Id,Name From Assignment_Group__c where Name = :system.label.Sales_Assignment_Group].name;
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