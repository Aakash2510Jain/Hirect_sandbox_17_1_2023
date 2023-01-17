public class CustomNotification {
    public static void notifyUsers(Set<String> recipientsIds, Map<Id,Lead> leadByIdMap) {
        

        string notificationTitle = 'Please Check out Lead Updated by OPPs Teams';
        String notificationBody = 'Comment has been added by OPPs Teams On ';
        CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Updated_By_OPPS_Team'];
        if(notificationType != null){
            if(!leadByIdMap.isEmpty()){
                for(Lead leadRec : leadByIdMap.values()){
                    Messaging.CustomNotification notification = new Messaging.CustomNotification();
                    if(!string.isBlank(notificationTitle))
                        notification.setTitle(notificationTitle);
                    if(!string.isBlank(notificationBody))
                        notification.setBody(notificationBody+' '+leadRec.FirstName+' '+leadRec.LastName);
                    notification.setNotificationTypeId(notificationType.Id);
                    notification.setTargetId(leadRec.Id);
                    system.debug('send');
                    try {
                        system.debug('sending');
                        notification.send(recipientsIds);
                    }
                    catch (Exception e) {
                        System.debug('Problem sending notification: ' + e.getMessage());
                    }   
                } 
            }
        }
    }
}