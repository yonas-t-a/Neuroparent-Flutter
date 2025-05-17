

import userEventModel from "../model/userEvent.js";

export async function getUserEvent(req,res){
    try {
        const userEvents = await userEventModel.getUserEvent();
        res.status(200).json(userEvents);
    } catch (error) {
        res.status(500).json({ error: "Error fetching user events" });
    }
}
export async function getUserEventById(req,res){
    const { id } = req.params;
    try {
        const userEvent = await userEventModel.getUserEventById(id);
        if (!userEvent) {
            return res.status(404).json({ message: "User event not found" });
        }
        res.status(200).json(userEvent);
    } catch (error) {
        res.status(500).json({ error: "Error fetching user event" });
    }
}
export async function createUserEvent(req,res){
    // Validate the request body
    const { user_id, event_id } = req.body;
    if (!user_id || !event_id) {
        return res.status(400).json({ error: "All fields are required" });
    }
    try {
        const newUserEvent = await userEventModel.createUserEvent({ user_id, event_id });
        res.status(201).json(newUserEvent);
    } catch (error) {
        res.status(500).json({ error: "Error creating user event" });
    }
}
export async function updateUserEvent(req,res){
    const { id } = req.params;
    const { user_id, event_id } = req.body;
    if (!user_id || !event_id) {
        return res.status(400).json({ error: "All fields are required" });
    }
    try {
        const updatedUserEvent = await userEventModel.updateUserEvent(id, { user_id, event_id });
        if (!updatedUserEvent) {
            return res.status(404).json({ message: "User event not found" });
        }
        res.status(200).json(updatedUserEvent);
    } catch (error) {
        res.status(500).json({ error: "Error updating user event" });
    }
}
export async function deleteUserEvent(req,res){
    const { id } = req.params;
    try {
        const deletedUserEvent = await userEventModel.deleteUserEvent(id);
        if (!deletedUserEvent) {
            return res.status(404).json({ message: "User event not found" });
        }
        res.status(200).json({ message: "User event deleted successfully" });
    } catch (error) {
        res.status(500).json({ error: "Error deleting user event" });
    }
}