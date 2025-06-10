import express from 'express';
import dotenv from 'dotenv';
import { setUpDatabase } from './database.js';


import articleRoute from './routers/api/articleRoute.js';
import userEventRoute from './routers/api/userEventRoute.js';
import userRoute from './routers/api/userRoute.js';
import authRoute from './routers/api/authRoute.js';
import eventRoute from './routers/api/eventRoute.js';

import cors from 'cors';




const app = express();
dotenv.config();
const PORT = process.env.PORT || 5000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Add a simple logger for all incoming requests
app.use((req, res, next) => {
    console.log(`Incoming Request: ${req.method} ${req.url}`);
    next();
});

app.use(cors({ origin: '*' }));
app.use('/images', express.static('public/images'));


// database connection
setUpDatabase()
    .then(() => {
        console.log('Database setup completed');
    })
    .catch((error) => {
        console.error('Error setting up database:', error);
    });


// Backend routes
app.use('/api/articles', articleRoute);
app.use('/api/userEvents', userEventRoute);
app.use('/api/users', userRoute);
app.use('/api/auth', authRoute);
app.use('/api/events', eventRoute);


app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server is running on http://0.0.0.0:${PORT}`);
});
