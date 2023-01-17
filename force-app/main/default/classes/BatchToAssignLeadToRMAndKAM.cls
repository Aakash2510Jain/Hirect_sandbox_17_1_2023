/*
* Author : Mukesh Chawla
* */


public class BatchToAssignLeadToRMAndKAM implements Database.Batchable<sObject>, Database.Stateful{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<Account_Assignment_Capacity__c> accountAssCap = Account_Assignment_Capacity__c.getall().values();
        
        date initiateddateyesterday = system.today().addDays(-integer.valueOf(accountAssCap[0].No_of_Days__c));
        system.debug('initiateddateyesterday :: ' + initiateddateyesterday);
        String QueryString = 'SELECT Email,FirstName,Company_Size__c,OwnerId,KAM_V1__c,RM_V1__c,Annual_Turnover__c,Id,IsConverted,LeadSource,Name,Onboarding_Completed__c,Payment_initiated_Date_Time__c FROM Lead Where Payment_Status__c = \'Initiated\' and  IsConverted = false and Payment_initiated_Date__c =:initiateddateyesterday';
        return  Database.getquerylocator(QueryString);
        
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> Leadlist){
        // process each batch of records
        system.debug('Leadlist-->'+Leadlist);
        Map<String, KAM_RM_Assignment_Group_Member__c> kamRmAssGrpMmbrByGrpName = new Map<String, KAM_RM_Assignment_Group_Member__c>();
        List<KAM_RM_Assignment_Group_Member__c> kamRmAssGrpMmbr = new List<KAM_RM_Assignment_Group_Member__c>();
        List<KAM_RM_Assignment_Group_Member__c>  agmToBeUpdated = new List<KAM_RM_Assignment_Group_Member__c>();
        List<LEad> leadListToBeUpdated = new List<Lead>();
        
        kamRmAssGrpMmbr = [Select Id,User__c,KAM_RM_Assignment_Group__c,Assigned_Date__c,KAM_RM_Assignment_Group__r.Group_Member_Type__c From KAM_RM_Assignment_Group_Member__c Where KAM_RM_Assignment_Group__r.Object__c = 'Lead' ];
        system.debug('kamRmAssGrpMmbr-->'+kamRmAssGrpMmbr);
        if(!kamRmAssGrpMmbr.isEmpty()){
            for(KAM_RM_Assignment_Group_Member__c member : kamRmAssGrpMmbr){
                // 
                system.debug('member.KAM_RM_Assignment_Group__r.Group_Member_Type__c-->'+member.KAM_RM_Assignment_Group__r.Group_Member_Type__c);
                if(kamRmAssGrpMmbrByGrpName.containsKey(member.KAM_RM_Assignment_Group__r.Group_Member_Type__c)){
                    DateTime assignedDateTime = kamRmAssGrpMmbrByGrpName.get(member.KAM_RM_Assignment_Group__r.Group_Member_Type__c).Assigned_Date__c;
                    if(member.Assigned_Date__c == null){
                        kamRmAssGrpMmbrByGrpName.put(member.KAM_RM_Assignment_Group__r.Group_Member_Type__c, member);
                    }else{
                        if(member.Assigned_Date__c < assignedDateTime){
                            kamRmAssGrpMmbrByGrpName.put(member.KAM_RM_Assignment_Group__r.Group_Member_Type__c, member);
                        }  
                    }
                }else{
                    kamRmAssGrpMmbrByGrpName.put(member.KAM_RM_Assignment_Group__r.Group_Member_Type__c, member);
                }
            }
        }
        system.debug('kamRmAssGrpMmbrByGrpName-->'+kamRmAssGrpMmbrByGrpName);
        system.debug('agmToBeUpdated-->'+agmToBeUpdated);
        system.debug('Leadlist-->'+Leadlist);
        if(!Leadlist.isEmpty()){
            for(Lead leadRec : Leadlist){
                KAM_RM_Assignment_Group_Member__c agmRec = new KAM_RM_Assignment_Group_Member__c();
                Lead leadRecToBeUpdated = new Lead();
                
                leadRecToBeUpdated.Id = leadRec.Id;
                system.debug('leadRec.Company_Size__c-->'+leadRec.Company_Size__c);
                system.debug('leadRec.Annual_Turnover__c-->'+leadRec.Annual_Turnover__c);
                if((leadRec.Company_Size__c.contains('500')|| leadRec.Company_Size__c.contains('1000')) && leadRec.Annual_Turnover__c > 1000000){
                    system.debug('kamRmAssGrpMmbrByGrpName.get(KAM).User__c-->'+kamRmAssGrpMmbrByGrpName.get('KAM').User__c);
                    agmRec.Id = kamRmAssGrpMmbrByGrpName.get('KAM').Id;
                    agmRec.Assigned_Date__c = system.now();
                     
                    leadRecToBeUpdated.BD__c = leadRec.OwnerId;
                    leadRecToBeUpdated.OwnerId = kamRmAssGrpMmbrByGrpName.get('KAM').User__c;
                    leadRecToBeUpdated.KAM_V1__c =kamRmAssGrpMmbrByGrpName.get('KAM').User__c ;
                }else if((leadRec.Company_Size__c.contains('19')|| leadRec.Company_Size__c.contains('99') || leadRec.Company_Size__c.contains('199')|| leadRec.Company_Size__c.contains('499')) && leadRec.Annual_Turnover__c < 1000000){
                    system.debug('kamRmAssGrpMmbrByGrpName.get(RM).User__c-->'+kamRmAssGrpMmbrByGrpName.get('RM').User__c);
                    agmRec.Id = kamRmAssGrpMmbrByGrpName.get('RM').Id;
                    agmRec.Assigned_Date__c = system.now();
                    
                    leadRecToBeUpdated.BD__c = leadRec.OwnerId;
                    leadRecToBeUpdated.OwnerId = kamRmAssGrpMmbrByGrpName.get('RM').User__c;
                    leadRecToBeUpdated.RM_V1__c =kamRmAssGrpMmbrByGrpName.get('RM').User__c ;
                }
                leadListToBeUpdated.add(leadRecToBeUpdated);
                agmToBeUpdated.add(agmRec);
            }
        }
        system.debug('leadListToBeUpdated-->'+leadListToBeUpdated);
        system.debug('agmToBeUpdated-->'+agmToBeUpdated);
        if(!agmToBeUpdated.isEmpty()){
            update agmToBeUpdated;
        }
        if(!leadListToBeUpdated.isEmpty()){
            update leadListToBeUpdated;
        }
        
    }
    
    public void finish(Database.BatchableContext bc){
    }
    
}