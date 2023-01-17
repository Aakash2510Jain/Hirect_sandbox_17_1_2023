public with sharing class UserLeavesStats {

    @auraEnabled
    public static User userdetailsonDoint(){
        User U = new User();
        try {
            U = [SELECT FirstName,Id,LastName,Leave_End_Date__c,Leave_Start_Date__c,Username FROM User Where Id =:UserInfo.getUserId()];
            System.debug('user Details :: ' + U);
        } catch (Exception e) {
            System.debug('the Error has ocurred due to ====== >' + e.getMessage());
            System.debug('the Error has ocurred at Line Number ====== >' + e.getLineNumber());
        }
        return U;
    }

    @AuraEnabled
    public static void UpdateUserDetails(date LeaveStartdate, date LeaveEnddate){
        try {
            System.debug('LeaveStartdate =====> ' + LeaveStartdate);
            System.debug('LeaveEnddate =====> ' + LeaveEnddate);
            user updatedUserDetails = new User();
            updatedUserDetails.Id = UserInfo.getUserId();
            updatedUserDetails.Leave_Start_Date__c = LeaveStartdate;
            updatedUserDetails.Leave_End_Date__c = LeaveEnddate;
            System.debug(' updatedUserDetails =====>' + updatedUserDetails );
            Update updatedUserDetails;
            
        } catch (Exception e) {
            System.debug('the Error has ocurred due to ====== >' + e.getMessage());
            System.debug('the Error has ocurred at Line Number ====== >' + e.getLineNumber());
        }
    }

    
}