using { sap.capire.bookstore as my } from '../db/schema';

/**
 * Service used by customers to browse and order books
 */
service CatalogService {
  @readonly entity Books as projection on my.Books;
  @readonly entity Authors as projection on my.Authors;
  
  entity Orders as projection on my.Orders;
  entity OrderItems as projection on my.OrderItems;
}

/**
 * Service used by administrators to manage the bookstore
 */
service AdminService {
  entity Books as projection on my.Books;
  entity Authors as projection on my.Authors;
  entity Customers as projection on my.Customers;
  entity Orders as projection on my.Orders;
  entity OrderItems as projection on my.OrderItems;
}