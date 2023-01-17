public class UserTrackingHelper{
    static UserTrackingHelper handlerInstance;
    
    public static UserTrackingHelper getInstance(){
        if (handlerInstance == null)
            handlerInstance = new UserTrackingHelper();
        return handlerInstance;
    }
    
    public void afterinsert(Map<Id, User_Tracking__c> newUserTrackingMap){
        try{
            String hirectLeadQueue = [SELECT Id, Type
                                      FROM Group
                                      WHERE Type = 'Queue' AND Name = :constants.PRIVATE_LEAD_QUEUE
                                      limit 1].Id;
            
            List<Lead> leadlist = [SELECT Active_level__c, Address, Ad_Group_Id__c, Ad_id__c, Amount__c, Annual_Turnover__c, Approval_Status__c, Audit_Rejection_Reason__c, Audit_Status__c, BD__c, Budget__c, Call_Connected__c, Campaign__c, Channel__c, Chat_level__c, City, Clickpay_1day__c, Clickpay_3day__c, Closed_By_Remarketing__c, CommentA__c, CommentB__c, CommentC__c, CommentD__c, Company, Company_Audit_Status__c, Company_ID__c, Company_Profile_Link__c, Company_recruiter__c, Company_Size__c, Connected_Call_Duration__c, ConvertedAccountId, ConvertedContactId, ConvertedDate, ConvertedOpportunityId, Country, CreatedById, CreatedDate, Descison_Maker__c, Discount_in_Amount__c, Discount_Threshold__c, Discount_Type__c, Discount__c, DNP_Count__c, Don_t_Change_Source__c, Double_chat_level__c, Email, EmailBouncedDate, EmailBouncedReason, Email_Copy__c, Enter_URL__c, Feed_Item_Id__c, FirstName, First_Call_Time_Before_Onboarding__c, First_Connected_Date__c, First_Visit_Time__c, Followup_Comments__c, Functional_Area__c, GCL_Id__c, GeocodeAccuracy, Homepage_Visited_Time__c, Id, Industry, IsConverted, IsDeleted, IsUnreadByOwner, Is_3_Hours_Completed__c, Is_Assigned__c, Is_Rejected__c, Is_Remarketing_Lead__c, Is_Remote_Job__c, Jigsaw, JigsawContactId, Job_Description__c, Job_Location__c, Job_Requirements__c, Job_title__c, KAM_Owner__c, KAM_V1__c, Key_Word_Id__c, LastActivityDate, LastModifiedById, LastModifiedDate, LastName, LastReferencedDate, LastViewedDate, Last_Called_Date_Time__c, Last_Connected_Call_Before_Onboarding__c, Last_connected_call_duration_before_onba__c, Last_connected_call_duration_hh_mm_ss__c, Last_Connected_Date__c, Latest_Call_Time_Before_Onboarding__c, Latitude, LeadSource, Lead_Assigned_Date__c, Lead_Score__c, Lead_Stage__c, Lead_Substage__c, Learner_Uid__c, LinkedIn_Referral_Link__c, Location__c, Longitude, MasterRecordId, MiddleName, MobilePhone, Name, Network__c, Next_Followup_Date_Time__c, No_Of_Calls_Made_Before_Onboarding__c, No_Of_Payments_Done__c, NumberOfEmployees, NumberOfLiveJobs__c, Onboarding_Completed__c, Onboarding_Stages__c, OwnerId, Paid_Amount__c, Payment_Captured__c, Payment_Date__c, Payment_initiated_Date_Time__c, Payment_initiated_Date__c, Payment_Status__c, Phone, PhotoUrl, Plan_Bought__c, Plan_Expiry_Date__c, Plan_Upgraded_To__c, PostalCode, Product__c, Qualification_Reason__c, Qualification_Status__c, Quantity__c, Rating, Recruiter_Audit_Status__c, Recruiter_Id__c, Recruiter_Profile_Link__c, RegistrationProgress__c, Reject_Reason__c, Remarketing_Assignment_Reason__c, Remarketing_Transferred_Stage__c, Remote_Job__c, RequestsCall__c, RM_assigned_Date_Time__c, RM_KAM_Lead_Lost_Reason__c, RM_KAM_Lead_Stage__c, RM_KAM_Tickets_Created__c, RM_KAM_Tickets_Open__c, RM_V1__c, RM__c, Sales_Owner_Assigned_to__c, Sales_Owner__c, Salutation, Saved_candidates__c, Source_Source_of_acquisition__c, State, Status, Street, Sub_Status__c, Suffix, SystemModstamp, testfield__c, Test_Round_Robin__c, Title, Total_Calls__c, Total_Call_Duration__c, Trial_End_Date__c, Trigger_1day__c, Trigger_3day__c, Under_Approval__c, UTM_Ad_Position__c, UTM_Campaign__c, UTM_Device__c, UTM_Medium__c, UTM_Source__c, Website
                                   FROM Lead
                                   Where OwnerId = :hirectLeadQueue];
            if (!leadlist.isEmpty()){
                BatchToAssignLeadsFromQueue batchInstance = new BatchToAssignLeadsFromQueue();
                database.executeBatch(batchInstance);
            }
        } catch (exception ex){
            system.debug('Errror-->' + ex.getMessage());
            system.debug('Errror-->' + ex.getCause());
            system.debug('Errror-->' + ex.getLineNumber());
        }
    }
    
}