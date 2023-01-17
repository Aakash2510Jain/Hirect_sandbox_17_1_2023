global class ScheduleBatchToUpdateTriggerAndClickPay implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchToUpdateTriggerAndClickPay batchInstance = new BatchToUpdateTriggerAndClickPay();
        Database.executeBatch(batchInstance);
    }
}