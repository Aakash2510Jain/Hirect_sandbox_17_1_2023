public without sharing class InvoiceTriggerHelper {
    static InvoiceTriggerHelper handlerInstance;
    public static InvoiceTriggerHelper getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new InvoiceTriggerHelper();
        return handlerInstance;
    }
    public void paymentStatusUpdated(Map<Id, Invoice__c> oldMap, Map<Id, Invoice__c> newMap){
        try{
            set<Id> invoiceIds = new Set<Id>();
            
            for(Invoice__c invoiceRec : newMap.values()){
                if(invoiceRec.Status__c != oldMap.get(invoiceRec.Id).Status__c && invoiceRec.Status__c == Constants.INVOICE_STATUS_REALIZED){
                    invoiceIds.add(invoiceRec.Id);
                }
            }
            if(!invoiceIds.isEmpty()){
                for(Id invoiceRecId : invoiceIds){
                    TaxInvoiceHelper.attachPdf(invoiceRecId);
                }
            }
        }catch(exception ex){
            system.debug('Errror-->'+ex.getMessage());
            system.debug('Errror-->'+ex.getCause());
            system.debug('Errror-->'+ex.getLineNumber());
        }
    }
}