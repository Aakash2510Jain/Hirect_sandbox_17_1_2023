public class TransferLeadAssignmentRR {
    public static string assignmentGroupName = 'NA';
    @future
    public Static void assignLeadsToBDS(String courseName,Set<String> leadIdList , boolean TransferLeadUsed, boolean AssignLeadForRevenueTeam){
        system.debug('courseName::'+ courseName);
        assignmentGroupName 										= courseName;
        boolean withinWorkingHour 									= false;
        List<lead> updateLeadList 									= new List<lead>();
        List<Assignment_Group__c> QtoBeUpdated 						= new List<Assignment_Group__c>();
        Map<String, List<String>> QueueNameToQmemberIdList 			= new Map<String, List<String>>();
        Map<String, Boolean> userIdToUserAvailablityMap 			= new Map<String, Boolean>();
        Map<String, List<Lead>> qNameToListOfLeadsMap 				= new map<String,List<lead>>();
        Map<String, Integer> qNameAndMemberIdTORoundRobinIDMaP 		= new Map<String, Integer>();
        Map<String, Integer> qNameToLastAssignedQmemberRRid 		= new Map<String, Integer>();
        Map<String, String> QnameAndRRidToMemberIDMap				= new Map<String, String>();
        List<Lead> LeadData											= new List<Lead>();
        //In case the Method fails assign to first member 
        String Assignee = '';
        //withinWorkingHour = BuildMaps.CheckBusinessHours();
        //Getting the Leads which are in default queue from this List Lead..
        system.debug('leadIdList::'+leadIdList);
        If(leadIdList.size() > 0){
            LeadData =  [SELECT ID,Revenue_BD__c,Lead_Assigned_Date__c,Assignment_Group__c,OWNERID,Status,Is_Transfer_Lead_Used__c,Transfer_Lead_Date_Time__c FROM Lead WHERE  id IN:leadIdList limit 50000];
            //Leads by coursename where lead ids are passed to the method
            qNameToListOfLeadsMap.put(courseName,LeadData);
        }
        //Getting the Group Members Corresponding to the Course
        QueueNameToQmemberIdList 									= makeCustomQueueNameToListOfUserId(courseName); // CourseName by group member
        userIdToUserAvailablityMap 									= makeuserIdToUserAvailablityMap(courseName); // Group members where out of office is false
        
        //qNameAndMemberIdTORoundRobinIDMaP = makeqNameAndMemberIdTORoundRobinIDMaP(courseName);
        qNameToLastAssignedQmemberRRid 								= BuildMaps.makeQNameToLastAssignedQmemberRRid(); // qname with last allocated ID
        QnameAndRRidToMemberIDMap 									= makeQnameAndRRidToMemberID(courseName); // Map of qname+rrid(Key) Group Member Id(Value)
        //BuildMaps.validateUserCapacityForRM(courseName,leadIdList);
        for(String qName: qNameToListOfLeadsMap.keySet()){
            if(qName != null){
                for(lead ld: qNameToListOfLeadsMap.get(qName)){
                    Boolean isAssigned = false;
                    Integer qMemberSize = 1;
                    While(QueueNameToQmemberIdList != null && qMemberSize != null && QueueNameToQmemberIdList.get(qName) != null && isAssigned == false && qMemberSize <= QueueNameToQmemberIdList.get(qName).size()){
                        Assignee = QueueNameToQmemberIdList.get(qName)[0];
                        Integer currentRRid, LastRRid; 
                        String QnameAndRRid, qMemberID;
                        if(qNameToLastAssignedQmemberRRid.get(qName) != null)
                            LastRRid = qNameToLastAssignedQmemberRRid.get(qName); 
                        if(LastRRid == null || LastRRid < 1){
                            qNameToLastAssignedQmemberRRid.remove(qName);
                            qNameToLastAssignedQmemberRRid.put(qName, 0);
                            currentRRid = 1;
                        }
                        if(LastRRid < QueueNameToQmemberIdList.get(qName).size()){
                            currentRRid = LastRRid + 1;
                        }
                        else{
                            currentRRid = 1;
                            LastRRid = 0;
                        }
                        QnameAndRRid = qName + String.valueOf(currentRRid);
                        qMemberID = QnameAndRRidToMemberIDMap.get(QnameAndRRid);
                        boolean test = true;
                        if(userIdToUserAvailablityMap.get(qMemberID) == true){
                            system.debug('AssignLeadForRevenueTeam-->'+AssignLeadForRevenueTeam);
                            
                            if(AssignLeadForRevenueTeam){
                                system.debug('Id of queuemember-->'+Id.valueOf(qMemberID));
                                ld.Revenue_BD__c = Id.valueOf(qMemberID);
                            }else{
                                system.debug('inside avaibility');
                                ld.ownerId = Id.valueOf(qMemberID);
                                if(ld.Assignment_Group__c != null)
                                    ld.Assignment_Group__c =ld.Assignment_Group__c+', '+assignmentGroupName; 
                                else
                                    ld.Assignment_Group__c = assignmentGroupName; 
                                //ld.Lead_Assigned_Date__c = system.today();
                                if(TransferLeadUsed){
                                    ld.Is_Transfer_Lead_Used__c = true;
                                    ld.Transfer_Lead_Date_Time__c = system.now();
                                }
                                //ld.Lead_Assigned_Time__c = Time.newInstance(Datetime.now().hour(), Datetime.now().minute(), Datetime.now().second(), 0);
                                ld.status = 'Working';
                                ld.Lead_Stage__c = 'New';
                            }
                            updateLeadList.add(ld); 
                            isAssigned = true;
                            if(BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID) == null)
                                BuildMaps.mapofMemidByTodayLeadCount.put(qMemberID,0);
                            BuildMaps.mapofMemidByTodayLeadCount.put(qMemberID,BuildMaps.mapofMemidByTodayLeadCount.get(qMemberID)+1);
                            if(BuildMaps.mapofMemidByPendingLeads.get(qMemberID) == null)
                                BuildMaps.mapofMemidByPendingLeads.put(qMemberID,0);
                            BuildMaps.mapofMemidByPendingLeads.put(qMemberID,BuildMaps.mapofMemidByPendingLeads.get(qMemberID) + 1);
                            if(BuildMaps.mapofMemidByTodayNewLead.get(qMemberID) == null)
                                BuildMaps.mapofMemidByTodayNewLead.put(qMemberID,0);
                            BuildMaps.mapofMemidByTodayNewLead.put(qMemberID,BuildMaps.mapofMemidByTodayNewLead.get(qMemberID)+1);
                            if(BuildMaps.mapofMemidByAssignedLead.get(qMemberID) == null)
                                BuildMaps.mapofMemidByAssignedLead.put(qMemberID,0);
                            BuildMaps.mapofMemidByAssignedLead.put(qMemberID,BuildMaps.mapofMemidByAssignedLead.get(qMemberID) + 1);
                            
                        }
                        LastRRid = LastRRid +1; 
                        qNameToLastAssignedQmemberRRid.remove(qName);
                        qNameToLastAssignedQmemberRRid.put(qName, LastRRid);
                        qMemberSize ++;
                    }
                }
            }
        }
        
        if(!qNameToLastAssignedQmemberRRid.keySet().isEmpty())
        {
            List<Assignment_Group__c> updateQrId = new List<Assignment_Group__c>();
            updateQrId = [Select id, name, Last_Allocated_RRid__c  from Assignment_Group__c where Name IN: qNameToLastAssignedQmemberRRid.keySet()];
            for(Assignment_Group__c Q: updateQrId)
            {
                Q.Last_Allocated_RRid__c = qNameToLastAssignedQmemberRRid.get(Q.Name);
                QtoBeUpdated.add(q);
            }
        }
        System.debug('updateLeadList---'+updateLeadList);
        if(!updateLeadList.isEmpty()){
            try{
                System.debug('updateLeadList---'+updateLeadList);
                LeadQueuableJob  lqj= new LeadQueuableJob(updateLeadList);
                system.enqueueJob(lqj);
                //Update updateLeadList;  
            }catch(exception e){
                system.debug('Exception'+ e.getMessage() +'@@@@'+e.getLineNumber());
            }
            
        }
        if(!QtoBeUpdated.isEmpty())
            Update QtoBeUpdated;
        
    }
    
    public static map<String,List<lead>> makeQueueNameToListOfAssignedLeadsMap(string courseName,set<String> leadId){
        system.debug('courseName::'+courseName);
        system.debug('leadId::'+leadId);
        map<String,string> sourceIntentByGroupMap = new map<String,String>();
        Map<String, List<lead>> groupNameByLeads = new Map<String, List<lead>>();
        List<Lead> leadsInQueue = [SELECT ID,Lead_Assigned_Date__c,OWNERID,Status FROM Lead WHERE id in:leadId limit 50000];
        system.debug('leadsInQueue::'+leadsInQueue);
        if(!leadsInQueue.isEmpty()){
            for(Lead ld: leadsInQueue){
                if(ld.status != null){
                    if(groupNameByLeads.containsKey(courseName))
                    {
                        groupNameByLeads.get(courseName).add(ld);    
                    }else{
                        groupNameByLeads.put(courseName,new List<lead>{ld});      
                    }
                }
            }
        }
        System.debug('QueueNameToListOfAssignedCasesMap::'+groupNameByLeads);
        return groupNameByLeads;
    }
    
    public static Map<String, List<String>> makeCustomQueueNameToListOfUserId(string assignmentGroupName){
        
        List<Assignment_Group__c> queueWithQueueMembers 					= new List<Assignment_Group__c>();
        List<Assignment_Group_Member__c > listOfExistingQueueMembers 		= new List<Assignment_Group_Member__c >();
        Map<String, List<String>> customQueueNameToListOfUserId 			= new Map<String, List<String>>();
        Map<String, Id> queueNameToQueueIdMap 								= new Map<String, Id> ();
        Set<Id> existingQueueMembersQueueId 								= new Set<Id>();
        
        listOfExistingQueueMembers											= [select id, name,Out_Of_Office__c,Assignment_Group__c,Assignment_Group__r.name, Assignment_Id__c,Leave_End_Date__c,Leave_Start_Date__c,Group_Member__c,Group_Member__r.Id from Assignment_Group_Member__c where Assignment_Group__r.name =: assignmentGroupName ];
        system.debug('listOfExistingQueueMembers::'+listOfExistingQueueMembers);
        
        if(!listOfExistingQueueMembers.isEmpty()){
            for(Assignment_Group_Member__c agm : listOfExistingQueueMembers){
                if(customQueueNameToListOfUserId.containsKey(agm.Assignment_Group__r.name)){
                    customQueueNameToListOfUserId.get(agm.Assignment_Group__r.name).add(agm.Group_Member__r.Id);
                }else{
                    customQueueNameToListOfUserId.put(agm.Assignment_Group__r.name,new list<string>{agm.Group_Member__r.Id});
                }
            }
        }
        system.debug('customQueueNameToListOfUserId::'+customQueueNameToListOfUserId);
        return customQueueNameToListOfUserId;
    }
    
    public static Map<String, Boolean> makeuserIdToUserAvailablityMap(string assignmentGroupName){
        /**Need to  handle leave*/ 
        Map<String, Boolean> userIdToUserAvailablityMap 					= new Map<String, Boolean>();   
        List<Assignment_Group_Member__c> agentAvailablity 					= new List<Assignment_Group_Member__c>();  
        // Assignment group member by coursename and out of office is FALSE
        agentAvailablity 													= [select id,Out_Of_Office__c,Group_Member__r.Id,Assignment_Group__r.name from Assignment_Group_Member__c where Assignment_Group__r.name =: assignmentGroupName and Out_Of_Office__c = false];
        
        if(!agentAvailablity.isEmpty()){        
            for(Assignment_Group_Member__c Aa: agentAvailablity)
            {
                userIdToUserAvailablityMap.put(aa.Group_Member__r.Id, true);    
            }
        }
        System.debug('userIdToUserAvailablityMap-----'+userIdToUserAvailablityMap);
        return userIdToUserAvailablityMap;
    }
    
    public static Map<String, Integer> makeqNameAndMemberIdTORoundRobinIDMaP(String groupName){
        Map<String, Integer> qNameAndMemberIdTORoundRobinIDMaP = new Map<String, Integer>();
        list<Assignment_Group_Member__c> agmList = new list<Assignment_Group_Member__c>();
        agmList = [select id,Assignment_Group__r.name,Assignment_Id__c,Group_Member__r.Id from Assignment_Group_Member__c where Assignment_Group__r.name =: groupName];
        
        if(!agmList.isEmpty()){
            for(Assignment_Group_Member__c agm : agmList){
                String qName = agm.Assignment_Group__r.name; String qMember = agm.Group_Member__r.Id;
                if(!string.isBlank(qName) && !String.isBlank(qMember)){
                    String qNameAndQmamber = qName+qMember;
                    qNameAndMemberIdTORoundRobinIDMaP.put(qNameAndQmamber, Integer.valueOf(agm.Assignment_Id__c));
                } 
            }
        }
        return qNameAndMemberIdTORoundRobinIDMaP;        
    }
    
    public static Map<String, String> makeQnameAndRRidToMemberID(String groupName){
        Map<String, String> QnameAndRRidToMemberIDMap 			= new Map<String, String>();
        list<Assignment_Group_Member__c> agmList 				= new list<Assignment_Group_Member__c>();
        
        agmList 												= [select id,Assignment_Group__r.name,Assignment_Id__c,Group_Member__r.Id,Out_Of_Office__c from Assignment_Group_Member__c where Assignment_Group__r.name =: groupName and Out_Of_Office__c = false];
        system.debug('agmList::'+agmList);
        if(!agmList.isEmpty()){
            for(Assignment_Group_Member__c agm : agmList){
                String qName 									= agm.Assignment_Group__r.name; 
                String qMember 									= string.valueOf(agm.Assignment_Id__c);
                system.debug('qName::'+qName);
                system.debug('qMember::'+qMember);
                if(!string.isBlank(qName) && !String.isBlank(qMember)){
                    String qNameAndQmamber = qName+qMember;
                    system.debug('qNameAndQmamber::'+qNameAndQmamber);
                    QnameAndRRidToMemberIDMap.put(qNameAndQmamber, String.valueOf(agm.Group_Member__r.Id));
                } 
            }
        }
        
        return QnameAndRRidToMemberIDMap;        
    }
}