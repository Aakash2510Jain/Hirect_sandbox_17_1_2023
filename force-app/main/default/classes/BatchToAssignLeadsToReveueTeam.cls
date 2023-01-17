public class BatchToAssignLeadsToReveueTeam implements Database.Batchable<SObject>{
    public Database.QueryLocator Start(Database.BatchableContext bc){
        dateTime todayDate = system.now();
        DateTime seventyTwoHoursPast = todayDate.addHours(-72);
        
        String Query = 'SELECT Id FROM Lead WHERE Homepage_Visited_Time__c <= : seventyTwoHoursPast AND Revenue_BD__c = null AND leadSource != \'LinkedIn Request (India)\' AND leadSource != \'Offline Outreach\' LIMIT 40000';
        system.debug('Query------'+Query);
        return Database.getQueryLocator(Query);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> newLeadList){
        Set<String> leadIdList =  new Set<String>();
        String assignmEntGroupName = [Select Id,Name From Assignment_Group__c where Name = :system.label.Revenue_Team].name;
        if(!newLeadList.isEmpty()){
            for(Lead leadRec  : newLeadList){
                leadIdList.add(leadRec.Id);
            }
            if(!leadIdList.isEmpty()){
                RoundRobinLeadAssignment.assignLeadsToBDS(assignmEntGroupName, leadIdList, false, true);
            }
        }
    }
    public void Finish(Database.BatchableContext bc){
    }
}