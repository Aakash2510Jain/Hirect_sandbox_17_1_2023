public with sharing class ProcessTaskRecords {

    public List<Task> selTaskLst;
    public String taskIds;
    // Constructor
    public ProcessTaskRecords(ApexPages.StandardSetController cntlr){

        selTaskLst = cntlr.getSelected(); //get selected records from account list view

        system.debug('selTaskLst :: ' + selTaskLst);
        taskIds = '';
        for ( Task tas : selTaskLst ){
            taskIds += tas.Id + ','; //build list of ids string concatenated with comma
        }
        system.debug('taskIds :: ' + taskIds);
        taskIds = taskIds.removeEnd(',');
    }



    public PageReference redirectToLC(){
        String returnUrl = '/lightning/cmp/c__ProcessTaskRecordsToRoundRobins?c__listofTasks=' + taskIds;
        PageReference pgReturnPage = new PageReference( returnUrl );
        pgReturnPage.setRedirect(true);
        return pgReturnPage;
    }

    @AuraEnabled
    public static AssignGroupWrapper QueryAssignmentGroup(){
        AssignGroupWrapper AGWrap = new AssignGroupWrapper();
        try{

            Map<Id, Assignment_Group__c> AssignGroupMap = new Map<Id, Assignment_Group__c>();
            List<Assignment_Group__c> AssignGroup = [SELECT Id, Last_Allocated_RRid__c, Lead_Assigning_Criteria__r.name, Lead_Assigning_Criteria__c, Lead_Stage_Exceed_Count__c, Lead_Stage__c, Max_Lead_Per_Day__c, Minimum_Lead_Volume__c, Name, OwnerId
                                                     FROM Assignment_Group__c];

            for ( Assignment_Group__c AG : AssignGroup ){
                AssignGroupMap.put(AG.id, AG);
            }
            AGWrap.AssignGroupMapWrap = AssignGroupMap;
            String tasklistview = System.Label.Task_List_view_Name_to_Redirect;
            System.debug('tasklistview ======> ' + tasklistview);
            //String tasklistview = 'Today Tasks - ops';

            ListView listviews = [SELECT Id, Name
                                  FROM ListView
                                  WHERE SobjectType = 'task' and name =:tasklistview];
            AGWrap.Alltasklistview = listviews;
            system.debug('AGWrap :: ' + AGWrap);
            return AGWrap;
        }
        catch ( DmlException e ){
            System.debug('The following exception has occurred: ' + e.getMessage() + ' at lin number :: ' + e.getLineNumber());
        }
        return AGWrap;
    }

    @AuraEnabled
    public static String TransferTask(List<String> taskListId, String SelectedAssignGroup){
        System.debug('taskListId ======>  ' + taskListId);
        System.debug('SelectedAssignGroup ======>  ' + SelectedAssignGroup);
        Set<String> TaskIds = new Set<String>();
        List<Lead> allLeadList = new List<Lead>();

        TaskIds.addAll(taskListId);

        //List<List<Opportunity>> listOfOpps = getOppIds
        String asignmentGrpName = [Select Name
                                   From Assignment_Group__c
                                   where Id = :SelectedAssignGroup].Name;

        if ( asignmentGrpName != null && TaskIds != null ){
            TaskAssignmentModule.taskAssignmentLogic(asignmentGrpName, TaskIds);
        }    
        return 'SUCCESS';
    }

    // @InvocableMethod
    // public static List<List<Opportunity>> getOppIds(List<String> Ids){
    //     String[] VarIds = Ids[0].split(',');
    //     List<Opportunity> Opps = [SELECT Id,
    //                               FROM Opportunity
    //                               WHERE Id in:VarIds];

    //     List<List<Opportunity>> listOfOpps = new List<List<Opportunity>>();
    //     System.debug('Map Opportunity Size ' + listOfOpps.size());
    //     System.debug('=== contents of opptymap: ' + listOfOpps);

    //     listOfOpps.add(Opps);
    //     return listOfOpps;
    // }

public class AssignGroupWrapper{
    @AuraEnabled
    public Map<Id, Assignment_Group__c> AssignGroupMapWrap{ get; set; }

    @AuraEnabled
    public ListView Alltasklistview{ get; set; }

}
}