global class SchedulableBatchToAssignOnboardedLeads implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchToAssignOnboardedLeads batchInstance = new BatchToAssignOnboardedLeads();
        Database.executeBatch(batchInstance);
    }
}