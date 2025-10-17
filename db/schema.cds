using { cuid, managed } from '@sap/cds/common';

namespace sap.capire.bookstore;

/**
 * Books available in the bookstore
 */
entity Books : cuid, managed {
  title         : String @title: 'Title';
  author        : String @title: 'Author';
  genre         : String @title: 'Genre';
  price         : Decimal(10,2) @title: 'Price';
  currency_code : String(3) @title: 'Currency Code' default 'USD';
  stock         : Integer @title: 'Stock';
  description   : String @title: 'Description';
  publisher     : String @title: 'Publisher';
  publishedAt   : Date @title: 'Published Date';
  isbn          : String(13) @title: 'ISBN';
}

/**
 * Authors of the books
 */
entity Authors : cuid, managed {
  name        : String @title: 'Name';
  birthDate   : Date @title: 'Birth Date';
  nationality : String @title: 'Nationality';
  biography   : String @title: 'Biography';
  books       : Association to many Books on books.author = $self.name;
}

/**
 * Customers who buy books
 */
entity Customers : cuid, managed {
  firstName   : String @title: 'First Name';
  lastName    : String @title: 'Last Name';
  email       : String @title: 'Email';
  phone       : String @title: 'Phone';
  address     : String @title: 'Address';
  city        : String @title: 'City';
  country     : String @title: 'Country';
  postalCode  : String @title: 'Postal Code';
}

/**
 * Orders placed by customers
 */
entity Orders : cuid, managed {
  customer_ID : UUID;
  customer    : Association to Customers on customer.ID = customer_ID;
  orderDate   : Date @title: 'Order Date';
  totalAmount : Decimal(10,2) @title: 'Total Amount';
  status      : String @title: 'Status' enum {
    pending = 'P';
    confirmed = 'C';
    shipped = 'S';
    delivered = 'D';
    cancelled = 'X';
  };
  items       : Composition of many OrderItems on items.order = $self;
}

/**
 * Items within an order
 */
entity OrderItems : cuid {
  order       : Association to Orders;
  book        : Association to Books;
  quantity    : Integer @title: 'Quantity';
  price       : Decimal(10,2) @title: 'Price';
}
