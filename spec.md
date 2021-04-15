# Specifications for the Rails Assessment

Specs:
- [x] Using Ruby on Rails for the project
- [x] Include at least one has_many relationship (x has_many y; e.g. User has_many Recipes): My app has Categories, which have many Products, which themselves have many Dimensions
- [x] Include at least one belongs_to relationship (x belongs_to y; e.g. Post belongs_to User): PriceModifiers belong to a Dimension which belong to a Product which belong to a Category
- [x] Include at least two has_many through relationships (x has_many y through z; e.g. Recipe has_many Items through Ingredients): Product has many PriceModifiers through Dimensions, User has many Products through Quantities, Product has many Users through Quantities
- [x] Include at least one many-to-many relationship (x has_many y through z, y has_many x through z; e.g. Recipe has_many Items through Ingredients, Item has_many Recipes through Ingredients): Products have many Users through Quantities, Users have many Products through Quantities
- [x] The "through" part of the has_many through includes at least one user submittable attribute, that is to say, some attribute other than its foreign keys that can be submitted by the app's user (attribute_name e.g. ingredients.quantity): Quantities have an amount of Products: quantities.amount, user submittable through checkout flow
- [x] Include reasonable validations for simple model objects (list of model objects with validations e.g. User, Recipe, Ingredient, Item): User, Admin, Product, Dimension, PriceModifier, Category, Quantity
- [x] Include a class level ActiveRecord scope method (model object & class method name and URL to see the working feature e.g. User.most_recipes URL: /users/most_recipes): My app's Product model has a search scope method that itself uses other scope methods to provide filters on a search
- [x] Include signup (how e.g. Devise): My app has custom signup logic for Admins and Users
- [x] Include login (how e.g. Devise): My app has custom login functionality for Admins and Users
- [x] Include logout (how e.g. Devise): My app has custom logout functionality for Admins and Users
- [x] Include third party signup/login (how e.g. Devise/OmniAuth): My app has Single Sign On functionality integrated through FoxyCart's API (Accounts are automatically synced to FoxyCart if they sign up on my site, User accounts are automatically created or signed in if they log in or sign up on FoxyCart, sessions are synced between my site and FoxyCart)
- [x] Include nested resource show or index (URL e.g. users/2/recipes): My app has a nested index view eg /categories/1/products
- [x] Include nested resource "new" form (URL e.g. recipes/1/ingredients/new): My app can update Products through a nested form eg /categories/1/products/new, or Dimensions through a nested form eg /categories/1/products/1/dimensions/new
- [x] Include form display of validation errors (form URL e.g. /recipes/new): Errors are displayed when submitting a new Product, Dimension, or Price Modifier

Confirm:
- [ ] The application is pretty DRY
- [ ] Limited logic in controllers
- [x] Views use helper methods if appropriate
- [x] Views use partials if appropriate
