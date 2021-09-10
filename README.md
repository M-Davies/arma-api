# arma-api

An unofficial API for Arma 3 classnames and data from vanilla, DLC and common mod sources.

## Disclaimer

I, the developer, and contributors to this project in no way own the game, term or any other asset related to the video game series Arma. That right belongs solely to Bohemia Interactive. This is a simple, free, open-source project to make development and gameplay of the game's mission making feature easier and does not look to steal Bohemia Interactive's rights to the series and it's assets. The term, arma-api, is free to be claimed by Bohemia at any time.

However, as per the [license](./LICENSE), the code and assets for this api belong to the owner of this repository, with credit given to any contributors to the project for their contributions (which are welcome and gratefully appreciated).

## Usage and Examples

View usage on my [Swagger Instance](https://app.swaggerhub.com/apis-docs/M_Davies/arma-api/1.0.0).

- Fetch all classes: http://localhost:8080/classes
- Filter classes by mod: http://localhost:8080/classes/rhs
- Filter classes by type: http://localhost:8080/classes/?type=Bipods
- Filter by mod & class: http://localhost:8080/classes/rhs?type=Bipods
- Filter by search term: http://localhost:8080/classes/search/M16%20Rifle

## Contributing

All contributions or feature requests are more than appreciated. To get started, put a new post on [#General](https://github.com/M-Davies/arma-api/discussions/categories/general) stating who you are and how you wish to help out the community. This is just so I'm aware of who is looking into what so I can appropriately prioritise issues that you may be interested in!

### Building

1. To build the API locally, you will need the following dependencies:
    - Java 11 (recommended) or higher. I used a binary from [Adoptium](https://adoptium.net/) but any other provider should be fine.
    - [Mongo Community Server](https://www.mongodb.com/try/download/community) to store the classes.
    - [Maven](https://maven.apache.org/) to build the API. I used [brew](https://formulae.brew.sh/formula/maven) to install it but any method should be fine so long as it can be executed from a terminal.
    - [Community Based Addons (CBA)](https://steamcommunity.com/workshop/filedetails/?id=450814997) for Arma 3 (this is required as the SQF extraction script uses some of their functions).
    - You should also download and install the Arma 3 mods containing the configs you wish to extract, but keep in mind that you may experience weird errors if you are not using [the modset](https://steamcommunity.com/workshop/filedetails/?id=1355620316) I based it off of.
    - Once you're ready to go with the mods, boot up Arma 3 with the mods you want to extract Cfg Classes from.
2. Create your `.env` file. Duplicate the provided [env.example](env.example/) file and rename it to `.env`. Fill out the fields with your database and other configuration details. **Never commit this file to source control, keep it safe!**
3. Retrieve content from Arma 3. This will involve some fiddling but is easy when you get the hang of it:
    - Open a [Debug Console](https://community.bistudio.com/wiki/Arma_3:_Debug_Console) in Arma 3
    - In a text editor, open the [SQF Extraction Script](sqf/CFG_To_JSON.sqf) and edit the `_CONFIGS` hashmap to include the Cfg Classes you wish to extract to a JSON array. **NOTE:** Since Arma no longer supports arrays over 9,999,999 elements, you may encouter errors complaining of that face. In such cases, you may have to do the extraction in chunks (e.g. do `weapons` and `glasses` and then do `vehicles` and `magazines` separately).
    - Execute the script. If you encounter an error and you are using a different modset to the one I mentioned in step 1, please either [let the owner of arma-api know](https://github.com/M-Davies/arma-api/issues/new/choose) or make a pull request to add it to the script.
    - You should now have the JSON array on your clipboard!
4. Clear the contents of the [data](data/) directory of any JSON files to ensure that only your data is copied across. Copy the contents of your clipboard to an empty JSON file in the [data](data/) directory, creating it if necessary. The filename doesn't matter.
5. Then open a terminal at the root of this project and run `mvn clean install` to download the necessary libraries.
6. Now you're ready to populate your Mongo database! From the same terminal, run `mvn exec:java@Mongo-Updater`. This runs the [Updater](src/main/java/com/api/main/Updater.java) script that will clean and install two databases (one production and one backup) on Mongo full of configs.
7. Finally, run `mvn spring-boot:run` to run the API application. The API should now be accessible at http://localhost:8080/.
