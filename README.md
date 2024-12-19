# Discount Degree

## Description
Discount Degree is a web app that shows users the cheapest path to get a degree from an acreddited four year university.
It will show you all available transfer credits from a community college, and possibly a cheaper intermediary university, before finishing the degree at the university of choice. 

## Table of Contents
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)
- [Current State](#current-state-of-project)

## Installation

1. Clone the repository:
`git clone https://github.com/Testell/discount_degree`

2. Navigate to the project directory:
`cd discount_degree`

3. Install the required gems:
`bundle install`

4. Set up the database:
`rails db:setup`

5. Run:
`rails db:migrate` <!-- Does the migration give you the user or the setup? >
  - This will give you:
    - A admin account email: admin@example.com pw: admin123
    - Sample data with courses/transferable courses, a degree, 3 schools, and it will generate a plan.

6. Start the Rails server:
`rails server`

## Usage

1. Start the Rails server:
`rails server`

2. Open your browser and navigate to http://localhost:3000

3. Sign into admin account to have access to admin workflows

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Go to [Project Board](https://github.com/users/Testell/projects/2/views/1)
3. Create a new branch from a issue on the project board
4. Commit your changes (`git commit -m 'Add some feature'`)
5. Push to the branch (`git push origin feature-branch`)
6. Open a pull request
7. There is a rubocop check for [Prettier Ruby](https://github.com/prettier/plugin-ruby) to be used on all .rb files
8. Please use [erb-formatter](https://github.com/nebulab/erb-formatter) for all .erb files

## License
Distributed under the MIT License. See `LICENSE` for more information.

## Contact

Tyler - [tylerestell1@gmail.com](mailto:tylerestell1@gmail.com)
Project Link: [https://github.com/Testell/discount_degree](https://github.com/Testell/discount_degree)

## Current state of project
![ERD](image-1.png)

- Next steps for domain modeling:
  1. Plans needs to be refactored to account for custom user plans in the future
  2. All is_mandatory = false course_requirement courses should be saved as a list of options
  3. List of options is all possible courses at school that can be chosen(ex. All philospohy classes for philosphy requirement)
  4. User plans table which is identical to plans currently, will be the users custom plans with all optional courses chosen.

- Next steps for cheapest_plan_service
  - The algorithm needs comprehensive testing

  - Intermediary university logic is questionable

  - Currently works, but if transferable courses have differing credit hours the total will be off
        I have to do more research on this but from what I understand the credit hour amount given
        for a transfer course depends on the school. So if you take a 3 credit hour course at a 
        community college and transfer it to a university, the university might not have a equivalent
        course, but the course may be valid for transfer to fulfill a degree requirement. Otherwise the 
        course might have a 1 to 1 transfer to another course. In the case that its a 1 to 1 
        transfer, the amount of credit hours given varies by school. The algo currently works 
        on the 1 to 1 transfer method where the ending school rewards the credit hours based on the course
        offered at their school, but total credits will be off if the credit amounts are
        different, due to displaying the credit hours from the school the course was taken.

    - May have to refactor the transferable courses table to connect to degree requirements
      in the case of schools not having 1 to 1 transfers.

    Feedback i've gotten on the service:

    - All paths should be shown. 
      I think this can be filtered to:
        Find cheapest plan, cheapest full time plan, and the traditional 
        plans(full time at ending uni, and community -> ending university)

      With all of these a graph can be shown to users showing comparisons of time spent vs money spent.




    
  
  Sketch for algorithm:

  ![Alt text](image-2.png)
