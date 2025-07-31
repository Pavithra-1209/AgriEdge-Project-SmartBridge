# AgriEdge-Project-SmartBridge
## AgriEdge Order Management System (Salesforce Project)

This Salesforce project is built to streamline and automate the order management process for AgriEdge Or-Mange Ltd., a company engaged in agricultural product distribution. The solution includes the creation of custom objects, Apex classes, triggers, validation rules, and permission configurations - all aligned with the company's specific operational needs. The system handles key functionalities such as order creation, inventory updates, shipment tracking, and automated task generation, ensuring a smooth and efficient workflow from order placement to delivery.

---

## Features Implemented

- **Custom Objects**  
  - `AgriEdge_Order__c`  
  - `AgriEdge_OrderItem__c`  
  - `AgriEdge_Shipment__c`  
  - `AgriEdge_Inventory__c`

- **Automation**  
  - Validation rules to ensure data accuracy  
  - Process Builder for basic automation (record updates, task creation, etc.)  
  - Lookup filters and dynamic form behavior

- **Apex Code**  
  - Triggers to handle:
    - Auto-creation of order items and shipments
    - Inventory updates
    - Cascade deletion of child records  
  - Apex classes for:
    - Task creation  
    - Email notifications  
    - Order processing logic  
  - Test classes covering >75% of code, meeting deployment requirements

- **Security**  
  - Profiles for different platforms: `Platform 1`, `Platform 2`, and `Platform 3`  
  - Role hierarchy to control record visibility  
  - Organization-Wide Defaults (OWDs) and Sharing Settings configured

---

## Testing

- Unit tests ensure that:
  - Order creation behaves correctly  
  - Shipments and tasks are generated properly  
  - Inventory records are updated accurately  
  - Deletion of an AgriEdge Order record results in automatic deletion of related OrderItems and Shipment records
- Manual UI testing done via Salesforce Lightning Experience

---

## Possible Enhancements

- Implement Lightning Web Components (LWC) for order visualization  
- Use Apex Scheduler for inventory sync  
- Add approval process for bulk orders  
- Enhance reporting and dashboards

---

## Prepared By

**Pavithra Pamula**  
_Salesforce Developer Edition — SmartBridge Project_

---

