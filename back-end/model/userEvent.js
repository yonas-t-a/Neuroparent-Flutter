
import { pool } from '../database.js';
const userEventModel = {
    async getUserEvent() {
        const [rows] = await pool.query('SELECT * FROM user_event');
        return rows;
    },

    async getUserEventById(id) {
        const [rows] = await pool.query('SELECT * FROM user_event WHERE user_event_id = ?', [id]);
        return rows[0];
    },

    async createUserEvent(userEvent) {
        const [result] = await pool.query('INSERT INTO user_event SET ?', [userEvent]);
        return result;
    },

    async updateUserEvent(id, userEvent) {
        const [result] = await pool.query('UPDATE user_event SET ? WHERE user_event_id = ?', [userEvent, id]);
        return result;
    },

    async deleteUserEvent(id) {
        const [result] = await pool.query('DELETE FROM user_event WHERE user_event_id = ?', [id]);
        return result;
    }
};
export default userEventModel;