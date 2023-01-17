public with sharing class OpportunityController {
   
    @AuraEnabled 
    public Static List<Opportunity> getOppList(String recordId){
        return [SELECT Id,Name,StageName,CloseDate FROM Opportunity WHERE ID =:recordId];
    }
}