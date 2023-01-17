public without sharing class AccountTriggerHelper {
    static AccountTriggerHelper handlerInstance;
    public static AccountTriggerHelper getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new AccountTriggerHelper();
        return handlerInstance;
    }
    public void updateAccountOwnership(List<Account> accountList){
        try{
            Map<String, KAM_RM_Assignment_Group_Member__c> kamRmAssGrpMmbrByGrpName = new Map<String, KAM_RM_Assignment_Group_Member__c>();
            List<KAM_RM_Assignment_Group_Member__c> kamRmAssGrpMmbr = new List<KAM_RM_Assignment_Group_Member__c>();
            List<KAM_RM_Assignment_Group_Member__c>  agmToBeUpdated = new List<KAM_RM_Assignment_Group_Member__c>();
            List<Account> accountListToBeUpdated = new List<Account>();
            
            kamRmAssGrpMmbr = [Select Id,User__c,KAM_RM_Assignment_Group__c,Assigned_Date__c,KAM_RM_Assignment_Group__r.Group_Member_Type__c From KAM_RM_Assignment_Group_Member__c Where KAM_RM_Assignment_Group__r.Object__c = 'Account' ];
            if(!kamRmAssGrpMmbr.isEmpty()){
                for(KAM_RM_Assignment_Group_Member__c member : kamRmAssGrpMmbr){
                    // 
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
            if(!accountList.isEmpty()){
                for(Account accRec : accountList){
                    KAM_RM_Assignment_Group_Member__c agmRec = new KAM_RM_Assignment_Group_Member__c();
                    If(accRec.Company_Size__c == null || accRec.Company_Size__c.contains('19')|| accRec.Company_Size__c.contains('99') || accRec.Company_Size__c.contains('199')|| accRec.Company_Size__c.contains('499')){
                        agmRec.Id = kamRmAssGrpMmbrByGrpName.get('RM').Id;
                        agmRec.Assigned_Date__c = system.now();
                        agmToBeUpdated.add(agmRec);
                        accRec.BD__c = accRec.OwnerId;
                        accRec.OwnerId = kamRmAssGrpMmbrByGrpName.get('RM').User__c;
                        accRec.RM__c =kamRmAssGrpMmbrByGrpName.get('RM').User__c ;
                        accRec.BD_KAM_RM_Updated__c = true;
                    }else if(accRec.Company_Size__c.contains('500')|| accRec.Company_Size__c.contains('1000')){
                        agmRec.Id = kamRmAssGrpMmbrByGrpName.get('KAM').Id;
                        agmRec.Assigned_Date__c = system.now();
                        agmToBeUpdated.add(agmRec);
                        accRec.BD__c = accRec.OwnerId;
                        accRec.OwnerId = kamRmAssGrpMmbrByGrpName.get('KAM').User__c;
                        accRec.KAM__c =kamRmAssGrpMmbrByGrpName.get('KAM').User__c ;
                        accRec.BD_KAM_RM_Updated__c = true;
                    }
                }
            }
            if(!agmToBeUpdated.isEmpty()){
                update agmToBeUpdated;
            }
        }catch(exception ex){
            system.debug('Errror-->'+ex.getMessage());
            system.debug('Errror-->'+ex.getCause());
            system.debug('Errror-->'+ex.getLineNumber());
        }
    }
}