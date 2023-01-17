public class BatchForAutoCheckin implements Database.Batchable<SObject>{
    public Database.QueryLocator Start(Database.BatchableContext bc){
        String Query = 'SELECT Id,Active__c,Leave_End_Date__c,Assignment_Group__r.Name,Group_Member__c,Leave_Start_Date__c,Out_Of_Office__c FROM Assignment_Group_Member__c WHERE Active__c = true AND Assignment_Group__r.Group_Type__c != \'Task\'';
        system.debug('Query------' + Query);
        return Database.getQueryLocator(Query);
    }

    public void execute(Database.BatchableContext bc, List<Assignment_Group_Member__c> agmList){
        dateTime todayDate = system.now();
        List<Assignment_Group_Member__c> agmListToUpdate = new List<Assignment_Group_Member__c>();
        List<User_Tracking__c> userTrackingList = new List<User_Tracking__c>();
        set<Id> usersId = new Set<Id>();

        if (!agmList.isEmpty()){
            for (Assignment_Group_Member__c agmRec : agmList){
                if (agmRec.Leave_Start_Date__c == todayDate || agmRec.Leave_End_Date__c == todayDate || (todayDate > agmRec.Leave_Start_Date__c && todayDate < agmRec.Leave_End_Date__c)){

                } else{
                    usersId.add(agmRec.Group_Member__c);
                    Assignment_Group_Member__c agmRecToUpdate = new Assignment_Group_Member__c();
                    agmRecToUpdate.Id = agmRec.Id;
                    agmRecToUpdate.Out_Of_Office__c = false;
                    agmListToUpdate.add(agmRecToUpdate);
                }
            }

            if (!agmListToUpdate.isEmpty()){
                update agmListToUpdate;
            }
            if (!usersId.isEmpty()){
                for (Id userIdRec : usersId){
                    User_Tracking__c userTrackingRec = new User_Tracking__c();
                    userTrackingRec.Checkin_Datetime__c = system.now();
                    userTrackingRec.Member__c = userIdRec;
                    userTrackingList.add(userTrackingRec);
                }
                if (!userTrackingList.isEmpty()){
                    insert userTrackingList;
                }
            }
        }
    }

    public void Finish(Database.BatchableContext bc){
    }

}