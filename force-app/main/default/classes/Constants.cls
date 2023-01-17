public without sharing class Constants{
    // queue name
    public static final string PRIVATE_LEAD_QUEUE = 'Hirect Default Queue';
    public static final string PUBLIC_LEAD_QUEUE = 'App India Registration Queue';
    public static final string DISQUALIFIED_lEAD_QUEUE = 'Disqualified Lead Queue';

    //User details
    public static final string INTEGRATION_USER_ALIAS = 'SF@123';
    //Inactive more than 37 days
    public static final string RENEWAL_EMAIL_TEMPLATE = 'Renewal Email';
    public static final string INACTIVE_EMAIL_TEMPLATE = 'Inactive Account Email'; //Inactive more than 37 days
    public static final string DEAD_EMAIL_TEMPLATE = 'Dead Account Email'; //Lost Account
    //Razor pay
    public static final string RAZOR_PAY_SUCCESS_EMAIL_OPPORTUNITY = 'Razor Pay Success Status'; //Payment Success Opportunity
    public static final string RAZOR_PAY_FAILURE_EMAIL_OPPORTUNITY = 'Razor Pay Failure Status'; //Payment FAILURE Opportunity
    public static final string RAZOR_PAY_SUCCESS_EMAIL_LEAD = 'Razor Pay Success Status Lead'; //Payment Success Lead
    public static final string RAZOR_PAY_FAILURE_EMAIL_LEAD = 'Razor Pay Failure Status Lead'; //Payment FAILURE Lead
    public static final string PAYMENT_SUCCESS = 'Success';
    public static final string PAYMENT_FAILED = 'Failed';
    public static final string OPPORTUNITY = 'Opportunity';
    public static final string LEAD = 'Lead';
    public static final string INVOICE_STATUS_REALIZED = 'Realized';
    public static final string LEAD_PAYMENT_CAPTURED_FAILED = 'Failed';
    public static final string LEAD_PAYMENT_STATUS_NOT_REALISED = 'Not Realized';
    public static final string PENDING = 'Pending';
    //Approval
    public static final string OPPORTUNITY_APPROVAL_PROCESS = 'Discount_10_for_opportunity';
    public static final string LEAD_APPROVAL_PROCESS = 'Discount_Approval_Process';
    public static final string Onboarding_Stage_Document_uploaded = 'Document uploaded';
    // Registration Progress
    public static final string RegistrationProgress_Audit_Checking = 'Audited Checking';
    public static final string RegistrationProgress_Audit_Rejected = 'Audit Rejected';
    public static final string RegistrationProgress_Audited_Rejected = 'Audited Rejected';
    public static final string RegistrationProgress_Audited_Verified = 'Audited Verified';
    public static final string RegistrationProgress_Filled_up_Lead_form = 'Filled up leads form';
    public static final string RegistrationProgress_VERIFIED_PHONE_NUMBER = 'Verified Phone Number';
    public static final string RegistrationProgress_COMPLETED_ALL_REGISTRATION_STEPS = 'Completed all registration steps';
    public static final string RegistrationProgress_POSTED_JOB = 'Posted Job';
    public static final string RegistrationProgress_CREATED_RECRUITER_CARD = 'Created recruiter card';
    public static final string RegistrationProgress_AUDITED_HOLD = 'Audit Hold';

    //Lead Source
    public static final string LEAD_SOURCE_APP_INDIA = 'App India Registration (Backend)';
    public static final string LEAD_SOURCE_LINKEDIN = 'LinkedIn Request (India)';
    public static final string LEAD_SOURCE_OFFLINE_OUTREACH = 'Offline Outreach';

    //Lead Stages
    public static final string Lead_Stage_New = 'New';
    public static final string Lead_Stage_OPEN = 'Open';
    public static final string Lead_Stage_FOLLOWUP = 'Followup';
    public static final string Lead_Stage_Document_Uploaded = 'Document Uploaded';
    public static final string Lead_Stage_AUDIT_REJECTED = 'Audit Rejected';
    public static final string Lead_Stage_Audit_In_Progress = 'Audit in Progress';
    public static final string Lead_Stage_Not_Verified = 'Not Verified';
    public static final string Lead_Stage_Verified = 'Verified';
    public static final string Lead_Stage_Onboarded = 'Onboarded';
    public static final string Lead_Stage_Payment_Initiated = 'Payment Initiated';
    public static final string Lead_Stage_Disqualified = 'Disqualified';
    public static final string Lead_Stage_Nurturing = 'Nurturing';
    //Payment status
    public static final string Payment_Status_Realized = 'Realized';
    public static final string Payment_Status_Initiated = 'Initiated';
    //Audit Status
    public static final string Audit_Status_Document_Uploaded = 'Document Uploaded';
    public static final string Audit_Status_Rejected = 'Rejected';
    public static final string Audit_Status_Accepted = 'Accepted';
    // OPPORTUNITY RELATED
    public static final string OPPORTUNITY_WELCOME_EMAIL = 'Welcome Email on Opportunity Creation';
    public static final string OPPORTUNITY_RENEWAL_EMAIL = 'Email for Opportunity Renewal';
    public static final string OPPORTUNITY_CLOSED_WON = 'Closed Won';
    public static final string ONLINE = 'online';
    public static final string OFFLINE = 'offline';
    public static final string TASK_STATUS_COMPLETED = 'Completed';
    public static final string TASK_STATUS_OPEN = 'Open';
    public static final string TASK_STATUS_MEDIUM = 'Medium';
    public static final string TASK_STATUS_NORMAL = 'Normal';
    public static final string FOLLOW_UP_CLIENT = 'Follow up with Client';
    public static final string VERIFY_DOCUMENT_UPLOADED = 'Verify Documents Uploaded';
    public static final string FOLLOWUP_WITHCLIENT_FOR_OPP_RENEWAL = 'Followup with Client For Renewal.';
    
    public static final string LEAD_APPROVED = 'Approved';
}