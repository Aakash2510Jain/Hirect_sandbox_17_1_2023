global class ScheduleBatchToSendEmailForRenewalAlert implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchToSendEmailForRenewalAlert batchInstance = new BatchToSendEmailForRenewalAlert();
        Database.executeBatch(batchInstance);
    }
}