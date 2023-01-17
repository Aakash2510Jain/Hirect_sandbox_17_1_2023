@RESTResource(urlMapping='/razorpayWebhook/*')
global without sharing class RazorpayWebhookHandler {
    @HttpPost
    global static String webhookListener(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        String body = req.requestBody.toString();
        
        System.debug('REQUEST----'+body);
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(body);
        Map<String,Object> m2 =  (Map<String, Object>) m.get('payload');
        Map<String,Object> m3 =  (Map<String, Object>) m2.get('payment');
        Map<String,Object> m4 =  (Map<String, Object>) m3.get('entity');
        Map<String,Object> m5 = new Map<String, Object>();
        System.debug('PAYMENTID-----'+m4.get('id'));
        if(m4.containsKey('captured')){
            m5 =  (Map<String, Object>) m4.get('notes');
            String recId = m5.get('policy_name').toString();
            String objName = m5.get('objectName').toString();
            if(objName=='Opportunity'){
                Opportunity opp = new Opportunity(Id=recId, Payment_Captured__c= m4.get('captured')==true?'Success':'Failed');
                opp.StageName = 'Closed Won';
                update opp;
                Invoice__c invoiceRec = [Select Id,Status__c From Invoice__c Where Opportunity__c =: recId ORDER BY CreatedDate DESC limit 1];
                if(m4.get('captured')==true){
                    invoiceRec.Status__c = 'Realized';
                    invoiceRec.Transaction_No__c = String.ValueOf(m4.get('id'));
                }
                if(m4.get('captured')==false){
                    invoiceRec.Status__c = 'Not realized';
                }
                update invoiceRec;
                
            }else if(objName=='Lead'){
                
                LeadTriggerHandler.convertLeadAfterPayment(recId, m4);
                /*system.debug('Inside webhook handler for lead');
                Lead ld = new Lead(Id=recId, Payment_Captured__c= m4.get('captured')==true?'Success':'Failed',Payment_Status__c= m4.get('captured')==true?'Realized':'Not Realized');
                system.debug('Inside webhook handler-->'+ld);
                update ld;
                Invoice__c invoiceRec = [Select Id,Status__c From Invoice__c Where Lead__c =: recId ORDER BY CreatedDate DESC limit 1];
                if(m4.get('captured')==true){
                    invoiceRec.Status__c = 'Realized';
                }
                if(m4.get('captured')==false){
                    invoiceRec.Status__c = 'Not realized';
                }
                update invoiceRec;*/
            }
        }
        return 'Success';
    }
}