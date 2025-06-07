
import eventModel from "../model/event.js";

export async function getEvent(req, res) {
    try {
        const events = await eventModel.getEvent();
        res.status(200).json(events);
    } catch (error) {
        res.status(500).json({ error: "Error fetching events" });
    }
}
export async function getEventById(req, res) {
    const { id } = req.params;
    try {
        const event = await eventModel.getEventById(id);
        if (!event) {
            return res.status(404).json({ error: "Event not found" });
        }
        res.status(200).json(event);
    } catch (error) {
        res.status(500).json({ error: "Error fetching event" });
    }
}
export async function createEvent(req, res) {
    console.log(req.body);
    // Validate the request body
    const { title, description, date, time, location, category, creator_id } = req.body;

    console.log("Creating event with data:", req.body);
    if (!title || !description || !date || !time || !location || !category || !creator_id) {
        return res.status(400).json({ error: "All fields are required" });
    }
    const eventData = {
        event_title: title,
        event_description: description,
        event_date: date,
        event_time: time,
        event_location: location,
        event_category: category,
        creator_id:  creator_id,  // This must be solved 
        event_status: true // default value
    };

    try {
        const newEvent = await eventModel.createEvent(eventData);
        res.status(201).json(newEvent);
        console.log("Event created successfully:", newEvent);
    } catch (error) {
        res.status(500).json({ error: "Error creating event" });
        console.error("Error creating event:", error);
    }
}
export async function updateEvent(req, res) {
    // Validate the request body
    const { id } = req.params;
    const { title, description, date, time, location, category, creator_id } = req.body;
    if (!title || !description || !date || !time || !location || !category || !creator_id) {
        return res.status(400).json({ error: "All fields are required" });
    }
    const eventData = {
        event_title: title,
        event_description: description,
        event_date: date,
        event_time: time,
        event_location: location,
        event_category: category,
        creator_id:  creator_id,  // This must be solved 
        event_status: true // default value
    };
    try {
        const updatedEvent = await eventModel.updateEvent(id, eventData);
        if (updatedEvent.affectedRows === 0) {
            return res.status(404).json({ error: "Event not found" });
        }
        res.status(200).json(updatedEvent);
        console.log("Event updated successfully:", updatedEvent);
    } catch (error) {
        console.log(error);
        res.status(500).json({ error: "Error updating event" });
    }
}
export async function deleteEvent(req, res) {
    const { id } = req.params;
    try {
        const deletedEvent = await eventModel.deleteEvent(id);
        if (deletedEvent.affectedRows === 0) {
            return res.status(404).json({ error: "Event not found" });
        }
        res.status(200).json({ message: "Event deleted successfully" });
    } catch (error) {
        res.status(500).json({ error: "Error deleting event" });
    }
}
export async function getEventByCategory(req, res) {
    const { category } = req.params;
    try {
        const events = await eventModel.getEventByCategory(category);
        if (events.length === 0) {
            return res.status(404).json({ error: "No events found for this category" });
        }
        res.status(200).json(events);
    } catch (error) {
        res.status(500).json({ error: "Error fetching events by category" });
    }
}
export async function getEventByDate(req, res) {
    const { date } = req.params;
    try {
        const events = await eventModel.getEventByDate(date);
        if (events.length === 0) {
            return res.status(404).json({ error: "No events found for this date" });
        }
        res.status(200).json(events);
    } catch (error) {
        res.status(500).json({ error: "Error fetching events by date" });
    }
}
export async function getEventByLocation(req, res) {
    const { location } = req.params;
    try {
        const events = await eventModel.getEventByLocation(location);
        if (events.length === 0) {
            return res.status(404).json({ error: "No events found for this location" });
        }
        res.status(200).json(events);
    } catch (error) {
        res.status(500).json({ error: "Error fetching events by location" });
    }
}