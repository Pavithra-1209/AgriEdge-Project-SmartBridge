trigger AgriEdgeOrderItemStockReducer on AgriEdge_OrderItem__c (after insert,after update) {
    Map<Id, Integer> productToQtyOrdered = new Map<Id, Integer>();

    // Step 1: Aggregate quantity ordered per product
    for (AgriEdge_OrderItem__c item : Trigger.new) {
        if (item.Product__c != null && item.Quantity__c != null) {
            if (!productToQtyOrdered.containsKey(item.Product__c)) {
                productToQtyOrdered.put(item.Product__c, 0);
            }
            productToQtyOrdered.put(item.Product__c, productToQtyOrdered.get(item.Product__c) + item.Quantity__c.intValue());
        }
    }

    // Step 2: Fetch inventory records for those products
    Map<Id, AgriEdge_Inventory__c> productToInventoryMap = new Map<Id, AgriEdge_Inventory__c>();
    for (AgriEdge_Inventory__c inv : [
        SELECT Id, Product__c, Stock_Quantity__c
        FROM AgriEdge_Inventory__c
        WHERE Product__c IN :productToQtyOrdered.keySet()
    ]) {
        productToInventoryMap.put(inv.Product__c, inv);
    }

    // Step 3: Reduce stock quantity
    List<AgriEdge_Inventory__c> inventoriesToUpdate = new List<AgriEdge_Inventory__c>();
    for (Id productId : productToQtyOrdered.keySet()) {
        if (productToInventoryMap.containsKey(productId)) {
            AgriEdge_Inventory__c inventory = productToInventoryMap.get(productId);
            Integer currentStock = inventory.Stock_Quantity__c != null ? inventory.Stock_Quantity__c.intValue() : 0;
            Integer orderedQty = productToQtyOrdered.get(productId);

            inventory.Stock_Quantity__c = currentStock - orderedQty;
            inventoriesToUpdate.add(inventory);
        }
    }

    // Step 4: Update inventory
    if (!inventoriesToUpdate.isEmpty()) {
        update inventoriesToUpdate;
    }
}