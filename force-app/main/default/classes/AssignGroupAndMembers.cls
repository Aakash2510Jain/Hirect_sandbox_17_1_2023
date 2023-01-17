public with sharing class AssignGroupAndMembers{
    @future
    public static void UpdateAssignGroupMemberList(Set<Id> DeactivatedUsersIds){

        map<Id, user> mapofDeactivatedUserIdWithuser = new map<Id, user>();
        map<String, List<Assignment_Group_Member__c>> mapofAGIdWithAGmember = new map<String, List<Assignment_Group_Member__c>>();
        list<Assignment_Group_Member__c> updatedAGmemberList = new list<Assignment_Group_Member__c>();
        list<Assignment_Group_Member__c> TobeDeletedAGmemberList = new list<Assignment_Group_Member__c>();
        List<Assignment_Group_Member__c> AGM_Of_DeactivatedUser = new List<Assignment_Group_Member__c>();
        list<User> DeactivatedUserList = new List<User>();

        List<Assignment_Group_Member__c> agmMemberoBeDeleted = new List<Assignment_Group_Member__c>();
        if (!DeactivatedUsersIds.isEmpty()){
            delete [Select Id
                    from Assignment_Group_Member__c
                    where Group_Member__c in:DeactivatedUsersIds]; 
        }
    }

}

/*
 if (!DeactivatedUsersIds.isEmpty()){
 DeactivatedUserList = [SELECT Email, FirstName, Id, IsActive, LastName, Leave_End_Date__c, Leave_Start_Date__c, Max_Lead_Per_Day__c, MiddleName, Name, Phone, ProfileId, State, Street, Username, UserRoleId
 FROM User
 Where Id IN:DeactivatedUsersIds];

 if (!DeactivatedUserList.isEmpty()){
 for (User u : DeactivatedUserList){
 mapofDeactivatedUserIdWithuser.put(u.Id, u);
 }
 }
 if (!mapofDeactivatedUserIdWithuser.isEmpty()){
 List<Assignment_Group__c> allAssignGroupWithAGMember = [SELECT Id, Last_Allocated_RRid__c, Lead_Assigning_Criteria__c, Lead_Stage_Exceed_Count__c, Lead_Stage__c, Max_Lead_Per_Day__c, Minimum_Lead_Volume__c, Name, (SELECT Active__c, Assignment_Group__c, Assignment_Id__c, BreakTime_Started__c, Group_Member__c, Id, Leave_End_Date__c, Leave_Start_Date__c, Max_Lead_Per_Day__c, Name, Out_Of_Office__c
 FROM Assignment_Group_Members__r)
 FROM Assignment_Group__c ];

 for (Assignment_Group__c AG : allAssignGroupWithAGMember){
 mapofAGIdWithAGmember.put(AG.Id, AG.Assignment_Group_Members__r);
 }
 System.debug('mapofAGIdWithAGmember ======> ' + mapofAGIdWithAGmember);

 if (!mapofAGIdWithAGmember.isEmpty()){
 for (List<Assignment_Group_Member__c> AGMembers : mapofAGIdWithAGmember.values()){
 system.debug('AGMembers ========> ' + AGMembers);
 integer assignId = 0;
 for (Assignment_Group_Member__c AGm : AGMembers){
 if (mapofDeactivatedUserIdWithuser.containsKey(AGm.Group_Member__c)){
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
 */
// Map<Id, List<Assignment_Group_Member__c>> Map_of_AGId_With_AGmember = new Map<Id, List<Assignment_Group_Member__c>>();
// if ( !mapofDeactivatedUserIdWithuser.isEmpty() ){
//     AGM_Of_DeactivatedUser = [SELECT Active__c, Assignment_Group__c, Assignment_Id__c, BreakTime_Started__c, Group_Member__c, Id, Leave_End_Date__c, Leave_Start_Date__c, Max_Lead_Per_Day__c, Name, Out_Of_Office__c
//                               FROM Assignment_Group_Member__c
//                               Where Group_Member__c IN:DeactivatedUsersIds];
//     if ( !AGM_Of_DeactivatedUser.isEmpty() ){
//         for ( Assignment_Group_Member__c AGMember : AGM_Of_DeactivatedUser ){
//             if ( Map_of_AGId_With_AGmember.containsKey(AGMember.Assignment_Group__c) ){
//                 List<Assignment_Group_Member__c> ExistingAGMList = Map_of_AGId_With_AGmember.get(AGMember.Assignment_Group__c);
//                 ExistingAGMList.add(AGMember);
//             }
//             else{
//                 List<Assignment_Group_Member__c> NewAGMList = new List<Assignment_Group_Member__c>();
//                 NewAGMList.add(AGMember);
//                 Map_of_AGId_With_AGmember.put(AGMember.Assignment_Group__c, NewAGMList);
//             }
//         }
//     }
//     if ( !Map_of_AGId_With_AGmember.isEmpty() ){
//         for ( List<Assignment_Group_Member__c> AGMembers : Map_of_AGId_With_AGmember.values() ){
//             system.debug('AGMembers ========> ' + AGMembers);
//             integer assignId = 0;
//             for ( Assignment_Group_Member__c AGm : AGMembers ){
//                 if ( mapofDeactivatedUserIdWithuser.containsKey(AGm.Group_Member__c) ){
//                     TobeDeletedAGmemberList.add(AGm);
//                 }
//                 else{
//                     assignId++;
//                     AGm.Assignment_Id__c = assignId;
//                     updatedAGmemberList.add(AGm);
//                 }
//             }
//         }
//     }
//     System.debug('ToeDeletedAGmemberList ======> ' + TobeDeletedAGmemberList);
//     System.debug('updatedAGmemberList ======> ' + updatedAGmemberList);
//     if ( !TobeDeletedAGmemberList.isEmpty() ){
//         delete TobeDeletedAGmemberList;
//     }
//     if ( !updatedAGmemberList.isEmpty() ){
//         update updatedAGmemberList;
//     }
// }