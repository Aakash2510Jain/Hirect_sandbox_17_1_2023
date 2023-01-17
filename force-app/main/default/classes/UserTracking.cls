public without sharing class UserTracking{
    public UserTracking(){
    }

    @AuraEnabled(cacheable = true)
    public static UserTrack OnpageLoad(string userId){
        UserTrack usr = new UserTrack();

        User xUser = [Select Name
                      From User
                      where Id = :UserInfo.getUserId()];

        list<User_Tracking__c> userTracking = [select id, Checkin_Datetime__c, Checkout_Datetime__c, BreakTime_Started__c, Member__c
                                               from User_Tracking__c
                                               where Member__c = :userId and CreatedDate = TODAY
                                               limit 1];
        if (!userTracking.isEmpty()){
            //if(System.now().time() > Time.newInstance(14, 45, 00, 00))
            usr.IsbreakStarted = userTracking[0].BreakTime_Started__c;
            usr.checkin = true;
            if (userTracking[0].Checkout_Datetime__c != null)
                usr.checkout = true;
            else
                usr.checkout = false;
        } else{
            usr.checkin = false;
            usr.checkout = true;
        }

        usr.username = xUser.Name;

        return usr;
    }

    @AuraEnabled
    public static String UserCheckin(string userId){


        List<Lead> leadList = new List<Lead>();
        String eventStatus = 'Something went wrong';
        string groupName = '';
        DateTime dt = DateTime.now();
        boolean isOpsMember = [Select Is_Ops_Member__c from user where id =:userId ].Is_Ops_Member__c;
        
        String dayOfWeek = dt.format('EEEE');
        /*if(dayOfWeek == 'Sunday'){
         eventStatus = 'You can not checkin on sunday.';
         return eventStatus;
         }*/
		
        if(!isOpsMember){
            if (System.now().time() < Time.newInstance(10, 00, 00, 00)){
                system.debug('Inside 9 :30');
                eventStatus = 'You can not checkin before 10:00 AM.';
                system.debug('eventStatus-->' + eventStatus);
                return eventStatus;
            }
        }
        system.debug('Outside');
        map<string, string> mapofGroupNameBySourceIntent = new map<string, string>();
        if (userId != null){
            boolean isTaskAssignmentGroupMember = false;
            list<User_Tracking__c> userTracking = new list<User_Tracking__c>();
            list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
            userTracking = [select id, Checkin_Datetime__c, Checkout_Datetime__c, Member__c
                            from User_Tracking__c
                            where Member__c = :userId and CreatedDate = TODAY
                            limit 1];
            agmList = [select id, Group_Member__c, Assignment_Group__r.name, Assignment_Group__r.Group_Type__c
                       from Assignment_Group_Member__c
                       where Group_Member__c = :userId];
            if (userTracking.isEmpty()){
                list<Course_Interested_And_Group_Name__mdt> groupNameSourceIntent = [select id, Group_Name__c, Source_Intent__c
                                                                                     from Course_Interested_And_Group_Name__mdt];

                if (!groupNameSourceIntent.isEmpty()){
                    for (Course_Interested_And_Group_Name__mdt signMeta : groupNameSourceIntent){
                        mapofGroupNameBySourceIntent.put(signMeta.Group_Name__c, signMeta.Source_Intent__c);
                    }
                }

                User_Tracking__c userTrackRec = new User_Tracking__c();
                userTrackRec.Member__c = userId;
                userTrackRec.Checkin_Datetime__c = DateTime.now();
                insert userTrackRec;
                if (!agmList.isEmpty()){
                    for (Assignment_Group_Member__c agm : agmList){
                        agm.Out_Of_Office__c = false;

                        if (agm.Assignment_Group__r.Group_Type__c == 'Task'){
                            isTaskAssignmentGroupMember = true;
                        }

                    }

                    update agmList;

                    if (isTaskAssignmentGroupMember){
                        list<Assignment_group__c> agList = new list<Assignment_group__c>();
                        agList = [select id, name
                                  from assignment_group__c
                                  where Group_Type__c = 'Task'];
                        set<string> taskId = new set<String>();
                        list<task> taskListTobePass = new list<Task>();
                        string taskDefaulrUserId = system.Label.Document_Task_Default_ID;
                        taskListTobePass = [select id, ownerId
                                            from task
                                            where ownerId = :taskDefaulrUserId];
                        if (!taskListTobePass.isEmpty()){
                            for (Task ts : taskListTobePass){
                                taskId.add(ts.Id);
                            }
                        }
                        if (!taskId.isEmpty() && !agList.isEmpty()){
                            for (Assignment_group__c ag : agList){
                                TaskAssignmentModule.taskAssignmentLogic(ag.Name, taskId);
                            }

                        }
                    }
                    /*BatchToAssignLeadsFromQueue batchInstance = new BatchToAssignLeadsFromQueue();
                     database.executeBatch(batchInstance);*/

                }

                eventStatus = 'Checkin successful';
            } else{
                eventStatus = 'Your checkin was already created.';
            }

        } else{
            eventStatus = 'User is not registered in system.Please contact to your admin.';
        }


        return eventStatus;
    }

    @AuraEnabled
    public static String UserCheckout(string userId){
        String eventStatus = 'Something went wrong';
        if (userId != null){
            list<User_Tracking__c> userTracking = new list<User_Tracking__c>();
            list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
            userTracking = [select id, Checkin_Datetime__c, Checkout_Datetime__c, Member__c
                            from User_Tracking__c
                            where Member__c = :userId and createddate = TODAY
                            limit 1];
            agmList = [select id, Group_Member__c
                       from Assignment_Group_Member__c
                       where Group_Member__c = :userId];
            if (!userTracking.isEmpty()){
                for (User_Tracking__c ut : userTracking){
                    ut.Checkout_Datetime__c = DateTime.now();
                }
                update userTracking;
                if (!agmList.isEmpty()){
                    for (Assignment_Group_Member__c agm : agmList){
                        agm.Out_Of_Office__c = true;
                        agm.BreakTime_Started__c = false;
                    }

                    update agmList;
                }
                eventStatus = 'Checkout datetime has been updated.';
            } else{
                eventStatus = 'You can not checkout without checkin.';
            }

        } else{
            eventStatus = 'User is not registered in system.Please contact to your admin.';
        }


        return eventStatus;
    }

    @AuraEnabled
    public static void manageBreakTime(string userId){
        UserTrack usr = new UserTrack();
        List<Assignment_Group_Member__c> agmListToBeUpdated = new List<Assignment_Group_Member__c>();
        list<User_Tracking__c> userTracking = [select id, BreakTime_Started__c, Checkin_Datetime__c, Checkout_Datetime__c, Member__c
                                               from User_Tracking__c
                                               where Member__c = :userId and CreatedDate = TODAY
                                               limit 1];
        List<Assignment_Group_Member__c> agmList = [Select Id, BreakTime_Started__c
                                                    From Assignment_Group_Member__c
                                                    where Group_Member__c = :userId];
        if (!userTracking.isEmpty()){
            userTracking[0].BreakTime_Started__c = !userTracking[0].BreakTime_Started__c;
            update userTracking[0];
        }
        if (!agmList.isEmpty()){
            for (Assignment_Group_Member__c agm : agmList){
                Assignment_Group_Member__c agmRec = new Assignment_Group_Member__c();
                agmRec.Id = agm.Id;
                agmRec.BreakTime_Started__c = !agm.BreakTime_Started__c;
                agmListToBeUpdated.add(agmRec);
            }
            if (!agmListToBeUpdated.isEmpty()){
                update agmListToBeUpdated;
            }
        }
    }

    public class UserTrack{
        @AuraEnabled
        public boolean checkin;
        @AuraEnabled
        public boolean checkout;
        @AuraEnabled
        public boolean IsbreakStarted;
        @AuraEnabled
        public String username;

    }

}