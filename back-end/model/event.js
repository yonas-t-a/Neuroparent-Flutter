import { pool } from '../database.js';
const eventModel = {
    async getEvent() {
        const [rows] = await pool.query('SELECT * FROM event');
        return rows;
    },

    async getEventById(id) {
        const [rows] = await pool.query('SELECT * FROM event WHERE event_id = ?', [id]);
        return rows[0];
    },

    async createEvent(event) {
        const [result] = await pool.query('INSERT INTO event SET ?', [event]);
        return result;
    },

    async updateEvent(id, event) {
        const [result] = await pool.query('UPDATE event SET ? WHERE event_id = ?', [event, id]);
        return result;
    },
    async deleteEvent(id) {
        const [result] = await pool.query('DELETE FROM event WHERE event_id = ?', [id]);
        return result;
    },
    async getEventByCategory(category) {
        const [rows] = await pool.query('SELECT * FROM event WHERE event_category = ?', [category]);
        return rows;
    },
    async getEventByDate(date) {
        const [rows] = await pool.query('SELECT * FROM event WHERE event_date = ?', [date]);
        return rows;
    },
    async getEventByLocation(location) {
        const [rows] = await pool.query('SELECT * FROM event WHERE event_location = ?', [location]);
        return rows;
    }
};
export default eventModel;