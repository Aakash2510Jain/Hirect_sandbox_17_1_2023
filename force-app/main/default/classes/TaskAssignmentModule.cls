public class TaskAssignmentModule{
    @future
    public static void taskAssignmentLogic(String groupName, set<string> taskId){
        string taskDefaulrUserId = system.Label.Document_Task_Default_ID;
        List<lead> updateLeadList = new List<lead>();
        List<Task> taskList = new list<Task>();
        List<Assignment_Group__c> QtoBeUpdated = new List<Assignment_Group__c>();
        Map<String, List<String>> QueueNameToQmemberIdList = new Map<String, List<String>>();
        Map<String, Integer> qNameToLastAssignedQmemberRRid = new Map<String, Integer>();
        Map<String, String> QnameAndRRidToMemberIDMap = new Map<String, String>();
        Map<String, integer> openTaskByUserId = new Map<String, integer>();
        List<Task> orderListTemp = new List<Task>();
        
        list<task> orderList = [select id, ownerId
                                from task
                                where id in:taskId and ownerId = :taskDefaulrUserId];
        system.debug('groupName::' + groupName);
        system.debug('orderList::' + orderList);
        
        QueueNameToQmemberIdList = makeCustomQueueNameToListOfUserId(groupName); // group by group member
        system.debug('QueueNameToQmemberIdList::' + QueueNameToQmemberIdList);
        qNameToLastAssignedQmemberRRid = BuildMaps.makeQNameToLastAssignedQmemberRRid(); // qname with last allocated ID
        system.debug('qNameToLastAssignedQmemberRRid::' + qNameToLastAssignedQmemberRRid);
        system.debug('qNameToLastAssignedQmemberRRid--->'+qNameToLastAssignedQmemberRRid.get(groupName));
        QnameAndRRidToMemberIDMap = makeQnameAndRRidToMemberID(groupName); // qname with qname+rrid
        system.debug('QnameAndRRidToMemberIDMap::' + QnameAndRRidToMemberIDMap);
        openTaskByUserId = makeUserIdToOpenTaskMap();
        for (Task tsk : orderList){
            system.debug('tsk-->'+tsk);
            Boolean isAssigned = false;
            Integer qMemberSize = 1;
            system.debug('QueueNameToQmemberIdList.get(groupName).size()-->'+QueueNameToQmemberIdList.get(groupName).size());
            While (QueueNameToQmemberIdList != null && qMemberSize != null && QueueNameToQmemberIdList.get(groupName) != null && isAssigned == false && qMemberSize <= QueueNameToQmemberIdList.get(groupName).size()){
                Integer currentRRid, LastRRid;
                String QnameAndRRid, qMemberID;
                system.debug('qNameToLastAssignedQmemberRRid.get(groupName)-->'+qNameToLastAssignedQmemberRRid.get(groupName));
                if (qNameToLastAssignedQmemberRRid.get(groupName) != null)
                    LastRRid = qNameToLastAssignedQmemberRRid.get(groupName);
                System.debug('LastRRid-------+++++' + LastRRid);
                if (LastRRid == null || LastRRid < 1){
                    qNameToLastAssignedQmemberRRid.remove(groupName);
                    qNameToLastAssignedQmemberRRid.put(groupName, 0);
                    currentRRid = 1;
                    System.debug('Inside 1  currentRRid' + currentRRid);
                }
                system.debug('LastRRid::' + LastRRid);
                system.debug('QueueNameToQmemberIdList.get(groupName).size()::' + QueueNameToQmemberIdList.get(groupName).size());
                if (LastRRid < QueueNameToQmemberIdList.get(groupName).size()){
                    currentRRid = LastRRid + 1;
                    System.debug('Inside 2  currentRRid' + currentRRid);
                } else{
                    currentRRid = 1;
                    LastRRid = 0;
                    System.debug('Inside 3  currentRRid' + currentRRid);
                }
                QnameAndRRid = groupName + String.valueOf(currentRRid);
                system.debug('QnameAndRRid::' + QnameAndRRid);
                system.debug('QnameAndRRidToMemberIDMap::' + QnameAndRRidToMemberIDMap);
                qMemberID = QnameAndRRidToMemberIDMap.get(QnameAndRRid);
                System.debug('QnameAndRRid::' + QnameAndRRid);
                System.debug('qMemberID::' + qMemberID);
                boolean test = true;
                if(test) {
                    system.debug('qMemberID-->'+qMemberID);
                    //qName,qMemberID,userIdbyLeadcount,ld.Learner_Uid__c,assignmentConditionSatisfied(true)
                    if (qMemberID != null){
                        system.debug('openTaskByUserId.containsKey(qMemberID)-->'+openTaskByUserId.containsKey(qMemberID));
                        system.debug('openTaskByUserId.get(qMemberID)-->'+openTaskByUserId.get(qMemberID));
                        if(openTaskByUserId.containsKey(qMemberID)){
                            if(openTaskByUserId.get(qMemberID) < integer.valueOf(system.label.Max_Open_Task) ){
                                system.debug('INSIDE IF');
                                tsk.ownerId = qMemberID;//ord.account.ownerId;
                                tsk.Task_Assigned_Date_Time__c = system.now();
                                tsk.ActivityDate = system.today() + 2;
                                taskList.add(tsk);
                                isAssigned = true;
                                //orderListTemp.add(New Order(Id=ord.Id,OwnerId=qMemberID));
                            }
                        }else{
                            system.debug('INSIDE ELSE');
                            tsk.ownerId = qMemberID;//ord.account.ownerId;
                            tsk.Task_Assigned_Date_Time__c = system.now();
                            tsk.ActivityDate = system.today() + 2;
                            taskList.add(tsk);
                            isAssigned = true;
                        }
                    }
                    system.debug('LastRRid-->'+LastRRid);
                    LastRRid = LastRRid + 1;
                    system.debug('qNameToLastAssignedQmemberRRid-->'+qNameToLastAssignedQmemberRRid);
                    qNameToLastAssignedQmemberRRid.remove(groupName);
                    qNameToLastAssignedQmemberRRid.put(groupName, LastRRid);
                    System.debug('qNameToLastAssignedQmemberRRid::' + qNameToLastAssignedQmemberRRid);
                    qMemberSize++;
                    system.debug('qMemberSize::' + qMemberSize);
                } else{
                    system.debug('LastRRid-->'+LastRRid);
                    LastRRid = LastRRid + 1;
                    system.debug('LastRRid-->'+LastRRid);
                    qNameToLastAssignedQmemberRRid.remove(groupName);
                    qNameToLastAssignedQmemberRRid.put(groupName, LastRRid);
                    System.debug('qNameToLastAssignedQmemberRRid::' + qNameToLastAssignedQmemberRRid);
                    qMemberSize++;
                }
            }
        }
        
        system.debug('qNameToLastAssignedQmemberRRid-->'+qNameToLastAssignedQmemberRRid);
        if (!qNameToLastAssignedQmemberRRid.keySet().isEmpty()){
            List<Assignment_Group__c> updateQrId = new List<Assignment_Group__c>();
            updateQrId = [Select id, name, Last_Allocated_RRid__c
                          from Assignment_Group__c
                          where Name IN:qNameToLastAssignedQmemberRRid.keySet()];
            system.debug('updateQrId-->'+updateQrId);
            for (Assignment_Group__c Q : updateQrId){
                system.debug('qNameToLastAssignedQmemberRRid.get(Q.Name)-->'+qNameToLastAssignedQmemberRRid.get(Q.Name));
                Q.Last_Allocated_RRid__c = qNameToLastAssignedQmemberRRid.get(Q.Name);
                QtoBeUpdated.add(q);
            }
        }
        system.debug('taskList::' + taskList);
        
        if (!taskList.isEmpty()){
            update taskList;
        }
        system.debug('QtoBeUpdated-->'+QtoBeUpdated);
        if (!QtoBeUpdated.isEmpty())
            Update QtoBeUpdated;
    }
    
    public static Map<String, List<String>> makeCustomQueueNameToListOfUserId(string assignmentGroupName){
        Map<String, List<String>> customQueueNameToListOfUserId = new Map<String, List<String>>();
        List<Assignment_Group_Member__c> listOfExistingQueueMembers = new List<Assignment_Group_Member__c>();
        
        listOfExistingQueueMembers = [select id, name, Out_Of_Office__c, Assignment_Group__c, Assignment_Group__r.name, Assignment_Id__c, Leave_End_Date__c, Leave_Start_Date__c, Group_Member__c, Group_Member__r.Id
                                      from Assignment_Group_Member__c
                                      where Assignment_Group__r.name = :assignmentGroupName ANd Active__c = true ];
        system.debug('listOfExistingQueueMembers-->'+listOfExistingQueueMembers);
        if (!listOfExistingQueueMembers.isEmpty()){
            for (Assignment_Group_Member__c agm : listOfExistingQueueMembers){
                if (customQueueNameToListOfUserId.containsKey(agm.Assignment_Group__r.name)){
                    customQueueNameToListOfUserId.get(agm.Assignment_Group__r.name).add(agm.Group_Member__r.Id);
                } else{
                    customQueueNameToListOfUserId.put(agm.Assignment_Group__r.name, new list<string>{ agm.Group_Member__r.Id });
                }
            }
        }
        system.debug('customQueueNameToListOfUserId::' + customQueueNameToListOfUserId);
        return customQueueNameToListOfUserId;
    }
    
    public static Map<String, Integer> makeQNameToLastAssignedQmemberRRid(){
        Map<String, Integer> qNameToLastAssignedQmemberRRid = new Map<String, Integer>();
        List<Assignment_Group__c> allExistingQueue = new List<Assignment_Group__c>([SELECT id, name, Last_Allocated_RRid__c
                                                                                    from Assignment_Group__c]);
        system.debug('allExistingQueue-->'+allExistingQueue);
        for (Assignment_Group__c q : allExistingQueue){
            if (q.Last_Allocated_RRid__c != null){
                qNameToLastAssignedQmemberRRid.put(q.name, Integer.valueOf(q.Last_Allocated_RRid__c));
            } else
                qNameToLastAssignedQmemberRRid.put(q.name, null);
        }
        system.debug('qNameToLastAssignedQmemberRRid-->'+qNameToLastAssignedQmemberRRid);
        return qNameToLastAssignedQmemberRRid;
    }
    
    public static Map<String, String> makeQnameAndRRidToMemberID(String groupName){
        //Map<String, Map<String, Integer>> qNameAndMemberIdTORoundRobinIDMaP = new Map<String, Map<String, Integer>>();
        Map<String, String> QnameAndRRidToMemberIDMap = new Map<String, String>();
        list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
        
        agmList = [select id, Assignment_Group__r.name, Assignment_Id__c, Group_Member__r.Id, Out_Of_Office__c
                   from Assignment_Group_Member__c
                   where Assignment_Group__r.name = :groupName and Out_Of_Office__c = false and Active__c = true And BreakTime_Started__c = False];
        system.debug('agmList::' + agmList);
        if (!agmList.isEmpty()){
            for (Assignment_Group_Member__c agm : agmList){
                String qName = agm.Assignment_Group__r.name;
                String qMember = string.valueOf(agm.Assignment_Id__c);
                system.debug('qName::' + qName);
                system.debug('qMember::' + qMember);
                if (!string.isBlank(qName) && !String.isBlank(qMember)){
                    String qNameAndQmamber = qName + qMember;
                    system.debug('qNameAndQmamber::' + qNameAndQmamber);
                    QnameAndRRidToMemberIDMap.put(qNameAndQmamber, String.valueOf(agm.Group_Member__r.Id));
                }
            }
        }
        
        System.debug('QnameAndRRidToMemberIDMap---'+QnameAndRRidToMemberIDMap);
        return QnameAndRRidToMemberIDMap;
    }
    public static Map<String, integer> makeUserIdToOpenTaskMap(){
        Map<String, integer> openTaskByUserId = new Map<String, integer>();
        List<Task> openTaskList = new List<Task>();
        
        User dummyUserRec = [Select Id From User where Name = 'Dummy User'];
        openTaskList = [Select Id,OwnerId From Task where Status = 'Open' And OwnerId != : dummyUserRec.Id AND Task_Assigned_Date_Time__c >: system.today() ];
        if(!openTaskList.isEmpty()){
            for(Task taskRec : openTaskList){
                if(openTaskByUserId.containskey(taskRec.OwnerId)){
                    integer openTaskCount = openTaskByUserId.get(taskRec.OwnerId) + 1 ;
                    openTaskByUserId.put(taskRec.OwnerId, openTaskCount);
                }else{
                    openTaskByUserId.put(taskRec.OwnerId, 1);
                }
            }
        }
        return openTaskByUserId;
    }
}