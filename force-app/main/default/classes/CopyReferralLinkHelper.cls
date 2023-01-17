public without sharing class CopyReferralLinkHelper {
    @AuraEnabled 
    public static user fetchUser(){
        User userRec = [select id,Name,Profile.Name from User where id =: userInfo.getUserId()];
        return userRec;
    }
}