import userModel from "../model/user.js";

export async function getUser (req,res){
    try {
        const users = await userModel.getUser();
        res.status(200).json(users);
    } catch (error) {
        res.status(500).json({ error: "Error fetching users" });
    }
}
export async function getUserById (req,res){
    const { id } = req.params;
    try {
        const user = await userModel.getUserById(id);
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }
        res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ error: "Error fetching user" });
    }
}
export async function createUser (req,res){
    // Validate the request body
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
        return res.status(400).json({ error: "All fields are required" });
    }
    try {
        const user = await userModel.createUser({ name, email, password });
        res.status(201).json(user);
    } catch (error) {
        res.status(500).json({ error: "Error creating user" });
    }
}
export async function updateUser (req,res){
    // Validate the request body
    const { id } = req.params;
    const { name, email, password } = req.body;
    if (!name || !email || !password) {
        return res.status(400).json({ error: "All fields are required" });
    }
    try {
        const user = await userModel.updateUser(id, { name, email, password });
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }
        res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ error: "Error updating user" });
    }
}
export async function deleteUser (req,res){
    const { id } = req.params;
    try {
        const user = await userModel.deleteUser(id);
        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }
        res.status(200).json({ message: "User deleted successfully" });
    } catch (error) {
        res.status(500).json({ error: "Error deleting user" });
    }
}
