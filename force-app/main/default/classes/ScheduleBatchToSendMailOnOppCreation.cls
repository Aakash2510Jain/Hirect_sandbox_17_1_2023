global class ScheduleBatchToSendMailOnOppCreation implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchToSendMailOnOppCreation batchInstance = new BatchToSendMailOnOppCreation();
        Database.executeBatch(batchInstance);
    }
}