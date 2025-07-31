public class OrderStatusUpdater {
    public static void updateOrderStatus(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return; // No orders to update
        }

        // Get only orders in 'New' status
        List<AgriEdge_Order__c> ordersToUpdate = [
            SELECT Id, Order_Status__c 
            FROM AgriEdge_Order__c 
            WHERE Id IN :orderIds AND Order_Status__c = 'New'
        ];

        // Update status to 'Processing'
        for (AgriEdge_Order__c order : ordersToUpdate) {
            order.Order_Status__c = 'Processing';
        }

        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }
}