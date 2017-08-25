# Intermine gene search iOS
The InterMine app allows you to search through integrated genomics data-sets at a variety of model-organism databases. Use structured search templates to find relationships between different data sets, inspect your lists of genes of interest and use them in further data analysis and find items of interest from a range of searches on your iPhone.

## How to run the project?
1. [Download Xcode](https://itunes.apple.com/us/app/xcode/id497799835?mt=12)
2. Clone the project from Github:
```bash
git clone https://github.com/joystate/intermine-ios.git
```
3. Build and run project in Xcode

## Architecture
The application is build following [MVVM](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93viewmodel) pattern. The following logical parts are present in the application:
1. Models. There are two types of models - CoreData models (representing mine, mine model and saved search objects) and view models (providing UI elements for search results, lists and templates)
2. Views. The main storyboard contains all view controllers and major UI elements. Navigation between view controllers is written in code with animated transitions when appropriate.
3. Controllers. The main controller is tab bar controller. Navigation controllers are used to achieve the navigation inside the tabs.
4. Networking module is build using Alamofire library. IntermineAPIClient performs network requests.

## How to contribute?
To contribute to Intermine iOS app, one can do the following:
1. Write tests. All modules of the app need tests, including all application models and layers. Writing tests is the best place to start for a new contributor, as it allows to get familiar with the codebase.
2. Refactoring. Chasing perfection leads to better understanding of the codebase and makes the code more maintainable and clean.
3. [Github issues](https://github.com/intermine/intermine-ios/issues). Issues are written by developers of the application for the developers working on the application. Most likely, a new contributor will have trouble understanding the problem described in any particular issue. Try to get familiar with the codebase and contact one of the developers for more details.

## Dependencies
(All dependencies are already installed in the project repo)
* [Alamofire](https://github.com/Alamofire/Alamofire)
* [Font-Awesome-Swift](https://github.com/thii/FontAwesome.swift)
* [NVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView)
* [SWXMLHash](https://github.com/drmohundro/SWXMLHash)
