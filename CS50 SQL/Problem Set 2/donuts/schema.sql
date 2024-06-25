CREATE TABLE "ingredients" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "price_per_unit" NUMERIC NOT NULL,
    "unit" TEXT NOT NULL,
    PRIMARY KEY("id")
);

CREATE TABLE "donuts" (
    "id" INTEGER,
    "name" TEXT NOT NULL UNIQUE,
    "gluten_free" TEXT NOT NULL,
    "price" NUMERIC NOT NULL,
    "ingredient_1" INTEGER,
    "ingredient_2" INTEGER,
    "ingredient_3" INTEGER,
    "ingredient_4" INTEGER,
    PRIMARY KEY("id")
    FOREIGN KEY("ingredient_1") REFERENCES "ingredients"("id"),
    FOREIGN KEY("ingredient_2") REFERENCES "ingredients"("id"),
    FOREIGN KEY("ingredient_3") REFERENCES "ingredients"("id"),
    FOREIGN KEY("ingredient_4") REFERENCES "ingredients"("id")
);

CREATE TABLE "orders" (
    "id" INTEGER,
    "donuts" TEXT NOT NULL,
    "customer_id" INTEGER,
    PRIMARY KEY("id"),
    FOREIGN KEY("customer_id") REFERENCES "customers"("id")
);

CREATE TABLE "customers" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "orders" TEXT NOT NULL,
    PRIMARY KEY("id")
);