global without sharing class TaxInvoiceHelper {
    
    public  String InvoiceId {get; set;}
    public  Opportunity oppDetails {get; set;} 
    public  Invoice__c invoiceRecord {get; set;} 
    public  Company_Specifications__c companyDetails {get; set;} 
    public  Lead leadDetails {get; set;} 

    global TaxInvoiceHelper(){
        InvoiceId =  ApexPages.CurrentPage().getparameters().get('id');
        system.debug('InvoiceId-->'+InvoiceId);
        
        
        companyDetails = [Select Name__c,Address__c,SAC__c,CIN__c,Email__c,GSTIN__c,PAN__c,Phone__c From Company_Specifications__c ];
        system.debug('companyDetails-->'+companyDetails);
        invoiceRecord = [Select Opportunity__c,Invoice_Number__c,Initiated_Date__c,Invoice_Due_Date__c,PRODUCT_CODE__c,Amount__c,Opportunity__r.Description,Opportunity__r.Amount,Lead__c,Lead__r.Amount__c,Lead__r.Product__r.ProductCode From Invoice__c where Id =: InvoiceId ];
        system.debug('invoiceRecord-->'+invoiceRecord);
        
        if(invoiceRecord.Opportunity__c != null){
            oppDetails = [Select Id,Name,Account.Name, Account.GST_number__c, Account.PAN__c, Account.CIN__c,Account.Phone,Account.Email__c,Account.BillingStreet,Description,Amount, 
            Account.BillingCity, Account.BillingState,Account.ShippingStreet,Account.ShippingCity, Account.ShippingState,Account.ShippingPostalCode,Account.BillingPostalCode
            ,Account.BillingCountry,(Select Name,TotalPrice From OpportunityLineItems limit 1) From Opportunity where id =: invoiceRecord.Opportunity__c];
        }else{
            
        }
       system.debug('oppDetails-->'+oppDetails);
    }
    @future(callout=true)
    global static void attachPdf(string recordId){
        
        try{
            String reciepientEmail;
            PageReference pdfPage;
            if([Select id,Profile.UserLicense.Name from User where Id=: UserInfo.getUserId()].Profile.UserLicense.Name == 'Guest User License'){
                //site 
                pdfPage  = new PageReference(Label.Site_URL);
            }else{
                //internal user
                pdfPage = Page.TaxInvoice;
            }            
            
            pdfPage.getParameters().put('id',recordId);
            system.debug('recordId-->'+recordId);
            Blob pdfBlob; 
            pdfBlob = pdfPage.getContent(); 
           
            Attachment attach = new Attachment(parentId = recordId, Name = 'TaxInvoice.pdf', body = pdfBlob); 
            insert attach;
            reciepientEmail = [Select Opportunity__r.Account.Email__c From Invoice__c where Id =: recordId].Opportunity__r.Account.Email__c;
            system.debug('reciepientEmail :: '+ reciepientEmail);
            if(!string.isBlank(reciepientEmail)){
                EmailIUtility.sendEmailForPaymentSuccess(reciepientEmail, Constants.RAZOR_PAY_SUCCESS_EMAIL_OPPORTUNITY, Constants.OPPORTUNITY, recordId);
            }
            
        }
        catch(exception ex){
            system.debug('Error-->'+ex.getLineNumber());
            system.debug('Error-->>'+ex.getMessage());
        }
        
    }    
}