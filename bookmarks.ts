const fs = require("fs");

type Leaf = {
    "children" : Leaf[] | null;
    "date_added": string;
    "date_last_used": string;
    "guid": string;
    "id": string;
    "meta_info": any | null;
    "name": string;
    "type": Types;
    "url": string | null;
};

type Types = "url" | "folder"

const stringList: string[] = [];

const filePath = process.argv[2]

fs.readFile(filePath, 'utf-8', (err, data) => {
    if (err){
        console.log("Error reading the file");
    }
    const jsonObject = JSON.parse(data);
    const root = jsonObject.roots;
    for (const obj1 in root){
        const child1: Leaf[] = root[obj1];
        if (child1["type"] == "folder"){
            const child2: Leaf[] = child1["children"];
            for (const obj2 of child2){
                if (obj2["type"] == "folder"){
                    const child3: Leaf[] | null = obj2["children"];
                    if (child3 != null){
                        for(const obj3 of child3){
                            if(obj3.url == undefined) continue;
                            stringList.push(`${obj3.name}~~${obj3.url}`);
                        }
                    }   
                } else {
                    stringList.push(`${obj2.name}~~${obj2.url}`)
                }
            }
        }
    }
    for (let url of stringList){
        console.log(url);
    }
} );
