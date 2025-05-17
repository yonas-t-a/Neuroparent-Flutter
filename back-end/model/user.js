import { pool } from '../database.js';
const userModel = {
    async getUser() {
        const [rows] = await pool.query('SELECT * FROM user');
        return rows;
    },

    async getUserById(id) {
        const [rows] = await pool.query('SELECT * FROM user WHERE user_id = ?', [id]);
        return rows[0];
    },

    async createUser(user) {
        const [result] = await pool.query('INSERT INTO user SET ?', [user]);
        return result;
    },

    async updateUser(id, user) {
        const [result] = await pool.query('UPDATE user SET ? WHERE user_id = ?', [user, id]);
        return result;
    },

    async deleteUser(id) {
        const [result] = await pool.query('DELETE FROM user WHERE user_id = ?', [id]);
        return result;
    },
    async getUserByEmail(email) {
        const [rows] = await pool.query('SELECT * FROM user WHERE email = ?', [email]);
        return rows[0];
    },
    async getUserByUsername(username) {
        const [rows] = await pool.query('SELECT * FROM user WHERE username = ?', [username]);
        return rows[0];
    }
};
export default userModel;
