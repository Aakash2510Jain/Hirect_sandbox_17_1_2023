public without sharing class AssignmentGroupMemberTriggerHelper{
    public static void AssignmentGroupMemberDeletion(map<Id, Assignment_Group_Member__c> OldAGMMap){
        
        System.debug('OldAGMMap =====> ' + OldAGMMap);
        //Map<Id, Assignment_Group__c> Mapof_AG_With_AGId = new Map<Id, Assignment_Group__c>();
        Set<Id> assignmentGroupIds = new Set<Id>();
        List<Assignment_Group__c> allAssignGroupWithAGMember = new List<Assignment_Group__c>();
        map<String, List<Assignment_Group_Member__c>> mapofAGIdWithAGmember = new map<String, List<Assignment_Group_Member__c>>();
        list<Assignment_Group_Member__c> updatedAGmemberList = new list<Assignment_Group_Member__c>();
        list<Assignment_Group_Member__c> TobeDeletedAGmemberList = new list<Assignment_Group_Member__c>();
        List<Assignment_Group_Member__c> assignmentGroupListToUpdate = new List<Assignment_Group_Member__c>();
        
        
        if (!OldAGMMap.isEmpty()){
            for (Assignment_Group_Member__c AGM : OldAGMMap.values()){
                assignmentGroupIds.add(AGM.Assignment_Group__c);
            }
            
            if (!assignmentGroupIds.isEmpty()){
                allAssignGroupWithAGMember = [SELECT Id, Last_Allocated_RRid__c, Lead_Assigning_Criteria__c, Lead_Stage_Exceed_Count__c, Lead_Stage__c, Max_Lead_Per_Day__c, Minimum_Lead_Volume__c, Name, (SELECT Active__c, Assignment_Group__c, Assignment_Id__c, BreakTime_Started__c, Group_Member__c, Id, Leave_End_Date__c, Leave_Start_Date__c, Max_Lead_Per_Day__c, Name, Out_Of_Office__c
                                                                                                                                                                                                            FROM Assignment_Group_Members__r order by Assignment_Id__c ASC NULLS LAST)
                                              FROM Assignment_Group__c 
                                              Where Id IN:assignmentGroupIds];
                System.debug('allAssignGroupWithAGMember ====> ' + allAssignGroupWithAGMember);
                
                if (!allAssignGroupWithAGMember.isEmpty()){
                    for (Assignment_Group__c assignemtGroup : allAssignGroupWithAGMember){
                        integer i = 1;
                        for(Assignment_Group_Member__c agmRec : assignemtGroup.Assignment_Group_Members__r){
                            Assignment_Group_Member__c agmRecToUpdate = new Assignment_Group_Member__c();
                            agmRecToUpdate.Id = agmRec.Id;
                            agmRecToUpdate.Assignment_Id__c = i;
                            i++;
                            assignmentGroupListToUpdate.add(agmRecToUpdate);
                        }
                        //mapofAGIdWithAGmember.put(AG.Id, AG.Assignment_Group_Members__r);
                    }
                    if(!assignmentGroupListToUpdate.isEmpty()){
                        update assignmentGroupListToUpdate;
                    }
                    //System.debug('mapofAGIdWithAGmember ======> ' + mapofAGIdWithAGmember);
                }
                
                /*if (!mapofAGIdWithAGmember.isEmpty()){
for (List<Assignment_Group_Member__c> AGMembers : mapofAGIdWithAGmember.values()){
system.debug('AGMembers ========> ' + AGMembers);
integer assignId = 0;
for (Assignment_Group_Member__c AGm : AGMembers){
if (OldAGMMap.containsKey(AGm.Group_Member__c)){
TobeDeletedAGmemberList.add(AGm);
} else{
assignId++;
AGm.Assignment_Id__c = assignId;
updatedAGmemberList.add(AGm);
}
}
}
}

System.debug('ToeDeletedAGmemberList ======> ' + TobeDeletedAGmemberList);
System.debug('updatedAGmemberList ======> ' + updatedAGmemberList);
if (!TobeDeletedAGmemberList.isEmpty()){
delete TobeDeletedAGmemberList;
}
if (!updatedAGmemberList.isEmpty()){
update updatedAGmemberList;
}


}
}
}
*/
            }
        }
    }
}