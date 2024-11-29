# cities
SwiftUI challenge 

Sort approach: 
The search functionality is optimized using a dictionary-based approach that indexes cities by their first character. CitiesSearchHelper is used to solve the search problem. This is a dictionary of char as key and array of CityId. This is a custom class with the name and the city id. This is a big improvement since we don't need to look into the huge array. In this way we can search only on the array of cities matching the prefix of the city name.

LazyVStack is used to list the cities since List has some performance issues.

Background task are done using Task.

CitiesViewModel uses dictionaries to access city displays in O(1).

User default is used to store the favorites using an array of ids.

## Portrait

|![Simulator Screenshot - iPhone 16 Pro - 2024-11-28 at 23 58 18](https://github.com/user-attachments/assets/e4116fa3-8956-48fb-9510-70896068d77a)|![Simulator Screenshot - iPhone 16 Pro - 2024-11-28 at 23 57 43](https://github.com/user-attachments/assets/0a5292a6-c1cf-4124-a387-e98a4e339726)|![Simulator Screenshot - iPhone 16 Pro - 2024-11-28 at 23 58 33](https://github.com/user-attachments/assets/08fee306-b0fc-4940-8e00-6ec4e329cd71)|
|---|----|---|

## Landscape
|![Simulator Screenshot - iPhone 16 Pro - 2024-11-29 at 00 00 02](https://github.com/user-attachments/assets/81c4fa08-6ecc-44b9-a761-185ac506b59e)|![Simulator Screenshot - iPhone 16 Pro - 2024-11-28 at 23 59 53](https://github.com/user-attachments/assets/79109303-a34b-4cca-b3c2-e18e76e9c69b)|
|---|----|


Out of scope:
- Improve separation of concerns. ViewModel is quite big
- Unit test
- UI tests 
- portrait and landscape views repeat code, find a DRY way
- UI improvements 
