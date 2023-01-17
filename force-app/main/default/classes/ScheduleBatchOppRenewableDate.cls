global class ScheduleBatchOppRenewableDate implements Schedulable{
    global void execute(SchedulableContext sc) {
        BatchOpportunityRenewableDate batchInstance = new BatchOpportunityRenewableDate();
        Database.executeBatch(batchInstance);
    }
}