# Market News App

## Overview
The purpose of the market news app is to keep its users updated with the latest news about the market. The home page shows thumbnails of news from latest to oldest, and the user can click a thumbnail to see a preview of the news article. In the preview they can decide to read the full article by clicking a button. It has other features that facilitate the process of managing the overwhelming amount of news that the user receives. One of these features is a favorites list. With this feature, the user is able to add interesting news to the list and watch them later. This list is especially helpful if the user doesn’t have time to read some articles. Another feature is a history tab, where the user can see previously visited articles. A history of visited articles can help the user reference back to them in case they need to read them again. Last but not least, the app has a search feature that allows the user to search for articles containing some text in their title. Therefore, the users can use this feature to find news that talk about certain topics. The app also has a simple yet useful user interface which improves the user experience.

## Resources
This app gets the 100 most recent news from Finnhub. Though, the Finnhub API only returns the 100 most recent news, so it doesn’t keep track of older news. To fix this problem, the app stores all news in Firestore, which is a cloud database. By storing them in a database, it allows the app to access older news. Since the app doesn’t ask for user registration, it saves the history and favorite lists in the memory. It uses the sqflite package which is the flutter plugin for SQLite, a SQL database. To manage the state of the news, favorite, history, and search lists, the app uses Cubit. Other packages that the app uses are timeago and intl to calculate the publish time and http to make the request to the Finnhub API. Since Finnhub only gives the url to the article, the app has to use webview_flutter to show the full article.

## Screenshots
![Home Page](/images/home_screenshot.png | width=580)  

![Preview Page](/images/preview_screenshot.png = 580x1645)  
