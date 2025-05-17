import { pool } from '../database.js';

const articleModel = {
    // Get all articles
    async getArticle() {
        const [rows] = await pool.query('SELECT * FROM article');
        return rows;
    },

    // Get a single article by ID
    async getArticleById(id) {
        const [rows] = await pool.query('SELECT * FROM article WHERE article_id = ?', [id]);
        return rows[0];
    },

    // Create a new article
    async createArticle(article) {
        const mappedArticle = {
            article_title: article.title,
            article_content: article.content,
            article_category: article.category,
            article_image: article.img,
            article_creator_id: article.article_creator_id,
        };
        const [result] = await pool.query('INSERT INTO article SET ?', [mappedArticle]);
        return result;
    },

    // Update an article by ID (partial update supported)
    async updateArticle(id, article) {
        // Map API fields to DB columns if needed
        const mappedArticle = {};
        if (article.article_title) mappedArticle.article_title = article.article_title;
        if (article.article_content) mappedArticle.article_content = article.article_content;
        if (article.article_category) mappedArticle.article_category = article.article_category;
        if (article.article_image) mappedArticle.article_image = article.article_image;
        // Prevent empty update
        if (Object.keys(mappedArticle).length === 0) {
            return { affectedRows: 0 };
        }
        const [result] = await pool.query('UPDATE article SET ? WHERE article_id = ?', [mappedArticle, id]);
        return result;
    },

    // Delete an article by ID
    async deleteArticle(id) {
        const [result] = await pool.query('DELETE FROM article WHERE article_id = ?', [id]);
        return result;
    },

    // Get articles by category
    async getArticleByCategory(category) {
        const [rows] = await pool.query('SELECT * FROM article WHERE article_category = ?', [category]);
        return rows;
    }
};
export default articleModel;