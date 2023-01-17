global class ScheduleBatchAccountInactiveSince implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchAccountInactiveSince batchInstance = new BatchAccountInactiveSince();
        Database.executeBatch(batchInstance);
    }
}