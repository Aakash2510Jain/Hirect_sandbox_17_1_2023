public without Sharing class SendPaymentLinkHandler {
    
    @AuraEnabled 
    Public static SendPayLinkWrapper queryDataOnDoInit(String RecID){
        system.debug('RecID-->'+RecID);
        SendPayLinkWrapper SPLWrap = new SendPayLinkWrapper();
       List<PricebookEntry> PBElist = [SELECT id, Name,Pricebook2Id,Product2.Family,ProductCode,UnitPrice FROM PricebookEntry Where isactive = true];
       system.debug('PBElist-->'+PBElist);
       if(!PBElist.isEmpty()){
            SPLWrap.PBERecords= PBElist;
        }
        lead ldrec = [SELECT Email,RegistrationProgress__c,FirstName,Id,IsConverted,LeadSource,MiddleName,Name,Onboarding_Completed__c,phone FROM Lead where id =:RecID ];
        system.debug('ldrec-->'+ldrec);
        if(ldrec !=  null){
            SPLWrap.LeadRecord = ldrec;
        }
        return SPLWrap;
       
    }
    
    @AuraEnabled 
    Public Static String updateLead(Lead LeadRecords){
        system.debug('LeadRecords :: ' + LeadRecords);
        string message = '';
        //String DiscountOption = '';
        if(LeadRecords != null){
            LeadRecords.Payment_Status__c = 'Initiated';
            LeadRecords.Payment_initiated_Date_Time__c = system.now();
            update LeadRecords;
            message = 'SUCCESS';
            //RazorpayPaymentHandler.sendPaymentLink(LeadRecords.Id);
        }
        return message;
    }
    
    @AuraEnabled 
    Public Static void sendPaymentLinkFromLead(id leadId){
        system.debug('leadId :: ' + leadId);
        RazorpayPaymentHandler.sendPaymentLink(leadId);
    }
    @AuraEnabled 
    Public Static void createInvoiceRec(id leadId){
        system.debug('leadId :: ' + leadId);
        RazorpayPaymentHandler.createInvoiceRec(leadId);
    }
    public class SendPayLinkWrapper{
        @AuraEnabled 
        public List<PricebookEntry> PBERecords{get; set;}
        @AuraEnabled 
        public Lead LeadRecord{get; set;}
    }

}