public without sharing class TaskTriggerHelper{
    static TaskTriggerHelper handlerInstance;

    public static TaskTriggerHelper getInstance(){
        if (handlerInstance == null)
            handlerInstance = new TaskTriggerHelper();
        return handlerInstance;
    }

    public void updateLeadStageForCallActivity(Map<Id, Task> newTaskMap){
        try{
            system.debug('Update DNP COunt');
            set<Id> leadIds = new set<Id>();
            List<Lead> leadListToBeMarkedAsOpen = new List<Lead>();
            List<Lead> leadListToBeUpdated = new List<Lead>();
            List<Lead> leadListWithDNPCount = new List<Lead>();
            List<Lead> leadListToUpdateDNPCount = new List<Lead>();

            if (!newTaskMap.isEmpty()){
                for (Task taskRec : newTaskMap.values()){
                    system.debug('taskRec-->' + taskRec);
                    if (taskRec.Call_Status__c == 'NO_ANSWER' || taskRec.Call_Status__c == 'BUSY' || taskRec.Call_Status__c == 'CALL_NOT_PICKED' || taskRec.Call_Status__c == 'PROVIDER_TEMP_FAILURE'){
                        leadIds.add(taskRec.whoid);
                    }
                }
                system.debug('leadIds---->' + leadIds);
                if (!leadIds.isEmpty()){
                    leadListToBeMarkedAsOpen = [Select Id, Lead_Stage__c
                                                From Lead
                                                Where Lead_stage__c = 'New' AND id in:leadIds];
                    leadListWithDNPCount = [Select Id, DNP_Count__c
                                            From Lead
                                            where Id in:leadIds];
                    system.debug('leadListToBeMarkedAsOpen-->' + leadListToBeMarkedAsOpen);
                    system.debug('leadListWithDNPCount-->' + leadListWithDNPCount);
                    if (!leadListToBeMarkedAsOpen.isEmpty()){
                        for (Lead leadRec : leadListToBeMarkedAsOpen){
                            lead leadRecTobeUpdated = new Lead();
                            leadRecTobeUpdated.Id = leadRec.id;
                            leadRecTobeUpdated.Lead_Stage__c = 'Open';
                            leadListToBeUpdated.add(leadRecTobeUpdated);
                        }
                        if (!leadListToBeUpdated.isEmpty()){
                            update leadListToBeUpdated;
                        }
                    }
                    if (!leadListWithDNPCount.isEmpty()){
                        system.debug('INside DNP count UPdate');
                        for (Lead leadRec : leadListWithDNPCount){
                            lead leadRecTobeUpdated = new Lead();
                            leadRecTobeUpdated.Id = leadRec.id;
                            if (leadRec.DNP_Count__c == null){
                                leadRecTobeUpdated.DNP_Count__c = 1;
                            } else{
                                leadRecTobeUpdated.DNP_Count__c = leadRec.DNP_Count__c + 1;
                            }
                            leadListToUpdateDNPCount.add(leadRecTobeUpdated);
                        }
                        system.debug('leadListToUpdateDNPCount-->' + leadListToUpdateDNPCount);
                        if (!leadListToUpdateDNPCount.isEmpty()){
                            update leadListToUpdateDNPCount;
                        }
                    }
                }
            }
        } catch (exception ex){
            system.debug('Errror-->' + ex.getMessage());
            system.debug('Errror-->' + ex.getCause());
            system.debug('Errror-->' + ex.getLineNumber());
        }
    }

    public void updateCallActivityOnLead(Map<Id, Task> newTaskMap){
        try{
            set<Id> leadIds = new set<Id>();
            List<Lead> existingLeadList = new List<Lead>();
            List<Lead> leadListToBeUpdated = new List<Lead>();
            Map<string, DateTime> callStartDateTimeByLeadId = new Map<String, DateTime>();

            if (!newTaskMap.isEmpty()){
                for (Task taskRec : newTaskMap.values()){
                    if (taskRec.CallSID__c != null && taskRec.whoid != null){
                        leadIds.add(taskRec.whoid);
                        callStartDateTimeByLeadId.put(taskRec.whoid, taskRec.CallStartTime__c);
                    }
                }
                if (leadIds.isEmpty()){
                    existingLeadList = [Select Id, Last_Called_Date_Time__c
                                        From Lead
                                        Where id in:leadIds];
                    if (!existingLeadList.isEmpty()){
                        for (Lead leadRec : existingLeadList){
                            lead leadRecTobeUpdated = new Lead();
                            leadRecTobeUpdated.Id = leadRec.id;
                            leadRecTobeUpdated.Last_Called_Date_Time__c = callStartDateTimeByLeadId.get(leadRec.id);
                            leadListToBeUpdated.add(leadRecTobeUpdated);
                        }
                        if (!leadListToBeUpdated.isEmpty()){
                            update leadListToBeUpdated;
                        }
                    }
                }
            }
        } catch (exception ex){
            system.debug('Errror-->' + ex.getMessage());
            system.debug('Errror-->' + ex.getCause());
            system.debug('Errror-->' + ex.getLineNumber());
        }
    }

    public void runTaskAssignmentLogic(list<Task> newTaskList){
        list<task> taskListTobePass = new list<Task>();
        list<Assignment_group__c> agList = new list<Assignment_group__c>();
        set<string> taskId = new set<String>();
        string taskDefaulrUserId = system.Label.Document_Task_Default_ID;
        taskListTobePass = [select id, ownerId
                            from task
                            where ownerId = :taskDefaulrUserId];
        agList = [select id, name
                  from assignment_group__c
                  where Group_Type__c = 'Task'];
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

    public void handleCallTime(List<Task> taskList){
        system.debug('Before Inserting Task');
        for (Task taskRec : taskList){

            if (taskRec.CallStartTime__c != null){
                taskRec.CallStartTime__c = taskRec.CallStartTime__c.addMinutes(-330);
            }
            if (taskRec.callEndTime__c != null){
                taskRec.callEndTime__c = taskRec.callEndTime__c.addMinutes(-330);
            }
        }
    }

    public void updateCallDetailsOnLead(Map<Id, Task> newTaskMap){
        try{
            set<Id> calledLeadIds = new Set<Id>();
            set<Id> connectedLeadIds = new Set<Id>();
            Map<String, List<Task>> listCalledTaskByLeadID = new Map<String, List<Task>>();
            Map<String, List<Task>> listConnectedTaskByLeadID = new Map<String, List<Task>>();
            List<Lead> calledLeadList = new List<Lead>();
            List<Lead> connectedLeadList = new List<Lead>();
            List<Lead> calledLeadListToBeUpdated = new List<Lead>();
            List<Lead> connectedLeadListToBeUpdated = new List<Lead>();

            for (Task taskRec : newTaskMap.values()){
                if (taskRec.CallSID__c != null){
                    //called call
                    if (listCalledTaskByLeadID.containsKey(taskRec.WhoId)){
                        List<Task> taskList = listCalledTaskByLeadID.get(taskRec.WhoId);
                        taskList.add(taskRec);
                        listCalledTaskByLeadID.put(taskRec.WhoId, taskList);
                    } else{
                        listCalledTaskByLeadID.put(taskRec.WhoId, new List<Task>{ taskRec });
                    }
                }
                if (taskRec.Call_Status__c == 'Connected'){
                    //connected call
                    if (listConnectedTaskByLeadID.containsKey(taskRec.WhoId)){
                        List<Task> taskList = listConnectedTaskByLeadID.get(taskRec.WhoId);
                        taskList.add(taskRec);
                        listConnectedTaskByLeadID.put(taskRec.WhoId, taskList);
                    } else{
                        listConnectedTaskByLeadID.put(taskRec.WhoId, new List<Task>{ taskRec });
                    }
                }
            }
            if (!listCalledTaskByLeadID.isEmpty()){
                calledLeadList = [Select Id, Last_Called_Date_Time__c, Total_Calls__c, Call_Connected__c, First_Connected_Date__c, Total_Call_Duration__c, Connected_Call_Duration__c, Last_Connected_Date__c, First_Called_Date_Time__c
                                  From Lead
                                  Where ID in:listCalledTaskByLeadID.keyset()];
                if (!calledLeadList.isEmpty()){
                    for (Lead leadRec : calledLeadList){
                        Lead leadRecToBeUpdated = new Lead();
                        leadRecToBeUpdated.Id = leadRec.Id;
                        //total call
                        // last called dat
                        //First called date/time
                        integer totalCall = 0;
                        DateTime firstCallTime;
                        DateTime lastCalledTime;
                        for (Task taskRec : listCalledTaskByLeadID.get(leadRec.Id)){
                            totalCall++;
                            if (firstCallTime == null)
                                firstCallTime = taskRec.CallStartTime__c;
                            else if (taskRec.CallStartTime__c < firstCallTime)
                                firstCallTime = taskRec.CallStartTime__c;
                            if (taskRec.CallStartTime__c > leadRec.Last_Called_Date_Time__c || leadRec.Last_Called_Date_Time__c == null)
                                leadRecToBeUpdated.Last_Called_Date_Time__c = taskRec.CallStartTime__c;
                        }
                        if (leadRec.Total_Calls__c == null)
                            leadRec.Total_Calls__c = 0;
                        leadRecToBeUpdated.Total_Calls__c = leadRec.Total_Calls__c + totalCall;
                        if (leadRec.First_Called_Date_Time__c == null)
                            leadRecToBeUpdated.First_Called_Date_Time__c = firstCallTime;
                        //leadRec.Last_Called_Date_Time__c
                        calledLeadListToBeUpdated.add(leadRecToBeUpdated);
                    }
                    if (!calledLeadListToBeUpdated.isEmpty()){
                        update calledLeadListToBeUpdated;
                    }
                }
            }
            if (!listConnectedTaskByLeadID.isEmpty()){
                connectedLeadList = [Select Id, Last_Called_Date_Time__c, Total_Calls__c, Call_Connected__c, First_Connected_Date__c, Total_Call_Duration__c, Connected_Call_Duration__c, Last_Connected_Date__c, First_Called_Date_Time__c
                                     From Lead
                                     Where ID in:listConnectedTaskByLeadID.keyset()];
                if (!connectedLeadList.isEmpty()){
                    for (Lead leadRec : connectedLeadList){
                        Lead leadRecToBeUpdated = new Lead();
                        leadRecToBeUpdated.Id = leadRec.Id;
                        //Call Connected
                        // First Connected Date - First_Connected_Date__c
                        //Connected Call Duration
                        //last connected date
                        integer connectedCall = 0;
                        DateTime firstConnectedTime;
                        DateTime lastConnectedTime;
                        integer callDuration = 0;
                        for (Task taskRec : listConnectedTaskByLeadID.get(leadRec.Id)){
                            connectedCall++;
                            if (firstConnectedTime == null)
                                firstConnectedTime = taskRec.CallStartTime__c;
                            else if (taskRec.CallStartTime__c < firstConnectedTime)
                                firstConnectedTime = taskRec.CallStartTime__c;
                            callDuration += taskRec.CallDurationInSeconds;
                            system.debug('taskRec.CallStartTime__c-->' + taskRec.CallStartTime__c);
                            system.debug('leadRec.Last_Connected_Date__c-->' + leadRec.Last_Connected_Date__c);
                            if (taskRec.CallStartTime__c > leadRec.Last_Connected_Date__c || leadRec.Last_Connected_Date__c == null)
                                leadRecToBeUpdated.Last_Connected_Date__c = taskRec.CallStartTime__c;
                            system.debug('leadRecToBeUpdated.Last_Called_Date_Time__c-->' + leadRecToBeUpdated.Last_Called_Date_Time__c);
                        }
                        if (leadRec.Call_Connected__c == null)
                            leadRec.Call_Connected__c = 0;
                        leadRecToBeUpdated.Call_Connected__c = leadRec.Call_Connected__c + connectedCall;
                        if (leadRec.Connected_Call_Duration__c == null)
                            leadRec.Connected_Call_Duration__c = 0;
                        leadRecToBeUpdated.Connected_Call_Duration__c = leadRec.Connected_Call_Duration__c + callDuration;
                        if (leadRec.First_Connected_Date__c == null)
                            leadRecToBeUpdated.First_Connected_Date__c = firstConnectedTime;
                        //leadRec.Last_Called_Date_Time__c
                        connectedLeadListToBeUpdated.add(leadRecToBeUpdated);

                    }
                    if (!connectedLeadListToBeUpdated.isEmpty()){
                        update connectedLeadListToBeUpdated;
                    }
                }
            }
        } catch (exception ex){
            system.debug('Error-->' + ex.getLineNumber());
            system.debug('Error-->' + ex.getMessage());
            system.debug('Error-->' + ex.getCause());
            system.debug('Error-->' + ex.getStackTraceString());

        }
    }

}