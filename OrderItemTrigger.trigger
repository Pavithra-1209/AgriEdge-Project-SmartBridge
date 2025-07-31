trigger OrderItemTrigger on AgriEdge_OrderItem__c (after insert, after update) {
    Set<Id> orderIds = new Set<Id>();

    // Collect Order IDs from inserted/updated OrderItem records
    for (AgriEdge_OrderItem__c orderItem : Trigger.new) {
        if (orderItem.AgriEdge_Order__c != null) {
            orderIds.add(orderItem.AgriEdge_Order__c);
        }
    }

    if (!orderIds.isEmpty()) {
        OrderStatusUpdater.updateOrderStatus(orderIds);
        OrderTotalUpdater.updateOrderTotal(orderIds);
    }
}
