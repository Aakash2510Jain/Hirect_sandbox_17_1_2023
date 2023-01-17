public with sharing class OpportunityHelper {
    
    @AuraEnabled(cacheable=true)
    public Static Opportunity getOppRecord(String OppRecId,String CloseDate, String StageName){
        try{

         return [SELECT Id,AccountId,Name,CloseDate, StageName FROM Opportunity WHERE ID =:OppRecId];
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
            
        }
    }

}