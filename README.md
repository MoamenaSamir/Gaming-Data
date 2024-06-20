# Gaming Analysis with SQL

## Purpose
The primary purpose of this project is to analyze gaming data using SQL Server Management Studio (SSMS). The analysis aims to clean and extract valuable insights from the data to enhance game development and player experience.

## Objectives
- Clean and preprocess the data to ensure its accuracy and usability.
- Extract meaningful insights through SQL queries to support game development.
- Identify patterns and trends within the gaming data that can inform future enhancements.

## Key Features or Components
- **Dataset Composition**: The analysis involves two main tables:
  - **Player Details Table**: Contains information about the players, their IDs, and login details.
  - **Level Details Table**: Includes data on game levels, stages, difficulty levels, and player performance.

## Target Audience or Beneficiaries
- **Fans of War Games**: The insights gained from this project will primarily benefit war game enthusiasts by improving game features and overall player experience.

## Methodology or Approach
1. **Data Import**:
   - Import the data as a flat file into the gaming analysis database.
2. **Data Preparation and Modification**:
   - Delete unnecessary columns.
   - Change data types to ensure consistency and accuracy.
3. **SQL Problem Statement Analysis**:
   - Utilize various SQL functions and clauses to analyze the data, including:
     - **SQL Joins**: To combine data from different tables.
     - **SQL GROUP BY and HAVING Clause**: For grouping data and filtering groups.
     - **Nested Queries**: To perform complex queries within queries.
     - **COALESCE and CAST Function**: For handling NULL values and data type conversions.
     - **Row Number and Rank Function**: To assign unique ranks and numbers to rows.
     - **Minimum and Top Function**: To identify the smallest values and top records.
     - **SQL Declare Variable**: To define variables for query operations.
     - **OFFSET-FETCH Clause**: For pagination of query results.

## Expected Outcomes or Results
- **Enhanced Game Development**: The insights derived from the analysis will inform improvements in game design and functionality.
- **Advanced Features**: Potential to add new and advanced features based on player behavior and performance data.

## Dataset Description
- **Game Structure**:
  - The game is divided into three levels: L0, L1, and L2.
  - Each level has three difficulty levels: Low, Medium, and High.
  - Players must kill opponents using guns or physical combat in each level.
  - Each level consists of multiple stages at each difficulty level.
  - Players can only progress to Level 1 (L1) and Level 2 (L2) with system-generated codes.
  - Players start at Level 0 (L0) by default.
  - Players log in using a Dev_ID.
  - Extra lives can be earned at each stage in a level.
