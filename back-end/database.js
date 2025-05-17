import mysql from 'mysql2';
import dotenv from 'dotenv';
dotenv.config();

import fs from 'fs';

import { fileURLToPath } from 'url';
import { join, dirname } from 'path';

export const pool = mysql.createPool({
    host: process.env.MySQL_HOST,
    user: process.env.MySQL_USER,
    password: process.env.MySQL_PASSWORD,
    database: process.env.MySQL_DATABASE,
    multipleStatements: true,
    queueLimit: 0
}).promise();

const executeSQLFile = async (filePath) => {
    try {
        const sql = fs.readFileSync(filePath, {encoding: "utf8"});
        await pool.query(sql)
        console.log(`Query OK,for ${filePath}`)
    } catch (error) {
        console.log(`Error in Excuting ${filePath}: ${error.message}`)
    }
}
const __filePath  = fileURLToPath(import.meta.url);
const __dirpath = dirname(__filePath)

export const setUpDatabase = async () => {
    try {
        console.log("Setting up database...")
        
        const folderLocation = join(__dirpath, 'schema');

        const sqlFileNames = [
            "create_user_table.sql",
            "create_article_table.sql",
            "create_event_table.sql",
            "create_user_event_table.sql",
        ] 

        // Create DataBase
        await executeSQLFile(join(folderLocation, 'create_Database.sql'))

        // Create each table by using for loop
        for (let index = 0; index < sqlFileNames.length; index++) {
            await executeSQLFile(join(folderLocation, sqlFileNames[index]))
        }
            
        
        console.log("Databse design has been complated")
    } catch (error) {
        console.log(error.message)
    }
}