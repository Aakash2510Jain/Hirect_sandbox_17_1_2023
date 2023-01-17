global class ScheduleBatchForAutoCheckin implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchForAutoCheckin batchInstance = new BatchForAutoCheckin();
        Database.executeBatch(batchInstance);
    }
}