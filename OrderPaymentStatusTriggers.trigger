trigger OrderPaymentStatusTriggers on AgriEdge_Order__c (after update) {
    Set<Id> updatedOrderIds = new Set<Id>();

    // Collect Orders where Payment_Status__c was changed to "Paid"
    for (AgriEdge_Order__c order : Trigger.new) {
        AgriEdge_Order__c oldOrder = Trigger.oldMap.get(order.Id);
        if (oldOrder.Payment_Status__c != 'Paid' && order.Payment_Status__c == 'Paid' && order.Customer__c != null) {
            updatedOrderIds.add(order.Id);
        }
    }

    if (!updatedOrderIds.isEmpty()) {
       
        OrderEmailSender.sendOrderEmail(updatedOrderIds);
    }
}