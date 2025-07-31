public class OrderTotalUpdater {
    public static void updateOrderTotal(Set<Id> orderIds) {
        if (orderIds == null || orderIds.isEmpty()) {
            return;
        }
        // Map to store OrderId and its Total Price
        Map<Id, Decimal> orderTotals = new Map<Id, Decimal>();
        // Query all order items related to the given orders
        for (AggregateResult ar : [
            SELECT AgriEdge_Order__c orderId, SUM(Total_Price__c) totalAmount
            FROM AgriEdge_OrderItem__c 
            WHERE AgriEdge_Order__c IN :orderIds
            GROUP BY AgriEdge_Order__c
        ]) {
            orderTotals.put((Id) ar.get('orderId'), (Decimal) ar.get('totalAmount'));
        }
        List<AgriEdge_Order__c> ordersToUpdate = new List<AgriEdge_Order__c>();
        // Query orders that need to be updated
        for (AgriEdge_Order__c order : [
            SELECT Id, Total_Amount__c, Payment_Status__c 
            FROM AgriEdge_Order__c 
            WHERE Id IN :orderIds
        ]) {
            order.Total_Amount__c = orderTotals.containsKey(order.Id) ? orderTotals.get(order.Id) : 0;
            order.Payment_Status__c = (order.Total_Amount__c > 0) ? 'Pending' : 'Paid'; // If total > 0, set to Pending
            ordersToUpdate.add(order);
        }
        if (!ordersToUpdate.isEmpty()) {
            update ordersToUpdate;
        }
    }
}