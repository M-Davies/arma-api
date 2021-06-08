package com.api.main;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.stream.Collectors;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.expression.EvaluationException;

public class Parser {
    public static void main(String[] args) throws EvaluationException {
        final String[] PAGES = {
            "https://community.bistudio.com/wiki/Arma_3:_CfgWeapons_Weapons",
            "https://community.bistudio.com/wiki/Arma_3:_CfgWeapons_Items",
            "https://community.bistudio.com/wiki/Arma_3:_CfgWeapons_Equipment",
            "https://community.bistudio.com/wiki/Arma_3:_CfgMagazines"
        };

        HashMap<String, ArrayList<HashMap<String, ?>>> vanillaData = new HashMap<String, ArrayList<HashMap<String, ?>>> ();
        Config.getTypes().forEach(type -> {
            vanillaData.put(type, new ArrayList<HashMap<String, ?>> ());
        });

        final ArrayList<String> IGNORED_HEADERS = new ArrayList<String>(Arrays.asList("Used by", "Objects", "Ammo"));

        for (String wikiLink : PAGES) {
            try {
                // Grab wiki table from the page
                System.out.println("[INFO] Downloading " + wikiLink);
                Document doc = Jsoup.connect(wikiLink).get();
                Elements tableElements = doc.select("[class*=\"wikitable\"]");

                // Grab header elements & filter out unneeded ones
                System.out.println("[INFO] Constructing table header schema...");
                Elements tableHeaderEles = tableElements.select("tbody tr th");
                ArrayList<Element> tableHeaders = new ArrayList<Element> (
                    tableHeaderEles
                    .stream()
                    .filter(ele -> !IGNORED_HEADERS.contains(ele.text()))
                    .collect(Collectors.toList())
                );
                System.out.println("[SUCCESS] Obtained table headers!");
                tableHeaders.forEach(ele -> System.out.println(ele.text()));

                // Iterate through each row of the table
                System.out.println("[INFO] Parsing table contents...");
                Elements tableRowElements = tableElements.select(":not(thead) tr");
                for (int i = 0; i < tableRowElements.size(); i++) {
                    // Ensure we are only getting rows for columns that are not ignored
                    if (i <= tableHeaders.size()) {
                        Element row = tableRowElements.get(i);

                        // Iterate over the contents of a row
                        Elements rowItems = row.select("td");
                        for (int j = 0; j < rowItems.size(); j++) {
                            // Ensure we are only getting row items for columns that are not ignored
                            if (j <= tableHeaders.size()) {
                                // Get co-responding header
                                String headerName = tableHeaders.get(j).text();
                                HashMap<String, Object> newData = new HashMap<String, Object>();
                                System.out.println("[INFO] Parsing row item for header " + headerName + "\n" + row);

                                // Add to data depending on type of content
                                String itemContent = rowItems.get(j).text();
                                switch (headerName) {
                                    case "Preview":
                                        // If we have a image src link, add it
                                        if (rowItems.get(j).attributes().get("src") == null || rowItems.get(j).attributes().get("src").isEmpty()) {
                                            newData.put("image", "");
                                        } else {
                                            newData.put("image", rowItems.get(j).attributes().get("src"));
                                        }
                                        break;
                                    case "Class":
                                        newData.put("class", itemContent);
                                        break;
                                    case "Name":
                                        newData.put("name", itemContent);
                                        break;
                                    case "Inventory Description":
                                        newData.put("description", itemContent);
                                        break;
                                    case "Magazines":
                                        // Split the compatible ammo magazines into array
                                        newData.put("magazines", itemContent.split(" "));
                                        break;
                                    case "Accessories":
                                        // Split the compatible weapon attachments into array
                                        newData.put("accessories", itemContent.split(" "));
                                        break;
                                    default:
                                        throw new EvaluationException("[ERROR] Unrecognised header name: " + headerName);
                                }
                            }
                        }

                        // Finally, add the created object to JSON array according to it's type
                        
                    }
                }

                // Update JSON file with scraped data
                System.out.println("[SUCCESS] Finished parsing! Updating JSON file...");

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
