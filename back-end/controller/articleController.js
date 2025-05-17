import articleModel from "../model/article.js";
import path from 'path';

const getImageUrl = (req, imgPath) => {
    if (!imgPath) return null;
    return `${req.protocol}://${req.get('host')}${imgPath}`;
};

export async function getArticle(req, res) {
    try {
        const articles = await articleModel.getArticle();
        articles.forEach(a => a.article_image = getImageUrl(req, a.article_image));
        res.status(200).json({ success: true, data: articles });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error fetching articles" });
    }
}

export async function getArticleById(req, res) {
    const { id } = req.params;
    try {
        const article = await articleModel.getArticleById(id);
        if (!article) {
            return res.status(404).json({ success: false, message: "Article not found" });
        }
        article.article_image = getImageUrl(req, article.article_image);
        res.status(200).json({ success: true, data: article });
    } catch (error) {
        res.status(500).json({ success: false, message: `Error fetching article: ${error.message}` });
    }
}

export async function createArticle(req, res) {
    const { title, content, category } = req.body;
    const img = req.file ? `/images/${req.file.filename}` : null;

    if (!title || !content || !category || !img) {
        return res.status(400).json({ success: false, message: "All fields, including an image, are required" });
    }

    try {
        if (!req.user || !req.user.id) {
            return res.status(401).json({ success: false, message: "Unauthorized: User information not found in token" });
        }
        const article_creator_id = req.user.id;
        const newArticle = { title, content, category, img, article_creator_id };
        const result = await articleModel.createArticle(newArticle);
        const created = await articleModel.getArticleById(result.insertId);
        created.article_image = getImageUrl(req, created.article_image);
        res.status(201).json({ success: true, data: created });
    } catch (error) {
        res.status(500).json({ success: false, message: `Error creating article: ${error.message}` });
    }
}

export async function updateArticle(req, res) {
    const { id } = req.params;
    const { title, content, category } = req.body;
    const img = req.file ? `/images/${req.file.filename}` : undefined;

    if (!title && !content && !category && !img) {
        return res.status(400).json({ success: false, message: "At least one field is required" });
    }

    try {
        const updateFields = {};
        if (title) updateFields.article_title = title;
        if (content) updateFields.article_content = content;
        if (category) updateFields.article_category = category;
        if (img) updateFields.article_image = img;

        const result = await articleModel.updateArticle(id, updateFields);
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: "Article not found" });
        }
        const updated = await articleModel.getArticleById(id);
        updated.article_image = getImageUrl(req, updated.article_image);
        res.status(200).json({ success: true, data: updated });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error updating article" });
    }
}

export async function deleteArticle(req, res) {
    const { id } = req.params;
    try {
        const result = await articleModel.deleteArticle(id);
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: "Article not found" });
        }
        res.status(200).json({ success: true, message: "Article deleted successfully" });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error deleting article" });
    }
}

export async function getArticleByCategory(req, res) {
    const { category } = req.params;
    try {
        const articles = await articleModel.getArticleByCategory(category);
        articles.forEach(a => a.article_image = getImageUrl(req, a.article_image));
        if (articles.length === 0) {
            return res.status(404).json({ success: false, message: "No articles found in this category" });
        }
        res.status(200).json({ success: true, data: articles });
    } catch (error) {
        res.status(500).json({ success: false, message: "Error fetching articles by category" });
    }
}