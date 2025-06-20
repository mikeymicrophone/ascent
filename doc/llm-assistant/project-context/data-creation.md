## Data Creation

### Seeding

This project can support user-generated data, but also can realistically seed a huge portion of what we would need.  Historical elections and candidates will be important, and contemporary candidates should be easy to identify.  Any time these can be added to our seeds, that's totally good.


### Factories

Rather than minimalist, unit-test oriented factories, our definitions are highly specified with realistic data, and are developing a library of traits that will help to define the situations that our system can be useful for.  These factories can be used during the development process, and are also intended for use in our controllers, via the simulate pattern.  Simulating data involves a find-or-create paradigm, where some degree of chance factors into how many records are present.

### Ruby Scripts

Do not use temporary Ruby scripts to create data, unless you are sure it is a scenario where our factories cannot be used.  