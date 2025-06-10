import userModel from "../model/user.js";
import bcrypt from 'bcrypt';

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
        // Remove hashedPassword before sending the response
        delete user.hashedPassword;
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
        const hashedPassword = await bcrypt.hash(password, 10);
        const user = await userModel.createUser({ name, email, hashedPassword });
        res.status(201).json(user);
    } catch (error) {
        res.status(500).json({ error: "Error creating user" });
    }
}
export async function updateUser (req,res){
    const { id } = req.params;
    const { name, email, oldPassword, newPassword } = req.body; // Added oldPassword and newPassword

    const userData = {};

    if (name) {
        userData.name = name;
    }
    if (email) {
        userData.email = email;
    }

    // Handle password update separately
    if (newPassword) {
        if (!oldPassword) {
            return res.status(400).json({ error: "Old password is required to set a new password." });
        }

        try {
            const existingUser = await userModel.getUserById(id);
            if (!existingUser) {
                console.log("Debug: User not found for ID:", id);
                return res.status(404).json({ message: "User not found" });
            }
            console.log("Debug: Existing user retrieved:", existingUser);
            console.log("Debug: oldPassword received:", oldPassword);
            console.log("Debug: newPassword received:", newPassword);

            const isMatch = await bcrypt.compare(oldPassword, existingUser.password);
            if (!isMatch) {
                console.log("Debug: Password mismatch for user ID:", id);
                return res.status(401).json({ error: "Incorrect old password." });
            }

            userData.password = await bcrypt.hash(newPassword, 10);
        } catch (error) {
            console.error("Error during password hashing or comparison:", error);
            return res.status(500).json({ error: "Error processing password." });
        }
    }

    // If no fields are provided for update, return a bad request
    if (Object.keys(userData).length === 0) {
        return res.status(400).json({ error: "No fields provided for update" });
    }

    // General old password confirmation for any update if present in request
    if (oldPassword) {
        try {
            const existingUser = await userModel.getUserById(id);
            if (!existingUser) {
                return res.status(404).json({ message: "User not found" });
            }
            const isMatch = await bcrypt.compare(oldPassword, existingUser.password);
            if (!isMatch) {
                return res.status(401).json({ error: "Incorrect old password." });
            }
        } catch (error) {
            console.error("Error during general old password comparison:", error);
            return res.status(500).json({ error: "Error processing password confirmation." });
        }
    }

    try {
        const result = await userModel.updateUser(id, userData);
        if (result.affectedRows === 0) { // Check affectedRows for update success
            return res.status(404).json({ message: "User not found or no changes made." });
        }
        // Fetch the updated user to return the full user object (excluding password)
        const updatedUser = await userModel.getUserById(id);
        // Remove hashedPassword from the response for security
        delete updatedUser.hashedPassword;
        res.status(200).json(updatedUser);
    } catch (error) {
        console.error("Error updating user:", error);
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
