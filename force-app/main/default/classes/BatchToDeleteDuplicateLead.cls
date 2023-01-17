global class BatchToDeleteDuplicateLead implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //List<String> ListofDuplicateLeadIds = new List<String>{'00Q0w000005dZL4EAM', '00Q0w000005dZLOEA2', '00Q0w000005dZMMEA2', '00Q0w000005dZMREA2', '00Q0w000005dZMWEA2','00Q0w000005daF7EAI','00Q0w000005daGAEAY','00Q0w000005daFbEAI','00Q0w000005daF4EAI'};
        String query = 'SELECT Id, Name,FormattedPhone__c, IsDuplicate__c FROM Lead Where IsDuplicate__c = false';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> LeadList) {
        
        System.debug('LeadList:: ' + LeadList);
        try {
            list<Lead> leadrecordswithSamePhone = new list<Lead>();
            map<Id, lead> MapofUpdatedLeadWithlead = new Map<Id,Lead>();
            Map<String, Integer> MapofLeadaStageWithPosition = new Map<String, integer>();
            list<LeadStage__c> leadStageList = [SELECT Id,Name,Value__c FROM LeadStage__c];
            for(LeadStage__c LS : leadStageList){
                MapofLeadaStageWithPosition.put(LS.Name, Integer.valueof(LS.Value__c));
            }
            System.debug('MapofLeadaStageWithPosition :; ' + MapofLeadaStageWithPosition);
            
            for(Lead Ld : LeadList){
                string PhoneNumber = Ld.FormattedPhone__c;
                leadrecordswithSamePhone = [SELECT Id, Name,FormattedPhone__c, IsDuplicate__c, Lead_Stage__c  FROM Lead  where FormattedPhone__c =: PhoneNumber And IsDuplicate__c = false];
                System.debug('leadrecordswithSamePhone :; ' +leadrecordswithSamePhone.size());
                
                if(!leadrecordswithSamePhone.isEmpty()){
                    
                    integer maxpositionLeadValue=0;
                    String MaxpositionLead;
                    for (Lead LeadRec : leadrecordswithSamePhone) {
                        Lead leadUpdatedRec = new Lead();
                        leadUpdatedRec.id = LeadRec.Id;
                        leadUpdatedRec.IsDuplicate__c = true;
                        MapofUpdatedLeadWithlead.put(leadUpdatedRec.Id, leadUpdatedRec);
                        if(MapofLeadaStageWithPosition.containsKey(LeadRec.Lead_Stage__c) && MapofLeadaStageWithPosition.get(LeadRec.Lead_Stage__c) > maxpositionLeadValue){
                            maxpositionLeadValue = MapofLeadaStageWithPosition.get(LeadRec.Lead_Stage__c);
                            MaxpositionLead = LeadRec.id;
                        }
                    }
                    MapofUpdatedLeadWithlead.remove(MaxpositionLead);
                }
            }
            if(!MapofUpdatedLeadWithlead.isEmpty()){
                update MapofUpdatedLeadWithlead.values();
            }
            
        } catch(Exception e) {
            System.debug('The Error has Occurred =======> '  + e.getMessage() + ' at Line Number =========> ' + e.getLineNumber() );
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
    }
    
}