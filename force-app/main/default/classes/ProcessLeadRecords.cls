public without sharing class ProcessLeadRecords{
    public List<Lead> selLeadLst;
    public String LeadIds;
    // Constructor
    public ProcessLeadRecords(ApexPages.StandardSetController cntlr){

        selLeadLst = cntlr.getSelected(); //get selected records from account list view

        system.debug('selLeadLst :: ' + selLeadLst);
        LeadIds = '';
        for ( Lead ld : selLeadLst ){
            LeadIds += ld.Id + ','; //build list of ids string concatenated with comma
        }
        system.debug('LeadIds :: ' + LeadIds);
        LeadIds = LeadIds.removeEnd(',');
    }

    public PageReference redirectToLC(){
        String returnUrl = '/lightning/cmp/c__ProcesssLeadRecordsToRoundRobin?c__listofLeads=' + LeadIds;
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
            ListView listviews = [SELECT Id, Name
                                  FROM ListView
                                  WHERE SobjectType = 'Lead' and name = 'Recently Viewed Leads'];
            AGWrap.AllLeadlistview = listviews;
            system.debug('AGWrap :: ' + AGWrap);
            return AGWrap;
        }
        catch ( DmlException e ){
            System.debug('The following exception has occurred: ' + e.getMessage() + ' at lin number :: ' + e.getLineNumber());
        }
        return AGWrap;
    }

    @AuraEnabled
    public static String TransferLead(List<String> leadListId, String SelectedAssignGroup){
        Set<String> LeadIds = new Set<String>();
        List<Lead> allLeadList = new List<Lead>();

        LeadIds.addAll(leadListId);

        //List<List<Opportunity>> listOfOpps = getOppIds
        String asignmentGrpName = [Select Name
                                   From Assignment_Group__c
                                   where Id = :SelectedAssignGroup].Name;

        if ( asignmentGrpName != null && LeadIds != null )
            TransferLeadAssignmentRR.assignLeadsToBDS(asignmentGrpName, LeadIds, true, false);
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
    public ListView AllLeadlistview{ get; set; }

}

}