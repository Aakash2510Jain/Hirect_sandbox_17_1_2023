public class ConvertLeadHelper {
    @AuraEnabled
    public static string convertingLead(string leadId){
        system.debug('leadId-->'+leadId);
        try{
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(leadId);
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            if(lcr.isSuccess()){
                system.debug('lcr--->'+lcr);
                system.debug('lcr.getContactId()-->'+lcr.getContactId());
                    
                return lcr.getContactId();
            }else{
                return String.ValueOf(lcr.getErrors());
            }
        }catch(exception ex){
            system.debug('Error-->'+ex.getMessage());
            system.debug('Error->'+ex.getLineNumber());
            return ex.getStackTraceString();
        }
    }

}