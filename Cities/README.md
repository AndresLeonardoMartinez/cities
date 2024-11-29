# cities
SwiftUI challenge 

Sort approach: 
The search functionality is optimized using a dictionary-based approach that indexes cities by their first character. CitiesSearchHelper is used to solve the search problem. This is a dictionary of char as key and array of CityId. This is a custom class with the name and the city id. This is a big improvement since we don't need to look into the huge array. In this way we can search only on the array of cities matching the prefix of the city name.
LazyVStack is used to list the cities since List has some performance issues.
Background task are done using Task.
CitiesViewModel uses dictionaries to access city displays in O(1).
User default is used to store the favorites using an array of ids.

Out of scope:
- Improve separation of concerns. ViewModel is quite big
- Unit test
- UI tests 
- portrait and landscape views repeat code, find a DRY way
- UI improvements 

