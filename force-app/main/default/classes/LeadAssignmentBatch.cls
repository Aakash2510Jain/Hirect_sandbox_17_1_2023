public class LeadAssignmentBatch implements 

Database.Batchable<sObject>, Database.Stateful {
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
   DateTime currentTime = system.now();
        DateTime threeHour = currentTime.addMinutes(-180);
        DateTime threeAndHalfHourBefore = currentTime.addMinutes(-210);
        
        String appIndiaRegQueueId = [SELECT Id, Type
                                     FROM Group
                                     WHERE Type = 'Queue' AND Name =:constants.PUBLIC_LEAD_QUEUE
                                     limit 1].Id;
        
        String Query = 'Select Active_level__c,Address,Ad_Group_Id__c,Ad_id__c,Amount__c,Annual_Turnover__c,Approval_Status__c,Audit_Rejection_Reason__c,Audit_Status__c,BD__c,Budget__c,Call_Connected__c,Campaign__c,Channel__c,Chat_level__c,City,Clickpay_1day__c,Clickpay_3day__c,Closed_By_Remarketing__c,CommentA__c,CommentB__c,CommentC__c,CommentD__c,Company,Company_Audit_Status__c,Company_ID__c,Company_Profile_Link__c,Company_recruiter__c,Company_Size__c,Connected_Call_Duration__c,ConvertedAccountId,ConvertedContactId,ConvertedDate,ConvertedOpportunityId,Country,CreatedById,CreatedDate,Descison_Maker__c,Discount_in_Amount__c,Discount_Threshold__c,Discount_Type__c,Discount__c,DNP_Count__c,Don_t_Change_Source__c,Double_chat_level__c,Email,EmailBouncedDate,EmailBouncedReason,Email_Copy__c,Enter_URL__c,Feed_Item_Id__c,FirstName,First_Call_Time_Before_Onboarding__c,First_Connected_Date__c,First_Visit_Time__c,Followup_Comments__c,Functional_Area__c,GCL_Id__c,GeocodeAccuracy,Homepage_Visited_Time__c,Id,Industry,IsConverted,IsDeleted,IsUnreadByOwner,Is_3_Hours_Completed__c,Is_Assigned__c,Is_Rejected__c,Is_Remarketing_Lead__c,Is_Remote_Job__c,Jigsaw,JigsawContactId,Job_Description__c,Job_Location__c,Job_Requirements__c,Job_title__c,KAM_Owner__c,KAM_V1__c,Key_Word_Id__c,LastActivityDate,LastModifiedById,LastModifiedDate,LastName,LastReferencedDate,LastViewedDate,Last_Called_Date_Time__c,Last_Connected_Call_Before_Onboarding__c,Last_connected_call_duration_before_onba__c,Last_connected_call_duration_hh_mm_ss__c,Last_Connected_Date__c,Latest_Call_Time_Before_Onboarding__c,Latitude,LeadSource,Lead_Assigned_Date__c,Lead_Score__c,Lead_Stage__c,Lead_Substage__c,Learner_Uid__c,LinkedIn_Referral_Link__c,Location__c,Longitude,MasterRecordId,MiddleName,MobilePhone,Name,Network__c,Next_Followup_Date_Time__c,No_Of_Calls_Made_Before_Onboarding__c,No_Of_Payments_Done__c,NumberOfEmployees,NumberOfLiveJobs__c,Onboarding_Completed__c,Onboarding_Stages__c,OwnerId,Paid_Amount__c,Payment_Captured__c,Payment_Date__c,Payment_initiated_Date_Time__c,Payment_initiated_Date__c,Payment_Status__c,Phone,PhotoUrl,Plan_Bought__c,Plan_Expiry_Date__c,Plan_Upgraded_To__c,PostalCode,Product__c,Qualification_Reason__c,Qualification_Status__c,Quantity__c,Rating,Recruiter_Audit_Status__c,Recruiter_Id__c,Recruiter_Profile_Link__c,RegistrationProgress__c,Reject_Reason__c,Remarketing_Assignment_Reason__c,Remarketing_Transferred_Stage__c,Remote_Job__c,RequestsCall__c,RM_assigned_Date_Time__c,RM_KAM_Lead_Lost_Reason__c,RM_KAM_Lead_Stage__c,RM_KAM_Tickets_Created__c,RM_KAM_Tickets_Open__c,RM_V1__c,RM__c,Sales_Owner_Assigned_to__c,Sales_Owner__c,Salutation,Saved_candidates__c,Source_Source_of_acquisition__c,State,Status,Street,Sub_Status__c,Suffix,SystemModstamp,testfield__c,Test_Round_Robin__c,Title,Total_Calls__c,Total_Call_Duration__c,Trial_End_Date__c,Trigger_1day__c,Trigger_3day__c,Under_Approval__c,UTM_Ad_Position__c,UTM_Campaign__c,UTM_Device__c,UTM_Medium__c,UTM_Source__c,Website From Lead Where OwnerId =: appIndiaRegQueueId AND  Homepage_Visited_Time__c = null ANd Company = \'no_company_name\' AND CreatedDate >= :threeHour  ';        system.debug('Query------------------'+Query);
        return Database.getQueryLocator(Query);
        
    }
    public void execute(Database.BatchableContext bc, List<Lead> newLeadList){
        system.debug('newLeadList'+newLeadList);
        Set<Lead> assignedLead = new Set<Lead>();
        Boolean IsLeadAssigned = False;
        list<lead> newLeadListTemp 												= new list<lead>();
        list<lead> DefaultQueueList 											= new list<lead>();
        list<String> matchedCriterias 											= new list<String>();
        map<string,list<Lead>> mapofExecutionIdByListLead 						= new map<String,List<Lead>>();
        map<String,integer> mapofExeIdByEntryCount								= new map<string,Integer>();
        map<String,String> mapofExeIdByEvaluaationExp 							= new map<string,String>();
        map<String,List<String>> mapByallFields 		            	        = new map<String,List<String>>();
        map<String,List<String>> mapofFieldsWithPossibleValues 			        = new map<String,List<String>>();
        map<String,map<String,Map<String,String>>> matchingTypeFieldByCriteria  = new map<String,map<String,Map<String,String>>>();
        map<string,map<string,List<String>>> multipleCriteriasForFields 	    = new map<string,map<string,List<String>>>();
        map<string,map<string,List<Decimal>>> allotedFieldbySequenceList	    = new map<string, map<string,List<Decimal>>>();
        map<String,List<Lead>> mapofRMGroupNameByLeadList 						= new map<String,List<Lead>>();
        map<string,map<string,String>> expectedValuebyCriteria 					= new map<string,map<string,String>>();
        map<String,String> leadIdByMatchedCriterias 							= new map<String,String>();
        map<string,map<string,Decimal>> allotedFieldbySequence 					= new map<string,map<string,Decimal>>();
        map<string,String> criteriaNameById 									= new Map<String,String>();
        map<String,map<string,list<String>>> fieldByMatchingType 				= new map<String,map<string,list<String>>>();
        map<String,map<string,String>> fieldByFieldType 						= new map<String,map<string,String>>();
        map<string,String> leadValueForFields 									= new Map<String,String>();
        map<String,List<Lead>> mapofCriteriaIdByLeadList 						= new map<String,List<Lead>>();
        
        map<String,List<Lead>> mapofFbGroupNameByLeadList = new map<String,List<Lead>>();
        map<string,Decimal> allotedMarksbySequence = new Map<String,Decimal>();
        set<String> newLeadsSet = new set<String>();
        
        if(newLeadList != null){
            for(Lead leadRec:newLeadList){
                newLeadListTemp.add(leadRec);
                newLeadsSet.add(leadRec.Id);
            }
        }
        
        string queueId = [SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name = 'Lead Default Queue' limit 1].Id;
        list<Default_Assignment_Group__mdt> defaultGroupName = [select id,Group_Name__c from Default_Assignment_Group__mdt];
        List<Execution_Criteria__c> AvailableCriterias = [SELECT Enabled__c,Evaluation_Expression_For_Execution__c,Id,Name ,(SELECT Execution_Criteria__c,serial__c,Field_Name__c,Field_Type__c,Matching_Type__c,Matching_Value__c,Related_Object__c,Scorecard_Execution_Criteria_Name__c,Scorecard__c,Sequence__c FROM Execution_Criteria_Entry__r WHERE Execution_Criteria__c != null ORDER BY Sequence__c ASC)FROM Execution_Criteria__c where Enabled__c = true];
        
        for(Execution_Criteria__c scr:AvailableCriterias){
            map<string,string> fieldNameByMatching                                  = new Map<String,string>();
            map<string,List<Decimal>> allotedFieldbySequenceListMap 				= new Map<String,List<Decimal>>();
            map<string,Decimal> allotedFieldbySequenceMap 							= new Map<String,Decimal>();
            map<string,List<String>> fieldByMatchingTypeMap                        = new map<string,List<String>>();
            map<string,String>fieldByFieldTypeMap                                 = new map<string,String>();
            map<String,Map<String,String>> matchingTypeAndValuesByField 			= new map<String,Map<String,String>>();
            List<String> allFields 													= new List<String>();  
            
            for(Execution_Criteria_Entry__c exe:scr.Execution_Criteria_Entry__R){
                
                if(mapofFieldsWithPossibleValues.containsKey(exe.Field_Name__c)){
                    mapofFieldsWithPossibleValues.get(exe.Field_Name__c).add(exe.Matching_Value__c);
                }else{ 
                    mapofFieldsWithPossibleValues.put(exe.Field_Name__c,new list<string>{exe.Matching_Value__c});
                }
                
                if(fieldByMatchingTypeMap.containsKey(exe.Field_Name__c)){
                    fieldByMatchingTypeMap.get(exe.Field_Name__c).add(exe.Matching_Type__c);
                }else{ 
                    fieldByMatchingTypeMap.put(exe.Field_Name__c,new list<string>{exe.Matching_Type__c});
                }
                
                if(matchingTypeAndValuesByField.containsKey(exe.Field_Name__c)){
                    matchingTypeAndValuesByField.get(exe.Field_Name__c).put(exe.Matching_Type__c,exe.Matching_Value__c);
                }else{ 
                    map<string,String> matchingTypeAndValues = new  map<string,String>();
                    matchingTypeAndValues.put(exe.Matching_Type__c,exe.Matching_Value__c);
                    matchingTypeAndValuesByField.put(exe.Field_Name__c,matchingTypeAndValues);
                }
                
                if(allotedFieldbySequenceMap.containsKey(exe.Field_Name__c)){
                    allotedFieldbySequenceListMap.get(exe.Field_Name__c).add(exe.Sequence__c);
                }else{ 
                    allotedFieldbySequenceListMap.put(exe.Field_Name__c,new list<Decimal>{exe.Sequence__c});
                }
                allotedFieldbySequenceMap.put(exe.Field_Name__c,exe.Sequence__c);
                fieldNameByMatching.put(exe.Field_Name__c,exe.Matching_Value__c);
                fieldByFieldTypeMap.put(exe.Field_Name__c,exe.Field_Type__c);
                allFields.add(exe.Field_Name__c);
            }
            
            fieldByMatchingType.put(scr.Name,fieldByMatchingTypeMap);
            fieldByFieldType.put(scr.Name,fieldByFieldTypeMap);
            mapByallFields.put(scr.Name,allFields);
            allotedFieldbySequence.put(scr.Name,allotedFieldbySequenceMap);
            allotedFieldbySequenceList.put(scr.Name,allotedFieldbySequenceListMap);
            matchingTypeFieldByCriteria.put(scr.Name,matchingTypeAndValuesByField);
            mapofExeIdByEntryCount.put(scr.Id,scr.Execution_Criteria_Entry__r.size());
            mapofExeIdByEvaluaationExp.put(scr.Name,scr.Evaluation_Expression_For_Execution__c);
            expectedValuebyCriteria.put(scr.Name,fieldNameByMatching);
            multipleCriteriasForFields.put(scr.Name,mapofFieldsWithPossibleValues);
            criteriaNameById.put(scr.Name,scr.Id);
            
        }
       
        String logicalValues = '';
        
        for(Lead ld:newLeadListTemp){
            boolean leadTemp = false;
            List<String> matchedCriteriasName = new List<String>();
            for(String criteriaName : expectedValuebyCriteria.keyset()){
                system.debug('criteriaName'+criteriaName);
                String Booleanvalues = mapofExeIdByEvaluaationExp.get(criteriaName);
                system.debug('Booleanvalues'+Booleanvalues);
                integer matchedValues = 0;
                
                Decimal recursionValue = 0;
                
               for(String field:mapByallFields.get(criteriaName))  {
                    
                    recursionValue = allotedFieldbySequence.get(criteriaName).get(field);
                    if(matchingTypeFieldByCriteria.get(criteriaName).get(field).size() <= 1){
                        if(fieldByFieldType.get(criteriaName).get(field) == 'Number'){
                            for(String str : fieldByMatchingType.get(criteriaName).get(field)){
                                system.debug('field::'+field +'str'+str+'recursionValue'+recursionValue);
                                if(str == '<' || str == '<='){
                                    if(Integer.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)) >= Integer.valueOf(ld.get(field))){
                                        matchedValues++;
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'True');
                                    }else{
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'False');
                                    } 
                                }else if(str == '>' || str == '>='){
                                    if(Integer.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)) <= Integer.valueOf(ld.get(field))){
                                        matchedValues++;
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'True');
                                    }else{
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'False');
                                    }
                                }else{
                                    if(Integer.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)) == Integer.valueOf(ld.get(field))){
                                        matchedValues++;
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'True');
                                    }else{
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'False');
                                    }
                                }
                            }
                        }
                        else if(fieldByFieldType.get(criteriaName).get(field) == 'Checkbox'){
                            if(ld.get(field) == Boolean.valueOf(expectedValuebyCriteria.get(criteriaName).get(field))){
                                matchedValues++;
                                Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'True');
                            }else{
                                Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'False');
                            }
                        }
                        else{
                            for(String str : fieldByMatchingType.get(criteriaName).get(field)){
                                if(str == '=='){
                                    if(expectedValuebyCriteria.get(criteriaName).get(field).contains(',')){
                                        List<String> commaSeparatedValues = expectedValuebyCriteria.get(criteriaName).get(field).split(',');
                                        for(String Str1:commaSeparatedValues){
                                            if(Str1 == String.valueOf(ld.get(field))){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'True');
                                            } 
                                        }
                                    }else{
                                        
                                        if(expectedValuebyCriteria.get(criteriaName).get(field) == String.valueOf(ld.get(field))){
                                            matchedValues++;
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'True');
                                        }else{
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'False');
                                        }   
                                    }    
                                }else if(str == '!='){
                                    if(expectedValuebyCriteria.get(criteriaName).get(field) == 'null'){
                                        
                                        if(ld.get(field) == null){
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'False');
                                        }else{
                                            if(expectedValuebyCriteria.get(criteriaName).get(field) != ld.get(field)){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'True');
                                            }else{
                                                Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'False');
                                            }    
                                        }
                                    }else{
                                        if(expectedValuebyCriteria.get(criteriaName).get(field) != String.valueOf(ld.get(field))){
                                            matchedValues++;
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'True');
                                        }else{
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'False');
                                        }     
                                    }
                                }else if(str == 'CONTAINS'){
                                    system.debug('Coming Here');
                                    if(String.valueOf(ld.get(field)) != null){
                                        if(String.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)).contains(String.valueOf(ld.get(field)))){
                                            matchedValues++;
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'True');
                                        }else{
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'False');
                                        }   
                                    }else{
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'False');
                                    }
                                    
                                }
                                else if(str == 'DOES NOT CONTAIN'){
                                    if(!expectedValuebyCriteria.get(criteriaName).get(field).contains(String.valueOf(ld.get(field)))){
                                        matchedValues++;
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'True');
                                    }
                                    else{
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'False');
                                    }
                                }
                            }
                        }
                    }
                    else{
                        integer start = 0;
                        for(String str : matchingTypeFieldByCriteria.get(criteriaName).get(field).keyset()){
                            if(fieldByFieldType.get(criteriaName).get(field) == 'Number'){
                                if(str == '<' || str == '<='){
                                    if(Integer.valueOf(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str)) >= Integer.valueOf(ld.get(field))){
                                        matchedValues++;
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                    }else{
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                    } 
                                }else if(str == '>' || str == '>='){
                                    if(Integer.valueOf(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str)) <= Integer.valueOf(ld.get(field))){
                                        matchedValues++;
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                    }else{
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                    }
                                }else{
                                    if(Integer.valueOf(expectedValuebyCriteria.get(criteriaName).get(field)) == Integer.valueOf(ld.get(field))){
                                        matchedValues++;
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'True');
                                    }else{
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'False');
                                    }
                                }
                            }
                            else if(fieldByFieldType.get(criteriaName).get(field) == 'Checkbox'){
                                if(ld.get(field) == Boolean.valueOf(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str))){
                                    matchedValues++;
                                    Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                }else{
                                    Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'false');
                                }
                            }
                            else{
                                if(str == '=='){
                                    if(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str).contains(',')){
                                        List<String> commaSeparatedValues = expectedValuebyCriteria.get(criteriaName).get(field).split(',');
                                        for(String Str1:commaSeparatedValues){
                                            if(Str1 == String.valueOf(ld.get(field))){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                            } else{
                                                Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                            }
                                        }
                                    }else{
                                        if(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str) == String.valueOf(ld.get(field))){
                                            matchedValues++;
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                        }else{
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                        }   
                                    }    
                                }
                                else if(str == '!='){
                                    if(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str) == 'null'){
                                        if(ld.get(field) == null){
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                            
                                        }else{
                                            if(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str) != ld.get(field)){
                                                matchedValues++;
                                                Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                            }else{
                                                Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                            }    
                                        }
                                    }else{
                                        if(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str) != String.valueOf(ld.get(field))){
                                            matchedValues++;
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                        }else{
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                        }     
                                    }
                                }
                                else if(str == 'CONTAINS'){
                                    system.debug('Coming Here');
                                    if(String.valueOf(ld.get(field)) != null){
                                        if(String.valueOf(matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str)).contains(String.valueOf(ld.get(field)))){
                                            matchedValues++;
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                        }else{
                                            Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                        }   
                                    }else{
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(recursionValue),'False');
                                    }
                                    
                                }
                                else if(str == 'DOES NOT CONTAIN'){
                                    if(!matchingTypeFieldByCriteria.get(criteriaName).get(field).get(str).contains(String.valueOf(ld.get(field)))){
                                        matchedValues++;
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'True');
                                    }
                                    else{
                                        Booleanvalues = Booleanvalues.replace(string.valueOf(allotedFieldbySequenceList.get(criteriaName).get(field)[start]),'False');
                                    }
                                }
                            }
                            system.debug('Booleanvalues::'+Booleanvalues);
                            start++;
                        }
                    }
                }
                system.debug('Booleanvalues'+Booleanvalues);
                if(Booleanvalues == 'false'){
                    leadTemp = False;
                }else if(Booleanvalues == 'true'){
                    leadTemp = True;
                }else{
                    leadTemp = BooleanExpressionCalculation.evaluateExpression(Booleanvalues);    
                }
                
                if(leadTemp == true){
                    assignedLead.add(ld);
                    matchedCriterias.add(criteriaName);
                }
            }
            if(assignedLead.contains(ld)){
                system.debug('assignedLead'+assignedLead);   
            }else{
                DefaultQueueList.add(ld);    
            }
            if(matchedCriterias.size() > 0){
                mapofExecutionIdByListLead.put(criteriaNameById.get(matchedCriterias[0]),new list<lead>(assignedLead));    
            }
        }
        List<Lead> updateLeadList = new List<Lead>();
        system.debug('DefaultQueueList-Size :::'+DefaultQueueList.size()+'@@@The List :::::'+DefaultQueueList);
        map<String,List<Lead>> mapofGlobalGroupNameByLeadList = new map<String,List<Lead>>();
        DefaultGroupAssignment__c dgc = [Select id,Name,Group_Id__c from DefaultGroupAssignment__c where name = 'Global Lead Team'][0];
        
        if(DefaultQueueList.size() > 0 && DefaultQueueList != null){
            mapofGlobalGroupNameByLeadList.put(dgc.Name,DefaultQueueList);
        }
        
        system.debug('mapofGlobalGroupNameByLeadList---------@@'+mapofGlobalGroupNameByLeadList);
        system.debug('mapofExecutionIdByListLead---------@@'+mapofExecutionIdByListLead);
        
        //Round Robin LOGIC :: 
        list<Assignment_Group__c> agList = [SELECT id,name,Lead_Assigning_Criteria__c from assignment_group__c where Lead_Assigning_Criteria__c in: mapofExecutionIdByListLead.keySet()];
        map<string,list<lead>> mapOfGroupNameByListLead = new map<string,list<lead>>();
        
        //If some Group have been Assigned
        if(!agList.isEmpty()){
            for(assignment_group__c assGroup : agList){
                mapOfGroupNameByListLead.put(assGroup.name, mapofExecutionIdByListLead.get(assGroup.Lead_Assigning_Criteria__c));
            }
            list<String> leadIdList = new list<String>();
            map<string,list<String>> mapofGroupnameByLeadIdList = new map<String,list<String>>();
            for(String mapKey : mapOfGroupNameByListLead.keySet()){
                for(lead ld : mapOfGroupNameByListLead.get(mapKey)){
                    if(mapofGroupnameByLeadIdList.containsKey(mapKey)){
                        mapofGroupnameByLeadIdList.get(mapKey).add(ld.Id);
                    }else{
                        mapofGroupnameByLeadIdList.put(mapKey,new list<String>{ld.Id});
                    }
                }
                Set<string> tempId = new Set<String>(mapofGroupnameByLeadIdList.get(mapKey));
                system.debug('mapKey---------@@'+mapKey+'The Leads To beAssigned @@@'+tempId.size()+ tempId);
                RoundRobinForBatchApex.assignLeadsToBDS(mapKey,tempId);
            }
        }
        //If No group is Assigned
        
        if(!mapofGlobalGroupNameByLeadList.isEmpty()){
            set<String> tempId = new set<String>();
            for(string mapKey : mapofGlobalGroupNameByLeadList.keySet()){
                for(Lead ld : mapofGlobalGroupNameByLeadList.get(mapKey)){
                    tempId.add(ld.id);
                }
                system.debug('mapKey---------@@'+mapKey+'The Leads To beAssigned @@@'+tempId.size()+ tempId);
                RoundRobinForBatchApex.assignLeadsToBDS(mapKey,tempId);
            }
        }
        
    }
    
    public void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + 'records processed');
    }
   
}