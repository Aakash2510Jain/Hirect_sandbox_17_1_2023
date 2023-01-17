public class AssignLeadsToRevenueTeam {
 @InvocableMethod(label='Assign Lead To Revenue Team' description='Run RR For Reveniuue Team' category='Lead')
  public static void assignLeads(List<ID> leadIdList) {
      set<String> leadIds = new set<String>();
      
      for(Id leadId : leadIdList){
          leadIds.add(leadId);
      }
      
      string courseName = [Select Id,Name From Assignment_group__c where Name =: system.label.Revenue_Team].Name;
      RoundRobinLeadAssignment.assignLeadsToBDS(courseName,leadIds, false,true);
  }
}