public class UserTriggerHelper{
    static UserTriggerHelper handlerInstance;

    public static UserTriggerHelper getInstance(){
        if (handlerInstance == null)
            handlerInstance = new UserTriggerHelper();
        return handlerInstance;
    }

    public void handleLeaveDate(Map<Id, User> newMap, Map<Id, User> oldMap){
        Map<Id, User> userRecById = new Map<Id, User>();
        List<Assignment_Group_Member__c> agmList = new List<Assignment_Group_Member__c>();
        List<Assignment_Group_Member__c> agmListToUpdate = new List<Assignment_Group_Member__c>();
        Map<Id, List<Assignment_Group_Member__c>> agmListByUserId = new Map<Id, List<Assignment_Group_Member__c>>();

        for (User userRec : newMap.values()){
            if ((userRec.Leave_Start_Date__c != oldMap.get(userRec.Id).Leave_Start_Date__c && userRec.Leave_Start_Date__c != null) || (userRec.Leave_End_Date__c != oldMap.get(userRec.Id).Leave_End_Date__c && userRec.Leave_End_Date__c != null)){

                if (userRec.Leave_Start_Date__c < system.today()){
                    userRec.addError('Leave START DATE cannot be of PAST');
                }
                if (userRec.Leave_End_Date__c < system.today()){
                    userRec.addError('Leave END DATE cannot be of PAST');
                }
                if (userRec.Leave_End_Date__c < userRec.Leave_Start_Date__c){
                    userRec.addError('Leave END DATE cannot be less than Leave START DATE');
                }

                if (userRec.Leave_Start_Date__c != null && userRec.Leave_End_Date__c == null){
                    userRec.addError('Leave END DATE cannot be EMPTY');
                }
                if (userRec.Leave_End_Date__c != null && userRec.Leave_Start_Date__c == null){
                    userRec.addError('Leave START DATE cannot be EMPTY');
                }
                userRecById.put(userRec.Id, userRec);
            }
        }
        system.debug('userRecById-->' + userRecById);
        if (!userRecById.isEmpty()){
            agmList = [Select Id, Group_Member__c, Leave_End_Date__c, Leave_Start_Date__c
                       From Assignment_Group_Member__c
                       where Group_Member__c In:userRecById.keySet()];
            system.debug('agmList-->' + agmList);
            if (!agmList.isEmpty()){
                for (Assignment_Group_Member__c agmRec : agmList){
                    if (agmListByUserId.containsKey(agmRec.Group_Member__c)){
                        List<Assignment_Group_Member__c> agmToAdd = agmListByUserId.get(agmRec.Group_Member__c);
                        agmToAdd.add(agmRec);
                        agmListByUserId.put(agmRec.Group_Member__c, agmToAdd);
                    } else{
                        agmListByUserId.put(agmRec.Group_Member__c, new List<Assignment_Group_Member__c>{ agmRec });
                    }
                }
                if (!agmListByUserId.isEmpty()){
                    for (Id userId : userRecById.keySet()){
                        if (agmListByUserId.containsKey(userId)){
                            for (Assignment_Group_Member__c agmrec : agmListByUserId.get(userId)){
                                Assignment_Group_Member__c agmrecToupdate = new Assignment_Group_Member__c();
                                agmrecToupdate.Id = agmrec.Id;
                                agmrecToupdate.Leave_Start_Date__c = userRecById.get(userId).Leave_Start_Date__c;
                                agmrecToupdate.Leave_End_Date__c = userRecById.get(userId).Leave_End_Date__c;
                                agmListToUpdate.add(agmrecToupdate);
                            }
                        }
                    }
                    if (!agmListToUpdate.isEmpty()){
                        update agmListToUpdate;
                    }
                }
            }
        }
    }

    public void handleInactiveUser(Map<Id, User> newMap, Map<Id, User> oldMap){

        System.debug('newMap =====> ' + newMap);
        System.debug('oldMap =====> ' + oldMap);
        try{
            Set<Id> DeactivatedUsersIds = new set<Id>();
            map<Id, user> mapofDeactivatedUserIdWithuser = new map<Id, user>();
            list<User> DeactivatedUserList = new List<User>();

            if (!newMap.isEmpty()){
                for (user u : newMap.values()){
                    if (u.IsActive != oldmap.get(u.id).IsActive && u.IsActive == false){
                        DeactivatedUsersIds.add(u.id);
                    }
                }
                System.debug('DeactivatedUsersIds ======> ' + DeactivatedUsersIds);

                if (!DeactivatedUsersIds.isEmpty()){
                    AssignGroupAndMembers.UpdateAssignGroupMemberList(DeactivatedUsersIds);
                }
            }
        } catch (Exception e){
            System.debug('This error has occured due to ========> ' + e.getMessage() + 'due to ======> ' + e.getLineNumber());
        }
    }

}