# -*- coding: utf-8 -*-
"""
Created on Wed Nov 20 12:20:44 2024

@author: Odoo
"""

# Reimport the necessary library
import random
import pandas as pd

# Generate data for vendor table (10 rows)
vendor_data = {
    "vid": list(range(1, 11)),
    "vname": [f"Vendor {chr(65 + i)}" for i in range(10)],
    "vphone": [f"010{random.randint(10000000, 99999999)}" for _ in range(10)]
}

# Generate data for category table (5 categories for grocery market)
category_data = {
    "cid": [1, 2, 3, 4, 5],
    "cname": ["Dairy", "Beverages", "Snacks", "Fruits", "Vegetables"],
    "product_unit": ["Piece", "Piece", "Piece", "Weight", "Weight"]
}

# Define product names for each category
product_names = {
    1: ["Milk", "Cheese", "Butter", "Yogurt", "Cream", "Cottage Cheese", "Mozzarella", "Feta", "Ricotta", "Ghee"],
    2: ["Orange Juice", "Apple Juice", "Lemonade", "Soda", "Mineral Water", "Coffee", "Tea", "Cocoa", "Milkshake", "Iced Tea"],
    3: ["Chips", "Cookies", "Popcorn", "Biscuits", "Nuts", "Granola Bars", "Candy", "Chocolate", "Crackers", "Pretzels"],
    4: ["Apples", "Bananas", "Oranges", "Grapes", "Pears", "Mangoes", "Pineapples", "Watermelon", "Cherries", "Peaches"],
    5: ["Potatoes", "Carrots", "Cucumbers", "Tomatoes", "Onions", "Lettuce", "Spinach", "Bell Peppers", "Garlic", "Broccoli"]
}

# Generate data for product table (50 rows)
product_data = {
    "pid": list(range(1, 51)),
    "pname": [random.choice(product_names[category]) for category in [random.choice(category_data["cid"]) for _ in range(50)]],
    "cost": [random.randint(5, 50) for _ in range(50)],
    "price": [random.randint(51, 100) for _ in range(50)],
    "cid": [random.choice(category_data["cid"]) for _ in range(50)]
}

# Generate data for customer table (50 rows)
customer_data = {
    "customerid": list(range(1, 51)),
    "fname": [f"Customer {i}" for i in range(1, 51)],
    "lname": [f"Last {i}" for i in range(1, 51)],
    "phone": [f"012{random.randint(10000000, 99999999)}" for _ in range(50)],
    "caddress": [random.choice(["Cairo", "Alex", "Mansoura"]) for _ in range(50)]
}

# Generate data for employee table (7 rows)
employee_data = {
    "eid": list(range(1, 8)),
    "fname": [f"Emp {i}" for i in range(1, 8)],
    "lname": [f"Last {i}" for i in range(1, 8)],
    "phone": [f"015{random.randint(10000000, 99999999)}" for _ in range(7)],
    "eaddress": ["Cairo"] * 7,
    "age": [random.randint(25, 40) for _ in range(7)],
    "salary": [7000 + i * 1000 for i in range(7)],  # Total: 70000
    "commission": [random.randint(400, 800) for _ in range(7)],
    "did": [random.randint(1, 3) for _ in range(7)]
}

# Generate data for orders table (50 rows)
orders_data = {
    "oid": list(range(1, 51)),
    "odate": [f"2024-11-{random.randint(1, 30):02d}" for _ in range(50)],
    "customerid": [random.randint(1, 50) for _ in range(50)],
    "payid": [random.randint(1, 2) for _ in range(50)],
    "eid": [random.randint(1, 7) for _ in range(50)],
    "quantity": [random.randint(1, 20) for _ in range(50)]
}

# Generate data for payment table (2 payment types only: Visa, Cash)
payment_data = {
    "payid": [1, 2],
    "ptype": ["Visa", "Cash"]
}

# Generate data for vendor_product table (50 rows)
vendor_product_data = {
    "vid": [random.randint(1, 10) for _ in range(50)],
    "pid": [random.randint(1, 50) for _ in range(50)]
}

# Generate data for product_order table (50 rows)
product_order_data = {
    "oid": [random.randint(1, 50) for _ in range(50)],
    "pid": [random.randint(1, 50) for _ in range(50)],
    "discount": [random.randint(0, 10) for _ in range(50)]
}

# Save all tables to an Excel file
file_path = "E:/Data Science/small_grocery_market.xlsx"
with pd.ExcelWriter(file_path) as writer:
    pd.DataFrame(vendor_data).to_excel(writer, index=False, sheet_name="vendor")
    pd.DataFrame(category_data).to_excel(writer, index=False, sheet_name="category")
    pd.DataFrame(product_data).to_excel(writer, index=False, sheet_name="product")
    pd.DataFrame(customer_data).to_excel(writer, index=False, sheet_name="customer")
    pd.DataFrame(employee_data).to_excel(writer, index=False, sheet_name="employee")
    pd.DataFrame(orders_data).to_excel(writer, index=False, sheet_name="orders")
    pd.DataFrame(payment_data).to_excel(writer, index=False, sheet_name="payment")
    pd.DataFrame(vendor_product_data).to_excel(writer, index=False, sheet_name="vendor_product")
    pd.DataFrame(product_order_data).to_excel(writer, index=False, sheet_name="product_order")

file_path
