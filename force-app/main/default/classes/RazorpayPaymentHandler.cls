public with sharing class RazorpayPaymentHandler {
    public RazorpayPaymentHandler() {}

    @AuraEnabled(cacheable=true)
    public static List<Opportunity> displayOppRecord(){
        return [Select Id,Name from Opportunity];
    }

    @AuraEnabled(cacheable = true)@future(callout=true)
    public static void sendPaymentLink(String recordId){
        // String username = 'rzp_test_UJ6CeLOw4o6n89';
        // String password = 'S6PdyPzfyds12aPkkH0CKrQP';

        if(!String.isBlank(recordId)){
            Id recId = (Id) recordId;
            String objectAPIName = String.valueOf(recId.getsobjecttype());

            System.debug('RecordId---'+recordId+' ---OBJNAME---'+objectAPIName);
            Opportunity opp;
            Lead ld;
            String email;
            String contact;
            String name;
            Decimal amount;

            
            if(objectAPIName=='Opportunity'){
                opp = [SELECT Id, Name, Amount ,AccountId,Account.Phone,Account.Email__c From Opportunity Where Id =: recordId];

                if(opp.Amount!=null && opp.Account.Email__c!=null && opp.Account.Phone!=null){
                    email = opp.Account.Email__c;
                    contact = opp.Account.Phone;
                    name = opp.Name;
                    amount = opp.Amount*100;
                }
                }else if(objectAPIName=='Lead'){
                    system.debug('objectAPIName-->>'+objectAPIName);
               ld = [Select Id, Name, Amount__c,Email, Phone From Lead Where Id=: recordId];
               system.debug('ld-->'+ld);
                if(ld.Amount__c!=null && ld.Email!=null && ld.Phone!=null){
                   system.debug('Sending Request-->'+ld);
                    email = ld.Email;
                    contact = ld.Phone;
                    name = ld.Name;
                    amount = ld.Amount__c*100;
                }
               }
           

            if(amount!=null && email!=null && contact!=null){
                try {
                    RazorpayRequestJSON razorpayRequestJSON = new RazorpayRequestJSON();

                    razorpayRequestJSON.amount = amount;
                    razorpayRequestJSON.first_min_partial_amount = amount;
                    razorpayRequestJSON.setCustomer(name,contact,email);
                    razorpayRequestJSON.setNotes(recordId,objectAPIName);

                    String body = JSON.serialize(razorpayRequestJSON);
                    body = body.replace('currencyType','currency');

                    System.debug('Body---'+body);

                    HTTP http = new HTTP();
                    HttpRequest req = new HttpRequest();

                    req.setHeader('Content-Type', 'application/json');
                    req.setEndpoint('callout:RazorPay');
                    req.setMethod('POST');
                    req.setBody(body);

                    HTTPResponse res = http.send(req);
                    Map<String,Object> jsonBody = (Map<String,Object>) Json.deserializeUntyped(res.getBody());

                    System.debug('RESPPPP'+jsonBody);
//                    return jsonBody;       
                }
                catch (Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
            }
        }else{
        }
    }
/*    public static void sendPaymentLinkFromLead(String recordId){
        // String username = 'rzp_test_UJ6CeLOw4o6n89';
        // String password = 'S6PdyPzfyds12aPkkH0CKrQP';

        if(!String.isBlank(recordId)){
            Id recId = (Id) recordId;
            String objectAPIName = String.valueOf(recId.getsobjecttype());

            System.debug('RecordId---'+recordId+' ---OBJNAME---'+objectAPIName);
            Opportunity opp;
            Lead ld;
            String email;
            String contact;
            String name;
            Decimal amount;

            
            if(objectAPIName=='Opportunity'){
                opp = [SELECT Id, Name, Amount ,AccountId,Account.Phone,Account.Email__c From Opportunity Where Id =: recordId];

                if(opp.Amount!=null && opp.Account.Email__c!=null && opp.Account.Phone!=null){
                    email = opp.Account.Email__c;
                    contact = opp.Account.Phone;
                    name = opp.Name;
                    amount = opp.Amount*100;
                }
                }else if(objectAPIName=='Lead'){
                    system.debug('objectAPIName-->>'+objectAPIName);
               ld = [Select Id, Name, Amount__c,Email, Phone From Lead Where Id=: recordId];
               system.debug('ld-->'+ld);
                if(ld.Amount__c!=null && ld.Email!=null && ld.Phone!=null){
                   system.debug('Sending Request-->'+ld);
                    email = ld.Email;
                    contact = ld.Phone;
                    name = ld.Name;
                    amount = ld.Amount__c*100;
                }
               }
           

            if(amount!=null && email!=null && contact!=null){
                try {
                    RazorpayRequestJSON razorpayRequestJSON = new RazorpayRequestJSON();

                    razorpayRequestJSON.amount = amount;
                    razorpayRequestJSON.first_min_partial_amount = amount;
                    razorpayRequestJSON.setCustomer(name,contact,email);
                    razorpayRequestJSON.setNotes(recordId,objectAPIName);

                    String body = JSON.serialize(razorpayRequestJSON);
                    body = body.replace('currencyType','currency');

                    System.debug('Body---'+body);

                    HTTP http = new HTTP();
                    HttpRequest req = new HttpRequest();

                    req.setHeader('Content-Type', 'application/json');
                    req.setEndpoint('callout:RazorPay');
                    req.setMethod('POST');
                    req.setBody(body);

                    HTTPResponse res = http.send(req);
                    Map<String,Object> jsonBody = (Map<String,Object>) Json.deserializeUntyped(res.getBody());

                    System.debug('RESPPPP'+jsonBody);
                    return jsonBody;       
                }
                catch (Exception e) {
                    throw new AuraHandledException(e.getMessage());
                }
            }
            return null;
        }else{
            return null;
        }
    }*/
    @AuraEnabled
    public static void createInvoiceRec(String recordId){
        try {
            if(!String.isBlank(recordId)){
                Id recId = (Id) recordId;
                String objectAPIName = String.valueOf(recId.getsobjecttype());
    
                System.debug('RecordId---'+recordId+' ---OBJNAME---'+objectAPIName);
                Opportunity opp;
                Lead ld;
               
                if(objectAPIName=='Opportunity'){
                    opp = [SELECT Id, Name, Amount ,AccountId,Account.Phone,Account.Email__c From Opportunity Where Id =: recordId];
                    Invoice__c invoiceRec = new Invoice__c();
                    invoiceRec.Opportunity__c = opp.Id;
                    invoiceRec.Amount__c = opp.Amount;
                    invoiceRec.Initiated_Date__c = system.today();
                    insert invoiceRec;
                    
                }else if(objectAPIName=='Lead'){
                    ld = [Select Id, Name, Amount__c,Email, Phone From Lead Where Id=: recordId];
                    Invoice__c invoiceRec = new Invoice__c();
                    invoiceRec.Lead__c = ld.Id;
                    invoiceRec.Amount__c = ld.Amount__c;
                    invoiceRec.Initiated_Date__c = system.today();
                    insert invoiceRec;
                }
            }    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}