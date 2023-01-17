public class LeadDetails_client {
    
    public String FN;
    public String LN;
    public String EmailAddress;
    public String Phone;
    public String Company;
    public string LeadSource;
    public string Jobtitle;
    public string RegistrationProgress;
    public string EnterURL;
    public string CompanySize;
    public string FirstVisitTime;
    public string RejectReason;
    public string LeadStatus;
    public string Industry;		
    public String NumberOfEmployees;
    public String funcationArea;
    public String jobDescription;
    public String jobRequirements;
    public String joblocation;
    public String remoteJob;
    public String location;
    public String Source;
    public String Leadstage;
    public String AuditRejection;
    public String Paymentstatus;
    public String Trigger1Day;
    public String Trigger3Day;
    public String Clickpay1Day;
    public String NumberofLiveJobs;
    public String Activelevel;
    public String Chatlevel;
    public String Doublechatlevel;
    public String SavedCandidate;
    public String NoOfCompanyRcruiters;
    public String RequestCall;
    
    public string CompanyProfileLink;
    Public string CompanyId;
    public string Channel;
    public string SalesOwner;
    public string Campaign;
    public string QualificationStatus;
    public string FirstCallTimeBeforeOnboarding;
    public string LatestCallTimeBeforeOnboarding;
    public string LastConnectedCallBeforeOnboarding;
    public string LastConnectedCallDurationBeforeOnboarding;
    public string NoOfCallsMadeBeforeOnboarding;
    public string LeadScore;
    public string OnboardingStage;
    public string RecruiterProfileLink;
    public string TrialEndDate;
    public string PaymentDate;
    public string PlanUpgradedTo;
    public string PlanExpiryDate;
    public string PaidAmount;
    public string NoOfPaymentsDone;
    public string RM; 
    public string KAMOwner;
    public string NoOfTicketsCreated;
    public string NoOfTicketsOpened;
    public string RMLeadstage;
    public string LostReason;
    public string Clickpay3Day;
    public string CommentA;
    public string CommentB;
    public string CommentC;
    public string CommentD;
    public string FunctionalArea;
    public string NoOfLiveJobs;
    public string SavedCandidates;
    public string IsRemoteJob;
    public string PlanBought;
    public string Clickpay0Day;
    public string Trigger0Day;
    
    public static LeadDetails_client parse(String json) {
        return (LeadDetails_client) System.JSON.deserialize(json, LeadDetails_client.class);
    }
    
    /*
{
"FN": "Mary",
"LN": "Smith",
"CreatedTime": "1654856908",
"LastModifiedTime": "1654856908",
"Jobtitle": "Test Engineer",
"FunctionalArea": "Test Engineer QA",
"JobDescription": "My company mean power 36000 noida sector _2 Uttar Pradesh near by priya goldMy company mean power 36000 noida sector _2 Uttar Pradesh near by priya gold",
"JobRequirements": "Graduation",
"JobLocation": "Delhi, DL",
"RemoteJob": "true",
"SalesOwner": "mash alex",
"Company": "Hirect",
"CompanyId": "CompanyId1654856908",
"CompanyProfileLink": "CompanyProfileLink1654856908",
"CompanySize": "12345",
"Location": "LocationDelhi, DL",
"EmailAddress": "vera@hirect.in",
"Phone": "+12222222222",
"LeadSource": "Google",
"Channel": "Test Engineer",
"Campaign": "registration",
"LeadStage": "designation",
"QualificationStatus": "QualificationStatus1654856908",
"FirstCallTimeBeforeOnboarding": "FirstCallTimeBeforeOnboarding1654856908",
"LatestCallTimeBeforeOnboarding": "LatestCallTimeBeforeOnboarding1654856908",
"LastConnectedCallBeforeOnboarding": "LastConnectedCallBeforeOnboarding1654856908",
"LastConnectedCallDurationBeforeOnboarding": "LastConnectedCallDurationBeforeOnboarding1654856908",
"NoOfCallsMadeBeforeOnboarding": "NoOfCallsMadeBeforeOnboarding1654856908",
"OnboardingStage": "OnboardingStage1654856908",
"RejectReason": "RejectReason1654856908",
"LeadScore": "LeadScore1654856908",
"FirstVisitTime": "2021-03-02",
"RecruiterProfileLink": "RecruiterProfileLink1654856908",
"TrialEndDate": "TrialEndDate1654856908",
"PaymentStatus": "PaymentStatus1654856908",
"PaymentDate": "PaymentDate1654856908",
"PlanUpgradedTo": "PlanUpgradedTo1654856908",
"PlanExpiryDate": "PlanExpiryDate1654856908",
"PaidAmount": "3344233",
"NoOfPaymentsDone": "324324",
"RM": "RM1654856908",
"KAMOwner": "KAMOwner1654856908",
"NoOfTicketsCreated": "33425",
"NoOfTicketsOpened": "32433",
"RMLeadstage": "RMLeadstage1654856908",
"LostReason": "LostReason1654856908",
"Trigger1Day": "11111",
"Trigger3Day": "22222",
"Clickpay1Day": "33333",
"Clickpay3Day": "44444",
"NoOfLiveJobs": "43243",
"ActiveLevel": "22343",
"ChatLevel": "54345235",
"DoubleChatLevel": "43454",
"SavedCandidates": "543534",
"NoOfCompanyRcruiters": "4534535434",
"IsRemoteJob": "IsRemoteJob1654856908",
"RequestCall": "RequestCall1654856908",
"CommentA": "CommentA1654856908",
"CommentB": "CommentB1654856908",
"CommentC": "CommentC1654856908",
"CommentD": "CommentD1654856908",
"RegistrationProgress": "RegistrationProgress1654856908",
"EnterURL": "EnterURL1654856908"
}'
*/
    
}