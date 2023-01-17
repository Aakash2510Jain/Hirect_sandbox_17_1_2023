global class ScheduleBatchToDeleteDuplicateLead implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchToDeleteDuplicateLead batchInstance = new BatchToDeleteDuplicateLead();
        Database.executeBatch(batchInstance, integer.valueOf((integer.valueOf(system.label.BatchSize))));
    }
}