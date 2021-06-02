package com.api.main;

import java.io.IOException;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

public class Parser {
    public static void main(String[] args) {
        final String[] pages = {
            "https://community.bistudio.com/wiki/Arma_3:_CfgWeapons_Weapons",
            "https://community.bistudio.com/wiki/Arma_3:_CfgMagazines",
            "https://community.bistudio.com/wiki/Arma_3:_CfgWeapons_Items",
            "https://community.bistudio.com/wiki/Arma_3:_CfgWeapons_Equipment"
        };

        for (String wikiLink : pages) {
            try {
                // Grab wiki table from the page
                Document doc = Jsoup.connect(wikiLink).get();
                Elements tableElements = doc.select("[class*=\"wikitable\"]");

                // Grab header elements
                Elements tableHeaderEles = tableElements.select("thead tr th");
                System.out.println("HEADERS FOR" + wikiLink);
                for (int i = 0; i < tableHeaderEles.size(); i++) {
                    System.out.println(tableHeaderEles.get(i).text());
                }
                System.out.println();

                // Iterate over table rows that are not a header
                Elements tableRowElements = tableElements.select(":not(thead) tr");
                for (int i = 0; i < tableRowElements.size(); i++) {
                    Element row = tableRowElements.get(i);
                    System.out.println("ROW");
                    Elements rowItems = row.select("td");
                    for (int j = 0; j < rowItems.size(); j++) {
                        System.out.println(rowItems.get(j).text());
                    }
                    System.out.println();
                }

            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
