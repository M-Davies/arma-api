package com.api.main;

import java.util.*;
import java.util.stream.Collectors;
import java.io.IOException;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

public class Parser {
    public static void main(String[] args) {
        final String[] PAGES = {
            "https://community.bistudio.com/wiki/Arma_3:_CfgWeapons_Weapons",
            "https://community.bistudio.com/wiki/Arma_3:_CfgWeapons_Items",
            "https://community.bistudio.com/wiki/Arma_3:_CfgWeapons_Equipment",
            "https://community.bistudio.com/wiki/Arma_3:_CfgMagazines"
        };

        final ArrayList<String> IGNORED_HEADERS = new ArrayList<String>(Arrays.asList("Used by", "Objects"));

        for (String wikiLink : PAGES) {
            try {
                // Grab wiki table from the page
                System.out.println("[INFO] Downloading " + wikiLink);
                Document doc = Jsoup.connect(wikiLink).get();
                Elements tableElements = doc.select("[class*=\"wikitable\"]");

                // Grab header elements & filter out unneeded ones
                System.out.println("[INFO] Constructing header schema...");
                Elements tableHeaderEles = tableElements.select("tbody tr th");
                ArrayList<Element> tableHeaders = new ArrayList<Element> (
                    tableHeaderEles
                    .stream()
                    .filter(ele -> !IGNORED_HEADERS.contains(ele.text()))
                    .collect(Collectors.toList())
                );
                System.out.println("[SUCCESS] Obtained headers!");
                tableHeaders.forEach(ele -> System.out.println(ele.text()));

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
