public class AssignLeadsFromAppIndia{
    public static void distributeLeads(){
        DateTime currentTime = system.now();
        DateTime twoAndHalHourBefore = currentTime.addMinutes(-150);
        DateTime threeAndHalfHourBefore = currentTime.addMinutes(-210);

        String appIndiaRegQueueId = [SELECT Id, Type
                                     FROM Group
                                     WHERE Type = 'Queue' AND Name = 'App India Registration (Backend)'
                                     limit 1].Id;
        Map<Id, Lead> leadMapForRoundRobin = new Map<Id, Lead>([Select Id, OwnerId
                                                                From Lead
                                                                Where OwnerId = :appIndiaRegQueueId AND (RegistrationProgress__c = 'Audit Rejected' OR RegistrationProgress__c = 'Upload documents') AND (CreatedDate < :twoAndHalHourBefore AND CreatedDate > :threeAndHalfHourBefore)]);
        Map<Id, Lead> leadMapForDummyUser = new Map<Id, Lead>([Select Id, OwnerId
                                                               From Lead
                                                               Where OwnerId = :appIndiaRegQueueId AND (RegistrationProgress__c = 'Audit Verified') AND (CreatedDate < :twoAndHalHourBefore AND CreatedDate > :threeAndHalfHourBefore)]);
        List<Lead> leadListToBeUpdated = new List<Lead>();
        Set<String> leadIdSet = new Set<String>();
        String dummyUserId = [select id
                              From User
                              where Name = :'Dummy User'].Id;

        if (!leadMapForRoundRobin.isEmpty()){
            for (String leadId : leadMapForRoundRobin.keySet()){
                leadIdSet.add(leadId);
            }
            if (!leadIdSet.isEmpty()){
                RoundRobinLeadAssignmentForRM.assignLeadsToBDS('courseName', leadIdSet);
            }
        }
        if (!leadMapForDummyUser.isEmpty()){
            for (Lead leadRec : leadMapForDummyUser.values()){
                Lead leadRecToBeUpdated = new Lead();
                leadRecToBeUpdated.Id = leadRec.Id;
                leadRecToBeUpdated.OwnerId = dummyUserId;
                leadListToBeUpdated.add(leadRecToBeUpdated);
            }
            if (!leadListToBeUpdated.isEmpty()){
                Update leadListToBeUpdated;
            }
        }
    }

}