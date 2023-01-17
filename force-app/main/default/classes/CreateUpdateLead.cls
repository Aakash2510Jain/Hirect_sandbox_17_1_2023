@RestResource(urlMapping='/createUpdateLead/*')
global class CreateUpdateLead {
    @httpPost
    global static responseWrapper leadCreateUpdate(){
        responseWrapper responseJSON = new responseWrapper();
        try {
            system.debug('LeadRequestList::'+RestContext.request.requestBody.tostring());
            LeadDetails_client leadClientRec = LeadDetails_client.parse(RestContext.request.requestBody.tostring());
            
            List<Lead> LdList = new List<Lead>();
            List<Account> accList = new List<Account>();
            
            if(!String.isBlank(leadClientRec.Phone)){
                String StrPhone = leadClientRec.Phone.right(10);
                
                accList = [Select Id,Company_Size__c,NumberOfEmployees,Company_recruiter__c,Company_Profile_Link__c,Company_ID__c,
                           (Select Id From Contacts limit 1) From Account where phone Like: '%'+StrPhone limit 1];
                if(!accList.isEmpty()){
                    system.debug('Account Already Exists');
                    system.debug('accList[0].ID-->'+accList[0].ID);
                    system.debug('Contact Id -->'+accList[0].Contacts[0].id);
                    
                    Account accRec  = new Account();
                    accRec.Id = accList[0].ID;
                    Contact conRec = new Contact();
                    conRec.Id = accList[0].Contacts[0].id;
                    
                    if(leadClientRec.CompanySize != null){
                        accRec.Company_Size__c = string.valueOf(leadClientRec.CompanySize);
                    }
                        if(leadClientRec.NumberOfEmployees != null ){
                        accRec.NumberOfEmployees = integer.valueOf(leadClientRec.NumberOfEmployees);
                    }
                         if(leadClientRec.NoOfCompanyRcruiters != null){
                        accRec.Company_recruiter__c = double.valueOf(leadClientRec.NoOfCompanyRcruiters);
                    }
                        if(leadClientRec.CompanyProfileLink != null && !string.isBlank(leadClientRec.CompanyProfileLink)){
                        accRec.Company_Profile_Link__c = string.valueOf(leadClientRec.CompanyProfileLink);
                    }
                        if(leadClientRec.CompanyId != null){
                        accRec.Company_ID__c = string.valueOf(leadClientRec.CompanyId);
                    }
                    update accRec;
                    //for contact
                    if(leadClientRec.EmailAddress != null){
                        conRec.Email = string.valueOf(leadClientRec.EmailAddress);
                    }
                    //LeadSource
                    if(leadClientRec.Jobtitle != null){
                        conRec.Job_title__c = string.valueOf(leadClientRec.Jobtitle);
                    }
                    if(leadClientRec.RegistrationProgress != null){
                        conRec.RegistrationProgress__c = string.valueOf(leadClientRec.RegistrationProgress);
                    }
                    if(leadClientRec.EnterURL != null){
                        conRec.Enter_URL__c = string.valueOf(leadClientRec.EnterURL);
                    }
                    if(leadClientRec.FirstVisitTime != null){
                        if(Date.valueOf(leadClientRec.FirstVisitTime) > system.today()){
                            responseJSON.Message = 'First visit time cannot be greater than Present time, So it is not captured!';
                            System.debug('First visit time cannot be greater than Present time!!!!!');
                        }
                        else{
                            DateTime currentDateTime = system.now();
                            Time myTime = Time.newInstance(currentDateTime.hour(), currentDateTime.minute(), 0, 0);
                            DateTime dt = DateTime.newInstance(Date.valueOf(leadClientRec.FirstVisitTime), myTime);
                            conRec.Homepage_Visited_Time__c = datetime.valueof(leadClientRec.FirstVisitTime);
                        }
                    }
                    if(leadClientRec.RejectReason != null){
                        conRec.Reject_Reason__c = string.valueOf(leadClientRec.RejectReason);
                    }
                    if(leadClientRec.LeadStatus != null && !string.isBlank(leadClientRec.LeadStatus)){
                        conRec.Lead_Status__c = string.valueOf(leadClientRec.LeadStatus);
                    }
                    if(leadClientRec.Industry != null){
                        conRec.Industry__c	 = string.valueOf(leadClientRec.Industry);  
                    }
                    if(leadClientRec.funcationArea != null){
                        conRec.Functional_Area__c = String.valueOf(leadClientRec.funcationArea);
                    }
                    if(leadClientRec.jobDescription != null){
                        conRec.Job_Description__c = String.valueOf(leadClientRec.jobDescription);
                    }
                    if(leadClientRec.jobRequirements != null){
                        conRec.Job_Requirements__c = string.valueOf(leadClientRec.jobRequirements);
                    }
                    if(leadClientRec.jobRequirements != null){
                        conRec.Job_Requirements__c = string.valueOf(leadClientRec.jobRequirements);
                    }
                    if(leadClientRec.joblocation != null){
                        conRec.Job_Location__c = String.valueOf(leadClientRec.joblocation);
                    } 
                    if(leadClientRec.remoteJob != null){
                        conRec.Remote_Job__c = leadClientRec.remoteJob;
                    }
                    if(leadClientRec.location != null){
                        conRec.Location__c = String.valueOf(leadClientRec.location);
                    }  
                    if(leadClientRec.Source != null){
                        conRec.Source_Source_of_acquisition__c = String.valueOf(leadClientRec.Source);
                    }
                    if(leadClientRec.Leadstage != null){
                        // conRec.Lead_Stage__c = String.valueOf(leadClientRec.Leadstage);
                    }
                    if(leadClientRec.AuditRejection != null){
                        conRec.Audit_Rejection_Reason__c = String.valueOf(leadClientRec.AuditRejection);
                    }
                    if(leadClientRec.Paymentstatus != null){
                        conRec.Payment_Status__c = String.valueOf(leadClientRec.Paymentstatus);
                    }
                    if(leadClientRec.Trigger0Day != null){
                        conRec.Trigger_0day__c = double.valueOf(leadClientRec.Trigger0Day);
                    }
                    if(leadClientRec.Trigger1Day != null){
                        conRec.Trigger_1day__c = double.valueOf(leadClientRec.Trigger1Day);
                    }
                    if(leadClientRec.Trigger3Day != null ){
                        conRec.Trigger_3day__c = double.valueOf(leadClientRec.Trigger3Day);
                    }  
                    if(leadClientRec.Clickpay0Day != null ){
                        conRec.Clickpay_0day__c = double.valueOf(leadClientRec.Clickpay0Day);
                    }
                    if(leadClientRec.Clickpay1Day != null ){
                        conRec.Clickpay_1day__c = double.valueOf(leadClientRec.Clickpay1Day);
                    }
                    if(leadClientRec.NumberofLiveJobs != null ){
                        conRec.NumberOfLiveJobs__c = double.valueOf(leadClientRec.NumberofLiveJobs);
                    }
                    if(leadClientRec.Activelevel != null ){
                        conRec.Active_level__c = double.valueOf(leadClientRec.Activelevel);
                    }
                    if(leadClientRec.Chatlevel != null ){
                        conRec.Chat_level__c = double.valueOf(leadClientRec.Chatlevel);
                    }
                    if(leadClientRec.Doublechatlevel != null ){
                        conRec.Double_chat_level__c = double.valueOf(leadClientRec.Doublechatlevel);
                    }
                    if(leadClientRec.SavedCandidate != null ){
                        conRec.Saved_candidates__c = double.valueOf(leadClientRec.SavedCandidate);
                    }
                    if(leadClientRec.RequestCall != null && !string.isBlank(leadClientRec.RequestCall)){
                        conRec.RequestsCall__c = String.valueOf(leadClientRec.RequestCall);
                    }
                    
                    
                    if(leadClientRec.CompanyId != null){
                        conRec.Company_ID__c = string.valueOf(leadClientRec.CompanyId);
                    }
                    if(leadClientRec.Channel != null){
                        conRec.Channel__c = string.valueOf(leadClientRec.Channel);
                    }
                    if(leadClientRec.SalesOwner != null){
                        conRec.Sales_Owner_Assigned_to__c = string.valueOf(leadClientRec.SalesOwner);
                    }
                    if(leadClientRec.Campaign != null){
                        conRec.Campaign__c = string.valueOf(leadClientRec.Campaign);
                    }
                    if(leadClientRec.QualificationStatus != null){
                        conRec.Qualification_Status__c = string.valueOf(leadClientRec.QualificationStatus);
                    }
                    if(leadClientRec.FirstCallTimeBeforeOnboarding != null){
                        conRec.First_Call_Time_Before_Onboarding__c = datetime.valueOf(leadClientRec.FirstCallTimeBeforeOnboarding);
                    }
                    if(leadClientRec.LatestCallTimeBeforeOnboarding != null){
                        conRec.Latest_Call_Time_Before_Onboarding__c = datetime.valueOf(leadClientRec.LatestCallTimeBeforeOnboarding);
                    }
                    if(leadClientRec.LastConnectedCallDurationBeforeOnboarding != null){
                        conRec.Last_connected_call_duration_before_onba__c = integer.valueOf(leadClientRec.LastConnectedCallDurationBeforeOnboarding);
                    }
                    if(leadClientRec.NoOfCallsMadeBeforeOnboarding != null){
                        conRec.No_Of_Calls_Made_Before_Onboarding__c = integer.valueOf(leadClientRec.NoOfCallsMadeBeforeOnboarding);
                    }
                    if(leadClientRec.LeadScore != null){
                        // conRec.Lead_Score__c = string.valueOf(leadClientRec.LeadScore);
                        conRec.Lead_Score__c = Decimal.valueOf(leadClientRec.LeadScore);
                    }  
                    if(leadClientRec.OnboardingStage != null){
                        conRec.Onboarding_Stages__c = string.valueOf(leadClientRec.OnboardingStage);
                    }
                    if(leadClientRec.RecruiterProfileLink != null){
                        conRec.Recruiter_Profile_Link__c = string.valueOf(leadClientRec.RecruiterProfileLink);
                    }
                    if(leadClientRec.TrialEndDate != null){
                        conRec.Trial_End_Date__c = date.valueOf(leadClientRec.TrialEndDate);
                    }
                    if(leadClientRec.PaymentDate != null){
                        conRec.Payment_Date__c = (Date)JSON.deserialize('"' + String.valueOf(leadClientRec.PaymentDate) + '"', Date.class);
                    }    
                    if(leadClientRec.PlanUpgradedTo != null){
                        conRec.Plan_Upgraded_To__c = string.valueOf(leadClientRec.PlanUpgradedTo);
                    }
                    if(leadClientRec.PlanBought != null){
                        conRec.Plan_Bought__c = string.valueOf(leadClientRec.PlanBought);
                    }
                    
                    if(leadClientRec.PlanExpiryDate != null){
                        conRec.Plan_Expiry_Date__c = (Date)JSON.deserialize('"' + String.valueOf(leadClientRec.PlanExpiryDate) + '"', Date.class);
                    }    
                    if(leadClientRec.PaidAmount != null){
                        conRec.Paid_Amount__c = decimal.valueOf(leadClientRec.PaidAmount);
                    }    
                    if(leadClientRec.NoOfPaymentsDone != null){
                        conRec.No_Of_Payments_Done__c = double.valueOf(leadClientRec.NoOfPaymentsDone);
                    }
                    if(leadClientRec.RM != null){
                        conRec.RM__c = string.valueOf(leadClientRec.RM);
                    }
                    if(leadClientRec.KAMOwner != null){
                        conRec.KAM_Owner__c = string.valueOf(leadClientRec.KAMOwner);
                    }
                    if(leadClientRec.NoOfTicketsCreated != null){
                        conRec.RM_KAM_Tickets_Created__c = double.valueOf(leadClientRec.NoOfTicketsCreated);
                    }
                    if(leadClientRec.NoOfTicketsOpened != null){
                        conRec.RM_KAM_Tickets_Open__c = double.valueOf(leadClientRec.NoOfTicketsOpened);
                    }
                    if(leadClientRec.RMLeadstage != null){
                        conRec.RM_KAM_Lead_Stage__c = string.valueOf(leadClientRec.RMLeadstage);
                    }
                    if(leadClientRec.LostReason != null){
                        conRec.RM_KAM_Lead_Lost_Reason__c = string.valueOf(leadClientRec.LostReason);
                    }
                    if(leadClientRec.Clickpay3Day != null){
                        conRec.Clickpay_3day__c = double.valueOf(leadClientRec.Clickpay3Day);
                    }
                    if(leadClientRec.CommentA != null){
                        conRec.CommentA__c = string.valueOf(leadClientRec.CommentA);
                    }
                    if(leadClientRec.CommentB != null){
                        conRec.CommentB__c = string.valueOf(leadClientRec.CommentB);
                    }
                    if(leadClientRec.CommentC != null){
                        conRec.CommentC__c = string.valueOf(leadClientRec.CommentC);
                    }
                    if(leadClientRec.CommentD != null){
                        conRec.CommentD__c = string.valueOf(leadClientRec.CommentD);
                    }
                    if(leadClientRec.FunctionalArea != null){
                        conRec.Functional_Area__c = string.valueOf(leadClientRec.FunctionalArea);
                    }
                    if(leadClientRec.NoOfLiveJobs != null){
                        conRec.NumberOfLiveJobs__c = double.valueOf(leadClientRec.NoOfLiveJobs);
                    }
                    if(leadClientRec.SavedCandidates != null){
                        conRec.Saved_candidates__c = double.valueOf(leadClientRec.SavedCandidates);
                    }
                    if(leadClientRec.IsRemoteJob != null){
                        conRec.Is_Remote_Job__c = boolean.valueOf(leadClientRec.IsRemoteJob);
                    }
                    update conRec;
                }else{
                    
                    StrPhone = '91'+StrPhone;
                    
                    LdList = [Select id, Company, Email, Phone, FirstName, LastName,Don_t_Change_Source__c From Lead where phone Like: '%'+StrPhone limit 1] ;
                    
                    lead createLd = new lead();
                    
                    if(leadClientRec.EmailAddress != null){
                        createLd.Email = string.valueOf(leadClientRec.EmailAddress);
                    }
                    
                    if(leadClientRec.Jobtitle != null){
                        createLd.Job_title__c = string.valueOf(leadClientRec.Jobtitle);
                    }
                    if(leadClientRec.FirstVisitTime != null){
                        if(Date.valueOf(leadClientRec.FirstVisitTime) > system.today()){
                            responseJSON.Message = 'But First visit time cannot be greater than Present time, So it is not captured!';
                            System.debug('First visit time cannot be greater than Present time!!!!!');
                        }
                        else{
                            DateTime currentDateTime = system.now();
                            Time myTime = Time.newInstance(currentDateTime.hour(), currentDateTime.minute(), 0, 0);
                            DateTime dt = DateTime.newInstance(Date.valueOf(leadClientRec.FirstVisitTime), myTime);
                            createLd.Homepage_Visited_Time__c = datetime.valueof(leadClientRec.FirstVisitTime);
                        }
                    }
                    if(leadClientRec.RegistrationProgress != null){
                        createLd.RegistrationProgress__c = string.valueOf(leadClientRec.RegistrationProgress);
                    }
                    if(leadClientRec.RejectReason != null){
                        createLd.Reject_Reason__c = string.valueOf(leadClientRec.RejectReason);
                    }
                    if(leadClientRec.EnterURL != null){
                        createLd.Enter_URL__c = string.valueOf(leadClientRec.EnterURL);
                    }
                    if(!LdList.isEmpty()){
                        if(!LdList[0].Don_t_Change_Source__c){
                            if(leadClientRec.LeadSource != null){
                                createLd.LeadSource = string.valueOf(leadClientRec.LeadSource);
                            }
                        }
                    }else{
                        if(leadClientRec.LeadSource != null){
                            createLd.LeadSource = string.valueOf(leadClientRec.LeadSource);
                        }
                    }
                    if(leadClientRec.LeadStatus != null && !string.isBlank(leadClientRec.LeadStatus)){
                        createLd.Status = string.valueOf(leadClientRec.LeadStatus);
                    }
                    
                    if(leadClientRec.Industry != null){
                        createLd.Industry = string.valueOf(leadClientRec.Industry);  
                    }
                    if(leadClientRec.NumberOfEmployees != null ){
                        createLd.NumberOfEmployees = integer.valueOf(leadClientRec.NumberOfEmployees);
                    }
                    if(leadClientRec.funcationArea != null){
                        createLd.Functional_Area__c = String.valueOf(leadClientRec.funcationArea);
                    }
                    if(leadClientRec.jobDescription != null){
                        createLd.Job_Description__c = String.valueOf(leadClientRec.jobDescription);
                    }
                    if(leadClientRec.jobRequirements != null){
                        createLd.Job_Requirements__c = string.valueOf(leadClientRec.jobRequirements);
                    }
                    if(leadClientRec.joblocation != null){
                        createLd.Job_Location__c = String.valueOf(leadClientRec.joblocation);
                    } 
                    if(leadClientRec.remoteJob != null){
                        createLd.Remote_Job__c = leadClientRec.remoteJob;
                    }
                    if(leadClientRec.location != null){
                        createLd.Location__c = String.valueOf(leadClientRec.location);
                    }  
                    if(leadClientRec.Source != null){
                        createLd.Source_Source_of_acquisition__c = String.valueOf(leadClientRec.Source);
                    }
                    if(leadClientRec.Leadstage != null){
                        // createLd.Lead_Stage__c = String.valueOf(leadClientRec.Leadstage);
                    }
                    if(leadClientRec.AuditRejection != null){
                        createLd.Audit_Rejection_Reason__c = String.valueOf(leadClientRec.AuditRejection);
                    }
                    if(leadClientRec.Paymentstatus != null){
                        createLd.Payment_Status__c = String.valueOf(leadClientRec.Paymentstatus);
                    }
                    if(leadClientRec.Trigger0Day != null){
                        createLd.Trigger_0day__c = double.valueOf(leadClientRec.Trigger0Day);
                    }
                    if(leadClientRec.Trigger1Day != null){
                        createLd.Trigger_1day__c = double.valueOf(leadClientRec.Trigger1Day);
                    }
                    if(leadClientRec.Trigger3Day != null ){
                        createLd.Trigger_3day__c = double.valueOf(leadClientRec.Trigger3Day);
                    }  
                    if(leadClientRec.Clickpay0Day != null ){
                        createLd.Clickpay_0day__c = double.valueOf(leadClientRec.Clickpay0Day);
                    }
                    if(leadClientRec.Clickpay1Day != null ){
                        createLd.Clickpay_1day__c = double.valueOf(leadClientRec.Clickpay1Day);
                    }
                    if(leadClientRec.NumberofLiveJobs != null ){
                        createLd.NumberOfLiveJobs__c = double.valueOf(leadClientRec.NumberofLiveJobs);
                    }
                    if(leadClientRec.Activelevel != null ){
                        createLd.Active_level__c = double.valueOf(leadClientRec.Activelevel);
                    }
                    if(leadClientRec.Chatlevel != null ){
                        createLd.Chat_level__c = double.valueOf(leadClientRec.Chatlevel);
                    }
                    if(leadClientRec.Doublechatlevel != null ){
                        createLd.Double_chat_level__c = double.valueOf(leadClientRec.Doublechatlevel);
                    }
                    if(leadClientRec.SavedCandidate != null ){
                        createLd.Saved_candidates__c = double.valueOf(leadClientRec.SavedCandidate);
                    }
                    if(leadClientRec.RequestCall != null && !string.isBlank(leadClientRec.RequestCall)){
                        createLd.RequestsCall__c = String.valueOf(leadClientRec.RequestCall);
                    }
                    
                    if(leadClientRec.CompanyProfileLink != null && !string.isBlank(leadClientRec.CompanyProfileLink)){
                        createLd.Company_Profile_Link__c = string.valueOf(leadClientRec.CompanyProfileLink);
                    }
                    if(leadClientRec.CompanyId != null){
                        createLd.Company_ID__c = string.valueOf(leadClientRec.CompanyId);
                    }
                    if(leadClientRec.Channel != null){
                        createLd.Channel__c = string.valueOf(leadClientRec.Channel);
                    }
                    if(leadClientRec.SalesOwner != null){
                        createLd.Sales_Owner__c = string.valueOf(leadClientRec.SalesOwner);
                    }
                    if(leadClientRec.CompanySize != null){
                        createLd.Company_Size__c = string.valueOf(leadClientRec.CompanySize);
                    }
                    if(leadClientRec.Campaign != null){
                        createLd.Campaign__c = string.valueOf(leadClientRec.Campaign);
                    }
                    if(leadClientRec.QualificationStatus != null){
                        createLd.Qualification_Status__c = string.valueOf(leadClientRec.QualificationStatus);
                    }
                    if(leadClientRec.FirstCallTimeBeforeOnboarding != null){
                        createLd.First_Call_Time_Before_Onboarding__c = datetime.valueOf(leadClientRec.FirstCallTimeBeforeOnboarding);
                    }
                    if(leadClientRec.LatestCallTimeBeforeOnboarding != null){
                        createLd.Latest_Call_Time_Before_Onboarding__c = datetime.valueOf(leadClientRec.LatestCallTimeBeforeOnboarding);
                    }
                    if(leadClientRec.LastConnectedCallDurationBeforeOnboarding != null){
                        createLd.Last_connected_call_duration_before_onba__c = integer.valueOf(leadClientRec.LastConnectedCallDurationBeforeOnboarding);
                    }
                    if(leadClientRec.NoOfCallsMadeBeforeOnboarding != null){
                        createLd.No_Of_Calls_Made_Before_Onboarding__c = integer.valueOf(leadClientRec.NoOfCallsMadeBeforeOnboarding);
                    }
                    if(leadClientRec.LeadScore != null){
                        // createLd.Lead_Score__c = string.valueOf(leadClientRec.LeadScore);
                        createLd.Lead_Score__c = Decimal.valueOf(leadClientRec.LeadScore);
                    }  
                    if(leadClientRec.OnboardingStage != null){
                        createLd.Onboarding_Stages__c = string.valueOf(leadClientRec.OnboardingStage);
                    }
                    if(leadClientRec.RecruiterProfileLink != null){
                        createLd.Recruiter_Profile_Link__c = string.valueOf(leadClientRec.RecruiterProfileLink);
                    }
                    if(leadClientRec.TrialEndDate != null){
                        createLd.Trial_End_Date__c = date.valueOf(leadClientRec.TrialEndDate);
                    }
                    if(leadClientRec.PaymentDate != null){
                        createLd.Payment_Date__c = (Date)JSON.deserialize('"' + String.valueOf(leadClientRec.PaymentDate) + '"', Date.class);
                    }    
                    if(leadClientRec.PlanUpgradedTo != null){
                        createLd.Plan_Upgraded_To__c = string.valueOf(leadClientRec.PlanUpgradedTo);
                    }
                    if(leadClientRec.PlanBought != null){
                        createLd.Plan_Bought__c = string.valueOf(leadClientRec.PlanBought);
                    }
                    
                    if(leadClientRec.PlanExpiryDate != null){
                        createLd.Plan_Expiry_Date__c = (Date)JSON.deserialize('"' + String.valueOf(leadClientRec.PlanExpiryDate) + '"', Date.class);
                    }    
                    if(leadClientRec.PaidAmount != null){
                        createLd.Paid_Amount__c = decimal.valueOf(leadClientRec.PaidAmount);
                    }    
                    if(leadClientRec.NoOfPaymentsDone != null){
                        createLd.No_Of_Payments_Done__c = double.valueOf(leadClientRec.NoOfPaymentsDone);
                    }
                    if(leadClientRec.RM != null){
                        createLd.RM__c = string.valueOf(leadClientRec.RM);
                    }
                    if(leadClientRec.KAMOwner != null){
                        createLd.KAM_Owner__c = string.valueOf(leadClientRec.KAMOwner);
                    }
                    if(leadClientRec.NoOfTicketsCreated != null){
                        createLd.RM_KAM_Tickets_Created__c = double.valueOf(leadClientRec.NoOfTicketsCreated);
                    }
                    if(leadClientRec.NoOfTicketsOpened != null){
                        createLd.RM_KAM_Tickets_Open__c = double.valueOf(leadClientRec.NoOfTicketsOpened);
                    }
                    if(leadClientRec.RMLeadstage != null){
                        createLd.RM_KAM_Lead_Stage__c = string.valueOf(leadClientRec.RMLeadstage);
                    }
                    if(leadClientRec.LostReason != null){
                        createLd.RM_KAM_Lead_Lost_Reason__c = string.valueOf(leadClientRec.LostReason);
                    }
                    if(leadClientRec.Clickpay3Day != null){
                        createLd.Clickpay_3day__c = double.valueOf(leadClientRec.Clickpay3Day);
                    }
                    if(leadClientRec.CommentA != null){
                        createLd.CommentA__c = string.valueOf(leadClientRec.CommentA);
                    }
                    if(leadClientRec.CommentB != null){
                        createLd.CommentB__c = string.valueOf(leadClientRec.CommentB);
                    }
                    if(leadClientRec.CommentC != null){
                        createLd.CommentC__c = string.valueOf(leadClientRec.CommentC);
                    }
                    if(leadClientRec.CommentD != null){
                        createLd.CommentD__c = string.valueOf(leadClientRec.CommentD);
                    }
                    if(leadClientRec.NoOfCompanyRcruiters != null){
                        createLd.Company_recruiter__c = double.valueOf(leadClientRec.NoOfCompanyRcruiters);
                    }
                    if(leadClientRec.FunctionalArea != null){
                        createLd.Functional_Area__c = string.valueOf(leadClientRec.FunctionalArea);
                    }
                    if(leadClientRec.LastConnectedCallBeforeOnboarding != null){
                        createLd.Last_Connected_Call_Before_Onboarding__c = string.valueOf(leadClientRec.LastConnectedCallBeforeOnboarding);
                    }
                    if(leadClientRec.NoOfLiveJobs != null){
                        createLd.NumberOfLiveJobs__c = double.valueOf(leadClientRec.NoOfLiveJobs);
                    }
                    if(leadClientRec.SavedCandidates != null){
                        createLd.Saved_candidates__c = double.valueOf(leadClientRec.SavedCandidates);
                    }
                    if(leadClientRec.IsRemoteJob != null){
                        createLd.Is_Remote_Job__c = boolean.valueOf(leadClientRec.IsRemoteJob);
                    }
                    system.debug('leadClientRec.FN-->'+leadClientRec.FN);
                    system.debug('leadClientRec.LN-->'+leadClientRec.LN);
                    if(LdList.isempty()){
                        if(leadClientRec.FN != null && leadClientRec.LN != null && !string.isEmpty(leadClientRec.FN) && !string.isEmpty(leadClientRec.LN)){
                            system.debug('Inside first');
                            if(leadClientRec.FN == leadClientRec.LN){
                                system.debug('inside 2');
                                string[] name = (string.valueOf(leadClientRec.LN)).split(' ');
                                if(name.size() > 1){
                                    system.debug('INside 3');
                                    createLd.FirstName = name[0];
                                    createLd.LastName = name[1];
                                }else if(name.size() == 1){
                                    system.debug('INside 4');
                                    createLd.LastName =  name[0];
                                }
                                else{
                                    system.debug('INside 5');
                                    createLd.LastName = 'NA';
                                }
                            }else{
                                system.debug('INside 6');
                                createLd.FirstName = string.valueOf(leadClientRec.FN);
                                createLd.LastName = string.valueOf(leadClientRec.LN);
                            }
                        }else if(leadClientRec.FN == null && leadClientRec.LN != null){
                            system.debug('INside 7');
                            createLd.LastName = string.valueOf(leadClientRec.LN);
                        }
                        else if(leadClientRec.FN != null && leadClientRec.LN == null){
                            system.debug('INside 8');
                            createLd.LastName = string.valueOf(leadClientRec.FN);
                        }
                        else{
                            system.debug('INside 9');
                            createLd.LastName = 'NA';
                        }
                    }else{
                        system.debug('Updating Data');
                        if(leadClientRec.FN != null && leadClientRec.LN != null && !string.isEmpty(leadClientRec.FN) && !string.isEmpty(leadClientRec.LN)){
                            if(leadClientRec.FN == leadClientRec.LN){
                                system.debug('inside 2');
                                string[] name = (string.valueOf(leadClientRec.LN)).split(' ');
                                if(name.size() > 1){
                                    system.debug('INside 3');
                                    createLd.FirstName = name[0];
                                    createLd.LastName = name[1];
                                }else if(name.size() == 1){
                                    system.debug('INside 4');
                                    createLd.LastName =  name[0];
                                }
                                else{
                                    system.debug('INside 5');
                                    createLd.LastName = 'NA';
                                }
                            }else{
                                system.debug('INside 6');
                                createLd.FirstName = string.valueOf(leadClientRec.FN);
                                createLd.LastName = string.valueOf(leadClientRec.LN);
                            }
                        }else if(leadClientRec.FN != null && !string.isEmpty(leadClientRec.FN) && string.isEmpty(leadClientRec.LN)){
                            createLd.FirstName = string.valueOf(leadClientRec.FN);
                        }else if(leadClientRec.LN != null && !string.isEmpty(leadClientRec.LN) && string.isEmpty(leadClientRec.FN)){
                            createLd.LastName = string.valueOf(leadClientRec.LN);
                        }
                    }
                    if(LdList.isempty()){
                        
                        if(leadClientRec.Company != null && !string.isBlank(leadClientRec.Company)){
                            system.debug('Company is not null');
                            createLd.Company = string.valueOf(leadClientRec.Company);
                        }
                        if(leadClientRec.Company == null || string.isBlank(leadClientRec.Company)){
                            system.debug('Company is null');
                            createLd.Company = '--';
                        }
                        if(leadClientRec.Phone != Null){
                            createLd.Phone = string.valueOf(leadClientRec.Phone);  
                        }
                        
                        insert createLd;
                        if(createLd != null ){
                            Json_Payload__c jsonLoad = new Json_Payload__c();
                            jsonLoad.Lead__c = createLd.Id;
                            jsonLoad.Payload_Request__c = String.valueOf(RestContext.request.requestBody.tostring());
                            insert jsonLoad;
                        }
                        if(responseJSON.Message != null){
                            System.debug('responseJSON.Message :: ' + responseJSON.Message);
                            responseJSON.Message = 'Lead Created Successfully. ' +responseJSON.Message;
                        }
                        else {
                            responseJSON.Message = 'Lead Created Successfully';
                        }
                        responseJSON.Success = True;
                        responseJSON.LeadId = createLd.Id;
                    }
                    else if(!LdList.isEmpty()){
                        
                        if(leadClientRec.Company != null && !string.isBlank(leadClientRec.Company)){
                            system.debug('Company is not null');
                            createLd.Company = string.valueOf(leadClientRec.Company);
                        }
                        Json_Payload__c jsonLoad = new Json_Payload__c();
                        jsonLoad.Lead__c = LdList[0].id;
                        jsonLoad.Payload_Request__c = String.valueOf(RestContext.request.requestBody.tostring());
                        insert jsonLoad;
                        
                        createLd.Id = LdList[0].id;
                        update createLd;
                        if(responseJSON.Message != null){
                            System.debug('responseJSON.Message :: ' + responseJSON.Message);
                            responseJSON.Message = 'Lead updated Successfully. ' +responseJSON.Message;
                        }
                        else {
                            responseJSON.Message = 'Lead updated Successfully';
                        }
                        responseJSON.Success = True;
                        responseJSON.LeadId = createLd.Id;
                    }
                }
            }
            else{
                responseJSON.Message = 'Please Provide 10-digit Phone No.';
                responseJSON.Success = False;
            }
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage() + 'at ' + e.getLineNumber());
            responseJSON.Message = 'Some Error Occured-->'+e.getMessage();
            responseJSON.Success = False;
        }
        return responseJSON;
    }
    
    global class responseWrapper {
        
        global String Message;//message string
        global boolean Success ;// Success String
        global String LeadId ;
    }
}