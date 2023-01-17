global class ScheduleBatchToUpdateInactivityOnLead implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchToUpdateInactivityOnLead batchInstance = new BatchToUpdateInactivityOnLead();
        Database.executeBatch(batchInstance);
    }
}